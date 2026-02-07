-- Create trip_tracking table to store historical location data for trips
CREATE TABLE IF NOT EXISTS public.trip_tracking (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  daily_trip_id UUID NOT NULL REFERENCES public.trips(id) ON DELETE CASCADE,
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  heading DOUBLE PRECISION,
  speed DOUBLE PRECISION,
  recorded_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for performance on querying trip history
CREATE INDEX IF NOT EXISTS idx_trip_tracking_trip_date 
  ON public.trip_tracking(daily_trip_id, recorded_at DESC);

-- Enable RLS
ALTER TABLE public.trip_tracking ENABLE ROW LEVEL SECURITY;

-- Policies

-- Drivers can insert tracking data for their assigned trips
CREATE POLICY "Drivers can insert tracking data"
  ON public.trip_tracking
  FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.trips
      WHERE id = daily_trip_id
      AND driver_id = auth.uid()
    )
  );

-- Parents can view tracking data for trips associated with their bookings
CREATE POLICY "Parents can view tracking data"
  ON public.trip_tracking
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.trips t
      JOIN public.bookings b ON t.booking_id = b.id -- Assuming trips are linked to bookings/parents
      WHERE t.id = trip_tracking.daily_trip_id
      AND b.parent_id = auth.uid()
    )
    OR
    EXISTS ( -- Alternative: If trip doesn't have booking_id directly, check via child/parent link
      SELECT 1 FROM public.trips t
      WHERE t.id = trip_tracking.daily_trip_id
      AND t.parent_id = auth.uid() -- if parent_id is on trips
    )
  );

-- Allow drivers to view their own tracking data
CREATE POLICY "Drivers can view their own tracking data"
  ON public.trip_tracking
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.trips
      WHERE id = daily_trip_id
      AND driver_id = auth.uid()
    )
  );
