-- Migration: Create media_assets table for R2 hybrid storage
-- This table tracks all media assets with Supabase handling metadata/RLS
-- and Cloudflare R2 handling actual file storage

-- Create media_assets table
CREATE TABLE IF NOT EXISTS public.media_assets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  r2_key TEXT NOT NULL UNIQUE,
  visibility TEXT NOT NULL CHECK (visibility IN ('public', 'private')),
  asset_type TEXT NOT NULL CHECK (asset_type IN ('avatar', 'license', 'mulkia', 'child_photo', 'adv_photo')),
  mime_type TEXT DEFAULT 'image/jpeg',
  file_size BIGINT,
  original_filename TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'uploaded', 'failed', 'deleted')),
  legacy_column TEXT, -- Target column for URL update: 'users.photo_url', 'drivers.license_image_url', etc.
  created_at TIMESTAMPTZ DEFAULT NOW(),
  uploaded_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ DEFAULT (NOW() + INTERVAL '15 minutes'), -- Pending uploads expire
  metadata JSONB DEFAULT '{}'::jsonb,

  -- Validate r2_key format
  CONSTRAINT valid_r2_key CHECK (r2_key ~ '^(public|private)/')
);

-- Add helpful comments
COMMENT ON TABLE public.media_assets IS 'Tracks media assets stored in Cloudflare R2';
COMMENT ON COLUMN public.media_assets.r2_key IS 'Full path in R2 bucket: public/users/{id}/avatar/xxx.webp or private/drivers/{id}/license/xxx.webp';
COMMENT ON COLUMN public.media_assets.visibility IS 'public = direct URL access, private = requires signed URL';
COMMENT ON COLUMN public.media_assets.legacy_column IS 'Database column to update with final URL, e.g., users.photo_url';
COMMENT ON COLUMN public.media_assets.expires_at IS 'Pending uploads not finalized by this time are marked as failed';

-- Performance indexes
CREATE INDEX IF NOT EXISTS idx_media_assets_owner ON public.media_assets(owner_id);
CREATE INDEX IF NOT EXISTS idx_media_assets_status ON public.media_assets(status) WHERE status = 'pending';
CREATE INDEX IF NOT EXISTS idx_media_assets_type ON public.media_assets(asset_type);
CREATE INDEX IF NOT EXISTS idx_media_assets_expires ON public.media_assets(expires_at) WHERE status = 'pending';

-- Enable RLS
ALTER TABLE public.media_assets ENABLE ROW LEVEL SECURITY;

-- RLS Policies

-- Users can view their own assets (all statuses)
CREATE POLICY "Users can view own assets"
  ON public.media_assets FOR SELECT
  USING (auth.uid() = owner_id);

-- Users can insert pending assets for themselves
CREATE POLICY "Users can insert pending assets"
  ON public.media_assets FOR INSERT
  WITH CHECK (auth.uid() = owner_id AND status = 'pending');

-- Edge functions (service role) can update any asset
-- Users can only update their own pending assets
CREATE POLICY "Users can update own pending assets"
  ON public.media_assets FOR UPDATE
  USING (auth.uid() = owner_id AND status = 'pending')
  WITH CHECK (auth.uid() = owner_id);

-- Users can soft-delete (mark as deleted) their own assets
CREATE POLICY "Users can delete own assets"
  ON public.media_assets FOR DELETE
  USING (auth.uid() = owner_id);

-- Function to cleanup expired pending uploads (run via pg_cron or scheduled job)
CREATE OR REPLACE FUNCTION cleanup_expired_pending_uploads()
RETURNS INTEGER AS $$
DECLARE
  affected_count INTEGER;
BEGIN
  UPDATE public.media_assets
  SET status = 'failed',
      metadata = metadata || jsonb_build_object('failure_reason', 'expired')
  WHERE status = 'pending'
    AND expires_at < NOW();

  GET DIAGNOSTICS affected_count = ROW_COUNT;
  RETURN affected_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get the public URL for an asset
-- For public assets, returns direct R2 URL
-- For private assets, this just returns NULL (client must use get-signed-url edge function)
CREATE OR REPLACE FUNCTION get_asset_public_url(asset_id UUID)
RETURNS TEXT AS $$
DECLARE
  asset RECORD;
  base_url TEXT := current_setting('app.r2_public_url', true);
BEGIN
  SELECT * INTO asset FROM public.media_assets WHERE id = asset_id;

  IF asset IS NULL THEN
    RETURN NULL;
  END IF;

  IF asset.visibility = 'private' THEN
    RETURN NULL; -- Private assets require signed URLs
  END IF;

  IF base_url IS NULL OR base_url = '' THEN
    base_url := 'https://media.gotosco.com'; -- Fallback
  END IF;

  RETURN base_url || '/' || asset.r2_key;
END;
$$ LANGUAGE plpgsql STABLE;

-- Function called by edge function to finalize upload and update legacy columns
CREATE OR REPLACE FUNCTION finalize_media_upload(
  p_asset_id UUID,
  p_file_size BIGINT DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
  asset RECORD;
  final_url TEXT;
  base_url TEXT := coalesce(current_setting('app.r2_public_url', true), 'https://media.gotosco.com');
  parts TEXT[];
  table_name TEXT;
  column_name TEXT;
BEGIN
  -- Get and lock the asset
  SELECT * INTO asset
  FROM public.media_assets
  WHERE id = p_asset_id
  FOR UPDATE;

  IF asset IS NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'Asset not found');
  END IF;

  IF asset.status != 'pending' THEN
    RETURN jsonb_build_object('success', false, 'error', 'Asset is not pending');
  END IF;

  -- Calculate final URL
  IF asset.visibility = 'public' THEN
    final_url := base_url || '/' || asset.r2_key;
  ELSE
    -- Private assets don't have a public URL, but we store the r2_key-based URL
    -- Clients will use get-signed-url to access
    final_url := base_url || '/' || asset.r2_key;
  END IF;

  -- Update asset status
  UPDATE public.media_assets
  SET status = 'uploaded',
      uploaded_at = NOW(),
      file_size = COALESCE(p_file_size, file_size),
      expires_at = NULL
  WHERE id = p_asset_id;

  -- Update legacy column if specified
  IF asset.legacy_column IS NOT NULL AND asset.legacy_column != '' THEN
    parts := string_to_array(asset.legacy_column, '.');
    IF array_length(parts, 1) = 2 THEN
      table_name := parts[1];
      column_name := parts[2];

      IF table_name = 'users' AND column_name = 'photo_url' THEN
        UPDATE public.users SET photo_url = final_url WHERE id = asset.owner_id;
      ELSIF table_name = 'drivers' AND column_name = 'license_image_url' THEN
        UPDATE public.drivers SET license_image_url = final_url WHERE user_id = asset.owner_id;
      ELSIF table_name = 'drivers' AND column_name = 'mulkia_image_url' THEN
        UPDATE public.drivers SET mulkia_image_url = final_url WHERE user_id = asset.owner_id;
      ELSIF table_name = 'children' AND column_name = 'photo_url' THEN
        -- Children require parent_id check - need to pass child_id in metadata
        IF asset.metadata ? 'child_id' THEN
          UPDATE public.children
          SET photo_url = final_url
          WHERE id = (asset.metadata->>'child_id')::UUID
            AND parent_id = asset.owner_id;
        END IF;
      END IF;
    END IF;
  END IF;

  RETURN jsonb_build_object(
    'success', true,
    'url', final_url,
    'asset_id', asset.id,
    'r2_key', asset.r2_key,
    'visibility', asset.visibility
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute to authenticated users (edge functions use service role anyway)
GRANT EXECUTE ON FUNCTION finalize_media_upload(UUID, BIGINT) TO authenticated;
GRANT EXECUTE ON FUNCTION get_asset_public_url(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION cleanup_expired_pending_uploads() TO service_role;
