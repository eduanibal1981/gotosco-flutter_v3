# R2 Media System Setup Guide

This document explains how to deploy and configure the production-grade hybrid media system for Gotosco v3.

## Architecture Overview

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│  Flutter App    │───▶│  Supabase Edge   │───▶│  Cloudflare R2  │
│                 │    │  Functions       │    │                 │
│ - Compress JPEG │    │ - request-upload │    │ - File Storage  │
│ - Upload to R2  │    │ - finalize-upload│    │ - CDN Delivery  │
│ - Update UI     │    │ - get-signed-url │    │                 │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                              │
                              ▼
                       ┌──────────────────┐
                       │  Supabase        │
                       │  PostgreSQL      │
                       │                  │
                       │ - media_assets   │
                       │ - RLS Policies   │
                       │ - Legacy columns │
                       └──────────────────┘
```

## Storage Structure

```
R2 Bucket: gotosco-media
├── public/
│   └── users/
│       └── {user_id}/
│           └── avatar/
│               └── {timestamp}_{random}.jpg
└── private/
    └── drivers/
        └── {user_id}/
            ├── license/
            │   └── {timestamp}_{random}.jpg
            └── mulkia/
                └── {timestamp}_{random}.jpg
```

## Setup Instructions

### 1. Cloudflare R2 Setup

1. Create a Cloudflare account at https://cloudflare.com
2. Navigate to R2 Object Storage
3. Create a new bucket named `gotosco-media`
4. Configure bucket settings:
   - Enable public access for the `public/` prefix
   - Keep `private/` prefix private (requires signed URLs)

5. Create R2 API Token:
   - Go to R2 > Manage R2 API Tokens
   - Create token with Object Read & Write permissions
   - Note the Access Key ID and Secret Access Key
Use this token for authenticating against the Cloudflare API:
Token value z5EjaWwMxvtded4Ev_gokoXcdHk5XT-lGHpnG_Gg

Use the following credentials for S3 clients:
Access Key ID c953f878f1bd33679c64143a62887600

Secret Access Key 1cbf6092be4e2d955ad562a4301ce3c21d1fd7ca4a941aff305fa441b3dc3ba7

Use jurisdiction-specific endpoints for S3 clients:
DefaultEuropean Union (EU)
https://4ba3b0c4b1f92bff9d95f70e154d65c6.eu.r2.cloudflarestorage.com
### 2. Supabase Configuration

#### a. Run Database Migration

```bash
cd supabase
supabase db push
# Or apply the migration manually:
# supabase/migrations/20260201_create_media_assets.sql
```

#### b. Set Edge Function Secrets

```bash
# Set R2 credentials as Supabase secrets
supabase secrets set R2_ACCOUNT_ID=4ba3b0c4b1f92bff9d95f70e154d65c6
supabase secrets set R2_ACCESS_KEY_ID=8c953f878f1bd33679c64143a62887600
supabase secrets set R2_SECRET_ACCESS_KEY=1cbf6092be4e2d955ad562a4301ce3c21d1fd7ca4a941aff305fa441b3dc3ba7
supabase secrets set R2_BUCKET_NAME=gotosco-media
supabase secrets set R2_PUBLIC_URL=https://media.gotosco.com
```

#### c. Deploy Edge Functions

```bash
# Deploy all media-related edge functions
supabase functions deploy request-upload
supabase functions deploy finalize-upload
supabase functions deploy get-signed-url
```

### 3. Custom Domain (Optional but Recommended)

1. In Cloudflare, add a custom domain for your R2 bucket
2. Configure DNS to point `media.gotosco.com` to R2
3. Update `R2_PUBLIC_URL` secret to match

### 4. Flutter App Configuration

The Flutter app is already configured. After deploying the edge functions:

1. Run `flutter pub get` to install dependencies
2. Run `dart run build_runner build` to generate Riverpod code
3. The app will automatically use the new R2 upload flow

## Usage

### Uploading Documents (Driver License/Mulkia)

```dart
// From driver_profile_tab.dart
final repository = ref.read(driverProfileRepositoryProvider);
final url = await repository.uploadDocument(
  driverId: profile.id,
  file: selectedFile,
  documentType: 'license', // or 'mulkia'
  onProgress: (progress) {
    // Update UI with progress
    print('${progress.stageLabel}: ${progress.progress * 100}%');
  },
);
```

### Uploading Avatar

```dart
// From edit_profile_screen.dart
final repository = ref.read(authRepositoryProvider);
final url = await repository.uploadProfileImage(
  userId,
  imageFile,
  onProgress: (progress) {
    print('${progress.stageLabel}');
  },
);
```

### Accessing Private Files

Private files (license, mulkia) require signed URLs:

```dart
final mediaService = ref.read(mediaServiceProvider);
final signedUrl = await mediaService.getSignedUrl(
  assetId,
  expiresIn: 3600, // 1 hour
);
// Use signedUrl to display the image
```

## Fallback Behavior

The system includes automatic fallback to Supabase Storage if R2 upload fails:

1. If Edge Functions are unavailable → Falls back to direct Supabase Storage upload
2. If R2 upload fails → Falls back to Supabase Storage
3. Legacy columns (photo_url, license_image_url, mulkia_image_url) are always updated

## Security

- R2 credentials are only stored in Supabase Edge Function secrets
- Signed PUT URLs expire in 5 minutes
- Signed GET URLs expire in 1 hour (configurable)
- RLS policies ensure users can only access their own assets
- File size limits enforced server-side

## Monitoring

### Check Pending Uploads

```sql
SELECT * FROM media_assets
WHERE status = 'pending'
AND expires_at < NOW();
```

### Cleanup Expired Uploads

```sql
SELECT cleanup_expired_pending_uploads();
```

### View Upload Statistics

```sql
SELECT
  asset_type,
  status,
  COUNT(*) as count,
  SUM(file_size) as total_bytes
FROM media_assets
GROUP BY asset_type, status;
```

## Troubleshooting

### "Asset not found" Error
- Check if the asset was created in media_assets table
- Verify the asset_id is correct

### Upload Times Out
- Check R2 bucket configuration
- Verify Edge Function secrets are set correctly
- Check network connectivity

### Signed URL Doesn't Work
- Verify R2 credentials have read permissions
- Check if URL has expired
- Ensure the file actually exists in R2

## Files Reference

### Database
- `supabase/migrations/20260201_create_media_assets.sql`

### Edge Functions
- `supabase/functions/_shared/r2-client.ts`
- `supabase/functions/request-upload/index.ts`
- `supabase/functions/finalize-upload/index.ts`
- `supabase/functions/get-signed-url/index.ts`

### Flutter
- `lib/core/services/media_service.dart`
- `lib/features/driver/profile/data/driver_profile_repository.dart`
- `lib/features/auth/data/auth_repository.dart`
