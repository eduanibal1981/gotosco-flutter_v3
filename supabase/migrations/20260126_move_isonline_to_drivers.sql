-- Move is_online from driver_locations to drivers table

-- 1. Add column to drivers if not exists
ALTER TABLE public.drivers 
ADD COLUMN IF NOT EXISTS is_online BOOLEAN DEFAULT false;

-- 2. Migrate existing status (if available in driver_locations)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'driver_locations' AND column_name = 'is_online') THEN
        UPDATE public.drivers d
        SET is_online = dl.is_online
        FROM public.driver_locations dl
        WHERE d.user_id = dl.driver_id;
    END IF;
END $$;

-- 3. Update Function: set_driver_online_status
CREATE OR REPLACE FUNCTION public.set_driver_online_status(p_is_online BOOLEAN)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_driver_id UUID := auth.uid();
BEGIN
  UPDATE public.drivers
  SET is_online = p_is_online
  WHERE user_id = v_driver_id;
END;
$$;

-- 4. Update Function: get_driver_availability_settings
CREATE OR REPLACE FUNCTION public.get_driver_availability_settings()
RETURNS TABLE(
  auto_offline_after_trip boolean, 
  auto_online_before_trip boolean, 
  auto_online_minutes_before integer, 
  availability_mode text, 
  is_online boolean
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_driver_id UUID := auth.uid();
BEGIN
    RETURN QUERY
    SELECT 
        d.auto_offline_after_trip,
        d.auto_online_before_trip,
        d.auto_online_minutes_before,
        d.availability_mode,
        COALESCE(d.is_online, false) as is_online
    FROM public.drivers d
    WHERE d.user_id = v_driver_id;
END;
$$;

-- 5. Drop the dependent policy on driver_locations
DROP POLICY IF EXISTS "Parents can view relevant drivers" ON "public"."driver_locations";

-- 6. Drop column from driver_locations
ALTER TABLE public.driver_locations 
DROP COLUMN IF EXISTS is_online;

-- 7. Re-create the policy using drivers table for online check
CREATE POLICY "Parents can view relevant drivers" ON "public"."driver_locations"
FOR SELECT
TO public
USING (
  (driver_id IN (SELECT user_id FROM drivers WHERE is_online = true))
  OR 
  (EXISTS ( 
     SELECT 1 FROM bookings
     WHERE bookings.driver_id = driver_locations.driver_id 
     AND bookings.parent_id = auth.uid() 
     AND bookings.status = 'accepted'
  ))
);
