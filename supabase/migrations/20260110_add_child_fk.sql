-- Add Foreign Key constraint for child_id in route_stops
-- This enables Supabase to detecting the relationship for joins like .select('*, children(*)')

DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 
    FROM information_schema.table_constraints 
    WHERE constraint_name = 'route_stops_child_id_fkey'
  ) THEN
    ALTER TABLE public.route_stops
    ADD CONSTRAINT route_stops_child_id_fkey
    FOREIGN KEY (child_id) REFERENCES public.children (id)
    ON DELETE CASCADE;
  END IF;
END $$;
