-- Add trips_started column to driver_locations
ALTER TABLE public.driver_locations ADD COLUMN IF NOT EXISTS trips_started boolean DEFAULT false;

-- DROP functions first to allow redefinition
DROP FUNCTION IF EXISTS public.start_trip(uuid, double precision, double precision);
DROP FUNCTION IF EXISTS public.complete_trip_with_auto_offline(uuid, double precision, double precision);
DROP FUNCTION IF EXISTS public.regenerate_daily_trips(date);

-- Update start_trip function
CREATE OR REPLACE FUNCTION public.start_trip(trip_id_input uuid, driver_lat double precision, driver_lng double precision)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  v_driver_id UUID := auth.uid();
BEGIN
  -- Mark trip as in_progress
  UPDATE public.trips 
  SET status = 'in_progress',
      actual_start_time = NOW(),
      updated_at = NOW()
  WHERE id = trip_id_input 
    AND driver_id = v_driver_id
    AND status = 'scheduled';

  -- Update driver location and status
  UPDATE public.driver_locations
  SET latitude = driver_lat,
      longitude = driver_lng,
      trip_type = (SELECT trip_type FROM public.trips WHERE id = trip_id_input),
      updated_at = NOW(),
      is_tracking_active = true, -- Auto enable tracking
      trips_started = true       -- Set trips_started flag
  WHERE driver_id = v_driver_id;
  
  -- Log initial location
  INSERT INTO public.trip_tracking (daily_trip_id, latitude, longitude)
  VALUES (trip_id_input, driver_lat, driver_lng);
END;
$function$;

-- Update complete_trip_with_auto_offline function
CREATE OR REPLACE FUNCTION public.complete_trip_with_auto_offline(trip_id_input uuid, driver_lat double precision, driver_lng double precision)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  v_driver_id UUID := auth.uid();
  v_auto_offline boolean;
BEGIN
  -- 1) Mark trip as completed
  UPDATE public.trips 
  SET status = 'completed',
      actual_end_time = NOW(),
      updated_at = NOW()
  WHERE id = trip_id_input 
    AND driver_id = v_driver_id;

  -- 2) Check auto-offline setting
  SELECT auto_offline_after_trip INTO v_auto_offline
  FROM public.drivers
  WHERE user_id = v_driver_id;

  -- 3) Update location table
  UPDATE public.driver_locations
  SET latitude = COALESCE(driver_lat, latitude),
      longitude = COALESCE(driver_lng, longitude),
      trip_type = 'idle',
      updated_at = NOW(),
      trips_started = false, -- Reset trips_started flag
      -- Only disable tracking if auto-offline is enabled
      is_tracking_active = CASE 
        WHEN v_auto_offline THEN false 
        ELSE is_tracking_active 
      END
  WHERE driver_id = v_driver_id;

  -- 4) If auto-offline, also update profile status
  IF v_auto_offline THEN
    PERFORM public.set_profile_online_status(false);
  END IF;
  
END;
$function$;

-- Update regenerate_daily_trips to reset trips_started
CREATE OR REPLACE FUNCTION public.regenerate_daily_trips(target_date date)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  v_driver_id UUID := auth.uid();
BEGIN
  -- 1. Detach bookings from trips
  UPDATE public.bookings
  SET daily_trip_id = NULL
  WHERE daily_trip_id IN (
    SELECT id FROM public.trips 
    WHERE driver_id = v_driver_id 
      AND trip_date = target_date
  );

  -- 2. Delete trip stops
  DELETE FROM public.trip_stops
  WHERE daily_trip_id IN (
    SELECT id FROM public.trips 
    WHERE driver_id = v_driver_id 
      AND trip_date = target_date
  );

  -- 3. Delete trips
  DELETE FROM public.trips 
  WHERE driver_id = v_driver_id 
    AND trip_date = target_date;

  -- 4. Reset driver state if today
  IF target_date = CURRENT_DATE THEN
    UPDATE public.driver_locations
    SET trip_type = 'idle',
        is_tracking_active = false,
        trips_started = false,
        updated_at = NOW()
    WHERE driver_id = v_driver_id;
  END IF;
  
  -- 5. Regenerate
  PERFORM public.generate_go_trips(target_date, v_driver_id);
  PERFORM public.generate_return_trips(target_date, v_driver_id);
END;
$function$;
