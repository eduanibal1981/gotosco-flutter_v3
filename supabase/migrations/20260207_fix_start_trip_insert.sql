-- Revert start_trip logic to include INSERT if no record exists
-- This fixes the issue where new drivers don't have location rows created

CREATE OR REPLACE FUNCTION public.start_trip(
  trip_id_input UUID,
  driver_lat double precision DEFAULT NULL,
  driver_lng double precision DEFAULT NULL
) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER
AS $function$
DECLARE
  v_driver_id UUID := auth.uid();
  v_trip_type_str text;
  v_mapped_type text;
BEGIN
  -- 1. Get trip type for mapping
  SELECT trip_type INTO v_trip_type_str
  FROM public.trips 
  WHERE id = trip_id_input;

  -- 2. Map trip_type to enum/string used in driver_locations
  IF v_trip_type_str = 'Go to School(s)' THEN
    v_mapped_type := 'pickup';
  ELSE
    v_mapped_type := 'dropoff';
  END IF;

  -- 3. Mark trip as in_progress
  UPDATE public.trips 
  SET status = 'in_progress',
      actual_start_time = NOW(),
      updated_at = NOW()
  WHERE id = trip_id_input 
    AND driver_id = v_driver_id
    AND status = 'scheduled';

  -- 4. Update driver location and status (UPSERT logic)
  UPDATE public.driver_locations
  SET latitude = COALESCE(driver_lat, latitude),
      longitude = COALESCE(driver_lng, longitude),
      trip_type = v_mapped_type,
      updated_at = NOW(),
      is_tracking_active = true,
      trips_started = true
  WHERE driver_id = v_driver_id;
  
  -- If update failed (no row), insert new row
  IF NOT FOUND THEN
    INSERT INTO public.driver_locations (
      driver_id, 
      latitude, 
      longitude, 
      trip_type, 
      is_tracking_active, 
      trips_started,
      updated_at
    ) VALUES (
      v_driver_id, 
      COALESCE(driver_lat, 0), 
      COALESCE(driver_lng, 0), 
      v_mapped_type, 
      true, 
      true,
      NOW()
    );
  END IF;
  
  -- 5. Log initial location
  INSERT INTO public.trip_tracking (daily_trip_id, latitude, longitude)
  VALUES (trip_id_input, COALESCE(driver_lat, 0), COALESCE(driver_lng, 0));
END;
$function$;
