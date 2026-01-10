-- Fix RLS policy for route_stops to allow drivers to update them (e.g. reordering)

-- Enable RLS on the table (ensure it's on)
ALTER TABLE public.route_stops ENABLE ROW LEVEL SECURITY;

-- Policy: Drivers can UPDATE route_stops if they are the assigned driver of the trip
CREATE POLICY "Drivers can update their own trip stops"
ON public.route_stops
FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.trips
    WHERE trips.id = route_stops.trip_id
    AND trips.driver_id = auth.uid()
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.trips
    WHERE trips.id = route_stops.trip_id
    AND trips.driver_id = auth.uid()
  )
);

-- Policy: Drivers can SELECT their own trip stops (usually already exists, but ensuring coverage)
CREATE POLICY "Drivers can select their own trip stops"
ON public.route_stops
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.trips
    WHERE trips.id = route_stops.trip_id
    AND trips.driver_id = auth.uid()
  )
);
