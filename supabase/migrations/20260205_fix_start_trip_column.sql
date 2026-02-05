CREATE OR REPLACE FUNCTION public.start_trip(
  trip_id_input UUID,
  driver_lat double precision DEFAULT NULL,
  driver_lng double precision DEFAULT NULL
) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_trip_type_str text;
  v_driver_id uuid;
  v_mapped_type text;
BEGIN
  -- 1. Get trip details
  SELECT trip_type, driver_id INTO v_trip_type_str, v_driver_id
  FROM public.trips
  WHERE id = trip_id_input;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Trip not found';
  END IF;

  -- 2. Map trip_type to driver_locations.trip_type enum/string
  -- 'Go to School(s)' -> 'pickup'
  -- 'Return from School(s)' -> 'dropoff'
  IF v_trip_type_str = 'Go to School(s)' THEN
    v_mapped_type := 'pickup';
  ELSE
    v_mapped_type := 'dropoff';
  END IF;

  -- 3. Update trips table
  UPDATE public.trips
  SET status = 'in_progress',
      start_time = COALESCE(start_time, NOW())
  WHERE id = trip_id_input;

  -- 4. Update driver_locations table
  -- FIX: Use 'is_tracking_active' instead of 'is_online' which was dropped
  UPDATE public.driver_locations
  SET trip_type = v_mapped_type,
      is_tracking_active = true,
      updated_at = NOW(),
      -- Update location only if valid coordinates are provided
      latitude = COALESCE(driver_lat, latitude),
      longitude = COALESCE(driver_lng, longitude)
  WHERE driver_id = v_driver_id;

  IF NOT FOUND THEN
    INSERT INTO public.driver_locations (
      driver_id, 
      latitude, 
      longitude, 
      trip_type, 
      is_tracking_active, 
      updated_at
    ) VALUES (
      v_driver_id, 
      COALESCE(driver_lat, 0), 
      COALESCE(driver_lng, 0), 
      v_mapped_type, 
      true, 
      NOW()
    );
  END IF;
END;
$$;
