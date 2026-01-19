


SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE SCHEMA IF NOT EXISTS "public";


ALTER SCHEMA "public" OWNER TO "pg_database_owner";


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE TYPE "public"."booking_status" AS ENUM (
    'pending',
    'accepted',
    'in_progress',
    'completed',
    'cancelled'
);


ALTER TYPE "public"."booking_status" OWNER TO "postgres";


CREATE TYPE "public"."user_role" AS ENUM (
    'parent',
    'driver',
    'admin'
);


ALTER TYPE "public"."user_role" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."check_auto_online"() RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    v_driver_id UUID := auth.uid();
    v_settings RECORD;
    v_first_trip RECORD;
    v_should_go_online BOOLEAN := false;
BEGIN
    -- Get driver settings
    SELECT auto_online_before_trip, auto_online_minutes_before, availability_mode
    INTO v_settings
    FROM public.drivers
    WHERE user_id = v_driver_id;
    
    -- If not in smart mode or auto-online disabled, skip
    IF v_settings.availability_mode != 'smart' OR NOT v_settings.auto_online_before_trip THEN
        RETURN false;
    END IF;
    
    -- Find first scheduled trip for today
    SELECT id, trip_type, start_time
    INTO v_first_trip
    FROM public.trips
    WHERE driver_id = v_driver_id
      AND trip_date = CURRENT_DATE
      AND status = 'scheduled'
    ORDER BY 
        CASE WHEN trip_type = 'Go to School(s)' THEN 0 ELSE 1 END,
        start_time
    LIMIT 1;
    
    -- If no trips, don't auto-online
    IF v_first_trip.id IS NULL THEN
        RETURN false;
    END IF;
    
    -- Check if we're within the auto-online window (e.g., 15 minutes before)
    -- Using NOW() and comparing to scheduled time
    IF v_first_trip.start_time IS NOT NULL AND 
       v_first_trip.start_time - INTERVAL '1 minute' * v_settings.auto_online_minutes_before <= NOW() AND
       v_first_trip.start_time > NOW() THEN
        -- Set online
        PERFORM public.set_driver_online_status(true);
        RETURN true;
    END IF;
    
    RETURN false;
END;
$$;


ALTER FUNCTION "public"."check_auto_online"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."check_duplicate_child_booking"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_driver_id UUID;
    v_start_date DATE;
    v_end_date DATE;
    v_is_recurring BOOLEAN;
    v_conflict_count INTEGER;
BEGIN
    -- Get booking details in one query
    SELECT 
        b.driver_id, 
        b.contract_start_date, 
        b.contract_end_date,
        b.is_recurring
    INTO 
        v_driver_id, 
        v_start_date, 
        v_end_date,
        v_is_recurring
    FROM bookings b
    WHERE b.id = NEW.booking_id;
    
    -- Check for conflicts with detailed logic
    SELECT COUNT(*)
    INTO v_conflict_count
    FROM booking_children bc
    JOIN bookings b ON bc.booking_id = b.id
    WHERE bc.child_id = NEW.child_id
    AND b.driver_id = v_driver_id
    AND b.status IN ('pending', 'accepted')
    AND b.id != NEW.booking_id
    AND (
        -- Case 1: Both are recurring and dates overlap
        (
            b.is_recurring = true 
            AND v_is_recurring = true 
            AND b.contract_start_date IS NOT NULL 
            AND b.contract_end_date IS NOT NULL
            AND v_start_date IS NOT NULL 
            AND v_end_date IS NOT NULL
            AND (
                -- Check if date ranges overlap
                (b.contract_start_date <= v_end_date AND b.contract_end_date >= v_start_date)
            )
        )
        OR
        -- Case 2: At least one is non-recurring (prevent any duplicate)
        (b.is_recurring = false OR v_is_recurring = false)
    );
    
    IF v_conflict_count > 0 THEN
        RAISE EXCEPTION 'This child already has % active booking(s) with this driver that conflict with the requested dates.', v_conflict_count
        USING HINT = 'Please cancel or modify the existing booking first.',
              ERRCODE = '23505';
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."check_duplicate_child_booking"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."complete_trip"("trip_id_input" "uuid", "driver_lat" double precision DEFAULT NULL::double precision, "driver_lng" double precision DEFAULT NULL::double precision) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
  UPDATE public.trips
  SET status = 'completed',
      end_time = NOW()
  WHERE id = trip_id_input;
END;
$$;


ALTER FUNCTION "public"."complete_trip"("trip_id_input" "uuid", "driver_lat" double precision, "driver_lng" double precision) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."complete_trip_with_auto_offline"("trip_id_input" "uuid", "driver_lat" double precision DEFAULT NULL::double precision, "driver_lng" double precision DEFAULT NULL::double precision) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    v_driver_id UUID := auth.uid();
    v_settings RECORD;
BEGIN
    -- Complete the trip
    UPDATE public.trips
    SET status = 'completed', end_time = NOW()
    WHERE id = trip_id_input;
    
    -- Check if should auto-offline
    SELECT auto_offline_after_trip, availability_mode
    INTO v_settings
    FROM public.drivers
    WHERE user_id = v_driver_id;
    
    IF v_settings.availability_mode = 'smart' AND v_settings.auto_offline_after_trip THEN
        -- Check if there are more trips today
        IF NOT EXISTS (
            SELECT 1 FROM public.trips
            WHERE driver_id = v_driver_id
              AND trip_date = CURRENT_DATE
              AND status = 'scheduled'
        ) THEN
            -- No more trips, go offline
            PERFORM public.set_driver_online_status(false);
        END IF;
    END IF;
END;
$$;


ALTER FUNCTION "public"."complete_trip_with_auto_offline"("trip_id_input" "uuid", "driver_lat" double precision, "driver_lng" double precision) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."generate_go_trips"("target_date" "date" DEFAULT CURRENT_DATE, "target_driver_id" "uuid" DEFAULT NULL::"uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  driver_rec RECORD;
  new_trip_id UUID;
  child_rec RECORD;
  stop_sequence INT;
  existing_trip_id UUID;
  has_children BOOLEAN;
  sched_start TIME;
  sched_end TIME;
  target_day_name TEXT;
BEGIN
  CREATE TEMP TABLE IF NOT EXISTS _temp_go_stops_v5 (
    booking_id UUID, child_id UUID, pickup_lat FLOAT, pickup_lng FLOAT, school_lat FLOAT, school_lng FLOAT
  ) ON COMMIT DROP;

  target_day_name := LOWER(TRIM(to_char(target_date, 'Day')));

  FOR driver_rec IN 
    SELECT DISTINCT b.driver_id, d.start_location_geo, d.location_geo 
    FROM public.bookings b
    JOIN public.drivers d ON b.driver_id = d.user_id
    WHERE b.subscription_status = 'active' AND (target_driver_id IS NULL OR b.driver_id = target_driver_id)
  LOOP
    SELECT id INTO existing_trip_id FROM public.trips 
    WHERE driver_id = driver_rec.driver_id AND trip_date = target_date AND trip_type = 'Go to School(s)' LIMIT 1;

    IF existing_trip_id IS NOT NULL THEN CONTINUE; END IF;

    DELETE FROM _temp_go_stops_v5 WHERE TRUE;

    -- FETCH DATA: Ordered by 'routego_order'
    INSERT INTO _temp_go_stops_v5 (booking_id, child_id, pickup_lat, pickup_lng, school_lat, school_lng)
    SELECT b.id, bc.child_id, b.home_lat, b.home_lng, b.school_lat, b.school_lng
      FROM public.bookings b
      JOIN public.booking_children bc ON b.id = bc.booking_id
      JOIN public.children c ON bc.child_id = c.id
      WHERE b.driver_id = driver_rec.driver_id
        AND b.subscription_status = 'active'
        AND b.booking_type IN ('Two Way', 'One Way to School')
        AND b.home_lat IS NOT NULL AND b.home_lng IS NOT NULL
        AND NOT EXISTS (SELECT 1 FROM public.child_absences ca WHERE ca.child_id = bc.child_id AND ca.date = target_date)
      ORDER BY 
        b.routego_order ASC NULLS LAST, -- PRIMARY SORT: Morning Sequence
        ST_Distance(b.homegeo_location, COALESCE(driver_rec.start_location_geo, driver_rec.location_geo)) ASC;

    SELECT EXISTS (SELECT 1 FROM _temp_go_stops_v5) INTO has_children;

    IF has_children THEN
        SELECT available_from, available_until INTO sched_start, sched_end
        FROM public.driver_schedules WHERE driver_id = driver_rec.driver_id AND LOWER(day_of_week) = target_day_name AND shift_type = 'Go to School(s)' LIMIT 1;

        INSERT INTO public.trips (driver_id, trip_date, status, trip_type, start_time, end_time)
        VALUES (driver_rec.driver_id, target_date, 'scheduled', 'Go to School(s)',
            CASE WHEN sched_start IS NOT NULL THEN (target_date + sched_start) ELSE NULL END,
            CASE WHEN sched_end IS NOT NULL THEN (target_date + sched_end) ELSE NULL END)
        RETURNING id INTO new_trip_id;

        stop_sequence := 1;
        -- Pickups (Home)
        FOR child_rec IN SELECT * FROM _temp_go_stops_v5 LOOP
            INSERT INTO public.route_stops (trip_id, booking_id, child_id, stop_type, sequence_order, location_lat, location_lng, status)
            VALUES (new_trip_id, child_rec.booking_id, child_rec.child_id, 'pickup', stop_sequence, child_rec.pickup_lat, child_rec.pickup_lng, 'pending');
            stop_sequence := stop_sequence + 1;
        END LOOP;
        -- Dropoffs (School)
        FOR child_rec IN SELECT * FROM _temp_go_stops_v5 ORDER BY school_lat, school_lng LOOP
            INSERT INTO public.route_stops (trip_id, booking_id, child_id, stop_type, sequence_order, location_lat, location_lng, status)
            VALUES (new_trip_id, child_rec.booking_id, child_rec.child_id, 'dropoff', stop_sequence, child_rec.school_lat, child_rec.school_lng, 'pending');
            stop_sequence := stop_sequence + 1;
        END LOOP;
    END IF;
  END LOOP;
END;
$$;


ALTER FUNCTION "public"."generate_go_trips"("target_date" "date", "target_driver_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."generate_return_trips"("target_date" "date" DEFAULT CURRENT_DATE, "target_driver_id" "uuid" DEFAULT NULL::"uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  driver_rec RECORD;
  new_trip_id UUID;
  child_rec RECORD;
  stop_sequence INT;
  existing_trip_id UUID;
  has_children BOOLEAN;
  sched_start TIME;
  sched_end TIME;
  target_day_name TEXT;
BEGIN
  CREATE TEMP TABLE IF NOT EXISTS _temp_return_stops_v5 (
    booking_id UUID, child_id UUID, pickup_lat FLOAT, pickup_lng FLOAT, school_lat FLOAT, school_lng FLOAT
  ) ON COMMIT DROP;

  target_day_name := LOWER(TRIM(to_char(target_date, 'Day')));

  FOR driver_rec IN 
    SELECT DISTINCT b.driver_id FROM public.bookings b
    WHERE b.subscription_status = 'active' AND (target_driver_id IS NULL OR b.driver_id = target_driver_id)
  LOOP
    SELECT id INTO existing_trip_id FROM public.trips 
    WHERE driver_id = driver_rec.driver_id AND trip_date = target_date AND trip_type = 'Return from School(s)' LIMIT 1;
    IF existing_trip_id IS NOT NULL THEN CONTINUE; END IF;

    DELETE FROM _temp_return_stops_v5 WHERE TRUE;

    -- FETCH DATA: Ordered by 'routeret_order'
    INSERT INTO _temp_return_stops_v5 (booking_id, child_id, pickup_lat, pickup_lng, school_lat, school_lng)
    SELECT b.id, bc.child_id, b.home_lat, b.home_lng, b.school_lat, b.school_lng
      FROM public.bookings b
      JOIN public.booking_children bc ON b.id = bc.booking_id
      JOIN public.children c ON bc.child_id = c.id
      WHERE b.driver_id = driver_rec.driver_id
        AND b.subscription_status = 'active'
        AND b.booking_type IN ('Two Way', 'One Way Back Home') 
        AND b.home_lat IS NOT NULL AND b.home_lng IS NOT NULL
        AND NOT EXISTS (SELECT 1 FROM public.child_absences ca WHERE ca.child_id = bc.child_id AND ca.date = target_date)
      ORDER BY 
        b.routeret_order ASC NULLS LAST, -- PRIMARY SORT: Afternoon Sequence (Explicit, not reverse)
        ST_Distance(b.schoolgeo_location, b.homegeo_location) ASC;

    SELECT EXISTS (SELECT 1 FROM _temp_return_stops_v5) INTO has_children;

    IF has_children THEN
        SELECT available_from, available_until INTO sched_start, sched_end
        FROM public.driver_schedules WHERE driver_id = driver_rec.driver_id AND LOWER(day_of_week) = target_day_name AND shift_type = 'Return from School(s)' LIMIT 1;

        INSERT INTO public.trips (driver_id, trip_date, status, trip_type, start_time, end_time)
        VALUES (driver_rec.driver_id, target_date, 'scheduled', 'Return from School(s)',
            CASE WHEN sched_start IS NOT NULL THEN (target_date + sched_start) ELSE NULL END,
            CASE WHEN sched_end IS NOT NULL THEN (target_date + sched_end) ELSE NULL END)
        RETURNING id INTO new_trip_id;

        stop_sequence := 1;
        -- Pickups (School) - Grouped
        FOR child_rec IN SELECT * FROM _temp_return_stops_v5 ORDER BY school_lat, school_lng LOOP
            INSERT INTO public.route_stops (trip_id, booking_id, child_id, stop_type, sequence_order, location_lat, location_lng, status)
            VALUES (new_trip_id, child_rec.booking_id, child_rec.child_id, 'pickup', stop_sequence, child_rec.school_lat, child_rec.school_lng, 'pending');
            stop_sequence := stop_sequence + 1;
        END LOOP;
        
        -- Dropoffs (Home) - SEQUENTIAL based on query order
        FOR child_rec IN SELECT * FROM _temp_return_stops_v5 LOOP
            INSERT INTO public.route_stops (trip_id, booking_id, child_id, stop_type, sequence_order, location_lat, location_lng, status)
            VALUES (new_trip_id, child_rec.booking_id, child_rec.child_id, 'dropoff', stop_sequence, child_rec.pickup_lat, child_rec.pickup_lng, 'pending');
            stop_sequence := stop_sequence + 1;
        END LOOP;
    END IF;
  END LOOP;
END;
$$;


ALTER FUNCTION "public"."generate_return_trips"("target_date" "date", "target_driver_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_driver_availability_settings"() RETURNS TABLE("auto_offline_after_trip" boolean, "auto_online_before_trip" boolean, "auto_online_minutes_before" integer, "availability_mode" "text", "is_online" boolean)
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    v_driver_id UUID := auth.uid();
BEGIN
    RETURN QUERY
    SELECT 
        d.auto_offline_after_trip,
        d.auto_online_before_trip,
        d.auto_online_minutes_before,
        d.availability_mode,
        COALESCE(dl.is_online, false) as is_online
    FROM public.drivers d
    LEFT JOIN public.driver_locations dl ON dl.driver_id = d.user_id
    WHERE d.user_id = v_driver_id;
END;
$$;


ALTER FUNCTION "public"."get_driver_availability_settings"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
  INSERT INTO public.users (
    id,
    role,
    full_name,
    phone,
    email,
    auth_provider,
    created_at
  )
  VALUES (
    NEW.id,
    ARRAY[]::text[], -- REQUIRED, non-null
    COALESCE(
      NEW.raw_user_meta_data->>'full_name',
      NEW.raw_user_meta_data->>'name',
      split_part(COALESCE(NEW.email, NEW.phone), '@', 1),
      'User'
    ),
    NEW.phone,
    NEW.email,
    COALESCE(NEW.raw_app_meta_data->>'provider', 'phone'),
    NEW.created_at
  )
  ON CONFLICT (id) DO NOTHING;

  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_new_user"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."notify_parent_on_ride_event"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
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
$$;


ALTER FUNCTION "public"."notify_parent_on_ride_event"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."process_stop"("stop_id_input" "uuid", "action" "text", "driver_lat" double precision DEFAULT NULL::double precision, "driver_lng" double precision DEFAULT NULL::double precision) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
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


ALTER FUNCTION "public"."process_stop"("stop_id_input" "uuid", "action" "text", "driver_lat" double precision, "driver_lng" double precision) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."refresh_driver_stats"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  REFRESH MATERIALIZED VIEW CONCURRENTLY public.driver_review_stats;
  RETURN NULL;
END;
$$;


ALTER FUNCTION "public"."refresh_driver_stats"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."save_trip_order_as_default"("trip_id_input" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  v_trip_type text;
BEGIN
  -- 1. Identify Trip Type
  SELECT trip_type INTO v_trip_type
  FROM public.trips
  WHERE id = trip_id_input;

  -- 2. CASE: Morning Trip (Save Pickup Order)
  IF v_trip_type = 'Go to School(s)' THEN
    UPDATE public.bookings b
    SET routego_order = rs.sequence_order
    FROM public.route_stops rs
    WHERE rs.booking_id = b.id
      AND rs.trip_id = trip_id_input
      AND rs.stop_type = 'pickup'; -- Save the sequence of picking up kids

  -- 3. CASE: Afternoon Trip (Save Drop-off Order)
  ELSIF v_trip_type = 'Return from School(s)' THEN
    UPDATE public.bookings b
    SET routeret_order = rs.sequence_order
    FROM public.route_stops rs
    WHERE rs.booking_id = b.id
      AND rs.trip_id = trip_id_input
      AND rs.stop_type = 'dropoff'; -- Save the sequence of dropping off kids
  END IF;
END;
$$;


ALTER FUNCTION "public"."save_trip_order_as_default"("trip_id_input" "uuid") OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."driver_covered_schools" (
    "driver_id" "uuid" NOT NULL,
    "school_id" "uuid" NOT NULL
);


ALTER TABLE "public"."driver_covered_schools" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."driver_service_areas" (
    "driver_id" "uuid" NOT NULL,
    "area_id" "uuid" NOT NULL
);


ALTER TABLE "public"."driver_service_areas" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."drivers" (
    "user_id" "uuid" NOT NULL,
    "vehicle_type" "text" NOT NULL,
    "vehicle_number" "text" NOT NULL,
    "service_radius_km" integer DEFAULT 10,
    "rating" numeric(2,1) DEFAULT 0,
    "is_verified" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "license_verified" boolean DEFAULT false,
    "insurance_verified" boolean DEFAULT false,
    "background_check_verified" boolean DEFAULT false,
    "price_base" numeric DEFAULT 10,
    "price_per_km" numeric DEFAULT 2,
    "price_monthly_two_way" numeric,
    "price_monthly_one_way" numeric,
    "price_daily" numeric,
    "currency" "text" DEFAULT 'OMR'::"text",
    "bio" "text",
    "is_active" boolean DEFAULT true,
    "experience_years" integer DEFAULT 0,
    "license_number" "text",
    "license_expiry" "date",
    "license_image_url" "text",
    "vehicle_capacity" integer DEFAULT 0,
    "mulkia_image_url" "text",
    "location_text" "text",
    "location_geo" "public"."geography"(Point,4326),
    "location_lat" double precision GENERATED ALWAYS AS ("public"."st_y"(("location_geo")::"public"."geometry")) STORED,
    "location_lng" double precision GENERATED ALWAYS AS ("public"."st_x"(("location_geo")::"public"."geometry")) STORED,
    "start_location_text" "text",
    "start_location_geo" "public"."geography"(Point,4326),
    "start_location_lat" double precision GENERATED ALWAYS AS ("public"."st_y"(("start_location_geo")::"public"."geometry")) STORED,
    "start_location_lng" double precision GENERATED ALWAYS AS ("public"."st_x"(("start_location_geo")::"public"."geometry")) STORED,
    "auto_offline_after_trip" boolean DEFAULT true,
    "auto_online_before_trip" boolean DEFAULT true,
    "auto_online_minutes_before" integer DEFAULT 15,
    "availability_mode" "text" DEFAULT 'smart'::"text",
    "last_location_update" timestamp with time zone DEFAULT "now"(),
    "location_accuracy_meters" double precision,
    "is_location_sharing_enabled" boolean DEFAULT true,
    "advs_photos" "text"[],
    CONSTRAINT "check_location_geo_valid" CHECK ((("location_geo" IS NULL) OR "public"."st_isvalid"(("location_geo")::"public"."geometry"))),
    CONSTRAINT "check_start_location_geo_valid" CHECK ((("start_location_geo" IS NULL) OR "public"."st_isvalid"(("start_location_geo")::"public"."geometry"))),
    CONSTRAINT "drivers_availability_mode_check" CHECK (("availability_mode" = ANY (ARRAY['smart'::"text", 'manual'::"text"])))
);


ALTER TABLE "public"."drivers" OWNER TO "postgres";


COMMENT ON COLUMN "public"."drivers"."location_geo" IS 'Current/active location of driver';



COMMENT ON COLUMN "public"."drivers"."start_location_geo" IS 'Starting point/home base of driver';



CREATE TABLE IF NOT EXISTS "public"."reviews" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "booking_id" "uuid",
    "parent_id" "uuid",
    "driver_id" "uuid",
    "rating" integer,
    "comment" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "reviews_rating_check" CHECK ((("rating" >= 1) AND ("rating" <= 5)))
);


ALTER TABLE "public"."reviews" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."users" (
    "id" "uuid" NOT NULL,
    "role" "text"[],
    "full_name" "text" NOT NULL,
    "phone" "text",
    "photo_url" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "gender" "text",
    "fcm_token" "text",
    "email" "text",
    "auth_provider" "text" DEFAULT 'phone'::"text",
    "updated_at" timestamp with time zone
);


ALTER TABLE "public"."users" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."verified_driver_ads" AS
 SELECT "d"."user_id" AS "driver_id",
    "u"."full_name" AS "name",
    "u"."phone",
    "u"."photo_url",
    "u"."gender",
    "d"."vehicle_type",
    "d"."price_monthly_two_way",
    "d"."price_monthly_one_way",
    "d"."rating",
    ( SELECT ("count"(*))::integer AS "count"
           FROM "public"."reviews" "r"
          WHERE ("r"."driver_id" = "d"."user_id")) AS "total_reviews",
    "d"."bio",
    "array_remove"("array_agg"(DISTINCT "dsa"."area_id"), NULL::"uuid") AS "service_area_ids",
    "array_remove"("array_agg"(DISTINCT "dcs"."school_id"), NULL::"uuid") AS "covered_school_ids"
   FROM ((("public"."drivers" "d"
     JOIN "public"."users" "u" ON (("d"."user_id" = "u"."id")))
     LEFT JOIN "public"."driver_service_areas" "dsa" ON (("d"."user_id" = "dsa"."driver_id")))
     LEFT JOIN "public"."driver_covered_schools" "dcs" ON (("d"."user_id" = "dcs"."driver_id")))
  WHERE (("d"."is_verified" = true) AND ("d"."is_active" = true))
  GROUP BY "d"."user_id", "u"."full_name", "u"."phone", "u"."photo_url", "u"."gender", "d"."vehicle_type", "d"."price_monthly_two_way", "d"."price_monthly_one_way", "d"."rating", "d"."bio";


ALTER VIEW "public"."verified_driver_ads" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."search_drivers"("filter_gender" "text" DEFAULT NULL::"text", "max_price" numeric DEFAULT NULL::numeric, "filter_area_id" "uuid" DEFAULT NULL::"uuid", "filter_school_id" "uuid" DEFAULT NULL::"uuid") RETURNS SETOF "public"."verified_driver_ads"
    LANGUAGE "sql"
    AS $$
  select *
  from public.verified_driver_ads
  where
    -- 1. Gender Filter
    (filter_gender is null or gender = filter_gender or filter_gender = 'All')
    
    -- 2. Price Filter
    and (max_price is null or price_monthly_two_way <= max_price)
    
    -- 3. Area Filter (Check if aggregated array contains the ID)
    and (filter_area_id is null or service_area_ids @> array[filter_area_id])
    
    -- 4. School Filter (Check if aggregated array contains the ID)
    and (filter_school_id is null or covered_school_ids @> array[filter_school_id]);
$$;


ALTER FUNCTION "public"."search_drivers"("filter_gender" "text", "max_price" numeric, "filter_area_id" "uuid", "filter_school_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."search_drivers"("filter_gender" "text" DEFAULT NULL::"text", "max_price" numeric DEFAULT 1000, "filter_area_id" "uuid" DEFAULT NULL::"uuid", "filter_school_id" "uuid" DEFAULT NULL::"uuid", "filter_online_only" boolean DEFAULT false) RETURNS TABLE("driver_id" "uuid", "name" "text", "photo_url" "text", "gender" "text", "vehicle_type" "text", "rating" numeric, "total_reviews" integer, "price_monthly_two_way" numeric, "price_monthly_one_way" numeric, "bio" "text", "phone" "text", "is_online" boolean)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        d.user_id as driver_id,
        u.full_name as name,
        u.photo_url,
        u.gender,
        d.vehicle_type,
        d.rating,
        -- Count reviews for this driver
        (SELECT COUNT(*)::INTEGER FROM public.reviews r WHERE r.driver_id = d.user_id) as total_reviews,
        d.price_monthly_two_way,
        d.price_monthly_one_way,
        d.bio,
        u.phone,
        COALESCE(l.is_online, false) as is_online
    FROM public.drivers d
    JOIN public.users u ON d.user_id = u.id
    LEFT JOIN public.driver_locations l ON d.user_id = l.driver_id
    WHERE
        d.is_active = true
        AND d.is_verified = true
        AND (filter_gender IS NULL OR u.gender = filter_gender)
        AND (max_price IS NULL OR d.price_monthly_two_way <= max_price)
        -- Check service areas if filter provided
        AND (
            filter_area_id IS NULL OR 
            EXISTS (
                SELECT 1 FROM public.driver_service_areas dsa 
                WHERE dsa.driver_id = d.user_id AND dsa.area_id = filter_area_id
            )
        )
        -- Check covered schools if filter provided
        AND (
            filter_school_id IS NULL OR 
            EXISTS (
                SELECT 1 FROM public.driver_covered_schools dcs 
                WHERE dcs.driver_id = d.user_id AND dcs.school_id = filter_school_id
            )
        )
        -- Check online status if filter is TRUE
        AND (
            filter_online_only IS FALSE OR 
            COALESCE(l.is_online, false) = TRUE
        );
END;
$$;


ALTER FUNCTION "public"."search_drivers"("filter_gender" "text", "max_price" numeric, "filter_area_id" "uuid", "filter_school_id" "uuid", "filter_online_only" boolean) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."search_drivers_for_parent_v2"("filter_gender" "text" DEFAULT NULL::"text", "filter_vehicle_type" "text" DEFAULT NULL::"text", "filter_min_rating" numeric DEFAULT NULL::numeric, "max_price_monthly_two_way" numeric DEFAULT NULL::numeric, "filter_area_id" "uuid" DEFAULT NULL::"uuid", "filter_school_id" "uuid" DEFAULT NULL::"uuid", "parent_location_lat" double precision DEFAULT NULL::double precision, "parent_location_lng" double precision DEFAULT NULL::double precision, "max_distance_km" integer DEFAULT NULL::integer, "filter_online_only" boolean DEFAULT false, "require_verified" boolean DEFAULT false, "page_limit" integer DEFAULT 20, "page_offset" integer DEFAULT 0) RETURNS TABLE("driver_id" "uuid", "name" "text", "photo_url" "text", "gender" "text", "bio" "text", "phone" "text", "vehicle_type" "text", "vehicle_capacity" integer, "rating" numeric, "total_reviews" integer, "price_monthly_two_way" numeric, "price_monthly_one_way" numeric, "price_daily" numeric, "currency" "text", "advs_photos" "text"[], "is_online" boolean, "is_verified" boolean, "distance_km" numeric, "covered_schools" "jsonb", "service_areas" "jsonb")
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    parent_geo geography;
BEGIN
    -- 1. Construct parent point once (with safety validation)
    IF parent_location_lat IS NOT NULL AND parent_location_lng IS NOT NULL THEN
        IF parent_location_lat BETWEEN -90 AND 90 
           AND parent_location_lng BETWEEN -180 AND 180 THEN
            parent_geo := ST_SetSRID(
                ST_MakePoint(parent_location_lng, parent_location_lat), 
                4326
            )::geography;
        ELSE
            RAISE WARNING 'Invalid coordinates provided: %, %', parent_location_lat, parent_location_lng;
        END IF;
    END IF;

    RETURN QUERY
    SELECT 
        d.user_id,
        u.full_name,
        u.photo_url,
        u.gender,
        d.bio,
        u.phone,
        
        d.vehicle_type,
        d.vehicle_capacity,
        d.rating,
        COALESCE(rs.total_reviews, 0),
        
        d.price_monthly_two_way,
        d.price_monthly_one_way,
        d.price_daily,
        d.currency,
        
        -- NEW: Return the photos array (handling NULLs)
        COALESCE(d.advs_photos, '{}'::text[]),
        
        COALESCE(l.is_online, false),
        d.is_verified,
        
        -- Distance Calculation
        CASE 
            WHEN parent_geo IS NOT NULL AND d.location_geo IS NOT NULL 
            THEN ROUND((ST_Distance(d.location_geo, parent_geo) / 1000)::numeric, 2)
            ELSE NULL 
        END,
        
        -- JSON Aggregations
        COALESCE(schools_data.json_agg, '[]'::jsonb),
        COALESCE(areas_data.json_agg, '[]'::jsonb)

    FROM public.drivers d
    INNER JOIN public.users u ON d.user_id = u.id
    LEFT JOIN public.driver_locations l ON d.user_id = l.driver_id
    
    -- Join Materialized View for fast stats
    LEFT JOIN public.driver_review_stats rs ON d.user_id = rs.driver_id
    
    -- LATERAL JOIN: Schools (Includes City Name)
    LEFT JOIN LATERAL (
        SELECT jsonb_agg(
            jsonb_build_object(
                'id', s.id, 
                'name', s.name,
                'address', s.address,
                'city_name', c.name
            )
        ) as json_agg
        FROM public.driver_covered_schools dcs
        JOIN public.schools s ON dcs.school_id = s.id
        LEFT JOIN public.cities c ON s.city_id = c.id
        WHERE dcs.driver_id = d.user_id
        LIMIT 50
    ) schools_data ON TRUE
    
    -- LATERAL JOIN: Areas
    LEFT JOIN LATERAL (
        SELECT jsonb_agg(
            jsonb_build_object(
                'id', a.id, 
                'name', a.name
            )
        ) as json_agg
        FROM public.driver_service_areas dsa
        JOIN public.areas a ON dsa.area_id = a.id
        WHERE dsa.driver_id = d.user_id
        LIMIT 50
    ) areas_data ON TRUE

    WHERE d.is_active = TRUE
      -- Basic Filters
      AND (require_verified IS FALSE OR d.is_verified = TRUE)
      AND (filter_min_rating IS NULL OR d.rating >= filter_min_rating)
      AND (filter_gender IS NULL OR u.gender = filter_gender)
      AND (filter_vehicle_type IS NULL OR d.vehicle_type = filter_vehicle_type)
      
      -- Price Filter (Only on Two Way)
      AND (max_price_monthly_two_way IS NULL OR d.price_monthly_two_way <= max_price_monthly_two_way)
      
      -- Availability
      AND (filter_online_only IS FALSE OR COALESCE(l.is_online, false) = TRUE)
      
      -- Location Filters
      AND (
          filter_area_id IS NULL 
          OR EXISTS (
              SELECT 1 FROM public.driver_service_areas dsa 
              WHERE dsa.driver_id = d.user_id 
              AND dsa.area_id = filter_area_id
          )
      )
      AND (
          filter_school_id IS NULL 
          OR EXISTS (
              SELECT 1 FROM public.driver_covered_schools dcs 
              WHERE dcs.driver_id = d.user_id 
              AND dcs.school_id = filter_school_id
          )
      )
      AND (
          max_distance_km IS NULL 
          OR parent_geo IS NULL 
          OR d.location_geo IS NULL
          OR ST_DWithin(d.location_geo, parent_geo, max_distance_km * 1000)
      )
      
    ORDER BY 
       COALESCE(l.is_online, false) DESC,
       CASE 
           WHEN parent_geo IS NOT NULL AND d.location_geo IS NOT NULL
           THEN d.location_geo <-> parent_geo 
           ELSE NULL
       END ASC NULLS LAST,
       d.rating DESC,
       d.created_at DESC
    
    LIMIT page_limit OFFSET page_offset;
END;
$$;


ALTER FUNCTION "public"."search_drivers_for_parent_v2"("filter_gender" "text", "filter_vehicle_type" "text", "filter_min_rating" numeric, "max_price_monthly_two_way" numeric, "filter_area_id" "uuid", "filter_school_id" "uuid", "parent_location_lat" double precision, "parent_location_lng" double precision, "max_distance_km" integer, "filter_online_only" boolean, "require_verified" boolean, "page_limit" integer, "page_offset" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."set_driver_current_location"("p_user_id" "uuid", "p_latitude" double precision, "p_longitude" double precision, "p_address" "text", "p_accuracy_meters" double precision DEFAULT NULL::double precision) RETURNS json
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    result JSON;
    previous_location GEOGRAPHY;
    distance_moved FLOAT;
BEGIN
    -- Validate coordinates
    IF p_latitude < -90 OR p_latitude > 90 THEN
        RAISE EXCEPTION 'Invalid latitude: must be between -90 and 90';
    END IF;
    
    IF p_longitude < -180 OR p_longitude > 180 THEN
        RAISE EXCEPTION 'Invalid longitude: must be between -180 and 180';
    END IF;
    
    -- Get previous location
    SELECT location_geo INTO previous_location
    FROM drivers
    WHERE user_id = p_user_id;
    
    -- Calculate distance moved
    IF previous_location IS NOT NULL THEN
        distance_moved := ST_Distance(
            previous_location,
            ST_SetSRID(ST_MakePoint(p_longitude, p_latitude), 4326)::geography
        );
    ELSE
        distance_moved := 0;
    END IF;
    
    -- Update location
    UPDATE drivers
    SET 
        location_geo = ST_SetSRID(ST_MakePoint(p_longitude, p_latitude), 4326)::geography,
        location_text = p_address,
        location_accuracy_meters = p_accuracy_meters,
        last_location_update = NOW()
    WHERE user_id = p_user_id
      AND is_location_sharing_enabled = true;
    
    -- Check if update happened
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Driver not found or location sharing is disabled';
    END IF;
    
    -- Return result
    SELECT json_build_object(
        'success', true,
        'user_id', p_user_id,
        'latitude', p_latitude,
        'longitude', p_longitude,
        'address', p_address,
        'distance_moved_meters', ROUND(distance_moved::numeric, 2),
        'accuracy_meters', p_accuracy_meters,
        'updated_at', NOW()
    ) INTO result;
    
    RETURN result;
END;
$$;


ALTER FUNCTION "public"."set_driver_current_location"("p_user_id" "uuid", "p_latitude" double precision, "p_longitude" double precision, "p_address" "text", "p_accuracy_meters" double precision) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."set_driver_online_status"("p_is_online" boolean) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    v_driver_id UUID := auth.uid();
BEGIN
    INSERT INTO public.driver_locations (driver_id, latitude, longitude, is_online, updated_at)
    VALUES (v_driver_id, 0, 0, p_is_online, NOW())
    ON CONFLICT (driver_id) 
    DO UPDATE SET is_online = p_is_online, updated_at = NOW();
END;
$$;


ALTER FUNCTION "public"."set_driver_online_status"("p_is_online" boolean) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."start_trip"("trip_id_input" "uuid", "driver_lat" double precision DEFAULT NULL::double precision, "driver_lng" double precision DEFAULT NULL::double precision) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
  UPDATE public.trips
  SET status = 'in_progress',
      start_time = COALESCE(start_time, NOW())
  WHERE id = trip_id_input;
END;
$$;


ALTER FUNCTION "public"."start_trip"("trip_id_input" "uuid", "driver_lat" double precision, "driver_lng" double precision) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."sync_stop_latlng_to_geo"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  -- Only update if lat/lng are provided
  IF NEW.location_lat IS NOT NULL AND NEW.location_lng IS NOT NULL THEN
    NEW.location_geo := ST_SetSRID(ST_MakePoint(NEW.location_lng, NEW.location_lat), 4326);
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."sync_stop_latlng_to_geo"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."toggle_saved_driver"("p_driver_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_user_id uuid;
  v_deleted int;
begin
  v_user_id := auth.uid();
  if v_user_id is null then
    raise exception 'Not authenticated';
  end if;

  -- Try delete first (fast path). If row existed, it is now NOT saved.
  delete from public.saved_drivers
  where parent_id = v_user_id
    and driver_id = p_driver_id
  returning 1 into v_deleted;

  if v_deleted = 1 then
    return false; -- now NOT saved
  end if;

  -- Not found -> insert (now saved)
  insert into public.saved_drivers (parent_id, driver_id)
  values (v_user_id, p_driver_id);

  return true; -- now saved
end;
$$;


ALTER FUNCTION "public"."toggle_saved_driver"("p_driver_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_driver_availability_settings"("p_auto_offline_after_trip" boolean DEFAULT NULL::boolean, "p_auto_online_before_trip" boolean DEFAULT NULL::boolean, "p_auto_online_minutes_before" integer DEFAULT NULL::integer, "p_availability_mode" "text" DEFAULT NULL::"text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    v_driver_id UUID := auth.uid();
BEGIN
    UPDATE public.drivers
    SET 
        auto_offline_after_trip = COALESCE(p_auto_offline_after_trip, auto_offline_after_trip),
        auto_online_before_trip = COALESCE(p_auto_online_before_trip, auto_online_before_trip),
        auto_online_minutes_before = COALESCE(p_auto_online_minutes_before, auto_online_minutes_before),
        availability_mode = COALESCE(p_availability_mode, availability_mode)
    WHERE user_id = v_driver_id;
END;
$$;


ALTER FUNCTION "public"."update_driver_availability_settings"("p_auto_offline_after_trip" boolean, "p_auto_online_before_trip" boolean, "p_auto_online_minutes_before" integer, "p_availability_mode" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_route_order"("updates" "jsonb") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  item jsonb;
  _stop_id UUID;
  _seq INT;
  _driver_id UUID;
BEGIN
  -- Get the current user ID
  _driver_id := auth.uid();

  -- Iterate through the updates
  FOR item IN SELECT * FROM jsonb_array_elements(updates)
  LOOP
    _stop_id := (item->>'id')::UUID;
    _seq := (item->>'sequence_order')::INT;

    -- Update the stop ONLY if it belongs to a trip assigned to this driver
    UPDATE public.route_stops rs
    SET sequence_order = _seq
    FROM public.trips t
    WHERE rs.trip_id = t.id
      AND rs.id = _stop_id
      AND t.driver_id = _driver_id; -- Security Check: Must belong to caller
  END LOOP;
END;
$$;


ALTER FUNCTION "public"."update_route_order"("updates" "jsonb") OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."areas" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "city_id" "uuid",
    "name" "text" NOT NULL,
    "boundary" "public"."geography"(Polygon,4326),
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL
);


ALTER TABLE "public"."areas" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."booking_children" (
    "booking_id" "uuid" NOT NULL,
    "child_id" "uuid" NOT NULL
);


ALTER TABLE "public"."booking_children" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."bookings" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "parent_id" "uuid" NOT NULL,
    "driver_id" "uuid" NOT NULL,
    "booking_type" "text" NOT NULL,
    "status" "text" DEFAULT 'pending'::"text",
    "hometxt_location" "text",
    "schooltxt_location" "text",
    "home_pickup_time" "text",
    "school_pickup_time" "text",
    "price" numeric,
    "notes" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "is_recurring" boolean DEFAULT false,
    "recurrence_pattern" "jsonb",
    "subscription_status" "text",
    "start_date" "date",
    "end_date" "date",
    "homegeo_location" "public"."geography"(Point,4326),
    "schoolgeo_location" "public"."geography"(Point,4326),
    "home_lat" double precision GENERATED ALWAYS AS ("public"."st_y"(("homegeo_location")::"public"."geometry")) STORED,
    "home_lng" double precision GENERATED ALWAYS AS ("public"."st_x"(("homegeo_location")::"public"."geometry")) STORED,
    "school_lat" double precision GENERATED ALWAYS AS ("public"."st_y"(("schoolgeo_location")::"public"."geometry")) STORED,
    "school_lng" double precision GENERATED ALWAYS AS ("public"."st_x"(("schoolgeo_location")::"public"."geometry")) STORED,
    "routego_order" integer DEFAULT 999,
    "routeret_order" integer DEFAULT 999,
    "is_monthly_subscription" boolean DEFAULT false,
    "student_id" "uuid",
    "school_id" "uuid",
    "recurring_days" "text"[],
    "payment_status" "text" DEFAULT 'unpaid'::"text",
    "cancellation_reason" "text",
    "cancelled_at" timestamp with time zone,
    "contract_start_date" "date",
    "contract_end_date" "date",
    CONSTRAINT "bookings_booking_type_check" CHECK (("booking_type" = ANY (ARRAY['Two Way'::"text", 'One Way to School'::"text", 'One Way Back Home'::"text", 'Other'::"text"]))),
    CONSTRAINT "bookings_status_check" CHECK (("status" = ANY (ARRAY['pending'::"text", 'accepted'::"text", 'rejected'::"text", 'completed'::"text", 'cancelled'::"text"]))),
    CONSTRAINT "bookings_subscription_status_check" CHECK (("subscription_status" = ANY (ARRAY['active'::"text", 'paused'::"text", 'cancelled'::"text", 'expired'::"text"])))
);


ALTER TABLE "public"."bookings" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."child_absences" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "child_id" "uuid" NOT NULL,
    "date" "date" NOT NULL,
    "reason" "text",
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."child_absences" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."children" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "parent_id" "uuid",
    "name" "text" NOT NULL,
    "school_name" "text",
    "grade" "text",
    "emergency_contact" "text",
    "photo_url" "text",
    "date_of_birth" "date",
    "gender" "text",
    "medical_conditions" "text",
    "notes" "text",
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."children" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."cities" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "state" "text",
    "country" "text",
    "location" "public"."geography"(Point,4326),
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL
);


ALTER TABLE "public"."cities" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."driver_availability" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "driver_id" "uuid",
    "day_of_week" integer,
    "start_time" time without time zone NOT NULL,
    "end_time" time without time zone NOT NULL,
    CONSTRAINT "driver_availability_day_of_week_check" CHECK ((("day_of_week" >= 0) AND ("day_of_week" <= 6)))
);


ALTER TABLE "public"."driver_availability" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."driver_documents" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "driver_id" "uuid",
    "document_type" "text" NOT NULL,
    "file_url" "text" NOT NULL,
    "verified" boolean DEFAULT false,
    "uploaded_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."driver_documents" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."driver_locations" (
    "driver_id" "uuid" NOT NULL,
    "latitude" double precision NOT NULL,
    "longitude" double precision NOT NULL,
    "heading" double precision DEFAULT 0.0,
    "speed" double precision DEFAULT 0.0,
    "trip_type" "text",
    "is_online" boolean DEFAULT false,
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "current_trip_id" "uuid",
    CONSTRAINT "driver_locations_trip_type_check" CHECK (("trip_type" = ANY (ARRAY['pickup'::"text", 'dropoff'::"text", 'idle'::"text"])))
);


ALTER TABLE "public"."driver_locations" OWNER TO "postgres";


CREATE MATERIALIZED VIEW "public"."driver_review_stats" AS
 SELECT "driver_id",
    ("count"(*))::integer AS "total_reviews",
    ("avg"("rating"))::numeric(2,1) AS "avg_rating",
    "max"("created_at") AS "last_review_date"
   FROM "public"."reviews"
  GROUP BY "driver_id"
  WITH NO DATA;


ALTER MATERIALIZED VIEW "public"."driver_review_stats" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."driver_schedules" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "driver_id" "uuid" NOT NULL,
    "day_of_week" "text" NOT NULL,
    "shift_type" "text" NOT NULL,
    "available_from" time without time zone NOT NULL,
    "available_until" time without time zone NOT NULL,
    "max_capacity" integer DEFAULT 8,
    "is_active" boolean DEFAULT true,
    CONSTRAINT "driver_schedules_day_check" CHECK (("day_of_week" = ANY (ARRAY['saturday'::"text", 'sunday'::"text", 'monday'::"text", 'tuesday'::"text", 'wednesday'::"text", 'thursday'::"text", 'friday'::"text"]))),
    CONSTRAINT "driver_schedules_shift_check" CHECK (("shift_type" = ANY (ARRAY['Go to School(s)'::"text", 'Return from School(s)'::"text", 'custom'::"text"]))),
    CONSTRAINT "driver_schedules_shift_type_check" CHECK (("shift_type" = ANY (ARRAY['Go to School(s)'::"text", 'Return from School(s)'::"text", 'custom'::"text"])))
);


ALTER TABLE "public"."driver_schedules" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."messages" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "sender_id" "uuid" NOT NULL,
    "receiver_id" "uuid" NOT NULL,
    "content" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "is_read" boolean DEFAULT false
);


ALTER TABLE "public"."messages" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."payments" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "booking_id" "uuid",
    "payer_id" "uuid",
    "amount" numeric NOT NULL,
    "currency" "text" DEFAULT 'OMR'::"text",
    "payment_method" "text",
    "payment_status" "text",
    "transaction_ref" "text",
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    CONSTRAINT "payments_payment_method_check" CHECK (("payment_method" = ANY (ARRAY['card'::"text", 'cash'::"text", 'wallet'::"text"]))),
    CONSTRAINT "payments_payment_status_check" CHECK (("payment_status" = ANY (ARRAY['pending'::"text", 'completed'::"text", 'failed'::"text", 'refunded'::"text"])))
);


ALTER TABLE "public"."payments" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."ride_events" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "booking_id" "uuid",
    "child_id" "uuid",
    "driver_id" "uuid",
    "parent_id" "uuid",
    "event_type" "text" NOT NULL,
    "event_data" "jsonb" DEFAULT '{}'::"jsonb",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "read_at" timestamp with time zone,
    CONSTRAINT "ride_events_event_type_check" CHECK (("event_type" = ANY (ARRAY['approaching'::"text", 'picked_up'::"text", 'dropped_off'::"text"])))
);


ALTER TABLE "public"."ride_events" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."route_stops" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "trip_id" "uuid" NOT NULL,
    "booking_id" "uuid" NOT NULL,
    "child_id" "uuid" NOT NULL,
    "stop_type" "text",
    "sequence_order" integer NOT NULL,
    "status" "text" DEFAULT 'pending'::"text",
    "arrived_at" timestamp with time zone,
    "completed_at" timestamp with time zone,
    "location_lat" double precision,
    "location_lng" double precision,
    "location_geo" "public"."geography"(Point,4326),
    CONSTRAINT "route_stops_status_check" CHECK (("status" = ANY (ARRAY['pending'::"text", 'arrived'::"text", 'completed'::"text", 'skipped'::"text"]))),
    CONSTRAINT "route_stops_stop_type_check" CHECK (("stop_type" = ANY (ARRAY['pickup'::"text", 'dropoff'::"text"])))
);


ALTER TABLE "public"."route_stops" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."saved_drivers" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "parent_id" "uuid",
    "driver_id" "uuid",
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL
);


ALTER TABLE "public"."saved_drivers" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."schools" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "address" "text",
    "location" "public"."geography"(Point,4326),
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "city_id" "uuid"
);


ALTER TABLE "public"."schools" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."transport_requests" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "parent_id" "uuid" NOT NULL,
    "child_id" "uuid",
    "child_name" "text" NOT NULL,
    "child_age" integer,
    "child_gender" "text",
    "child_grade" "text",
    "school_name" "text",
    "hometxt_location" "text",
    "schooltxt_location" "text",
    "homegeo_location" "public"."geography"(Point,4326),
    "schoolgeo_location" "public"."geography"(Point,4326),
    "home_lat" double precision GENERATED ALWAYS AS ("public"."st_y"(("homegeo_location")::"public"."geometry")) STORED,
    "home_lng" double precision GENERATED ALWAYS AS ("public"."st_x"(("homegeo_location")::"public"."geometry")) STORED,
    "school_lat" double precision GENERATED ALWAYS AS ("public"."st_y"(("schoolgeo_location")::"public"."geometry")) STORED,
    "school_lng" double precision GENERATED ALWAYS AS ("public"."st_x"(("schoolgeo_location")::"public"."geometry")) STORED,
    "booking_type" "text" DEFAULT 'Two Way'::"text",
    "notes" "text",
    "status" "text" DEFAULT 'open'::"text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "transport_requests_booking_type_check" CHECK (("booking_type" = ANY (ARRAY['Two Way'::"text", 'One Way to School'::"text", 'One Way Back Home'::"text", 'Other'::"text"]))),
    CONSTRAINT "transport_requests_status_check" CHECK (("status" = ANY (ARRAY['open'::"text", 'closed'::"text", 'cancelled'::"text"])))
);


ALTER TABLE "public"."transport_requests" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."trips" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "driver_id" "uuid" NOT NULL,
    "trip_type" "text",
    "trip_date" "date" DEFAULT CURRENT_DATE NOT NULL,
    "status" "text" DEFAULT 'scheduled'::"text",
    "start_time" timestamp with time zone,
    "end_time" timestamp with time zone,
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "current_location" "public"."geography"(Point,4326),
    "total_distance_km" numeric,
    "estimated_duration_minutes" integer,
    "route_polyline" "text",
    CONSTRAINT "trips_status_check" CHECK (("status" = ANY (ARRAY['scheduled'::"text", 'in_progress'::"text", 'completed'::"text", 'cancelled'::"text"]))),
    CONSTRAINT "trips_trip_type_check" CHECK (("trip_type" = ANY (ARRAY['Go to School(s)'::"text", 'Return from School(s)'::"text", 'custom'::"text"])))
);


ALTER TABLE "public"."trips" OWNER TO "postgres";


ALTER TABLE ONLY "public"."areas"
    ADD CONSTRAINT "areas_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."booking_children"
    ADD CONSTRAINT "booking_children_pkey" PRIMARY KEY ("booking_id", "child_id");



ALTER TABLE ONLY "public"."bookings"
    ADD CONSTRAINT "bookings_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."child_absences"
    ADD CONSTRAINT "child_absences_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."children"
    ADD CONSTRAINT "children_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."cities"
    ADD CONSTRAINT "cities_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."driver_availability"
    ADD CONSTRAINT "driver_availability_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."driver_covered_schools"
    ADD CONSTRAINT "driver_covered_schools_pkey" PRIMARY KEY ("driver_id", "school_id");



ALTER TABLE ONLY "public"."driver_documents"
    ADD CONSTRAINT "driver_documents_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."driver_locations"
    ADD CONSTRAINT "driver_locations_driver_id_unique" UNIQUE ("driver_id");



ALTER TABLE ONLY "public"."driver_locations"
    ADD CONSTRAINT "driver_locations_pkey" PRIMARY KEY ("driver_id");



ALTER TABLE ONLY "public"."driver_schedules"
    ADD CONSTRAINT "driver_schedules_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."driver_service_areas"
    ADD CONSTRAINT "driver_service_areas_pkey" PRIMARY KEY ("driver_id", "area_id");



ALTER TABLE ONLY "public"."drivers"
    ADD CONSTRAINT "drivers_pkey" PRIMARY KEY ("user_id");



ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."payments"
    ADD CONSTRAINT "payments_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."reviews"
    ADD CONSTRAINT "reviews_booking_id_key" UNIQUE ("booking_id");



ALTER TABLE ONLY "public"."reviews"
    ADD CONSTRAINT "reviews_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."ride_events"
    ADD CONSTRAINT "ride_events_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."route_stops"
    ADD CONSTRAINT "route_stops_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."saved_drivers"
    ADD CONSTRAINT "saved_drivers_parent_id_driver_id_key" UNIQUE ("parent_id", "driver_id");



ALTER TABLE ONLY "public"."saved_drivers"
    ADD CONSTRAINT "saved_drivers_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."schools"
    ADD CONSTRAINT "schools_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."transport_requests"
    ADD CONSTRAINT "transport_requests_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."trips"
    ADD CONSTRAINT "trips_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."child_absences"
    ADD CONSTRAINT "unique_child_absence_per_day" UNIQUE ("child_id", "date");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_phone_key" UNIQUE ("phone");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_pkey" PRIMARY KEY ("id");



CREATE INDEX "idx_booking_children_booking_id" ON "public"."booking_children" USING "btree" ("booking_id");



CREATE INDEX "idx_booking_children_child" ON "public"."booking_children" USING "btree" ("child_id");



CREATE INDEX "idx_booking_children_child_id" ON "public"."booking_children" USING "btree" ("child_id");



CREATE INDEX "idx_bookings_date_range" ON "public"."bookings" USING "btree" ("start_date", "end_date") WHERE ("is_recurring" = true);



CREATE INDEX "idx_bookings_driver_status" ON "public"."bookings" USING "btree" ("driver_id", "status") WHERE ("status" = ANY (ARRAY['pending'::"text", 'accepted'::"text"]));



CREATE INDEX "idx_bookings_driver_status_created" ON "public"."bookings" USING "btree" ("driver_id", "status", "created_at" DESC);



CREATE INDEX "idx_bookings_generator_lookup" ON "public"."bookings" USING "btree" ("driver_id", "subscription_status", "booking_type");



CREATE INDEX "idx_bookings_home_geo" ON "public"."bookings" USING "gist" ("homegeo_location");



CREATE INDEX "idx_bookings_monthly_subscription_true" ON "public"."bookings" USING "btree" ("parent_id", "contract_start_date", "contract_end_date") WHERE ("is_monthly_subscription" = true);



CREATE INDEX "idx_bookings_parent_created_at" ON "public"."bookings" USING "btree" ("parent_id", "created_at" DESC);



CREATE INDEX "idx_bookings_recurring_days_gin" ON "public"."bookings" USING "gin" ("recurring_days") WHERE ("is_recurring" = true);



CREATE INDEX "idx_bookings_recurring_true" ON "public"."bookings" USING "btree" ("parent_id", "created_at" DESC) WHERE ("is_recurring" = true);



CREATE INDEX "idx_bookings_school_geo" ON "public"."bookings" USING "gist" ("schoolgeo_location");



CREATE INDEX "idx_driver_covered_schools_lookup" ON "public"."driver_covered_schools" USING "btree" ("driver_id", "school_id");



CREATE INDEX "idx_driver_locations_driver_id" ON "public"."driver_locations" USING "btree" ("driver_id");



CREATE INDEX "idx_driver_locations_online" ON "public"."driver_locations" USING "btree" ("driver_id", "is_online") WHERE ("is_online" = true);



CREATE UNIQUE INDEX "idx_driver_review_stats_id" ON "public"."driver_review_stats" USING "btree" ("driver_id");



CREATE INDEX "idx_driver_schedules_lookup" ON "public"."driver_schedules" USING "btree" ("driver_id", "day_of_week", "is_active");



CREATE INDEX "idx_driver_service_areas_lookup" ON "public"."driver_service_areas" USING "btree" ("driver_id", "area_id");



CREATE INDEX "idx_drivers_location_geo" ON "public"."drivers" USING "gist" ("location_geo");



CREATE INDEX "idx_drivers_price" ON "public"."drivers" USING "btree" ("price_monthly_two_way");



CREATE INDEX "idx_drivers_rating" ON "public"."drivers" USING "btree" ("rating" DESC);



CREATE INDEX "idx_drivers_search_composite" ON "public"."drivers" USING "btree" ("is_verified", "rating" DESC, "vehicle_type") WHERE ("is_active" = true);



CREATE INDEX "idx_drivers_start_location_geo" ON "public"."drivers" USING "gist" ("start_location_geo");



CREATE INDEX "idx_ride_events_booking" ON "public"."ride_events" USING "btree" ("booking_id");



CREATE INDEX "idx_ride_events_created" ON "public"."ride_events" USING "btree" ("created_at" DESC);



CREATE INDEX "idx_ride_events_parent" ON "public"."ride_events" USING "btree" ("parent_id");



CREATE INDEX "idx_ride_events_read_at" ON "public"."ride_events" USING "btree" ("read_at");



CREATE INDEX "idx_route_stops_geo" ON "public"."route_stops" USING "gist" ("location_geo");



CREATE INDEX "idx_route_stops_trip_id" ON "public"."route_stops" USING "btree" ("trip_id");



CREATE INDEX "idx_schools_city_id" ON "public"."schools" USING "btree" ("city_id");



CREATE INDEX "idx_trips_driver_date" ON "public"."trips" USING "btree" ("driver_id", "trip_date");



CREATE INDEX "idx_users_email" ON "public"."users" USING "btree" ("email");



CREATE INDEX "idx_users_roles" ON "public"."users" USING "gin" ("role");



CREATE UNIQUE INDEX "saved_drivers_parent_driver_uniq" ON "public"."saved_drivers" USING "btree" ("parent_id", "driver_id");



CREATE OR REPLACE TRIGGER "on_review_change" AFTER INSERT OR DELETE OR UPDATE ON "public"."reviews" FOR EACH STATEMENT EXECUTE FUNCTION "public"."refresh_driver_stats"();



CREATE OR REPLACE TRIGGER "on_ride_event_notify" AFTER INSERT ON "public"."ride_events" FOR EACH ROW EXECUTE FUNCTION "public"."notify_parent_on_ride_event"();



CREATE OR REPLACE TRIGGER "trg_check_duplicate_child_booking" BEFORE INSERT OR UPDATE ON "public"."booking_children" FOR EACH ROW EXECUTE FUNCTION "public"."check_duplicate_child_booking"();



CREATE OR REPLACE TRIGGER "trigger_route_stops_geo_sync" BEFORE INSERT OR UPDATE ON "public"."route_stops" FOR EACH ROW EXECUTE FUNCTION "public"."sync_stop_latlng_to_geo"();



ALTER TABLE ONLY "public"."areas"
    ADD CONSTRAINT "areas_city_id_fkey" FOREIGN KEY ("city_id") REFERENCES "public"."cities"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."booking_children"
    ADD CONSTRAINT "booking_children_booking_id_fkey" FOREIGN KEY ("booking_id") REFERENCES "public"."bookings"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."booking_children"
    ADD CONSTRAINT "booking_children_child_id_fkey" FOREIGN KEY ("child_id") REFERENCES "public"."children"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."bookings"
    ADD CONSTRAINT "bookings_driver_id_fkey" FOREIGN KEY ("driver_id") REFERENCES "public"."drivers"("user_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."bookings"
    ADD CONSTRAINT "bookings_parent_id_fkey" FOREIGN KEY ("parent_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."children"
    ADD CONSTRAINT "children_parent_id_fkey" FOREIGN KEY ("parent_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."driver_availability"
    ADD CONSTRAINT "driver_availability_driver_id_fkey" FOREIGN KEY ("driver_id") REFERENCES "public"."drivers"("user_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."driver_covered_schools"
    ADD CONSTRAINT "driver_covered_schools_driver_id_fkey" FOREIGN KEY ("driver_id") REFERENCES "public"."drivers"("user_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."driver_covered_schools"
    ADD CONSTRAINT "driver_covered_schools_school_id_fkey" FOREIGN KEY ("school_id") REFERENCES "public"."schools"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."driver_documents"
    ADD CONSTRAINT "driver_documents_driver_id_fkey" FOREIGN KEY ("driver_id") REFERENCES "public"."drivers"("user_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."driver_locations"
    ADD CONSTRAINT "driver_locations_driver_id_fkey" FOREIGN KEY ("driver_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."driver_schedules"
    ADD CONSTRAINT "driver_schedules_driver_id_fkey" FOREIGN KEY ("driver_id") REFERENCES "public"."drivers"("user_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."driver_service_areas"
    ADD CONSTRAINT "driver_service_areas_area_id_fkey" FOREIGN KEY ("area_id") REFERENCES "public"."areas"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."driver_service_areas"
    ADD CONSTRAINT "driver_service_areas_driver_id_fkey" FOREIGN KEY ("driver_id") REFERENCES "public"."drivers"("user_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."drivers"
    ADD CONSTRAINT "drivers_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_receiver_id_fkey" FOREIGN KEY ("receiver_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_sender_id_fkey" FOREIGN KEY ("sender_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."payments"
    ADD CONSTRAINT "payments_payer_id_fkey" FOREIGN KEY ("payer_id") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."reviews"
    ADD CONSTRAINT "reviews_driver_id_fkey" FOREIGN KEY ("driver_id") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."reviews"
    ADD CONSTRAINT "reviews_parent_id_fkey" FOREIGN KEY ("parent_id") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."ride_events"
    ADD CONSTRAINT "ride_events_driver_id_fkey" FOREIGN KEY ("driver_id") REFERENCES "public"."drivers"("user_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."ride_events"
    ADD CONSTRAINT "ride_events_parent_id_fkey" FOREIGN KEY ("parent_id") REFERENCES "public"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."route_stops"
    ADD CONSTRAINT "route_stops_booking_id_fkey" FOREIGN KEY ("booking_id") REFERENCES "public"."bookings"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."route_stops"
    ADD CONSTRAINT "route_stops_child_id_fkey" FOREIGN KEY ("child_id") REFERENCES "public"."children"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."route_stops"
    ADD CONSTRAINT "route_stops_trip_id_fkey" FOREIGN KEY ("trip_id") REFERENCES "public"."trips"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."saved_drivers"
    ADD CONSTRAINT "saved_drivers_driver_id_fkey" FOREIGN KEY ("driver_id") REFERENCES "public"."drivers"("user_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."saved_drivers"
    ADD CONSTRAINT "saved_drivers_parent_id_fkey" FOREIGN KEY ("parent_id") REFERENCES "public"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."schools"
    ADD CONSTRAINT "schools_city_id_fkey" FOREIGN KEY ("city_id") REFERENCES "public"."cities"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."trips"
    ADD CONSTRAINT "trips_driver_id_fkey" FOREIGN KEY ("driver_id") REFERENCES "public"."drivers"("user_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;



CREATE POLICY "Allow insert from auth trigger" ON "public"."users" FOR INSERT WITH CHECK (true);



CREATE POLICY "Allow trigger insert" ON "public"."users" FOR INSERT WITH CHECK (true);



CREATE POLICY "Authenticated users view drivers" ON "public"."drivers" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Driver can update own location" ON "public"."driver_locations" FOR UPDATE USING (("driver_id" = "auth"."uid"()));



CREATE POLICY "Driver can upsert own location" ON "public"."driver_locations" FOR INSERT WITH CHECK (("driver_id" = "auth"."uid"()));



CREATE POLICY "Driver inserts own driver profile" ON "public"."drivers" FOR INSERT TO "authenticated" WITH CHECK (("user_id" = "auth"."uid"()));



CREATE POLICY "Driver manages own documents" ON "public"."driver_documents" USING (("driver_id" = "auth"."uid"())) WITH CHECK (("driver_id" = "auth"."uid"()));



CREATE POLICY "Driver updates own profile" ON "public"."drivers" FOR UPDATE TO "authenticated" USING (("user_id" = "auth"."uid"()));



CREATE POLICY "Drivers can insert ride events" ON "public"."ride_events" FOR INSERT TO "authenticated" WITH CHECK (("driver_id" IN ( SELECT "ride_events"."id"
   FROM "public"."drivers"
  WHERE ("drivers"."user_id" = "auth"."uid"()))));



CREATE POLICY "Drivers can manage their own location" ON "public"."driver_locations" USING (("auth"."uid"() = "driver_id")) WITH CHECK (("auth"."uid"() = "driver_id"));



CREATE POLICY "Drivers can read their own trips" ON "public"."trips" FOR SELECT USING (("driver_id" = "auth"."uid"()));



CREATE POLICY "Drivers can select their own trip stops" ON "public"."route_stops" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."trips"
  WHERE (("trips"."id" = "route_stops"."trip_id") AND ("trips"."driver_id" = "auth"."uid"())))));



CREATE POLICY "Drivers can update assigned bookings" ON "public"."bookings" FOR UPDATE TO "authenticated" USING (("auth"."uid"() = "driver_id")) WITH CHECK (("auth"."uid"() = "driver_id"));



CREATE POLICY "Drivers can update own location" ON "public"."driver_locations" USING (("auth"."uid"() = "driver_id")) WITH CHECK (("auth"."uid"() = "driver_id"));



CREATE POLICY "Drivers can update their own trip stops" ON "public"."route_stops" FOR UPDATE USING ((EXISTS ( SELECT 1
   FROM "public"."trips"
  WHERE (("trips"."id" = "route_stops"."trip_id") AND ("trips"."driver_id" = "auth"."uid"()))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."trips"
  WHERE (("trips"."id" = "route_stops"."trip_id") AND ("trips"."driver_id" = "auth"."uid"())))));



CREATE POLICY "Drivers can update their own trips" ON "public"."trips" FOR UPDATE USING (("driver_id" = "auth"."uid"())) WITH CHECK (("driver_id" = "auth"."uid"()));



CREATE POLICY "Drivers can view assigned bookings" ON "public"."bookings" FOR SELECT USING (("auth"."uid"() = "driver_id"));



CREATE POLICY "Drivers can view assigned children" ON "public"."children" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM ("public"."booking_children" "bc"
     JOIN "public"."bookings" "b" ON (("bc"."booking_id" = "b"."id")))
  WHERE (("bc"."child_id" = "children"."id") AND ("b"."driver_id" = "auth"."uid"())))));



CREATE POLICY "Drivers can view booking links" ON "public"."booking_children" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."bookings" "b"
  WHERE (("b"."id" = "booking_children"."booking_id") AND ("b"."driver_id" = "auth"."uid"())))));



CREATE POLICY "Drivers can view transport requests" ON "public"."transport_requests" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."users" "u"
  WHERE (("u"."id" = "auth"."uid"()) AND ('driver'::"text" = ANY ("u"."role"))))));



CREATE POLICY "Enable delete for users" ON "public"."saved_drivers" FOR DELETE USING (("auth"."uid"() = "parent_id"));



CREATE POLICY "Enable insert for authenticated users" ON "public"."saved_drivers" FOR INSERT WITH CHECK (("auth"."uid"() = "parent_id"));



CREATE POLICY "Enable read access for all users" ON "public"."areas" FOR SELECT USING (true);



CREATE POLICY "Enable read access for all users" ON "public"."cities" FOR SELECT USING (true);



CREATE POLICY "Enable read access for all users" ON "public"."driver_covered_schools" FOR SELECT USING (true);



CREATE POLICY "Enable read access for all users" ON "public"."driver_service_areas" FOR SELECT USING (true);



CREATE POLICY "Enable read access for all users" ON "public"."saved_drivers" FOR SELECT USING (true);



CREATE POLICY "Enable read access for all users" ON "public"."schools" FOR SELECT USING (true);



CREATE POLICY "Enable read access for own payments" ON "public"."payments" FOR SELECT USING (("auth"."uid"() = "payer_id"));



CREATE POLICY "Parent writes review" ON "public"."reviews" FOR INSERT TO "authenticated" WITH CHECK (("parent_id" = "auth"."uid"()));



CREATE POLICY "Parents can manage booking links" ON "public"."booking_children" USING ((EXISTS ( SELECT 1
   FROM "public"."bookings" "b"
  WHERE (("b"."id" = "booking_children"."booking_id") AND ("b"."parent_id" = "auth"."uid"())))));



CREATE POLICY "Parents can manage own bookings" ON "public"."bookings" USING (("auth"."uid"() = "parent_id"));



CREATE POLICY "Parents can manage own children" ON "public"."children" USING (("auth"."uid"() = "parent_id"));



CREATE POLICY "Parents can manage own transport requests" ON "public"."transport_requests" USING (("auth"."uid"() = "parent_id")) WITH CHECK (("auth"."uid"() = "parent_id"));



CREATE POLICY "Parents can update their ride events" ON "public"."ride_events" FOR UPDATE TO "authenticated" USING (("parent_id" = "auth"."uid"())) WITH CHECK (("parent_id" = "auth"."uid"()));



CREATE POLICY "Parents can view relevant drivers" ON "public"."driver_locations" FOR SELECT USING ((("is_online" = true) OR (EXISTS ( SELECT 1
   FROM "public"."bookings"
  WHERE (("bookings"."driver_id" = "driver_locations"."driver_id") AND ("bookings"."parent_id" = "auth"."uid"()) AND ("bookings"."status" = 'accepted'::"text"))))));



CREATE POLICY "Parents can view their ride events" ON "public"."ride_events" FOR SELECT TO "authenticated" USING (("parent_id" = "auth"."uid"()));



CREATE POLICY "Public Usage" ON "public"."users" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Public reads reviews" ON "public"."reviews" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Users can read own profile" ON "public"."users" FOR SELECT USING (("id" = "auth"."uid"()));



CREATE POLICY "Users can send messages" ON "public"."messages" FOR INSERT WITH CHECK (("auth"."uid"() = "sender_id"));



CREATE POLICY "Users can view their own messages" ON "public"."messages" FOR SELECT USING ((("auth"."uid"() = "sender_id") OR ("auth"."uid"() = "receiver_id")));



CREATE POLICY "Users insert own profile" ON "public"."users" FOR INSERT TO "authenticated" WITH CHECK (("id" = "auth"."uid"()));



CREATE POLICY "Users read own profile" ON "public"."users" FOR SELECT USING (("auth"."uid"() = "id"));



CREATE POLICY "Users update own profile" ON "public"."users" FOR UPDATE TO "authenticated" USING (("id" = "auth"."uid"()));



ALTER TABLE "public"."areas" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."booking_children" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."bookings" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."children" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."cities" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."driver_availability" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."driver_covered_schools" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."driver_documents" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."driver_locations" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."driver_service_areas" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."drivers" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."messages" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."payments" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."reviews" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."ride_events" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."route_stops" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."saved_drivers" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."schools" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."transport_requests" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."trips" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."users" ENABLE ROW LEVEL SECURITY;


GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";



GRANT ALL ON FUNCTION "public"."check_auto_online"() TO "anon";
GRANT ALL ON FUNCTION "public"."check_auto_online"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_auto_online"() TO "service_role";



GRANT ALL ON FUNCTION "public"."check_duplicate_child_booking"() TO "anon";
GRANT ALL ON FUNCTION "public"."check_duplicate_child_booking"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_duplicate_child_booking"() TO "service_role";



GRANT ALL ON FUNCTION "public"."complete_trip"("trip_id_input" "uuid", "driver_lat" double precision, "driver_lng" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."complete_trip"("trip_id_input" "uuid", "driver_lat" double precision, "driver_lng" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."complete_trip"("trip_id_input" "uuid", "driver_lat" double precision, "driver_lng" double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."complete_trip_with_auto_offline"("trip_id_input" "uuid", "driver_lat" double precision, "driver_lng" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."complete_trip_with_auto_offline"("trip_id_input" "uuid", "driver_lat" double precision, "driver_lng" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."complete_trip_with_auto_offline"("trip_id_input" "uuid", "driver_lat" double precision, "driver_lng" double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."generate_go_trips"("target_date" "date", "target_driver_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."generate_go_trips"("target_date" "date", "target_driver_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."generate_go_trips"("target_date" "date", "target_driver_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."generate_return_trips"("target_date" "date", "target_driver_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."generate_return_trips"("target_date" "date", "target_driver_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."generate_return_trips"("target_date" "date", "target_driver_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_driver_availability_settings"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_driver_availability_settings"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_driver_availability_settings"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "service_role";



GRANT ALL ON FUNCTION "public"."notify_parent_on_ride_event"() TO "anon";
GRANT ALL ON FUNCTION "public"."notify_parent_on_ride_event"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."notify_parent_on_ride_event"() TO "service_role";



GRANT ALL ON FUNCTION "public"."process_stop"("stop_id_input" "uuid", "action" "text", "driver_lat" double precision, "driver_lng" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."process_stop"("stop_id_input" "uuid", "action" "text", "driver_lat" double precision, "driver_lng" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."process_stop"("stop_id_input" "uuid", "action" "text", "driver_lat" double precision, "driver_lng" double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."refresh_driver_stats"() TO "anon";
GRANT ALL ON FUNCTION "public"."refresh_driver_stats"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."refresh_driver_stats"() TO "service_role";



GRANT ALL ON FUNCTION "public"."save_trip_order_as_default"("trip_id_input" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."save_trip_order_as_default"("trip_id_input" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."save_trip_order_as_default"("trip_id_input" "uuid") TO "service_role";



GRANT ALL ON TABLE "public"."driver_covered_schools" TO "anon";
GRANT ALL ON TABLE "public"."driver_covered_schools" TO "authenticated";
GRANT ALL ON TABLE "public"."driver_covered_schools" TO "service_role";



GRANT ALL ON TABLE "public"."driver_service_areas" TO "anon";
GRANT ALL ON TABLE "public"."driver_service_areas" TO "authenticated";
GRANT ALL ON TABLE "public"."driver_service_areas" TO "service_role";



GRANT ALL ON TABLE "public"."drivers" TO "anon";
GRANT ALL ON TABLE "public"."drivers" TO "authenticated";
GRANT ALL ON TABLE "public"."drivers" TO "service_role";



GRANT ALL ON TABLE "public"."reviews" TO "anon";
GRANT ALL ON TABLE "public"."reviews" TO "authenticated";
GRANT ALL ON TABLE "public"."reviews" TO "service_role";



GRANT ALL ON TABLE "public"."users" TO "anon";
GRANT ALL ON TABLE "public"."users" TO "authenticated";
GRANT ALL ON TABLE "public"."users" TO "service_role";



GRANT ALL ON TABLE "public"."verified_driver_ads" TO "anon";
GRANT ALL ON TABLE "public"."verified_driver_ads" TO "authenticated";
GRANT ALL ON TABLE "public"."verified_driver_ads" TO "service_role";



GRANT ALL ON FUNCTION "public"."search_drivers"("filter_gender" "text", "max_price" numeric, "filter_area_id" "uuid", "filter_school_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."search_drivers"("filter_gender" "text", "max_price" numeric, "filter_area_id" "uuid", "filter_school_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."search_drivers"("filter_gender" "text", "max_price" numeric, "filter_area_id" "uuid", "filter_school_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."search_drivers"("filter_gender" "text", "max_price" numeric, "filter_area_id" "uuid", "filter_school_id" "uuid", "filter_online_only" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."search_drivers"("filter_gender" "text", "max_price" numeric, "filter_area_id" "uuid", "filter_school_id" "uuid", "filter_online_only" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."search_drivers"("filter_gender" "text", "max_price" numeric, "filter_area_id" "uuid", "filter_school_id" "uuid", "filter_online_only" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."search_drivers_for_parent_v2"("filter_gender" "text", "filter_vehicle_type" "text", "filter_min_rating" numeric, "max_price_monthly_two_way" numeric, "filter_area_id" "uuid", "filter_school_id" "uuid", "parent_location_lat" double precision, "parent_location_lng" double precision, "max_distance_km" integer, "filter_online_only" boolean, "require_verified" boolean, "page_limit" integer, "page_offset" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."search_drivers_for_parent_v2"("filter_gender" "text", "filter_vehicle_type" "text", "filter_min_rating" numeric, "max_price_monthly_two_way" numeric, "filter_area_id" "uuid", "filter_school_id" "uuid", "parent_location_lat" double precision, "parent_location_lng" double precision, "max_distance_km" integer, "filter_online_only" boolean, "require_verified" boolean, "page_limit" integer, "page_offset" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."search_drivers_for_parent_v2"("filter_gender" "text", "filter_vehicle_type" "text", "filter_min_rating" numeric, "max_price_monthly_two_way" numeric, "filter_area_id" "uuid", "filter_school_id" "uuid", "parent_location_lat" double precision, "parent_location_lng" double precision, "max_distance_km" integer, "filter_online_only" boolean, "require_verified" boolean, "page_limit" integer, "page_offset" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."set_driver_current_location"("p_user_id" "uuid", "p_latitude" double precision, "p_longitude" double precision, "p_address" "text", "p_accuracy_meters" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."set_driver_current_location"("p_user_id" "uuid", "p_latitude" double precision, "p_longitude" double precision, "p_address" "text", "p_accuracy_meters" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_driver_current_location"("p_user_id" "uuid", "p_latitude" double precision, "p_longitude" double precision, "p_address" "text", "p_accuracy_meters" double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."set_driver_online_status"("p_is_online" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."set_driver_online_status"("p_is_online" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_driver_online_status"("p_is_online" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."start_trip"("trip_id_input" "uuid", "driver_lat" double precision, "driver_lng" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."start_trip"("trip_id_input" "uuid", "driver_lat" double precision, "driver_lng" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."start_trip"("trip_id_input" "uuid", "driver_lat" double precision, "driver_lng" double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."sync_stop_latlng_to_geo"() TO "anon";
GRANT ALL ON FUNCTION "public"."sync_stop_latlng_to_geo"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."sync_stop_latlng_to_geo"() TO "service_role";



GRANT ALL ON FUNCTION "public"."toggle_saved_driver"("p_driver_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."toggle_saved_driver"("p_driver_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."toggle_saved_driver"("p_driver_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."update_driver_availability_settings"("p_auto_offline_after_trip" boolean, "p_auto_online_before_trip" boolean, "p_auto_online_minutes_before" integer, "p_availability_mode" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."update_driver_availability_settings"("p_auto_offline_after_trip" boolean, "p_auto_online_before_trip" boolean, "p_auto_online_minutes_before" integer, "p_availability_mode" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_driver_availability_settings"("p_auto_offline_after_trip" boolean, "p_auto_online_before_trip" boolean, "p_auto_online_minutes_before" integer, "p_availability_mode" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."update_route_order"("updates" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."update_route_order"("updates" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_route_order"("updates" "jsonb") TO "service_role";



GRANT ALL ON TABLE "public"."areas" TO "anon";
GRANT ALL ON TABLE "public"."areas" TO "authenticated";
GRANT ALL ON TABLE "public"."areas" TO "service_role";



GRANT ALL ON TABLE "public"."booking_children" TO "anon";
GRANT ALL ON TABLE "public"."booking_children" TO "authenticated";
GRANT ALL ON TABLE "public"."booking_children" TO "service_role";



GRANT ALL ON TABLE "public"."bookings" TO "anon";
GRANT ALL ON TABLE "public"."bookings" TO "authenticated";
GRANT ALL ON TABLE "public"."bookings" TO "service_role";



GRANT ALL ON TABLE "public"."child_absences" TO "anon";
GRANT ALL ON TABLE "public"."child_absences" TO "authenticated";
GRANT ALL ON TABLE "public"."child_absences" TO "service_role";



GRANT ALL ON TABLE "public"."children" TO "anon";
GRANT ALL ON TABLE "public"."children" TO "authenticated";
GRANT ALL ON TABLE "public"."children" TO "service_role";



GRANT ALL ON TABLE "public"."cities" TO "anon";
GRANT ALL ON TABLE "public"."cities" TO "authenticated";
GRANT ALL ON TABLE "public"."cities" TO "service_role";



GRANT ALL ON TABLE "public"."driver_availability" TO "anon";
GRANT ALL ON TABLE "public"."driver_availability" TO "authenticated";
GRANT ALL ON TABLE "public"."driver_availability" TO "service_role";



GRANT ALL ON TABLE "public"."driver_documents" TO "anon";
GRANT ALL ON TABLE "public"."driver_documents" TO "authenticated";
GRANT ALL ON TABLE "public"."driver_documents" TO "service_role";



GRANT ALL ON TABLE "public"."driver_locations" TO "anon";
GRANT ALL ON TABLE "public"."driver_locations" TO "authenticated";
GRANT ALL ON TABLE "public"."driver_locations" TO "service_role";



GRANT ALL ON TABLE "public"."driver_review_stats" TO "anon";
GRANT ALL ON TABLE "public"."driver_review_stats" TO "authenticated";
GRANT ALL ON TABLE "public"."driver_review_stats" TO "service_role";



GRANT ALL ON TABLE "public"."driver_schedules" TO "anon";
GRANT ALL ON TABLE "public"."driver_schedules" TO "authenticated";
GRANT ALL ON TABLE "public"."driver_schedules" TO "service_role";



GRANT ALL ON TABLE "public"."messages" TO "anon";
GRANT ALL ON TABLE "public"."messages" TO "authenticated";
GRANT ALL ON TABLE "public"."messages" TO "service_role";



GRANT ALL ON TABLE "public"."payments" TO "anon";
GRANT ALL ON TABLE "public"."payments" TO "authenticated";
GRANT ALL ON TABLE "public"."payments" TO "service_role";



GRANT ALL ON TABLE "public"."ride_events" TO "anon";
GRANT ALL ON TABLE "public"."ride_events" TO "authenticated";
GRANT ALL ON TABLE "public"."ride_events" TO "service_role";



GRANT ALL ON TABLE "public"."route_stops" TO "anon";
GRANT ALL ON TABLE "public"."route_stops" TO "authenticated";
GRANT ALL ON TABLE "public"."route_stops" TO "service_role";



GRANT ALL ON TABLE "public"."saved_drivers" TO "anon";
GRANT ALL ON TABLE "public"."saved_drivers" TO "authenticated";
GRANT ALL ON TABLE "public"."saved_drivers" TO "service_role";



GRANT ALL ON TABLE "public"."schools" TO "anon";
GRANT ALL ON TABLE "public"."schools" TO "authenticated";
GRANT ALL ON TABLE "public"."schools" TO "service_role";



GRANT ALL ON TABLE "public"."transport_requests" TO "anon";
GRANT ALL ON TABLE "public"."transport_requests" TO "authenticated";
GRANT ALL ON TABLE "public"."transport_requests" TO "service_role";



GRANT ALL ON TABLE "public"."trips" TO "anon";
GRANT ALL ON TABLE "public"."trips" TO "authenticated";
GRANT ALL ON TABLE "public"."trips" TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";







