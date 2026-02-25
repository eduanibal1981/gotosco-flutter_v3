CREATE OR REPLACE FUNCTION public.process_stop(stop_id_input uuid, action text, driver_lat double precision DEFAULT NULL::double precision, driver_lng double precision DEFAULT NULL::double precision)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  v_booking_id uuid;
  v_child_id uuid;
  v_trip_id uuid;
  v_driver_id uuid;
  v_parent_id uuid;
  v_next_stop_id uuid;
  v_current_seq int;
BEGIN
  -- Get context
  SELECT rs.booking_id, rs.child_id, rs.trip_id, t.driver_id, b.parent_id, rs.sequence_order
  INTO v_booking_id, v_child_id, v_trip_id, v_driver_id, v_parent_id, v_current_seq
  FROM public.route_stops rs
  JOIN public.trips t ON rs.trip_id = t.id
  JOIN public.bookings b ON rs.booking_id = b.id
  WHERE rs.id = stop_id_input;

  -- Update Stop
  IF action = 'arrived' THEN
      UPDATE public.route_stops
      SET status = 'arrived', arrived_at = NOW()
      WHERE id = stop_id_input;
      
      -- Insert Event for Arrived
      INSERT INTO public.ride_events (booking_id, child_id, driver_id, parent_id, daily_trip_id, event_type, event_data, created_at)
      VALUES (
        v_booking_id, 
        v_child_id, 
        v_driver_id, 
        v_parent_id, 
        v_trip_id,
        'arrived', 
        jsonb_build_object(
            'description', 'Driver has arrived at the stop',
            'event_time', to_char(NOW() AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"')
        ),
        NOW()
      );

  ELSIF action IN ('picked_up', 'dropped_off') THEN
      UPDATE public.route_stops
      SET status = 'completed', completed_at = NOW()
      WHERE id = stop_id_input;
      
      -- Insert Event
      INSERT INTO public.ride_events (booking_id, child_id, driver_id, parent_id, daily_trip_id, event_type, event_data, created_at)
      VALUES (
        v_booking_id, 
        v_child_id, 
        v_driver_id, 
        v_parent_id, 
        v_trip_id,
        action, 
        jsonb_build_object(
            'description', 'Driver has ' || replace(action, '_', ' ') || ' the student',
            'event_time', to_char(NOW() AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"')
        ),
        NOW()
      );

  ELSIF action = 'skipped' THEN
      UPDATE public.route_stops
      SET status = 'skipped', completed_at = NOW()
      WHERE id = stop_id_input;
      
  ELSIF action = 'reset' THEN
      UPDATE public.route_stops
      SET status = 'pending', arrived_at = NULL, completed_at = NULL
      WHERE id = stop_id_input;
  END IF;
  
  -- Find Next Stop (for driver location)
  SELECT id INTO v_next_stop_id 
  FROM public.route_stops 
  WHERE trip_id = v_trip_id 
    AND status = 'pending'
    AND sequence_order > v_current_seq
  ORDER BY sequence_order ASC
  LIMIT 1;
  
  -- Update Driver Location
  IF v_driver_id IS NOT NULL THEN
     UPDATE public.driver_locations
     SET 
        latitude = COALESCE(driver_lat, latitude),
        longitude = COALESCE(driver_lng, longitude),
        updated_at = NOW(),
        next_stop_id = v_next_stop_id
     WHERE driver_id = v_driver_id;
  END IF;
END;
$function$;
