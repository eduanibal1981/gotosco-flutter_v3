-- Add Foreign Key constraint for booking_id in route_stops
-- This enables Supabase to detecting the relationship for joins like .select('*, bookings(*)')

DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 
    FROM information_schema.table_constraints 
    WHERE constraint_name = 'route_stops_booking_id_fkey'
  ) THEN
    ALTER TABLE public.route_stops
    ADD CONSTRAINT route_stops_booking_id_fkey
    FOREIGN KEY (booking_id) REFERENCES public.bookings (id)
    ON DELETE CASCADE;
  END IF;
END $$;
