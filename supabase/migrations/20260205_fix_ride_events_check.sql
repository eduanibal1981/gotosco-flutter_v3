-- Fix ride_events check constraint to include 'arrived'
ALTER TABLE public.ride_events 
DROP CONSTRAINT IF EXISTS ride_events_event_type_check;

ALTER TABLE public.ride_events 
ADD CONSTRAINT ride_events_event_type_check 
CHECK (event_type IN ('approaching', 'arrived', 'picked_up', 'dropped_off'));

-- Enable Realtime for ride_events (Critical for parent UI updates)
ALTER PUBLICATION supabase_realtime ADD TABLE public.ride_events;

-- Update notification function to handle 'arrived'
CREATE OR REPLACE FUNCTION public.notify_parent_on_ride_event()
RETURNS TRIGGER AS $$
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

  -- Get child's name
  SELECT c.name INTO child_name
  FROM children c
  WHERE c.id = NEW.child_id;

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
            'child_id', NEW.child_id::text
          )
        )
      );
  ELSE
    -- Log warning if settings are missing (visible in Supabase logs)
    RAISE WARNING 'Missing app.settings.supabase_functions_url or anon_key. Notification not sent.';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
