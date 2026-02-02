# R2 Media System Implementation Plan

## Overview
Replace Supabase Storage with Cloudflare R2 for media storage while maintaining Supabase for metadata and RLS.

## Architecture

### Storage Structure (R2)
```
bucket/
├── public/
│   └── users/
│       └── {user_id}/
│           └── avatar/
│               └── {timestamp}.webp
└── private/
    └── drivers/
        └── {user_id}/
            ├── license/
            │   └── {timestamp}.webp
            └── mulkia/
                └── {timestamp}.webp
```

### Flow
1. Client requests upload → Edge Function generates signed PUT URL
2. Client compresses image to WebP → Uploads directly to R2
3. Client finalizes → Edge Function validates & updates database
4. For private files: Client requests signed GET URL when needed

---

## Phase 1: Database Schema

### New Table: `public.media_assets`
```sql
CREATE TABLE public.media_assets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  r2_key TEXT NOT NULL UNIQUE,
  visibility TEXT NOT NULL CHECK (visibility IN ('public', 'private')),
  asset_type TEXT NOT NULL CHECK (asset_type IN ('avatar', 'license', 'mulkia', 'child_photo', 'adv_photo')),
  mime_type TEXT DEFAULT 'image/webp',
  file_size BIGINT,
  original_filename TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'uploaded', 'failed', 'deleted')),
  legacy_column TEXT, -- 'users.photo_url', 'drivers.license_image_url', etc.
  created_at TIMESTAMPTZ DEFAULT NOW(),
  uploaded_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ, -- For pending uploads that weren't finalized
  metadata JSONB DEFAULT '{}'::jsonb
);

-- Indexes
CREATE INDEX idx_media_assets_owner ON public.media_assets(owner_id);
CREATE INDEX idx_media_assets_status ON public.media_assets(status);
CREATE INDEX idx_media_assets_r2_key ON public.media_assets(r2_key);

-- RLS
ALTER TABLE public.media_assets ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Users can view own assets"
  ON public.media_assets FOR SELECT
  USING (auth.uid() = owner_id);

CREATE POLICY "Users can insert pending assets"
  ON public.media_assets FOR INSERT
  WITH CHECK (auth.uid() = owner_id AND status = 'pending');

CREATE POLICY "Users can update own pending assets"
  ON public.media_assets FOR UPDATE
  USING (auth.uid() = owner_id)
  WITH CHECK (auth.uid() = owner_id);

-- Cleanup function for expired pending uploads
CREATE OR REPLACE FUNCTION cleanup_expired_pending_uploads()
RETURNS void AS $$
BEGIN
  UPDATE public.media_assets
  SET status = 'failed'
  WHERE status = 'pending'
    AND expires_at < NOW();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

---

## Phase 2: Supabase Edge Functions

### Environment Variables (Supabase Secrets)
```
R2_ACCOUNT_ID=xxx
R2_ACCESS_KEY_ID=xxx
R2_SECRET_ACCESS_KEY=xxx
R2_BUCKET_NAME=gotosco-media
R2_PUBLIC_URL=https://media.gotosco.com  # or R2 public bucket URL
```

### Function 1: `request-upload`
**Purpose:** Generate pre-signed PUT URL for R2

**Request:**
```json
{
  "asset_type": "license|mulkia|avatar",
  "content_type": "image/webp",
  "file_size": 102400
}
```

**Response:**
```json
{
  "asset_id": "uuid",
  "upload_url": "https://r2-signed-put-url",
  "r2_key": "private/drivers/{user_id}/license/{timestamp}.webp",
  "expires_in": 300
}
```

### Function 2: `finalize-upload`
**Purpose:** Confirm upload completion, update database

**Request:**
```json
{
  "asset_id": "uuid"
}
```

**Response:**
```json
{
  "success": true,
  "url": "https://media.gotosco.com/public/users/{id}/avatar/xxx.webp",
  "asset": { ... }
}
```

**Actions:**
1. Verify file exists in R2 (HEAD request)
2. Update media_assets status to 'uploaded'
3. Update legacy column (photo_url, license_image_url, etc.)
4. Return final URL

### Function 3: `get-signed-url`
**Purpose:** Generate time-limited GET URL for private files

**Request:**
```json
{
  "asset_id": "uuid"
}
```

**Response:**
```json
{
  "url": "https://r2-signed-get-url",
  "expires_in": 3600
}
```

---

## Phase 3: Flutter Client

### New Package Dependencies
```yaml
dependencies:
  image: ^4.2.0  # For WebP compression
  http: ^1.6.0   # Already present
  path: ^1.9.0   # Path manipulation
  mime: ^1.0.5   # MIME type detection
```

### New Service: `lib/core/services/media_service.dart`

```dart
class MediaService {
  // Compress and resize image to WebP
  Future<Uint8List> compressImage(File file, {int maxWidth = 1200, int quality = 85});

  // Request upload URL from edge function
  Future<UploadRequest> requestUpload(MediaAssetType type);

  // Upload to R2 via signed PUT
  Future<void> uploadToR2(String uploadUrl, Uint8List data, String contentType);

  // Finalize upload
  Future<MediaAsset> finalizeUpload(String assetId);

  // Get signed URL for private assets
  Future<String> getSignedUrl(String assetId);
}
```

### Refactored Upload Flow
```dart
// Old
await repository.uploadDocument(driverId: id, file: file, documentType: 'license');

// New
final compressed = await mediaService.compressImage(file, maxWidth: 1600, quality: 90);
final request = await mediaService.requestUpload(MediaAssetType.license);
await mediaService.uploadToR2(request.uploadUrl, compressed, 'image/webp');
final asset = await mediaService.finalizeUpload(request.assetId);
// asset.url now contains the final URL
```

---

## Phase 4: Legacy Column Updates

The `finalize-upload` function will update these columns:
- `avatar` → `users.photo_url`
- `license` → `drivers.license_image_url`
- `mulkia` → `drivers.mulkia_image_url`
- `child_photo` → `children.photo_url` (future)

---

## Implementation Order

1. **Database Migration** - Create media_assets table with RLS
2. **Edge Functions** - Deploy all 3 functions with R2 integration
3. **MediaService** - Create Flutter service with compression
4. **MediaProvider** - Riverpod provider for MediaService
5. **Refactor DriverProfileRepository** - Replace uploadDocument
6. **Refactor AuthRepository** - Replace uploadProfileImage
7. **Update UI** - Handle private URLs with signed URL fetching
8. **Migration Script** - Optional: migrate existing assets to R2

---

## Security Considerations

1. **R2 Credentials** - Only stored in Supabase Edge Function secrets
2. **Signed URLs** - Short expiry (5 min for PUT, 1 hour for GET)
3. **File Validation** - Edge function validates:
   - Max file size (5MB for avatars, 10MB for documents)
   - MIME type (only image/*)
   - Owner matches authenticated user
4. **RLS** - Users can only access their own assets
5. **Private Files** - License/Mulkia require signed URLs

---

## Files to Create/Modify

### New Files
- `supabase/migrations/20260201_create_media_assets.sql`
- `supabase/functions/request-upload/index.ts`
- `supabase/functions/finalize-upload/index.ts`
- `supabase/functions/get-signed-url/index.ts`
- `supabase/functions/_shared/r2-client.ts`
- `lib/core/services/media_service.dart`
- `lib/core/services/media_service.g.dart` (generated)
- `lib/core/models/media_asset.dart`

### Modified Files
- `lib/features/driver/profile/data/driver_profile_repository.dart`
- `lib/features/auth/data/auth_repository.dart`
- `lib/features/driver/profile/presentation/driver_profile_tab.dart`
- `lib/features/parent/profile/presentation/edit_profile_screen.dart`
- `pubspec.yaml`
