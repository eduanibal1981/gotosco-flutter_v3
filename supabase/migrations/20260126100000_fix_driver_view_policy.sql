-- Policy to allow drivers to view open/posted bookings
-- This addresses the issue where drivers could not see bookings with driver_id = NULL
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_policies
        WHERE tablename = 'bookings'
        AND policyname = 'Drivers can view open bookings'
    ) THEN
        CREATE POLICY "Drivers can view open bookings" ON "public"."bookings"
        FOR SELECT
        TO authenticated
        USING (
            driver_id IS NULL 
            AND status IN ('posted', 'pending', 'open')
        );
    END IF;
END $$;
