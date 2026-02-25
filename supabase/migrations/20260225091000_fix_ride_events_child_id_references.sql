CREATE OR REPLACE FUNCTION public.notify_parent_on_ride_event()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  parent_fcm_token TEXT;
  child_name TEXT;
  notification_title TEXT;
  notification_body TEXT;
BEGIN
  -- Get parent's FCM token
  SELECT u.fcm_token INTO parent_fcm_token
  FROM users u
  WHERE u.id = NEW.parent_id;

  -- Get child/children names from event_data->child_ids
  SELECT string_agg(c.name, ' and ') INTO child_name
  FROM children c
  WHERE c.id IN (
    SELECT jsonb_array_elements_text(NEW.event_data->'child_ids')::uuid
  );

  -- Skip if no FCM token
  IF parent_fcm_token IS NULL THEN
    RETURN NEW;
  END IF;

  -- Set notification content based on event type
  CASE NEW.event_type
    WHEN 'approaching' THEN
      notification_title := 'Driver Approaching!';
      notification_body := 'The driver will arrive in approximately 5 minutes for ' || COALESCE(child_name, 'your child') || '.';
    WHEN 'arrived' THEN
      notification_title := 'Driver Arrived!';
      notification_body := 'The driver has arrived at the location for ' || COALESCE(child_name, 'your child') || '.';
    WHEN 'picked_up' THEN
      notification_title := 'Child Picked Up ✓';
      notification_body := COALESCE(child_name, 'Your child') || ' has been picked up safely.';
    WHEN 'dropped_off' THEN
      notification_title := 'Child Dropped Off ✓';
      notification_body := COALESCE(child_name, 'Your child') || ' has arrived at the destination.';
    ELSE
      -- Don't notify on system events like trip_started, we assume UI updates are enough
      RETURN NEW;
  END CASE;

  -- Call Edge Function to send notification
  -- Check for settings existence first to prevent crashes
  IF current_setting('app.settings.supabase_functions_url', true) IS NOT NULL 
     AND current_setting('app.settings.anon_key', true) IS NOT NULL THEN
    
    PERFORM
      net.http_post(
        url := current_setting('app.settings.supabase_functions_url', true) || '/send-notification',
        headers := jsonb_build_object(
          'Content-Type', 'application/json',
          'Authorization', 'Bearer ' || current_setting('app.settings.anon_key', true)
        ),
        body := jsonb_build_object(
          'fcm_token', parent_fcm_token,
          'title', notification_title,
          'body', notification_body,
          'data', jsonb_build_object(
            'event_type', NEW.event_type,
            'booking_id', NEW.booking_id::text,
            'child_ids', NEW.event_data->'child_ids'
          )
        )
      );
  ELSE
    -- Log warning if settings are missing (visible in Supabase logs)
    RAISE WARNING 'Missing app.settings.supabase_functions_url or anon_key. Notification not sent.';
  END IF;

  RETURN NEW;
END;
$function$;

-- Update process_stop to cleanly insert to ride_events without child_id column
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
      
      -- Insert Event for Arrived (no child_id column, passed via event_data)
      INSERT INTO public.ride_events (booking_id, driver_id, parent_id, daily_trip_id, event_type, event_data, created_at)
      VALUES (
        v_booking_id, 
        v_driver_id, 
        v_parent_id, 
        v_trip_id,
        'arrived', 
        jsonb_build_object(
            'description', 'Driver has arrived at the stop',
            'event_time', to_char(NOW() AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'),
            'child_ids', jsonb_build_array(v_child_id)
        ),
        NOW()
      );

  ELSIF action IN ('picked_up', 'dropped_off') THEN
      UPDATE public.route_stops
      SET status = 'completed', completed_at = NOW()
      WHERE id = stop_id_input;
      
      -- Insert Event (no child_id column, passed via event_data)
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
            'child_ids', jsonb_build_array(v_child_id)
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
