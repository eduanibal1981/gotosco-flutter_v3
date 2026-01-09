-- Migration to add RPCs for trip execution flow
-- Includes: start_trip, process_stop, complete_trip
-- Also ensures route_stops has necessary timestamp columns

-- 1. Ensure columns exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'route_stops' AND column_name = 'arrived_at') THEN
        ALTER TABLE public.route_stops ADD COLUMN arrived_at TIMESTAMP WITH TIME ZONE;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'route_stops' AND column_name = 'completed_at') THEN
        ALTER TABLE public.route_stops ADD COLUMN completed_at TIMESTAMP WITH TIME ZONE;
    END IF;
END $$;

-- 2. start_trip
CREATE OR REPLACE FUNCTION public.start_trip(trip_id_input UUID, driver_lat FLOAT DEFAULT NULL, driver_lng FLOAT DEFAULT NULL)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER 
SET search_path = public
AS $$
BEGIN
  UPDATE public.trips
  SET status = 'in_progress',
      start_time = COALESCE(start_time, NOW())
  WHERE id = trip_id_input;
END;
$$;

-- 3. process_stop
CREATE OR REPLACE FUNCTION public.process_stop(
    stop_id_input UUID,
    action TEXT, -- 'arrived', 'picked_up', 'dropped_off', 'skipped', 'reset'
    driver_lat FLOAT DEFAULT NULL,
    driver_lng FLOAT DEFAULT NULL
)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER 
SET search_path = public
AS $$
BEGIN
  IF action = 'arrived' THEN
      UPDATE public.route_stops
      SET status = 'arrived',
          arrived_at = NOW()
      WHERE id = stop_id_input;

  ELSIF action IN ('picked_up', 'dropped_off') THEN
      UPDATE public.route_stops
      SET status = 'completed',
          completed_at = NOW()
      WHERE id = stop_id_input;

  ELSIF action = 'skipped' THEN
      UPDATE public.route_stops
      SET status = 'skipped',
          completed_at = NOW()
      WHERE id = stop_id_input;
  
  ELSIF action = 'reset' THEN
      UPDATE public.route_stops
      SET status = 'pending',
          arrived_at = NULL,
          completed_at = NULL
      WHERE id = stop_id_input;
  END IF;
END;
$$;

-- 4. complete_trip
CREATE OR REPLACE FUNCTION public.complete_trip(trip_id_input UUID, driver_lat FLOAT DEFAULT NULL, driver_lng FLOAT DEFAULT NULL)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER 
SET search_path = public
AS $$
BEGIN
  UPDATE public.trips
  SET status = 'completed',
      end_time = NOW()
  WHERE id = trip_id_input;
END;
$$;
