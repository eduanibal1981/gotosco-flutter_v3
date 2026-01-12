-- Add email column to users table
-- This is needed for user registration and Google Sign-In

ALTER TABLE public.users
ADD COLUMN IF NOT EXISTS email text;

-- Optional: Create an index for faster email lookups
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);

-- Update the Full_schema_updates.sql documentation accordingly
COMMENT ON COLUMN public.users.email IS 'User email address from auth provider';
