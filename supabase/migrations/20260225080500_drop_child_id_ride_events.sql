-- 1. Drop the dependent view first
DROP VIEW IF EXISTS public.parent_notifications_view;

-- 2. Drop the redundant column
ALTER TABLE public.ride_events DROP COLUMN IF EXISTS child_id CASCADE;

-- 3. Modify process_stop to exclude child_id logic while keeping child_ids array JSON array feature
CREATE OR REPLACE FUNCTION public.process_stop(stop_id_input uuid, action text, driver_lat double precision DEFAULT NULL::double precision, driver_lng double precision DEFAULT NULL::double precision)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  v_booking_id uuid;
  v_trip_id uuid;
  v_driver_id uuid;
  v_parent_id uuid;
  v_next_stop_id uuid;
  v_current_seq int;
  v_stop_type text;
  v_location_name text;
  v_child_ids jsonb;
BEGIN
  -- Get context
  SELECT rs.booking_id, rs.trip_id, t.driver_id, b.parent_id, rs.sequence_order, rs.stop_type
  INTO v_booking_id, v_trip_id, v_driver_id, v_parent_id, v_current_seq, v_stop_type
  FROM public.route_stops rs
  JOIN public.trips t ON rs.trip_id = t.id
  JOIN public.bookings b ON rs.booking_id = b.id
  WHERE rs.id = stop_id_input;

  -- Determine location name from stop type
  IF v_stop_type ILIKE '%school%' THEN
    v_location_name := 'the School';
  ELSIF v_stop_type ILIKE '%home%' THEN
    v_location_name := 'the Home';
  ELSE
    v_location_name := 'the stop';
  END IF;

  -- Aggregate children for this booking into a JSON array
  SELECT jsonb_agg(child_id) INTO v_child_ids 
  FROM public.booking_children 
  WHERE booking_id = v_booking_id;

  -- Update Stop
  IF action = 'arrived' THEN
      UPDATE public.route_stops
      SET status = 'arrived', arrived_at = NOW()
      WHERE id = stop_id_input;
      
      -- Insert Event for Arrived
      INSERT INTO public.ride_events (booking_id, driver_id, parent_id, daily_trip_id, event_type, event_data, created_at)
      VALUES (
        v_booking_id, 
        v_driver_id, 
        v_parent_id, 
        v_trip_id,
        'arrived', 
        jsonb_build_object(
            'description', 'Driver has arrived at ' || v_location_name,
            'event_time', to_char(NOW() AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'),
            'child_ids', v_child_ids
        ),
        NOW()
      );

  ELSIF action IN ('picked_up', 'dropped_off') THEN
      UPDATE public.route_stops
      SET status = 'completed', completed_at = NOW()
      WHERE id = stop_id_input;
      
      -- Insert Event
      INSERT INTO public.ride_events (booking_id, driver_id, parent_id, daily_trip_id, event_type, event_data, created_at)
      VALUES (
        v_booking_id, 
        v_driver_id, 
        v_parent_id, 
        v_trip_id,
        action, 
        jsonb_build_object(
            'description', 'Driver has ' || replace(action, '_', ' ') || ' the student',
            'event_time', to_char(NOW() AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'),
            'child_ids', v_child_ids
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

-- 4. Recreate the parent_notifications_view securely mapped to current schema
CREATE OR REPLACE VIEW public.parent_notifications_view AS
 SELECT re.id,
    re.booking_id,
    re.driver_id,
    re.parent_id,
    re.daily_trip_id,
    re.event_type,
    re.event_data,
    re.created_at,
    re.read_at,
    ( SELECT string_agg(c.name, ', '::text) AS string_agg
           FROM (public.booking_children bc
             JOIN public.children c ON ((bc.child_id = c.id)))
          WHERE (bc.booking_id = re.booking_id)) AS child_name,
    u.full_name AS driver_name,
    u.photo_url AS driver_photo
   FROM (public.ride_events re
     LEFT JOIN public.users u ON ((re.driver_id = u.id)));
