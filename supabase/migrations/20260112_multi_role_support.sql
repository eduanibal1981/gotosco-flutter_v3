-- Migration: Multi-Role Support
-- Description: Allow users to have multiple roles (parent + driver)
-- Date: 2026-01-12

-- 1. Make phone optional (Google users don't have phone)
ALTER TABLE users 
ALTER COLUMN phone DROP NOT NULL;

-- 2. Add auth provider tracking
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS auth_provider text DEFAULT 'phone';

-- 3. Update existing users to have phone auth provider
UPDATE users 
SET auth_provider = 'phone' 
WHERE auth_provider IS NULL;

-- 4. Convert role from single text to array
-- Preserve existing data: if role is null -> empty array, else wrap in array
ALTER TABLE users 
ALTER COLUMN role TYPE text[] 
USING CASE 
  WHEN role IS NULL THEN ARRAY[]::text[]
  ELSE ARRAY[role::text]
END;

-- 5. Set default for new users (empty array, will require role selection)
ALTER TABLE users 
ALTER COLUMN role SET DEFAULT ARRAY[]::text[];

-- 6. Add GIN index for efficient array operations (checking if role contains 'driver' or 'parent')
CREATE INDEX IF NOT EXISTS idx_users_roles ON users USING GIN(role);

-- 7. Update RLS policies to work with array roles
-- Drop old policy if exists
DROP POLICY IF EXISTS "Drivers can access driver data" ON drivers;

-- Recreate with array syntax
CREATE POLICY "Drivers can access driver data"
ON drivers FOR ALL
USING (
  auth.uid() = user_id 
  AND EXISTS (
    SELECT 1 FROM users 
    WHERE id = auth.uid() 
    AND 'driver' = ANY(role)
  )
);

-- 8. Add helpful comment
COMMENT ON COLUMN users.role IS 'Array of roles: can be ["parent"], ["driver"], or ["parent", "driver"]';
