-- SQL to run in Supabase SQL Editor
-- This sets up the database for push notifications

-- 1. Add fcm_token column to users table
ALTER TABLE users ADD COLUMN IF NOT EXISTS fcm_token TEXT;

-- 2. Create ride_events table for tracking driver actions
CREATE TABLE IF NOT EXISTS ride_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id UUID REFERENCES bookings(id) ON DELETE CASCADE,
  child_id UUID REFERENCES children(id) ON DELETE CASCADE,
  driver_id UUID REFERENCES drivers(id) ON DELETE CASCADE,
  parent_id UUID REFERENCES users(id) ON DELETE CASCADE,
  event_type TEXT NOT NULL CHECK (event_type IN ('approaching', 'picked_up', 'dropped_off')),
  event_data JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_ride_events_booking ON ride_events(booking_id);
CREATE INDEX IF NOT EXISTS idx_ride_events_parent ON ride_events(parent_id);
CREATE INDEX IF NOT EXISTS idx_ride_events_created ON ride_events(created_at DESC);

-- 4. Enable RLS on ride_events
ALTER TABLE ride_events ENABLE ROW LEVEL SECURITY;

-- 5. RLS policies for ride_events
CREATE POLICY "Parents can view their ride events"
  ON ride_events FOR SELECT
  TO authenticated
  USING (parent_id = auth.uid());

CREATE POLICY "Drivers can insert ride events"
  ON ride_events FOR INSERT
  TO authenticated
  WITH CHECK (driver_id IN (SELECT id FROM drivers WHERE user_id = auth.uid()));

-- 6. Create function to send notification via Edge Function
CREATE OR REPLACE FUNCTION notify_parent_on_ride_event()
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
      notification_body := 'The driver will arrive in approximately 5 minutes to pick up ' || COALESCE(child_name, 'your child') || '.';
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
  PERFORM
    net.http_post(
      url := current_setting('app.settings.supabase_functions_url') || '/send-notification',
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'Authorization', 'Bearer ' || current_setting('app.settings.anon_key')
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

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7. Create trigger on ride_events
DROP TRIGGER IF EXISTS on_ride_event_notify ON ride_events;
CREATE TRIGGER on_ride_event_notify
  AFTER INSERT ON ride_events
  FOR EACH ROW
  EXECUTE FUNCTION notify_parent_on_ride_event();

-- Note: You also need to enable the pg_net extension in Supabase Dashboard:
-- Database > Extensions > Search "pg_net" > Enable
