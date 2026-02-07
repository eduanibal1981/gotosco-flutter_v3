-- Add online status columns to users table
ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS is_app_online BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS is_online_visible BOOLEAN DEFAULT true;

-- Function to set user online status (called on app resume/pause)
CREATE OR REPLACE FUNCTION public.set_user_online_status(p_is_online boolean)
RETURNS VOID
SECURITY DEFINER
AS $$
BEGIN
  UPDATE public.users
  SET is_app_online = p_is_online,
      updated_at = NOW()
  WHERE id = auth.uid();
END;
$$ LANGUAGE plpgsql;

-- Function to toggle visibility preference
CREATE OR REPLACE FUNCTION public.set_online_visibility(p_is_visible boolean)
RETURNS VOID
SECURITY DEFINER
AS $$
BEGIN
  UPDATE public.users
  SET is_online_visible = p_is_visible,
  updated_at = NOW()
  WHERE id = auth.uid();
END;
$$ LANGUAGE plpgsql;

-- Grant permissions
GRANT ALL ON FUNCTION public.set_user_online_status(boolean) TO authenticated;
GRANT ALL ON FUNCTION public.set_online_visibility(boolean) TO authenticated;
