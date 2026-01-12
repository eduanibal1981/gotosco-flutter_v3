-- Migration: Auto-create user profile when auth.users is created
-- Fixes: Google Sign-In users not appearing in public.users table
-- Date: 2026-01-12

-- 1. Make phone field nullable to support Google Sign-In users without phone
ALTER TABLE public.users 
  ALTER COLUMN phone DROP NOT NULL;

-- 2. Function to automatically create a public.users profile when auth.users is created
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, full_name, phone, role, auth_provider, created_at)
  VALUES (
    NEW.id,
    NEW.email,
    -- Use full_name from metadata if available, otherwise use email or 'User'
    COALESCE(
      NEW.raw_user_meta_data->>'full_name',
      NEW.raw_user_meta_data->>'name',
      split_part(NEW.email, '@', 1),
      'User'
    ),
    NEW.phone,
    '{}', -- Empty role array - user must select roles after signup
    -- Determine auth provider from metadata
    CASE 
      WHEN NEW.app_metadata->>'provider' = 'google' THEN 'google'
      WHEN NEW.app_metadata->>'provider' = 'email' THEN 'phone'
      ELSE COALESCE(NEW.app_metadata->>'provider', 'phone')
    END,
    NOW()
  )
  ON CONFLICT (id) DO NOTHING; -- Prevent duplicate errors if profile already exists
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Create trigger on auth.users table
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- 4. Backfill: Create profiles for existing auth users without public profiles
-- This handles any users who signed in before this migration
INSERT INTO public.users (id, email, full_name, phone, role, auth_provider, created_at)
SELECT 
  au.id,
  au.email,
  COALESCE(
    au.raw_user_meta_data->>'full_name',
    au.raw_user_meta_data->>'name',
    split_part(au.email, '@', 1),
    'User'
  ) as full_name,
  au.phone,
  '{}' as role,
  CASE 
    WHEN au.app_metadata->>'provider' = 'google' THEN 'google'
    WHEN au.app_metadata->>'provider' = 'email' THEN 'phone'
    ELSE COALESCE(au.app_metadata->>'provider', 'phone')
  END as auth_provider,
  au.created_at
FROM auth.users au
LEFT JOIN public.users pu ON au.id = pu.id
WHERE pu.id IS NULL; -- Only insert users that don't exist in public.users

COMMENT ON FUNCTION public.handle_new_user() IS 'Automatically creates a public.users profile when a new auth.users record is created';
COMMENT ON TRIGGER on_auth_user_created ON auth.users IS 'Triggers profile creation for new authenticated users';
