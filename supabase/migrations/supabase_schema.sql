


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


CREATE OR REPLACE FUNCTION "public"."cleanup_expired_pending_uploads"() RETURNS integer
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  affected_count INTEGER;
BEGIN
  UPDATE public.media_assets
  SET status = 'failed',
      metadata = metadata || jsonb_build_object('failure_reason', 'expired')
  WHERE status = 'pending'
    AND expires_at < NOW();

  GET DIAGNOSTICS affected_count = ROW_COUNT;
  RETURN affected_count;
END;
$$;


ALTER FUNCTION "public"."cleanup_expired_pending_uploads"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."complete_trip"("trip_id_input" "uuid", "driver_lat" double precision DEFAULT NULL::double precision, "driver_lng" double precision DEFAULT NULL::double precision) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    v_driver_id UUID := auth.uid();
BEGIN
    -- 1. Complete the trip
    UPDATE public.trips
    SET status = 'completed',
        end_time = NOW()
    WHERE id = trip_id_input;

    -- 2. Update driver location (Stop tracking)
    -- This ensures the UI reflects that the trip has ended immediately
    UPDATE public.driver_locations
    SET is_tracking_active = false,
        trip_type = 'idle',
        updated_at = NOW()
    WHERE driver_id = v_driver_id;
END;
$$;


ALTER FUNCTION "public"."complete_trip"("trip_id_input" "uuid", "driver_lat" double precision, "driver_lng" double precision) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."complete_trip_with_auto_offline"("trip_id_input" "uuid", "driver_lat" double precision, "driver_lng" double precision) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
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
$$;


ALTER FUNCTION "public"."complete_trip_with_auto_offline"("trip_id_input" "uuid", "driver_lat" double precision, "driver_lng" double precision) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."finalize_media_upload"("p_asset_id" "uuid", "p_file_size" bigint DEFAULT NULL::bigint) RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  asset RECORD;
  final_url TEXT;
  base_url TEXT := coalesce(current_setting('app.r2_public_url', true), 'https://media.gotosco.com');
  parts TEXT[];
  table_name TEXT;
  column_name TEXT;
BEGIN
  -- Get and lock the asset
  SELECT * INTO asset
  FROM public.media_assets
  WHERE id = p_asset_id
  FOR UPDATE;

  IF asset IS NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'Asset not found');
  END IF;

  IF asset.status != 'pending' THEN
    RETURN jsonb_build_object('success', false, 'error', 'Asset is not pending');
  END IF;

  -- Calculate final URL
  IF asset.visibility = 'public' THEN
    final_url := base_url || '/' || asset.r2_key;
  ELSE
    -- Private assets don't have a public URL, but we store the r2_key-based URL
    -- Clients will use get-signed-url to access
    final_url := base_url || '/' || asset.r2_key;
  END IF;

  -- Update asset status
  UPDATE public.media_assets
  SET status = 'uploaded',
      uploaded_at = NOW(),
      file_size = COALESCE(p_file_size, file_size),
      expires_at = NULL
  WHERE id = p_asset_id;

  -- Update legacy column if specified
  IF asset.legacy_column IS NOT NULL AND asset.legacy_column != '' THEN
    parts := string_to_array(asset.legacy_column, '.');
    IF array_length(parts, 1) = 2 THEN
      table_name := parts[1];
      column_name := parts[2];

      IF table_name = 'users' AND column_name = 'photo_url' THEN
        UPDATE public.users SET photo_url = final_url WHERE id = asset.owner_id;
      ELSIF table_name = 'drivers' AND column_name = 'license_image_url' THEN
        UPDATE public.drivers SET license_image_url = final_url WHERE user_id = asset.owner_id;
      ELSIF table_name = 'drivers' AND column_name = 'mulkia_image_url' THEN
        UPDATE public.drivers SET mulkia_image_url = final_url WHERE user_id = asset.owner_id;
      ELSIF table_name = 'children' AND column_name = 'photo_url' THEN
        -- Children require parent_id check - need to pass child_id in metadata
        IF asset.metadata ? 'child_id' THEN
          UPDATE public.children
          SET photo_url = final_url
          WHERE id = (asset.metadata->>'child_id')::UUID
            AND parent_id = asset.owner_id;
        END IF;
      END IF;
    END IF;
  END IF;

  RETURN jsonb_build_object(
    'success', true,
    'url', final_url,
    'asset_id', asset.id,
    'r2_key', asset.r2_key,
    'visibility', asset.visibility
  );
END;
$$;


ALTER FUNCTION "public"."finalize_media_upload"("p_asset_id" "uuid", "p_file_size" bigint) OWNER TO "postgres";


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
  -- 1. Modified Temp Table to include trip_category
  CREATE TEMP TABLE IF NOT EXISTS _temp_go_stops_v7 (
    booking_id UUID, 
    child_id UUID, 
    pickup_lat FLOAT, 
    pickup_lng FLOAT, 
    school_lat FLOAT, 
    school_lng FLOAT,
    trip_category TEXT
  ) ON COMMIT DROP;
  
  target_day_name := LOWER(TRIM(to_char(target_date, 'Day')));
  
  -- LOOP DRIVERS
  FOR driver_rec IN 
    SELECT DISTINCT b.driver_id, d.start_location_geo, d.location_geo 
    FROM public.bookings b
    JOIN public.drivers d ON b.driver_id = d.user_id
    WHERE (b.subscription_status = 'active' OR b.status IN ('confirmed', 'accepted'))
      AND (target_driver_id IS NULL OR b.driver_id = target_driver_id)
  LOOP
    -- CHECK ALREADY GENERATED
    SELECT id INTO existing_trip_id FROM public.trips 
    WHERE driver_id = driver_rec.driver_id AND trip_date = target_date AND trip_type = 'Go to School(s)' LIMIT 1;
    
    IF existing_trip_id IS NOT NULL THEN CONTINUE; END IF;
    
    DELETE FROM _temp_go_stops_v7 WHERE TRUE;
    
    -- INSERT STOPS (Now selecting trip_category)
    INSERT INTO _temp_go_stops_v7 (booking_id, child_id, pickup_lat, pickup_lng, school_lat, school_lng, trip_category)
    SELECT 
        b.id, 
        bc.child_id, 
        b.home_lat, 
        b.home_lng,
        COALESCE(s_child.latitude, s_booking.latitude, b.school_lat),
        COALESCE(s_child.longitude, s_booking.longitude, b.school_lng),
        b.trip_category  -- Captured here
      FROM public.bookings b
      JOIN public.booking_children bc ON b.id = bc.booking_id
      JOIN public.children c ON bc.child_id = c.id
      LEFT JOIN public.schools s_child ON c.school_id = s_child.id
      LEFT JOIN public.schools s_booking ON b.school_id = s_booking.id
      WHERE b.driver_id = driver_rec.driver_id
        AND (b.subscription_status = 'active' OR b.status IN ('confirmed', 'accepted'))
        AND b.booking_type IN ('Two Way', 'One Way to School')
        AND b.home_lat IS NOT NULL 
        AND COALESCE(s_child.latitude, s_booking.latitude, b.school_lat) IS NOT NULL
        AND NOT EXISTS (SELECT 1 FROM public.child_absences ca WHERE ca.child_id = bc.child_id AND ca.date = target_date)
      ORDER BY 
        b.routego_order ASC NULLS LAST,
        ST_Distance(b.homegeo_location, COALESCE(driver_rec.start_location_geo, driver_rec.location_geo)) ASC;
        
    SELECT EXISTS (SELECT 1 FROM _temp_go_stops_v7) INTO has_children;
    
    IF has_children THEN
        -- Create Trip
        SELECT available_from, available_until INTO sched_start, sched_end
        FROM public.driver_schedules WHERE driver_id = driver_rec.driver_id AND LOWER(day_of_week) = target_day_name AND shift_type = 'Go to School(s)' LIMIT 1;
        
        INSERT INTO public.trips (driver_id, trip_date, status, trip_type, trip_direction, start_time, end_time)
        VALUES (driver_rec.driver_id, target_date, 'scheduled', 'Go to School(s)', 'go',
            CASE WHEN sched_start IS NOT NULL THEN (target_date + sched_start) ELSE NULL END,
            CASE WHEN sched_end IS NOT NULL THEN (target_date + sched_end) ELSE NULL END)
        RETURNING id INTO new_trip_id;
        
        stop_sequence := 1;
        
        -- Pickups (Start at Home)
        FOR child_rec IN SELECT * FROM _temp_go_stops_v7 LOOP
            INSERT INTO public.route_stops (trip_id, booking_id, child_id, stop_type, sequence_order, location_lat, location_lng, status)
            VALUES (
                new_trip_id, 
                child_rec.booking_id, 
                child_rec.child_id, 
                'pick up from home', -- Always pickup from home for GO trips
                stop_sequence, 
                child_rec.pickup_lat, 
                child_rec.pickup_lng, 
                'pending'
            );
            stop_sequence := stop_sequence + 1;
        END LOOP;
        
        -- Dropoffs (School or Destination)
        FOR child_rec IN SELECT * FROM _temp_go_stops_v7 ORDER BY school_lat, school_lng LOOP
            INSERT INTO public.route_stops (trip_id, booking_id, child_id, stop_type, sequence_order, location_lat, location_lng, status)
            VALUES (
                new_trip_id, 
                child_rec.booking_id, 
                child_rec.child_id, 
                -- 2. Conditional Logic for Drop-off
                CASE 
                    WHEN child_rec.trip_category = 'school' THEN 'Drop off at school'
                    ELSE 'Drop off at destination'
                END,
                stop_sequence, 
                child_rec.school_lat, 
                child_rec.school_lng, 
                'pending'
            );
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
  -- 1. Modified Temp Table to include trip_category
  CREATE TEMP TABLE IF NOT EXISTS _temp_return_stops_v7 (
    booking_id UUID, 
    child_id UUID, 
    pickup_lat FLOAT, 
    pickup_lng FLOAT, 
    school_lat FLOAT, 
    school_lng FLOAT,
    trip_category TEXT
  ) ON COMMIT DROP;
  
  target_day_name := LOWER(TRIM(to_char(target_date, 'Day')));
  
  -- LOOP DRIVERS
  FOR driver_rec IN 
    SELECT DISTINCT b.driver_id FROM public.bookings b
    WHERE (b.subscription_status = 'active' OR b.status IN ('confirmed', 'accepted'))
      AND (target_driver_id IS NULL OR b.driver_id = target_driver_id)
  LOOP
    -- CHECK ALREADY GENERATED
    SELECT id INTO existing_trip_id FROM public.trips 
    WHERE driver_id = driver_rec.driver_id AND trip_date = target_date AND trip_type = 'Return from School(s)' LIMIT 1;
    
    IF existing_trip_id IS NOT NULL THEN CONTINUE; END IF;
    
    DELETE FROM _temp_return_stops_v7 WHERE TRUE;
    
    -- INSERT STOPS (Now selecting trip_category)
    INSERT INTO _temp_return_stops_v7 (booking_id, child_id, pickup_lat, pickup_lng, school_lat, school_lng, trip_category)
    SELECT 
        b.id, 
        bc.child_id, 
        b.home_lat, 
        b.home_lng, 
        COALESCE(s_child.latitude, s_booking.latitude, b.school_lat),
        COALESCE(s_child.longitude, s_booking.longitude, b.school_lng),
        b.trip_category -- Captured here
      FROM public.bookings b
      JOIN public.booking_children bc ON b.id = bc.booking_id
      JOIN public.children c ON bc.child_id = c.id
      LEFT JOIN public.schools s_child ON c.school_id = s_child.id
      LEFT JOIN public.schools s_booking ON b.school_id = s_booking.id
      WHERE b.driver_id = driver_rec.driver_id
        AND (b.subscription_status = 'active' OR b.status IN ('confirmed', 'accepted'))
        AND b.booking_type IN ('Two Way', 'One Way Back Home') 
        AND b.home_lat IS NOT NULL 
        AND COALESCE(s_child.latitude, s_booking.latitude, b.school_lat) IS NOT NULL
        AND NOT EXISTS (SELECT 1 FROM public.child_absences ca WHERE ca.child_id = bc.child_id AND ca.date = target_date)
      ORDER BY 
        b.routeret_order ASC NULLS LAST,
        ST_Distance(
            ST_SetSRID(ST_MakePoint(
                COALESCE(s_child.longitude, s_booking.longitude, b.school_lng),
                COALESCE(s_child.latitude, s_booking.latitude, b.school_lat)
            ), 4326)::geography, 
            b.homegeo_location
        ) ASC;
        
    SELECT EXISTS (SELECT 1 FROM _temp_return_stops_v7) INTO has_children;
    
    IF has_children THEN
        -- Create Trip
        SELECT available_from, available_until INTO sched_start, sched_end
        FROM public.driver_schedules WHERE driver_id = driver_rec.driver_id AND LOWER(day_of_week) = target_day_name AND shift_type = 'Return from School(s)' LIMIT 1;
        
        INSERT INTO public.trips (driver_id, trip_date, status, trip_type, trip_direction, start_time, end_time)
        VALUES (driver_rec.driver_id, target_date, 'scheduled', 'Return from School(s)', 'return',
            CASE WHEN sched_start IS NOT NULL THEN (target_date + sched_start) ELSE NULL END,
            CASE WHEN sched_end IS NOT NULL THEN (target_date + sched_end) ELSE NULL END)
        RETURNING id INTO new_trip_id;
        
        stop_sequence := 1;
        
        -- Pickups (School or Destination) - Clustered
        FOR child_rec IN SELECT * FROM _temp_return_stops_v7 ORDER BY school_lat, school_lng LOOP
            INSERT INTO public.route_stops (trip_id, booking_id, child_id, stop_type, sequence_order, location_lat, location_lng, status)
            VALUES (
                new_trip_id, 
                child_rec.booking_id, 
                child_rec.child_id, 
                -- 2. Conditional Logic for Pickup
                CASE 
                    WHEN child_rec.trip_category = 'school' THEN 'pick up from school'
                    ELSE 'pick up from destination'
                END,
                stop_sequence, 
                child_rec.school_lat, 
                child_rec.school_lng, 
                'pending'
            );
            stop_sequence := stop_sequence + 1;
        END LOOP;
        
        -- Dropoffs (Home) - Sequential
        FOR child_rec IN SELECT * FROM _temp_return_stops_v7 LOOP
            INSERT INTO public.route_stops (trip_id, booking_id, child_id, stop_type, sequence_order, location_lat, location_lng, status)
            VALUES (
                new_trip_id, 
                child_rec.booking_id, 
                child_rec.child_id, 
                'Drop off at home', -- Always home for Return trips
                stop_sequence, 
                child_rec.pickup_lat, 
                child_rec.pickup_lng, 
                'pending'
            );
            stop_sequence := stop_sequence + 1;
        END LOOP;
    END IF;
  END LOOP;
END;
$$;


ALTER FUNCTION "public"."generate_return_trips"("target_date" "date", "target_driver_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_asset_public_url"("asset_id" "uuid") RETURNS "text"
    LANGUAGE "plpgsql" STABLE
    AS $$
DECLARE
  asset RECORD;
  base_url TEXT := current_setting('app.r2_public_url', true);
BEGIN
  SELECT * INTO asset FROM public.media_assets WHERE id = asset_id;

  IF asset IS NULL THEN
    RETURN NULL;
  END IF;

  IF asset.visibility = 'private' THEN
    RETURN NULL; -- Private assets require signed URLs
  END IF;

  IF base_url IS NULL OR base_url = '' THEN
    base_url := 'https://media.gotosco.com'; -- Fallback
  END IF;

  RETURN base_url || '/' || asset.r2_key;
END;
$$;


ALTER FUNCTION "public"."get_asset_public_url"("asset_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_driver_availability_settings"() RETURNS TABLE("auto_offline_after_trip" boolean, "auto_online_before_trip" boolean, "auto_online_minutes_before" integer, "availability_mode" "text", "is_profile_online" boolean, "is_tracking_active" boolean, "is_app_online" boolean, "is_online_visible" boolean)
    LANGUAGE "plpgsql" SECURITY DEFINER
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
        COALESCE(d.is_profile_online, false) as is_profile_online,
        COALESCE(l.is_tracking_active, false) as is_tracking_active,
        COALESCE(u.is_app_online, false) as is_app_online,
        COALESCE(u.is_online_visible, true) as is_online_visible
    FROM public.drivers d
    JOIN public.users u ON u.id = d.user_id
    LEFT JOIN public.driver_locations l ON d.user_id = l.driver_id
    WHERE d.user_id = v_driver_id;
END;
$$;


ALTER FUNCTION "public"."get_driver_availability_settings"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_parent_tracking_ui_state"("booking_id_input" "uuid") RETURNS TABLE("status_badge" "text", "ui_title" "text", "ui_subtitle" "text", "stops_until" integer, "eta_minutes" integer, "is_go_trip" boolean)
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    v_parent_id UUID := auth.uid();
    v_booking RECORD;
    v_driver_online BOOLEAN := false;
    v_trips_started BOOLEAN := false;
    v_eta INTEGER := 0;
    
    v_trip RECORD;
    v_pickup_stop RECORD;
    v_dropoff_stop RECORD;
    
    v_stops_away INTEGER := 0;
    v_is_go BOOLEAN := true;
    
    v_badge TEXT;
    v_title TEXT;
    v_subtitle TEXT;
BEGIN
    -- 1. Validate Ownership
    SELECT b.id, b.parent_id, b.driver_id
    INTO v_booking
    FROM public.bookings b
    WHERE b.id = booking_id_input;

    IF v_booking.id IS NULL OR v_booking.parent_id != v_parent_id THEN
        RETURN; -- Unauthorized or invalid
    END IF;

    -- 2. Check Driver & Global Location Status (Scenario 1 & 2)
    SELECT d.is_active, COALESCE(dl.trips_started, false), dl.eta_minutes
    INTO v_driver_online, v_trips_started, v_eta
    FROM public.drivers d
    LEFT JOIN public.driver_locations dl ON dl.driver_id = d.user_id
    WHERE d.user_id = v_booking.driver_id;

    -- Scenario 1: Driver Offline
    IF v_driver_online IS NULL OR NOT v_driver_online THEN
        RETURN QUERY SELECT 'OFFLINE'::text, 'Scheduled Trip'::text, 'Driver is currently offline'::text, 0::int, v_eta, true::boolean;
        RETURN;
    END IF;

    -- 3. Fetch Active Trip
    SELECT t.id, t.trip_type
    INTO v_trip
    FROM public.trips t
    JOIN public.route_stops rs ON rs.trip_id = t.id
    WHERE rs.booking_id = booking_id_input
      AND t.status IN ('scheduled', 'in_progress')
    ORDER BY t.trip_date DESC, t.start_time DESC NULLS LAST
    LIMIT 1;

    -- Scenario 2: Online, but no active trip generated/started
    IF v_trip.id IS NULL OR NOT v_trips_started THEN
        RETURN QUERY SELECT 'SCHEDULED'::text, 'Trip Scheduled'::text, 'Driver is online'::text, 0::int, v_eta, true::boolean;
        RETURN;
    END IF;

    v_is_go := (v_trip.trip_type = 'Go to School(s)');

    -- 4. Fetch Exact Stops for this Booking
    -- Pickup Stop
    SELECT * INTO v_pickup_stop
    FROM public.route_stops
    WHERE trip_id = v_trip.id AND booking_id = booking_id_input
      AND stop_type IN ('pickup', 'pick up from home', 'pick up from school')
    LIMIT 1;

    -- Dropoff Stop
    SELECT * INTO v_dropoff_stop
    FROM public.route_stops
    WHERE trip_id = v_trip.id AND booking_id = booking_id_input
      AND stop_type IN ('dropoff', 'Drop off at home', 'Drop off at school', 'Drop off at destination')
    LIMIT 1;

    -- =========================================================
    -- 5. STATE MACHINE LOGIC (Scenarios 3 through 9)
    -- Evaluating in reverse chronological order of the trip
    -- =========================================================

    -- Scenario 8/9 (Final): Dropped Off safely
    IF v_dropoff_stop.status = 'completed' THEN
        v_badge := 'COMPLETED';
        v_title := 'Child Dropped Off';
        v_subtitle := CASE WHEN v_is_go THEN 'Arrived at school' ELSE 'Arrived home safely' END;
        v_stops_away := 0;

    -- Scenario 8/9: Driver Arrived at Dropoff (Waiting to hand over)
    ELSIF v_dropoff_stop.status = 'arrived' THEN
        v_badge := 'ARRIVED';
        v_title := 'Driver Arrived';
        v_subtitle := CASE WHEN v_is_go THEN 'Arrived at school' ELSE 'Arrived at home (Waiting for you to collect your child)' END;
        v_stops_away := 0;

    -- Scenario 7/9: Child Picked Up -> En route to Dropoff
    ELSIF v_pickup_stop.status = 'completed' THEN
        v_badge := 'ON_TRIP';
        v_title := 'Child Picked Up';
        
        -- Calculate stops until dropoff destination
        SELECT COUNT(*) INTO v_stops_away
        FROM public.route_stops rs
        WHERE rs.trip_id = v_trip.id AND rs.status IN ('pending', 'arrived')
          AND rs.sequence_order < v_dropoff_stop.sequence_order;
          
        v_subtitle := CASE WHEN v_is_go THEN 'Heading to School Dropoff' ELSE 'Heading to Home Dropoff' END;
        IF v_eta IS NOT NULL THEN
            v_subtitle := v_subtitle || ' · ' || v_eta || ' min';
        END IF;

    -- Scenario 6/9: Driver Arrived at Pickup (Ready for child)
    ELSIF v_pickup_stop.status = 'arrived' THEN
        v_badge := 'ARRIVED';
        v_title := 'Driver Arrived';
        v_subtitle := CASE WHEN v_is_go THEN 'Ready for pickup at home' ELSE 'Picking up from school' END;
        v_stops_away := 0;

    -- Scenarios 3, 4, 5 & 9 (Start): Live tracking en route to Pickup
    ELSE
        v_badge := CASE WHEN v_is_go THEN 'LIVE_TRIP' ELSE 'ON_TRIP' END;
        v_title := CASE WHEN v_is_go THEN 'Arriving for Pickup' ELSE 'Heading to School' END;
        
        -- Calculate stops until pickup location
        SELECT COUNT(*) INTO v_stops_away
        FROM public.route_stops rs
        WHERE rs.trip_id = v_trip.id AND rs.status IN ('pending', 'arrived')
          AND rs.sequence_order < v_pickup_stop.sequence_order;

        -- Subtitle formatting (drops 'stops away' if it hits 0)
        IF v_stops_away > 0 THEN
            v_subtitle := COALESCE(v_eta, 0) || ' min · ' || v_stops_away || ' stops away';
        ELSE
            v_subtitle := COALESCE(v_eta, 0) || ' min away';
        END IF;
    END IF;

    -- 6. Return Structured Data
    RETURN QUERY SELECT 
        v_badge,
        v_title,
        v_subtitle,
        v_stops_away,
        v_eta,
        v_is_go;

END;
$$;


ALTER FUNCTION "public"."get_parent_tracking_ui_state"("booking_id_input" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."get_parent_tracking_ui_state"("booking_id_input" "uuid") IS '@deprecated Use parent_tracking_snapshot view instead. Scheduled for removal in 1 week.';



CREATE OR REPLACE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
begin
  -- If public.users is missing, don't break auth
  if to_regclass('public.users') is null then
    return new;
  end if;

  insert into public.users (
    id, role, full_name, phone, email, auth_provider, created_at
  )
  values (
    new.id,
    array[]::text[],
    coalesce(
      new.raw_user_meta_data->>'full_name',
      new.raw_user_meta_data->>'name',
      split_part(coalesce(new.email, new.phone), '@', 1),
      'User'
    ),
    new.phone,
    new.email,
    coalesce(new.raw_app_meta_data->>'provider', 'phone'),
    new.created_at
  )
  on conflict (id) do nothing;

  return new;

exception when others then
  -- Never block auth flows for profile sync issues
  return new;
end;
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
$$;


ALTER FUNCTION "public"."notify_parent_on_ride_event"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."process_stop"("stop_id_input" "uuid", "action" "text", "driver_lat" double precision DEFAULT NULL::double precision, "driver_lng" double precision DEFAULT NULL::double precision) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  v_booking_id uuid;
  v_child_id uuid;
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
  SELECT rs.booking_id, rs.child_id, rs.trip_id, t.driver_id, b.parent_id, rs.sequence_order, rs.stop_type
  INTO v_booking_id, v_child_id, v_trip_id, v_driver_id, v_parent_id, v_current_seq, v_stop_type
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
  
  -- Fallback if booking_children is empty (though it shouldn't be)
  IF v_child_ids IS NULL THEN
    v_child_ids := jsonb_build_array(v_child_id);
  END IF;

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


CREATE OR REPLACE FUNCTION "public"."regenerate_daily_trips"("target_date" "date") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
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
$$;


ALTER FUNCTION "public"."regenerate_daily_trips"("target_date" "date") OWNER TO "postgres";


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


CREATE OR REPLACE FUNCTION "public"."search_drivers_for_parent_v2"("filter_gender" "text" DEFAULT NULL::"text", "filter_vehicle_type" "text" DEFAULT NULL::"text", "filter_min_rating" numeric DEFAULT NULL::numeric, "max_price_monthly_two_way" numeric DEFAULT NULL::numeric, "filter_area_id" "uuid" DEFAULT NULL::"uuid", "filter_school_id" "uuid" DEFAULT NULL::"uuid", "search_term" "text" DEFAULT NULL::"text", "parent_location_lat" double precision DEFAULT NULL::double precision, "parent_location_lng" double precision DEFAULT NULL::double precision, "max_distance_km" integer DEFAULT NULL::integer, "filter_online_only" boolean DEFAULT false, "require_verified" boolean DEFAULT false, "page_limit" integer DEFAULT 20, "page_offset" integer DEFAULT 0) RETURNS TABLE("driver_id" "uuid", "name" "text", "photo_url" "text", "gender" "text", "bio" "text", "phone" "text", "vehicle_type" "text", "vehicle_capacity" integer, "rating" numeric, "total_reviews" integer, "price_monthly_two_way" numeric, "price_monthly_one_way" numeric, "price_daily" numeric, "currency" "text", "advs_photos" "text"[], "is_online" boolean, "is_verified" boolean, "distance_km" numeric, "covered_schools" "jsonb", "service_areas" "jsonb")
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    parent_geo geography;
BEGIN
    IF parent_location_lat IS NOT NULL AND parent_location_lng IS NOT NULL THEN
        IF parent_location_lat BETWEEN -90 AND 90 AND parent_location_lng BETWEEN -180 AND 180 THEN
            parent_geo := ST_SetSRID(ST_MakePoint(parent_location_lng, parent_location_lat), 4326)::geography;
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
        COALESCE(d.advs_photos, '{}'::text[]),
        COALESCE(d.is_profile_online, false),
        d.is_verified,
        CASE
            WHEN parent_geo IS NOT NULL AND u.location_geo IS NOT NULL
            THEN ROUND((ST_Distance(u.location_geo, parent_geo) / 1000)::numeric, 2)
            ELSE NULL
        END,
        COALESCE(schools_data.json_agg, '[]'::jsonb),
        COALESCE(areas_data.json_agg, '[]'::jsonb)
    FROM public.drivers d
    INNER JOIN public.users u ON d.user_id = u.id
    LEFT JOIN public.driver_review_stats rs ON d.user_id = rs.driver_id
    LEFT JOIN LATERAL (
        SELECT jsonb_agg(jsonb_build_object('id', s.id, 'name', s.name, 'address', s.address, 'city_name', c.name)) as json_agg
        FROM public.driver_covered_schools dcs
        JOIN public.schools s ON dcs.school_id = s.id
        LEFT JOIN public.cities c ON s.city_id = c.id
        WHERE dcs.driver_id = d.user_id
        LIMIT 50
    ) schools_data ON TRUE
    LEFT JOIN LATERAL (
        SELECT jsonb_agg(jsonb_build_object('id', a.id, 'name', a.name)) as json_agg
        FROM public.driver_service_areas dsa
        JOIN public.areas a ON dsa.area_id = a.id
        WHERE dsa.driver_id = d.user_id
        LIMIT 50
    ) areas_data ON TRUE
    WHERE d.is_profile_online = TRUE
      AND (require_verified IS FALSE OR d.is_verified = TRUE)
      AND (filter_min_rating IS NULL OR d.rating >= filter_min_rating)
      AND (filter_gender IS NULL OR u.gender = filter_gender)
      AND (filter_vehicle_type IS NULL OR d.vehicle_type = filter_vehicle_type)
      AND (max_price_monthly_two_way IS NULL OR d.price_monthly_two_way <= max_price_monthly_two_way)
      AND COALESCE(d.is_profile_online, false) = TRUE
      AND (
          filter_area_id IS NULL OR EXISTS (SELECT 1 FROM public.driver_service_areas dsa WHERE dsa.driver_id = d.user_id AND dsa.area_id = filter_area_id)
      )
      AND (
          filter_school_id IS NULL OR EXISTS (SELECT 1 FROM public.driver_covered_schools dcs WHERE dcs.driver_id = d.user_id AND dcs.school_id = filter_school_id)
      )
      AND (
          max_distance_km IS NULL OR parent_geo IS NULL OR u.location_geo IS NULL
          OR ST_DWithin(u.location_geo, parent_geo, max_distance_km * 1000)
      )
      AND (
          search_term IS NULL OR search_term = '' OR u.full_name ILIKE '%' || search_term || '%'
          OR EXISTS (SELECT 1 FROM public.driver_covered_schools dcs JOIN public.schools s ON dcs.school_id = s.id WHERE dcs.driver_id = d.user_id AND s.name ILIKE '%' || search_term || '%')
          OR EXISTS (SELECT 1 FROM public.driver_service_areas dsa JOIN public.areas a ON dsa.area_id = a.id WHERE dsa.driver_id = d.user_id AND a.name ILIKE '%' || search_term || '%')
      )
    ORDER BY
       COALESCE(d.is_profile_online, false) DESC,
       CASE WHEN parent_geo IS NOT NULL AND u.location_geo IS NOT NULL THEN u.location_geo <-> parent_geo ELSE NULL END ASC NULLS LAST,
       d.rating DESC,
       d.created_at DESC
    LIMIT page_limit OFFSET page_offset;
END;
$$;


ALTER FUNCTION "public"."search_drivers_for_parent_v2"("filter_gender" "text", "filter_vehicle_type" "text", "filter_min_rating" numeric, "max_price_monthly_two_way" numeric, "filter_area_id" "uuid", "filter_school_id" "uuid", "search_term" "text", "parent_location_lat" double precision, "parent_location_lng" double precision, "max_distance_km" integer, "filter_online_only" boolean, "require_verified" boolean, "page_limit" integer, "page_offset" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."set_conversation_id"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    -- Always calculate conversation_id to ensure consistency
    NEW.conversation_id := CASE
        WHEN NEW.sender_id < NEW.receiver_id THEN NEW.sender_id::text || '_' || NEW.receiver_id::text
        ELSE NEW.receiver_id::text || '_' || NEW.sender_id::text
    END;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."set_conversation_id"() OWNER TO "postgres";


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
    
    -- Get previous location FROM USERS TABLE
    SELECT location_geo INTO previous_location
    FROM public.users
    WHERE id = p_user_id;
    
    -- Calculate distance moved
    IF previous_location IS NOT NULL THEN
        distance_moved := ST_Distance(
            previous_location,
            ST_SetSRID(ST_MakePoint(p_longitude, p_latitude), 4326)::geography
        );
    ELSE
        distance_moved := 0;
    END IF;
    
    UPDATE public.users
    SET 
        location_geo = ST_SetSRID(ST_MakePoint(p_longitude, p_latitude), 4326)::geography,
        location_text = p_address,
        location_accuracy_meters = p_accuracy_meters,
        last_location_update = NOW()
    WHERE id = p_user_id
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


CREATE OR REPLACE FUNCTION "public"."set_online_visibility"("p_is_visible" boolean) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  UPDATE public.users
  SET is_online_visible = p_is_visible,
  updated_at = NOW()
  WHERE id = auth.uid();
END;
$$;


ALTER FUNCTION "public"."set_online_visibility"("p_is_visible" boolean) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."set_profile_online_status"("p_is_online" boolean) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  v_driver_id UUID := auth.uid();
BEGIN
  UPDATE public.drivers
  SET is_profile_online = p_is_online
  WHERE user_id = v_driver_id;
END;
$$;


ALTER FUNCTION "public"."set_profile_online_status"("p_is_online" boolean) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."set_tracking_status"("p_is_tracking" boolean) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  v_driver_id UUID := auth.uid();
BEGIN
    INSERT INTO public.driver_locations (driver_id, latitude, longitude, is_tracking_active, updated_at)
    VALUES (v_driver_id, 0, 0, p_is_tracking, NOW())
    ON CONFLICT (driver_id) 
    DO UPDATE SET is_tracking_active = p_is_tracking, updated_at = NOW();
END;
$$;


ALTER FUNCTION "public"."set_tracking_status"("p_is_tracking" boolean) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."set_user_online_status"("p_is_online" boolean) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  UPDATE public.users
  SET is_app_online = p_is_online,
      updated_at = NOW()
  WHERE id = auth.uid();
END;
$$;


ALTER FUNCTION "public"."set_user_online_status"("p_is_online" boolean) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."start_trip"("trip_id_input" "uuid", "driver_lat" double precision DEFAULT NULL::double precision, "driver_lng" double precision DEFAULT NULL::double precision) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
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

  -- 6. Ensure driver is active so parent tracking UI state returns true
  UPDATE public.drivers
  SET is_active = true
  WHERE user_id = v_driver_id;
END;
$$;


ALTER FUNCTION "public"."start_trip"("trip_id_input" "uuid", "driver_lat" double precision, "driver_lng" double precision) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."sync_booking_school_location"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  school_row record;
BEGIN
  IF NEW.school_id IS NULL THEN
    RETURN NEW;
  END IF;

  SELECT name, address, location, latitude, longitude
  INTO school_row
  FROM public.schools
  WHERE id = NEW.school_id;

  IF FOUND THEN
    IF NEW.school_name IS NULL THEN
      NEW.school_name := school_row.name;
    END IF;

    IF NEW.schooltxt_location IS NULL OR NEW.schooltxt_location = '' THEN
      NEW.schooltxt_location := school_row.address;
    END IF;

    IF NEW.schoolgeo_location IS NULL THEN
      IF school_row.location IS NOT NULL THEN
        NEW.schoolgeo_location := school_row.location;
      ELSIF school_row.latitude IS NOT NULL AND school_row.longitude IS NOT NULL THEN
        NEW.schoolgeo_location := ST_SetSRID(
          ST_MakePoint(school_row.longitude, school_row.latitude),
          4326
        );
      END IF;
    END IF;
  END IF;

  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."sync_booking_school_location"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."sync_route_stop_label_v3"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  v_dir text;
BEGIN
  NEW.stop_kind := COALESCE(NEW.stop_kind, 'student');

  -- If explicitly provided, keep it (only ensure stop_label not null)
  IF NEW.stop_label_key IS NOT NULL AND NEW.stop_label_key <> '' THEN
    NEW.stop_label := COALESCE(NEW.stop_label, NEW.stop_label_key);
    RETURN NEW;
  END IF;

  -- Waypoint/custom stops: generic key (UI can use stop_context.title)
  IF NEW.stop_kind = 'waypoint' THEN
    NEW.stop_label_key := 'waypoint';
    NEW.stop_label := COALESCE(NEW.stop_label, 'Waypoint');
    RETURN NEW;
  END IF;

  IF NEW.stop_kind = 'custom' THEN
    NEW.stop_label_key := 'custom_stop';
    NEW.stop_label := COALESCE(NEW.stop_label, 'Stop');
    RETURN NEW;
  END IF;

  -- Student stops: label depends on trip_direction + stop_type
  SELECT trip_direction INTO v_dir
  FROM public.trips
  WHERE id = NEW.trip_id;

  -- Fallback if old trip rows missing trip_direction
  IF v_dir IS NULL THEN
    SELECT CASE
      WHEN trip_type = 'Go to School(s)' THEN 'go'
      WHEN trip_type = 'Return from School(s)' THEN 'return'
      ELSE 'custom'
    END INTO v_dir
    FROM public.trips
    WHERE id = NEW.trip_id;
  END IF;

  NEW.stop_label_key := CASE
    WHEN v_dir = 'go'     AND NEW.stop_type = 'pickup'  THEN 'home_pickup'
    WHEN v_dir = 'go'     AND NEW.stop_type = 'dropoff' THEN 'school_dropoff'
    WHEN v_dir = 'return' AND NEW.stop_type = 'pickup'  THEN 'school_pickup'
    WHEN v_dir = 'return' AND NEW.stop_type = 'dropoff' THEN 'home_dropoff'
    ELSE 'next_stop'
  END;

  -- Optional cached default English text
  NEW.stop_label := CASE NEW.stop_label_key
    WHEN 'home_pickup'    THEN 'Home Pickup'
    WHEN 'school_dropoff' THEN 'School Dropoff'
    WHEN 'school_pickup'  THEN 'School Pickup'
    WHEN 'home_dropoff'   THEN 'Home Dropoff'
    ELSE 'Next Stop'
  END;

  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."sync_route_stop_label_v3"() OWNER TO "postgres";


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

SET default_tablespace = '';

SET default_table_access_method = "heap";


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
    "driver_id" "uuid",
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
    "school_name" "text",
    "cancellation_type" "text",
    "cancellation_fee" numeric,
    "cancel_requested_at" timestamp with time zone,
    "pause_start_date" "date",
    "pause_end_date" "date",
    "trip_category" "text" DEFAULT 'school'::"text",
    "is_one_time" boolean DEFAULT false,
    "scheduled_pickup_datetime" timestamp with time zone,
    "scheduled_dropoff_datetime" timestamp with time zone,
    "custom_pickup_location_text" "text",
    "custom_pickup_geo" "public"."geography"(Point,4326),
    "custom_dropoff_location_text" "text",
    "custom_dropoff_geo" "public"."geography"(Point,4326),
    "booking_flow_step" "text" DEFAULT 'draft'::"text",
    "total_estimated_distance_km" numeric,
    "total_estimated_duration_minutes" integer,
    "custom_pickup_lat" double precision GENERATED ALWAYS AS ("public"."st_y"(("custom_pickup_geo")::"public"."geometry")) STORED,
    "custom_pickup_lng" double precision GENERATED ALWAYS AS ("public"."st_x"(("custom_pickup_geo")::"public"."geometry")) STORED,
    "custom_dropoff_lat" double precision GENERATED ALWAYS AS ("public"."st_y"(("custom_dropoff_geo")::"public"."geometry")) STORED,
    "custom_dropoff_lng" double precision GENERATED ALWAYS AS ("public"."st_x"(("custom_dropoff_geo")::"public"."geometry")) STORED,
    "is_multi_school" boolean DEFAULT false,
    "proposal_price" numeric,
    "is_for_parent" boolean,
    "school_ids" "uuid"[] DEFAULT ARRAY[]::"uuid"[],
    CONSTRAINT "bookings_booking_flow_step_check" CHECK (("booking_flow_step" = ANY (ARRAY['draft'::"text", 'submitted'::"text", 'confirmed'::"text"]))),
    CONSTRAINT "bookings_booking_type_check" CHECK (("booking_type" = ANY (ARRAY['Two Way'::"text", 'One Way to School'::"text", 'One Way Back Home'::"text", 'Other'::"text"]))),
    CONSTRAINT "bookings_cancellation_type_check" CHECK ((("cancellation_type" IS NULL) OR ("cancellation_type" = ANY (ARRAY['parent_cancel_grace'::"text", 'scheduled_stop'::"text", 'immediate_stop_fee'::"text", 'pause'::"text", 'safety_stop'::"text"])))),
    CONSTRAINT "bookings_status_check" CHECK (("status" = ANY (ARRAY['pending'::"text", 'confirmed'::"text", 'completed'::"text", 'cancelled'::"text", 'posted'::"text", 'open'::"text"]))),
    CONSTRAINT "bookings_subscription_status_check" CHECK (("subscription_status" = ANY (ARRAY['active'::"text", 'paused'::"text", 'cancelled'::"text", 'expired'::"text"]))),
    CONSTRAINT "bookings_trip_category_check" CHECK (("trip_category" = ANY (ARRAY['school'::"text", 'Journey'::"text", 'Other'::"text"])))
);


ALTER TABLE "public"."bookings" OWNER TO "postgres";


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
    "is_profile_online" boolean DEFAULT false,
    "vehicle_image_urls" "text"[] DEFAULT '{}'::"text"[],
    CONSTRAINT "check_location_geo_valid" CHECK ((("location_geo" IS NULL) OR "public"."st_isvalid"(("location_geo")::"public"."geometry"))),
    CONSTRAINT "check_start_location_geo_valid" CHECK ((("start_location_geo" IS NULL) OR "public"."st_isvalid"(("start_location_geo")::"public"."geometry"))),
    CONSTRAINT "drivers_availability_mode_check" CHECK (("availability_mode" = ANY (ARRAY['smart'::"text", 'manual'::"text"])))
);


ALTER TABLE "public"."drivers" OWNER TO "postgres";


COMMENT ON COLUMN "public"."drivers"."location_geo" IS 'Current/active location of driver';



COMMENT ON COLUMN "public"."drivers"."start_location_geo" IS 'Starting point/home base of driver';



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
    "updated_at" timestamp with time zone,
    "location_text" "text",
    "location_geo" "public"."geography",
    "location_lat" double precision GENERATED ALWAYS AS ("public"."st_y"(("location_geo")::"public"."geometry")) STORED,
    "location_lng" double precision GENERATED ALWAYS AS ("public"."st_x"(("location_geo")::"public"."geometry")) STORED,
    "location_accuracy_meters" double precision,
    "last_location_update" timestamp with time zone,
    "is_app_online" boolean DEFAULT false,
    "is_online_visible" boolean DEFAULT true
);


ALTER TABLE "public"."users" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."booking_locations_view" WITH ("security_invoker"='true') AS
 SELECT "b"."id" AS "booking_id",
    "b"."home_lat",
    "b"."home_lng",
    "b"."school_lat",
    "b"."school_lng",
    "b"."driver_id",
    "u"."full_name" AS "driver_name",
    "u"."phone" AS "driver_phone"
   FROM (("public"."bookings" "b"
     LEFT JOIN "public"."drivers" "d" ON (("b"."driver_id" = "d"."user_id")))
     LEFT JOIN "public"."users" "u" ON (("d"."user_id" = "u"."id")));


ALTER VIEW "public"."booking_locations_view" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."booking_schools" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "booking_id" "uuid" NOT NULL,
    "school_id" "uuid" NOT NULL,
    "sequence_order" integer,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."booking_schools" OWNER TO "postgres";


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
    "created_at" timestamp with time zone DEFAULT "now"(),
    "school_id" "uuid",
    "age" real
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


CREATE TABLE IF NOT EXISTS "public"."driver_covered_schools" (
    "driver_id" "uuid" NOT NULL,
    "school_id" "uuid" NOT NULL
);


ALTER TABLE "public"."driver_covered_schools" OWNER TO "postgres";


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
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "current_trip_id" "uuid",
    "is_tracking_active" boolean DEFAULT false,
    "next_stop_id" "uuid",
    "eta_minutes" integer,
    "students_onboard" integer DEFAULT 0,
    "trips_started" boolean DEFAULT false,
    CONSTRAINT "driver_locations_trip_type_check" CHECK (("trip_type" = ANY (ARRAY['pickup'::"text", 'dropoff'::"text", 'idle'::"text"])))
);


ALTER TABLE "public"."driver_locations" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."driver_service_areas" (
    "driver_id" "uuid" NOT NULL,
    "area_id" "uuid" NOT NULL
);


ALTER TABLE "public"."driver_service_areas" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."schools" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "address" "text",
    "location" "public"."geography"(Point,4326),
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "city_id" "uuid",
    "latitude" double precision,
    "longitude" double precision,
    "createdby" "uuid"
);


ALTER TABLE "public"."schools" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."driver_profile_view" AS
 SELECT "d"."user_id",
    "d"."user_id" AS "id",
    "d"."experience_years",
    "d"."license_number",
    "d"."license_image_url",
    "d"."license_expiry",
    "d"."vehicle_type",
    "d"."vehicle_number",
    "d"."vehicle_capacity",
    "d"."mulkia_image_url",
    "d"."vehicle_image_urls",
    "d"."price_monthly_two_way",
    "d"."price_monthly_one_way",
    "d"."price_daily",
    "d"."bio",
    "d"."rating",
    "d"."is_verified",
    "d"."license_verified",
    "d"."insurance_verified",
    "d"."background_check_verified",
    "d"."start_location_text",
    "d"."start_location_geo",
    "public"."st_x"(("d"."start_location_geo")::"public"."geometry") AS "start_location_lat",
    "public"."st_y"(("d"."start_location_geo")::"public"."geometry") AS "start_location_lng",
    "u"."full_name" AS "name",
    "u"."photo_url",
    "u"."phone",
    "u"."email",
    "u"."location_text",
    "public"."st_x"(("u"."location_geo")::"public"."geometry") AS "location_lat",
    "public"."st_y"(("u"."location_geo")::"public"."geometry") AS "location_lng",
    COALESCE(( SELECT "array_agg"("a"."name") AS "array_agg"
           FROM ("public"."driver_service_areas" "dsa"
             JOIN "public"."areas" "a" ON (("dsa"."area_id" = "a"."id")))
          WHERE ("dsa"."driver_id" = "d"."user_id")), ARRAY[]::"text"[]) AS "service_areas",
    COALESCE(( SELECT "array_agg"("s"."name") AS "array_agg"
           FROM ("public"."driver_covered_schools" "dcs"
             JOIN "public"."schools" "s" ON (("dcs"."school_id" = "s"."id")))
          WHERE ("dcs"."driver_id" = "d"."user_id")), ARRAY[]::"text"[]) AS "schools"
   FROM ("public"."drivers" "d"
     JOIN "public"."users" "u" ON (("d"."user_id" = "u"."id")));


ALTER VIEW "public"."driver_profile_view" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."driver_requests_view" WITH ("security_invoker"='true') AS
 SELECT "b"."id",
    "b"."created_at",
    "b"."parent_id",
    "b"."driver_id",
    "b"."booking_type",
    "b"."status",
    "b"."notes",
    "b"."hometxt_location",
    "b"."schooltxt_location",
    "public"."st_astext"("b"."homegeo_location") AS "homegeo_location",
    "public"."st_astext"("b"."schoolgeo_location") AS "schoolgeo_location",
    "b"."start_date",
    "b"."end_date",
    "b"."home_pickup_time",
    "b"."recurring_days",
    "b"."proposal_price",
    "b"."is_monthly_subscription",
    "b"."is_recurring",
    "b"."is_multi_school",
    "b"."school_name",
    "u"."full_name" AS "parent_name",
    "u"."photo_url" AS "parent_photo",
    "u"."phone" AS "parent_phone",
    COALESCE(( SELECT "jsonb_agg"("jsonb_build_object"('id', "c"."id", 'name', "c"."name", 'gender', "c"."gender", 'grade', "c"."grade", 'age', "c"."age")) AS "jsonb_agg"
           FROM ("public"."booking_children" "bc"
             JOIN "public"."children" "c" ON (("bc"."child_id" = "c"."id")))
          WHERE ("bc"."booking_id" = "b"."id")), '[]'::"jsonb") AS "students_info",
    COALESCE(( SELECT "jsonb_agg"("jsonb_build_object"('id', "s"."id", 'name', "s"."name", 'address', "s"."address", 'latitude', "s"."latitude", 'longitude', "s"."longitude")) AS "jsonb_agg"
           FROM ("public"."booking_schools" "bs"
             JOIN "public"."schools" "s" ON (("bs"."school_id" = "s"."id")))
          WHERE ("bs"."booking_id" = "b"."id")), '[]'::"jsonb") AS "schools_info"
   FROM ("public"."bookings" "b"
     LEFT JOIN "public"."users" "u" ON (("b"."parent_id" = "u"."id")));


ALTER VIEW "public"."driver_requests_view" OWNER TO "postgres";


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
    "is_schedactive" boolean DEFAULT true,
    CONSTRAINT "driver_schedules_day_check" CHECK (("day_of_week" = ANY (ARRAY['saturday'::"text", 'sunday'::"text", 'monday'::"text", 'tuesday'::"text", 'wednesday'::"text", 'thursday'::"text", 'friday'::"text"]))),
    CONSTRAINT "driver_schedules_shift_check" CHECK (("shift_type" = ANY (ARRAY['Go to School(s)'::"text", 'Return from School(s)'::"text", 'custom'::"text"]))),
    CONSTRAINT "driver_schedules_shift_type_check" CHECK (("shift_type" = ANY (ARRAY['Go to School(s)'::"text", 'Return from School(s)'::"text", 'custom'::"text"])))
);


ALTER TABLE "public"."driver_schedules" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."driver_stats_view" WITH ("security_invoker"='true') AS
 SELECT "user_id" AS "driver_id",
    ( SELECT "count"(DISTINCT "bc"."child_id") AS "count"
           FROM ("public"."bookings" "b"
             JOIN "public"."booking_children" "bc" ON (("b"."id" = "bc"."booking_id")))
          WHERE (("b"."driver_id" = "d"."user_id") AND ("b"."status" = ANY (ARRAY['accepted'::"text", 'confirmed'::"text", 'active'::"text"])))) AS "active_students",
    ( SELECT "count"(*) AS "count"
           FROM "public"."bookings" "b"
          WHERE (("b"."driver_id" = "d"."user_id") AND ("b"."status" = 'pending'::"text"))) AS "pending_requests",
    ( SELECT "count"(*) AS "count"
           FROM "public"."bookings" "b"
          WHERE (("b"."driver_id" = "d"."user_id") AND ("b"."status" = ANY (ARRAY['accepted'::"text", 'confirmed'::"text", 'active'::"text"])))) AS "active_bookings",
    ( SELECT COALESCE("sum"("b"."price"), (0)::numeric) AS "coalesce"
           FROM "public"."bookings" "b"
          WHERE (("b"."driver_id" = "d"."user_id") AND ("b"."status" = ANY (ARRAY['accepted'::"text", 'confirmed'::"text", 'active'::"text"])))) AS "monthly_earnings"
   FROM "public"."drivers" "d";


ALTER VIEW "public"."driver_stats_view" OWNER TO "postgres";


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
    "stop_kind" "text" DEFAULT 'student'::"text",
    "stop_label_key" "text",
    "stop_label" "text",
    "stop_context" "jsonb",
    CONSTRAINT "route_stops_label_key_not_empty" CHECK ((("stop_label_key" IS NULL) OR ("stop_label_key" <> ''::"text"))),
    CONSTRAINT "route_stops_status_check" CHECK (("status" = ANY (ARRAY['pending'::"text", 'arrived'::"text", 'completed'::"text", 'skipped'::"text"]))),
    CONSTRAINT "route_stops_stop_kind_check" CHECK (("stop_kind" = ANY (ARRAY['student'::"text", 'waypoint'::"text", 'custom'::"text"]))),
    CONSTRAINT "route_stops_stop_type_check" CHECK (("stop_type" = ANY (ARRAY['pickup'::"text", 'dropoff'::"text", 'pick up from home'::"text", 'pick up from school'::"text", 'Drop off at home'::"text", 'Drop off at school'::"text", 'Drop off at destination'::"text"])))
);


ALTER TABLE "public"."route_stops" OWNER TO "postgres";


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
    "actual_start_time" timestamp with time zone,
    "actual_end_time" timestamp with time zone,
    "trip_direction" "text",
    CONSTRAINT "trips_status_check" CHECK (("status" = ANY (ARRAY['scheduled'::"text", 'in_progress'::"text", 'completed'::"text", 'cancelled'::"text"]))),
    CONSTRAINT "trips_trip_direction_check" CHECK ((("trip_direction" IS NULL) OR ("trip_direction" = ANY (ARRAY['go'::"text", 'return'::"text", 'custom'::"text"])))),
    CONSTRAINT "trips_trip_type_check" CHECK (("trip_type" = ANY (ARRAY['Go to School(s)'::"text", 'Return from School(s)'::"text", 'custom'::"text"])))
);


ALTER TABLE "public"."trips" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."driver_trips_view" WITH ("security_invoker"='true') AS
 SELECT "id",
    "driver_id",
    "trip_date",
    "trip_type",
    "status",
    "start_time" AS "planned_start_time",
    "actual_start_time",
    "actual_end_time",
    "total_distance_km",
    COALESCE(( SELECT "jsonb_agg"("jsonb_build_object"('id', "rs"."id", 'stop_type', "rs"."stop_type", 'latitude', "rs"."location_lat", 'longitude', "rs"."location_lng", 'sequence_order', "rs"."sequence_order", 'actual_arrival_time', "rs"."arrived_at", 'status', "rs"."status", 'child_name', ( SELECT "c"."name"
                   FROM "public"."children" "c"
                  WHERE ("c"."id" = "rs"."child_id")), 'student_id', "rs"."child_id", 'booking_id', "rs"."booking_id", 'home_location', ( SELECT "b"."hometxt_location"
                   FROM "public"."bookings" "b"
                  WHERE ("b"."id" = "rs"."booking_id")), 'school_location', ( SELECT "b"."schooltxt_location"
                   FROM "public"."bookings" "b"
                  WHERE ("b"."id" = "rs"."booking_id"))) ORDER BY "rs"."sequence_order") AS "jsonb_agg"
           FROM "public"."route_stops" "rs"
          WHERE ("rs"."trip_id" = "t"."id")), '[]'::"jsonb") AS "route_stops"
   FROM "public"."trips" "t";


ALTER VIEW "public"."driver_trips_view" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."i18n_strings" (
    "key" "text" NOT NULL,
    "locale" "text" NOT NULL,
    "value" "text" NOT NULL
);


ALTER TABLE "public"."i18n_strings" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."ride_events" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "booking_id" "uuid",
    "driver_id" "uuid",
    "parent_id" "uuid",
    "event_type" "text" NOT NULL,
    "event_data" "jsonb" DEFAULT '{}'::"jsonb",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "read_at" timestamp with time zone,
    "daily_trip_id" "uuid",
    CONSTRAINT "ride_events_event_type_check" CHECK (("event_type" = ANY (ARRAY['approaching'::"text", 'arrived'::"text", 'picked_up'::"text", 'dropped_off'::"text", 'trip_started'::"text", 'skipped'::"text"])))
);


ALTER TABLE "public"."ride_events" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."latest_booking_event" AS
 SELECT DISTINCT ON ("booking_id") "id",
    "booking_id",
    "driver_id",
    "parent_id",
    "daily_trip_id",
    "event_type",
    "event_data",
    "created_at"
   FROM "public"."ride_events"
  ORDER BY "booking_id", "created_at" DESC;


ALTER VIEW "public"."latest_booking_event" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."media_assets" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "owner_id" "uuid" NOT NULL,
    "r2_key" "text" NOT NULL,
    "visibility" "text" NOT NULL,
    "asset_type" "text" NOT NULL,
    "mime_type" "text" DEFAULT 'image/jpeg'::"text",
    "file_size" bigint,
    "original_filename" "text",
    "status" "text" DEFAULT 'pending'::"text",
    "legacy_column" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "uploaded_at" timestamp with time zone,
    "expires_at" timestamp with time zone DEFAULT ("now"() + '00:15:00'::interval),
    "metadata" "jsonb" DEFAULT '{}'::"jsonb",
    CONSTRAINT "media_assets_asset_type_check" CHECK (("asset_type" = ANY (ARRAY['avatar'::"text", 'license'::"text", 'mulkia'::"text", 'child_photo'::"text", 'adv_photo'::"text", 'vehicle_photo'::"text"]))),
    CONSTRAINT "media_assets_status_check" CHECK (("status" = ANY (ARRAY['pending'::"text", 'uploaded'::"text", 'failed'::"text", 'deleted'::"text"]))),
    CONSTRAINT "media_assets_visibility_check" CHECK (("visibility" = ANY (ARRAY['public'::"text", 'private'::"text"]))),
    CONSTRAINT "valid_r2_key" CHECK (("r2_key" ~ '^(public|private)/'::"text"))
);


ALTER TABLE "public"."media_assets" OWNER TO "postgres";


COMMENT ON TABLE "public"."media_assets" IS 'Tracks media assets stored in Cloudflare R2';



COMMENT ON COLUMN "public"."media_assets"."r2_key" IS 'Full path in R2 bucket: public/users/{id}/avatar/xxx.webp or private/drivers/{id}/license/xxx.webp';



COMMENT ON COLUMN "public"."media_assets"."visibility" IS 'public = direct URL access, private = requires signed URL';



COMMENT ON COLUMN "public"."media_assets"."legacy_column" IS 'Database column to update with final URL, e.g., users.photo_url';



COMMENT ON COLUMN "public"."media_assets"."expires_at" IS 'Pending uploads not finalized by this time are marked as failed';



CREATE TABLE IF NOT EXISTS "public"."messages" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "sender_id" "uuid" NOT NULL,
    "receiver_id" "uuid" NOT NULL,
    "content" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "is_read" boolean DEFAULT false,
    "conversation_id" "text" NOT NULL
);


ALTER TABLE "public"."messages" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."notes" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "text" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."notes" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."parent_bookings_view" AS
 SELECT "b"."id",
    "b"."parent_id",
    "b"."driver_id",
    "b"."booking_type",
    "b"."status",
    "b"."hometxt_location",
    "b"."schooltxt_location",
    "b"."home_pickup_time",
    "b"."school_pickup_time",
    "b"."price",
    "b"."notes",
    "b"."created_at",
    "b"."is_recurring",
    "b"."recurrence_pattern",
    "b"."subscription_status",
    "b"."start_date",
    "b"."end_date",
    ("b"."homegeo_location")::"text" AS "homegeo_location_text",
    ("b"."schoolgeo_location")::"text" AS "schoolgeo_location_text",
    "b"."home_lat",
    "b"."home_lng",
    "b"."school_lat",
    "b"."school_lng",
    "b"."routego_order",
    "b"."routeret_order",
    "b"."is_monthly_subscription",
    "b"."student_id",
    "b"."school_id",
    "b"."recurring_days",
    "b"."payment_status",
    "b"."cancellation_reason",
    "b"."cancelled_at",
    "b"."contract_start_date",
    "b"."contract_end_date",
    "b"."school_name",
    "b"."cancellation_type",
    "b"."cancellation_fee",
    "b"."cancel_requested_at",
    "b"."pause_start_date",
    "b"."pause_end_date",
    "b"."trip_category",
    "b"."is_one_time",
    "b"."scheduled_pickup_datetime",
    "b"."scheduled_dropoff_datetime",
    "b"."custom_pickup_location_text",
    ("b"."custom_pickup_geo")::"text" AS "custom_pickup_geo_text",
    "b"."custom_dropoff_location_text",
    ("b"."custom_dropoff_geo")::"text" AS "custom_dropoff_geo_text",
    "b"."booking_flow_step",
    "b"."total_estimated_distance_km",
    "b"."total_estimated_duration_minutes",
    "b"."custom_pickup_lat",
    "b"."custom_pickup_lng",
    "b"."custom_dropoff_lat",
    "b"."custom_dropoff_lng",
    "b"."is_multi_school",
    "b"."proposal_price",
    "b"."is_for_parent",
    "b"."school_ids",
    "u"."full_name" AS "driver_name",
    "u"."photo_url" AS "driver_photo",
    "u"."phone" AS "driver_phone",
    "s"."name" AS "school_name_lookup",
    "s"."address" AS "school_address"
   FROM (("public"."bookings" "b"
     LEFT JOIN "public"."users" "u" ON (("b"."driver_id" = "u"."id")))
     LEFT JOIN "public"."schools" "s" ON (("b"."school_id" = "s"."id")));


ALTER VIEW "public"."parent_bookings_view" OWNER TO "postgres";


COMMENT ON VIEW "public"."parent_bookings_view" IS 'Denormalized view for parent bookings with driver and school info';



CREATE OR REPLACE VIEW "public"."parent_notifications_view" AS
 SELECT "re"."id",
    "re"."booking_id",
    "re"."driver_id",
    "re"."parent_id",
    "re"."daily_trip_id",
    "re"."event_type",
    "re"."event_data",
    "re"."created_at",
    "re"."read_at",
    ( SELECT "string_agg"("c"."name", ', '::"text") AS "string_agg"
           FROM ("public"."booking_children" "bc"
             JOIN "public"."children" "c" ON (("bc"."child_id" = "c"."id")))
          WHERE ("bc"."booking_id" = "re"."booking_id")) AS "child_name",
    "u"."full_name" AS "driver_name",
    "u"."photo_url" AS "driver_photo"
   FROM ("public"."ride_events" "re"
     LEFT JOIN "public"."users" "u" ON (("re"."driver_id" = "u"."id")));


ALTER VIEW "public"."parent_notifications_view" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."parent_tracking_snapshot" AS
 SELECT "b"."id" AS "booking_id",
    "b"."parent_id",
    "lbe"."driver_id",
    "lbe"."daily_trip_id" AS "trip_id",
    "lbe"."event_type",
    "lbe"."event_data",
    "lbe"."created_at" AS "event_created_at",
    "dl"."latitude",
    "dl"."longitude",
    "dl"."eta_minutes",
    "dl"."trips_started",
    "t"."trip_type",
    "t"."trip_direction",
    "t"."status" AS "trip_status",
        CASE
            WHEN ("d"."is_active" IS FALSE) THEN 'OFFLINE'::"text"
            WHEN ("lbe"."event_type" = 'dropped_off'::"text") THEN 'COMPLETED'::"text"
            WHEN ("lbe"."event_type" = 'arrived'::"text") THEN 'ARRIVED'::"text"
            WHEN ("lbe"."event_type" = 'picked_up'::"text") THEN 'ON_TRIP'::"text"
            WHEN ("lbe"."event_type" = 'trip_started'::"text") THEN 'LIVE_TRIP'::"text"
            ELSE 'SCHEDULED'::"text"
        END AS "status_badge",
        CASE
            WHEN ("d"."is_active" IS FALSE) THEN 'Scheduled Trip'::"text"
            WHEN ("lbe"."event_type" = 'dropped_off'::"text") THEN 'Child Dropped Off'::"text"
            WHEN ("lbe"."event_type" = 'arrived'::"text") THEN 'Driver Arrived'::"text"
            WHEN ("lbe"."event_type" = 'picked_up'::"text") THEN 'Child Picked Up'::"text"
            WHEN ("lbe"."event_type" = 'trip_started'::"text") THEN 'Trip Started'::"text"
            ELSE 'Trip Scheduled'::"text"
        END AS "ui_title",
        CASE
            WHEN ("d"."is_active" IS FALSE) THEN 'Driver is currently offline'::"text"
            WHEN ("lbe"."event_type" = 'dropped_off'::"text") THEN 'Arrived safely'::"text"
            WHEN ("lbe"."event_type" = 'arrived'::"text") THEN ("lbe"."event_data" ->> 'description'::"text")
            WHEN ("lbe"."event_type" = 'picked_up'::"text") THEN (('Heading to destination · '::"text" || COALESCE("dl"."eta_minutes", 0)) || ' min'::"text")
            WHEN ("lbe"."event_type" = 'trip_started'::"text") THEN (COALESCE("dl"."eta_minutes", 0) || ' min away'::"text")
            ELSE 'Waiting for trip to begin'::"text"
        END AS "ui_subtitle",
        CASE
            WHEN ("t"."trip_type" = 'Go to School(s)'::"text") THEN true
            ELSE false
        END AS "is_go_trip"
   FROM (((("public"."bookings" "b"
     LEFT JOIN "public"."latest_booking_event" "lbe" ON (("lbe"."booking_id" = "b"."id")))
     LEFT JOIN "public"."driver_locations" "dl" ON (("dl"."driver_id" = "lbe"."driver_id")))
     LEFT JOIN "public"."trips" "t" ON (("t"."id" = "lbe"."daily_trip_id")))
     LEFT JOIN "public"."drivers" "d" ON (("d"."user_id" = "lbe"."driver_id")));


ALTER VIEW "public"."parent_tracking_snapshot" OWNER TO "postgres";


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


CREATE TABLE IF NOT EXISTS "public"."saved_drivers" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "parent_id" "uuid",
    "driver_id" "uuid",
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL
);


ALTER TABLE "public"."saved_drivers" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."tracking_view" AS
 SELECT "dl"."driver_id",
    "dl"."latitude",
    "dl"."longitude",
    "dl"."heading",
    "dl"."speed",
    "dl"."trip_type",
    "dl"."updated_at",
    "dl"."current_trip_id",
    "dl"."is_tracking_active",
    "dl"."next_stop_id",
    "dl"."eta_minutes",
    "dl"."students_onboard",
    "dl"."trips_started",
    "u"."is_app_online",
    "u"."is_online_visible" AS "is_profile_online",
    (COALESCE("u"."is_app_online", false) AND COALESCE("u"."is_online_visible", true)) AS "is_online"
   FROM ("public"."driver_locations" "dl"
     JOIN "public"."users" "u" ON (("dl"."driver_id" = "u"."id")));


ALTER VIEW "public"."tracking_view" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."trip_tracking" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "daily_trip_id" "uuid",
    "latitude" double precision NOT NULL,
    "longitude" double precision NOT NULL,
    "heading" double precision,
    "speed" double precision,
    "recorded_at" timestamp with time zone DEFAULT "now"(),
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."trip_tracking" OWNER TO "postgres";


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


ALTER TABLE ONLY "public"."areas"
    ADD CONSTRAINT "areas_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."booking_children"
    ADD CONSTRAINT "booking_children_pkey" PRIMARY KEY ("booking_id", "child_id");



ALTER TABLE ONLY "public"."booking_schools"
    ADD CONSTRAINT "booking_schools_booking_id_school_id_key" UNIQUE ("booking_id", "school_id");



ALTER TABLE ONLY "public"."booking_schools"
    ADD CONSTRAINT "booking_schools_pkey" PRIMARY KEY ("id");



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



ALTER TABLE ONLY "public"."i18n_strings"
    ADD CONSTRAINT "i18n_strings_pkey" PRIMARY KEY ("key", "locale");



ALTER TABLE ONLY "public"."media_assets"
    ADD CONSTRAINT "media_assets_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."media_assets"
    ADD CONSTRAINT "media_assets_r2_key_key" UNIQUE ("r2_key");



ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."notes"
    ADD CONSTRAINT "notes_pkey" PRIMARY KEY ("id");



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



ALTER TABLE ONLY "public"."trip_tracking"
    ADD CONSTRAINT "trip_tracking_pkey" PRIMARY KEY ("id");



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



CREATE INDEX "idx_booking_schools_booking_id" ON "public"."booking_schools" USING "btree" ("booking_id");



CREATE INDEX "idx_booking_schools_school_id" ON "public"."booking_schools" USING "btree" ("school_id");



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



CREATE INDEX "idx_children_school_id" ON "public"."children" USING "btree" ("school_id");



CREATE INDEX "idx_driver_covered_schools_lookup" ON "public"."driver_covered_schools" USING "btree" ("driver_id", "school_id");



CREATE INDEX "idx_driver_covered_schools_school_id" ON "public"."driver_covered_schools" USING "btree" ("school_id");



CREATE INDEX "idx_driver_locations_driver_id" ON "public"."driver_locations" USING "btree" ("driver_id");



CREATE UNIQUE INDEX "idx_driver_review_stats_id" ON "public"."driver_review_stats" USING "btree" ("driver_id");



CREATE INDEX "idx_driver_schedules_lookup" ON "public"."driver_schedules" USING "btree" ("driver_id", "day_of_week", "is_schedactive");



CREATE INDEX "idx_driver_service_areas_lookup" ON "public"."driver_service_areas" USING "btree" ("driver_id", "area_id");



CREATE INDEX "idx_drivers_location_geo" ON "public"."drivers" USING "gist" ("location_geo");



CREATE INDEX "idx_drivers_price" ON "public"."drivers" USING "btree" ("price_monthly_two_way");



CREATE INDEX "idx_drivers_rating" ON "public"."drivers" USING "btree" ("rating" DESC);



CREATE INDEX "idx_drivers_search_composite" ON "public"."drivers" USING "btree" ("is_verified", "rating" DESC, "vehicle_type") WHERE ("is_active" = true);



CREATE INDEX "idx_drivers_start_location_geo" ON "public"."drivers" USING "gist" ("start_location_geo");



CREATE INDEX "idx_media_assets_expires" ON "public"."media_assets" USING "btree" ("expires_at") WHERE ("status" = 'pending'::"text");



CREATE INDEX "idx_media_assets_owner" ON "public"."media_assets" USING "btree" ("owner_id");



CREATE INDEX "idx_media_assets_status" ON "public"."media_assets" USING "btree" ("status") WHERE ("status" = 'pending'::"text");



CREATE INDEX "idx_media_assets_type" ON "public"."media_assets" USING "btree" ("asset_type");



CREATE INDEX "idx_messages_conversation_id" ON "public"."messages" USING "btree" ("conversation_id");



CREATE INDEX "idx_ride_events_booking" ON "public"."ride_events" USING "btree" ("booking_id");



CREATE INDEX "idx_ride_events_booking_created_desc" ON "public"."ride_events" USING "btree" ("booking_id", "created_at" DESC);



CREATE INDEX "idx_ride_events_created" ON "public"."ride_events" USING "btree" ("created_at" DESC);



CREATE INDEX "idx_ride_events_parent" ON "public"."ride_events" USING "btree" ("parent_id");



CREATE INDEX "idx_ride_events_read_at" ON "public"."ride_events" USING "btree" ("read_at");



CREATE INDEX "idx_route_stops_booking_trip" ON "public"."route_stops" USING "btree" ("booking_id", "trip_id");



CREATE INDEX "idx_route_stops_geo" ON "public"."route_stops" USING "gist" ("location_geo");



CREATE INDEX "idx_route_stops_trip_booking_status_seq" ON "public"."route_stops" USING "btree" ("trip_id", "booking_id", "status", "sequence_order");



CREATE INDEX "idx_route_stops_trip_id" ON "public"."route_stops" USING "btree" ("trip_id");



CREATE INDEX "idx_route_stops_trip_status_seq" ON "public"."route_stops" USING "btree" ("trip_id", "status", "sequence_order");



CREATE INDEX "idx_route_stops_trip_status_sequence" ON "public"."route_stops" USING "btree" ("trip_id", "status", "sequence_order");



CREATE INDEX "idx_schools_city_id" ON "public"."schools" USING "btree" ("city_id");



CREATE INDEX "idx_trip_tracking_trip_date" ON "public"."trip_tracking" USING "btree" ("daily_trip_id", "recorded_at" DESC);



CREATE INDEX "idx_trips_driver_date" ON "public"."trips" USING "btree" ("driver_id", "trip_date");



CREATE INDEX "idx_trips_status_date_time" ON "public"."trips" USING "btree" ("status", "trip_date" DESC, "start_time" DESC);



CREATE INDEX "idx_users_email" ON "public"."users" USING "btree" ("email");



CREATE INDEX "idx_users_roles" ON "public"."users" USING "gin" ("role");



CREATE UNIQUE INDEX "saved_drivers_parent_driver_uniq" ON "public"."saved_drivers" USING "btree" ("parent_id", "driver_id");



CREATE OR REPLACE TRIGGER "on_review_change" AFTER INSERT OR DELETE OR UPDATE ON "public"."reviews" FOR EACH STATEMENT EXECUTE FUNCTION "public"."refresh_driver_stats"();



CREATE OR REPLACE TRIGGER "on_ride_event_notify" AFTER INSERT ON "public"."ride_events" FOR EACH ROW EXECUTE FUNCTION "public"."notify_parent_on_ride_event"();



CREATE OR REPLACE TRIGGER "trg_check_duplicate_child_booking" BEFORE INSERT OR UPDATE ON "public"."booking_children" FOR EACH ROW EXECUTE FUNCTION "public"."check_duplicate_child_booking"();



CREATE OR REPLACE TRIGGER "trigger_route_stop_label_sync" BEFORE INSERT OR UPDATE OF "trip_id", "stop_type", "stop_kind", "stop_label_key", "stop_context" ON "public"."route_stops" FOR EACH ROW EXECUTE FUNCTION "public"."sync_route_stop_label_v3"();



CREATE OR REPLACE TRIGGER "trigger_route_stops_geo_sync" BEFORE INSERT OR UPDATE ON "public"."route_stops" FOR EACH ROW EXECUTE FUNCTION "public"."sync_stop_latlng_to_geo"();



CREATE OR REPLACE TRIGGER "trigger_set_conversation_id" BEFORE INSERT ON "public"."messages" FOR EACH ROW EXECUTE FUNCTION "public"."set_conversation_id"();



CREATE OR REPLACE TRIGGER "trigger_sync_booking_school_location" BEFORE INSERT OR UPDATE OF "school_id", "schoolgeo_location", "schooltxt_location" ON "public"."bookings" FOR EACH ROW EXECUTE FUNCTION "public"."sync_booking_school_location"();



ALTER TABLE ONLY "public"."areas"
    ADD CONSTRAINT "areas_city_id_fkey" FOREIGN KEY ("city_id") REFERENCES "public"."cities"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."booking_children"
    ADD CONSTRAINT "booking_children_booking_id_fkey" FOREIGN KEY ("booking_id") REFERENCES "public"."bookings"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."booking_children"
    ADD CONSTRAINT "booking_children_child_id_fkey" FOREIGN KEY ("child_id") REFERENCES "public"."children"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."booking_schools"
    ADD CONSTRAINT "booking_schools_booking_id_fkey" FOREIGN KEY ("booking_id") REFERENCES "public"."bookings"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."booking_schools"
    ADD CONSTRAINT "booking_schools_school_id_fkey" FOREIGN KEY ("school_id") REFERENCES "public"."schools"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."bookings"
    ADD CONSTRAINT "bookings_driver_id_fkey" FOREIGN KEY ("driver_id") REFERENCES "public"."drivers"("user_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."bookings"
    ADD CONSTRAINT "bookings_parent_id_fkey" FOREIGN KEY ("parent_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."children"
    ADD CONSTRAINT "children_parent_id_fkey" FOREIGN KEY ("parent_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."children"
    ADD CONSTRAINT "children_school_id_fkey" FOREIGN KEY ("school_id") REFERENCES "public"."schools"("id");



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



ALTER TABLE ONLY "public"."driver_locations"
    ADD CONSTRAINT "driver_locations_next_stop_id_fkey" FOREIGN KEY ("next_stop_id") REFERENCES "public"."route_stops"("id");



ALTER TABLE ONLY "public"."driver_schedules"
    ADD CONSTRAINT "driver_schedules_driver_id_fkey" FOREIGN KEY ("driver_id") REFERENCES "public"."drivers"("user_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."driver_service_areas"
    ADD CONSTRAINT "driver_service_areas_area_id_fkey" FOREIGN KEY ("area_id") REFERENCES "public"."areas"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."driver_service_areas"
    ADD CONSTRAINT "driver_service_areas_driver_id_fkey" FOREIGN KEY ("driver_id") REFERENCES "public"."drivers"("user_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."drivers"
    ADD CONSTRAINT "drivers_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."trip_tracking"
    ADD CONSTRAINT "fk_trip_tracking_trip" FOREIGN KEY ("daily_trip_id") REFERENCES "public"."trips"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."media_assets"
    ADD CONSTRAINT "media_assets_owner_id_fkey" FOREIGN KEY ("owner_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



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
    ADD CONSTRAINT "ride_events_daily_trip_id_fkey" FOREIGN KEY ("daily_trip_id") REFERENCES "public"."trips"("id") ON DELETE CASCADE;



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



ALTER TABLE ONLY "public"."trip_tracking"
    ADD CONSTRAINT "trip_tracking_daily_trip_id_fkey" FOREIGN KEY ("daily_trip_id") REFERENCES "public"."trips"("id") ON DELETE CASCADE;



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



CREATE POLICY "Drivers can add their own covered schools" ON "public"."driver_covered_schools" FOR INSERT WITH CHECK (("auth"."uid"() = "driver_id"));



CREATE POLICY "Drivers can add their own service areas" ON "public"."driver_service_areas" FOR INSERT WITH CHECK (("auth"."uid"() = "driver_id"));



CREATE POLICY "Drivers can insert ride events" ON "public"."ride_events" FOR INSERT TO "authenticated" WITH CHECK (("auth"."uid"() = "driver_id"));



CREATE POLICY "Drivers can manage their own location" ON "public"."driver_locations" USING (("auth"."uid"() = "driver_id")) WITH CHECK (("auth"."uid"() = "driver_id"));



CREATE POLICY "Drivers can read their own trips" ON "public"."trips" FOR SELECT USING (("driver_id" = "auth"."uid"()));



CREATE POLICY "Drivers can remove their own covered schools" ON "public"."driver_covered_schools" FOR DELETE USING (("auth"."uid"() = "driver_id"));



CREATE POLICY "Drivers can remove their own service areas" ON "public"."driver_service_areas" FOR DELETE USING (("auth"."uid"() = "driver_id"));



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



CREATE POLICY "Drivers can view open bookings" ON "public"."bookings" FOR SELECT TO "authenticated" USING ((("driver_id" IS NULL) AND ("status" = ANY (ARRAY['posted'::"text", 'pending'::"text", 'open'::"text"]))));



CREATE POLICY "Drivers can view their ride events" ON "public"."ride_events" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "driver_id"));



CREATE POLICY "Enable delete for users" ON "public"."saved_drivers" FOR DELETE USING (("auth"."uid"() = "parent_id"));



CREATE POLICY "Enable insert for authenticated users" ON "public"."saved_drivers" FOR INSERT WITH CHECK (("auth"."uid"() = "parent_id"));



CREATE POLICY "Enable read access for all users" ON "public"."areas" FOR SELECT USING (true);



CREATE POLICY "Enable read access for all users" ON "public"."cities" FOR SELECT USING (true);



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



CREATE POLICY "Parents can update their ride events" ON "public"."ride_events" FOR UPDATE TO "authenticated" USING (("parent_id" = "auth"."uid"())) WITH CHECK (("parent_id" = "auth"."uid"()));



CREATE POLICY "Parents can view relevant drivers" ON "public"."driver_locations" FOR SELECT USING ((("is_tracking_active" = true) OR (EXISTS ( SELECT 1
   FROM "public"."bookings"
  WHERE (("bookings"."driver_id" = "driver_locations"."driver_id") AND ("bookings"."parent_id" = "auth"."uid"()) AND ("bookings"."status" = 'accepted'::"text"))))));



CREATE POLICY "Parents can view their ride events" ON "public"."ride_events" FOR SELECT TO "authenticated" USING (("parent_id" = "auth"."uid"()));



CREATE POLICY "Public Usage" ON "public"."users" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Public can view driver covered schools" ON "public"."driver_covered_schools" FOR SELECT USING (true);



CREATE POLICY "Public reads reviews" ON "public"."reviews" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Users can delete own assets" ON "public"."media_assets" FOR DELETE USING (("auth"."uid"() = "owner_id"));



CREATE POLICY "Users can insert pending assets" ON "public"."media_assets" FOR INSERT WITH CHECK ((("auth"."uid"() = "owner_id") AND ("status" = 'pending'::"text")));



CREATE POLICY "Users can read own profile" ON "public"."users" FOR SELECT USING (("id" = "auth"."uid"()));



CREATE POLICY "Users can send messages" ON "public"."messages" FOR INSERT WITH CHECK (("auth"."uid"() = "sender_id"));



CREATE POLICY "Users can update own pending assets" ON "public"."media_assets" FOR UPDATE USING ((("auth"."uid"() = "owner_id") AND ("status" = 'pending'::"text"))) WITH CHECK (("auth"."uid"() = "owner_id"));



CREATE POLICY "Users can view own assets" ON "public"."media_assets" FOR SELECT USING (("auth"."uid"() = "owner_id"));



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


ALTER TABLE "public"."media_assets" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."messages" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."payments" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."reviews" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."ride_events" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."route_stops" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."saved_drivers" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."schools" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."trip_tracking" ENABLE ROW LEVEL SECURITY;


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



GRANT ALL ON FUNCTION "public"."cleanup_expired_pending_uploads"() TO "anon";
GRANT ALL ON FUNCTION "public"."cleanup_expired_pending_uploads"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."cleanup_expired_pending_uploads"() TO "service_role";



GRANT ALL ON FUNCTION "public"."complete_trip"("trip_id_input" "uuid", "driver_lat" double precision, "driver_lng" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."complete_trip"("trip_id_input" "uuid", "driver_lat" double precision, "driver_lng" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."complete_trip"("trip_id_input" "uuid", "driver_lat" double precision, "driver_lng" double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."complete_trip_with_auto_offline"("trip_id_input" "uuid", "driver_lat" double precision, "driver_lng" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."complete_trip_with_auto_offline"("trip_id_input" "uuid", "driver_lat" double precision, "driver_lng" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."complete_trip_with_auto_offline"("trip_id_input" "uuid", "driver_lat" double precision, "driver_lng" double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."finalize_media_upload"("p_asset_id" "uuid", "p_file_size" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."finalize_media_upload"("p_asset_id" "uuid", "p_file_size" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."finalize_media_upload"("p_asset_id" "uuid", "p_file_size" bigint) TO "service_role";



GRANT ALL ON FUNCTION "public"."generate_go_trips"("target_date" "date", "target_driver_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."generate_go_trips"("target_date" "date", "target_driver_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."generate_go_trips"("target_date" "date", "target_driver_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."generate_return_trips"("target_date" "date", "target_driver_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."generate_return_trips"("target_date" "date", "target_driver_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."generate_return_trips"("target_date" "date", "target_driver_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_asset_public_url"("asset_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_asset_public_url"("asset_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_asset_public_url"("asset_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_driver_availability_settings"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_driver_availability_settings"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_driver_availability_settings"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_parent_tracking_ui_state"("booking_id_input" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_parent_tracking_ui_state"("booking_id_input" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_parent_tracking_ui_state"("booking_id_input" "uuid") TO "service_role";



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



GRANT ALL ON FUNCTION "public"."regenerate_daily_trips"("target_date" "date") TO "anon";
GRANT ALL ON FUNCTION "public"."regenerate_daily_trips"("target_date" "date") TO "authenticated";
GRANT ALL ON FUNCTION "public"."regenerate_daily_trips"("target_date" "date") TO "service_role";



GRANT ALL ON FUNCTION "public"."save_trip_order_as_default"("trip_id_input" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."save_trip_order_as_default"("trip_id_input" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."save_trip_order_as_default"("trip_id_input" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."search_drivers_for_parent_v2"("filter_gender" "text", "filter_vehicle_type" "text", "filter_min_rating" numeric, "max_price_monthly_two_way" numeric, "filter_area_id" "uuid", "filter_school_id" "uuid", "search_term" "text", "parent_location_lat" double precision, "parent_location_lng" double precision, "max_distance_km" integer, "filter_online_only" boolean, "require_verified" boolean, "page_limit" integer, "page_offset" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."search_drivers_for_parent_v2"("filter_gender" "text", "filter_vehicle_type" "text", "filter_min_rating" numeric, "max_price_monthly_two_way" numeric, "filter_area_id" "uuid", "filter_school_id" "uuid", "search_term" "text", "parent_location_lat" double precision, "parent_location_lng" double precision, "max_distance_km" integer, "filter_online_only" boolean, "require_verified" boolean, "page_limit" integer, "page_offset" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."search_drivers_for_parent_v2"("filter_gender" "text", "filter_vehicle_type" "text", "filter_min_rating" numeric, "max_price_monthly_two_way" numeric, "filter_area_id" "uuid", "filter_school_id" "uuid", "search_term" "text", "parent_location_lat" double precision, "parent_location_lng" double precision, "max_distance_km" integer, "filter_online_only" boolean, "require_verified" boolean, "page_limit" integer, "page_offset" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."set_conversation_id"() TO "anon";
GRANT ALL ON FUNCTION "public"."set_conversation_id"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_conversation_id"() TO "service_role";



GRANT ALL ON FUNCTION "public"."set_driver_current_location"("p_user_id" "uuid", "p_latitude" double precision, "p_longitude" double precision, "p_address" "text", "p_accuracy_meters" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."set_driver_current_location"("p_user_id" "uuid", "p_latitude" double precision, "p_longitude" double precision, "p_address" "text", "p_accuracy_meters" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_driver_current_location"("p_user_id" "uuid", "p_latitude" double precision, "p_longitude" double precision, "p_address" "text", "p_accuracy_meters" double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."set_online_visibility"("p_is_visible" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."set_online_visibility"("p_is_visible" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_online_visibility"("p_is_visible" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."set_profile_online_status"("p_is_online" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."set_profile_online_status"("p_is_online" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_profile_online_status"("p_is_online" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."set_tracking_status"("p_is_tracking" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."set_tracking_status"("p_is_tracking" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_tracking_status"("p_is_tracking" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."set_user_online_status"("p_is_online" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."set_user_online_status"("p_is_online" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_user_online_status"("p_is_online" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."start_trip"("trip_id_input" "uuid", "driver_lat" double precision, "driver_lng" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."start_trip"("trip_id_input" "uuid", "driver_lat" double precision, "driver_lng" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."start_trip"("trip_id_input" "uuid", "driver_lat" double precision, "driver_lng" double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."sync_booking_school_location"() TO "anon";
GRANT ALL ON FUNCTION "public"."sync_booking_school_location"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."sync_booking_school_location"() TO "service_role";



GRANT ALL ON FUNCTION "public"."sync_route_stop_label_v3"() TO "anon";
GRANT ALL ON FUNCTION "public"."sync_route_stop_label_v3"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."sync_route_stop_label_v3"() TO "service_role";



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



GRANT ALL ON TABLE "public"."drivers" TO "anon";
GRANT ALL ON TABLE "public"."drivers" TO "authenticated";
GRANT ALL ON TABLE "public"."drivers" TO "service_role";



GRANT ALL ON TABLE "public"."users" TO "anon";
GRANT ALL ON TABLE "public"."users" TO "authenticated";
GRANT ALL ON TABLE "public"."users" TO "service_role";



GRANT ALL ON TABLE "public"."booking_locations_view" TO "anon";
GRANT ALL ON TABLE "public"."booking_locations_view" TO "authenticated";
GRANT ALL ON TABLE "public"."booking_locations_view" TO "service_role";



GRANT ALL ON TABLE "public"."booking_schools" TO "anon";
GRANT ALL ON TABLE "public"."booking_schools" TO "authenticated";
GRANT ALL ON TABLE "public"."booking_schools" TO "service_role";



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



GRANT ALL ON TABLE "public"."driver_covered_schools" TO "anon";
GRANT ALL ON TABLE "public"."driver_covered_schools" TO "authenticated";
GRANT ALL ON TABLE "public"."driver_covered_schools" TO "service_role";



GRANT ALL ON TABLE "public"."driver_documents" TO "anon";
GRANT ALL ON TABLE "public"."driver_documents" TO "authenticated";
GRANT ALL ON TABLE "public"."driver_documents" TO "service_role";



GRANT ALL ON TABLE "public"."driver_locations" TO "anon";
GRANT ALL ON TABLE "public"."driver_locations" TO "authenticated";
GRANT ALL ON TABLE "public"."driver_locations" TO "service_role";



GRANT ALL ON TABLE "public"."driver_service_areas" TO "anon";
GRANT ALL ON TABLE "public"."driver_service_areas" TO "authenticated";
GRANT ALL ON TABLE "public"."driver_service_areas" TO "service_role";



GRANT ALL ON TABLE "public"."schools" TO "anon";
GRANT ALL ON TABLE "public"."schools" TO "authenticated";
GRANT ALL ON TABLE "public"."schools" TO "service_role";



GRANT ALL ON TABLE "public"."driver_profile_view" TO "anon";
GRANT ALL ON TABLE "public"."driver_profile_view" TO "authenticated";
GRANT ALL ON TABLE "public"."driver_profile_view" TO "service_role";



GRANT ALL ON TABLE "public"."driver_requests_view" TO "anon";
GRANT ALL ON TABLE "public"."driver_requests_view" TO "authenticated";
GRANT ALL ON TABLE "public"."driver_requests_view" TO "service_role";



GRANT ALL ON TABLE "public"."reviews" TO "anon";
GRANT ALL ON TABLE "public"."reviews" TO "authenticated";
GRANT ALL ON TABLE "public"."reviews" TO "service_role";



GRANT ALL ON TABLE "public"."driver_review_stats" TO "anon";
GRANT ALL ON TABLE "public"."driver_review_stats" TO "authenticated";
GRANT ALL ON TABLE "public"."driver_review_stats" TO "service_role";



GRANT ALL ON TABLE "public"."driver_schedules" TO "anon";
GRANT ALL ON TABLE "public"."driver_schedules" TO "authenticated";
GRANT ALL ON TABLE "public"."driver_schedules" TO "service_role";



GRANT ALL ON TABLE "public"."driver_stats_view" TO "anon";
GRANT ALL ON TABLE "public"."driver_stats_view" TO "authenticated";
GRANT ALL ON TABLE "public"."driver_stats_view" TO "service_role";



GRANT ALL ON TABLE "public"."route_stops" TO "anon";
GRANT ALL ON TABLE "public"."route_stops" TO "authenticated";
GRANT ALL ON TABLE "public"."route_stops" TO "service_role";



GRANT ALL ON TABLE "public"."trips" TO "anon";
GRANT ALL ON TABLE "public"."trips" TO "authenticated";
GRANT ALL ON TABLE "public"."trips" TO "service_role";



GRANT ALL ON TABLE "public"."driver_trips_view" TO "anon";
GRANT ALL ON TABLE "public"."driver_trips_view" TO "authenticated";
GRANT ALL ON TABLE "public"."driver_trips_view" TO "service_role";



GRANT ALL ON TABLE "public"."i18n_strings" TO "anon";
GRANT ALL ON TABLE "public"."i18n_strings" TO "authenticated";
GRANT ALL ON TABLE "public"."i18n_strings" TO "service_role";



GRANT ALL ON TABLE "public"."ride_events" TO "anon";
GRANT ALL ON TABLE "public"."ride_events" TO "authenticated";
GRANT ALL ON TABLE "public"."ride_events" TO "service_role";



GRANT ALL ON TABLE "public"."latest_booking_event" TO "anon";
GRANT ALL ON TABLE "public"."latest_booking_event" TO "authenticated";
GRANT ALL ON TABLE "public"."latest_booking_event" TO "service_role";



GRANT ALL ON TABLE "public"."media_assets" TO "anon";
GRANT ALL ON TABLE "public"."media_assets" TO "authenticated";
GRANT ALL ON TABLE "public"."media_assets" TO "service_role";



GRANT ALL ON TABLE "public"."messages" TO "anon";
GRANT ALL ON TABLE "public"."messages" TO "authenticated";
GRANT ALL ON TABLE "public"."messages" TO "service_role";



GRANT ALL ON TABLE "public"."notes" TO "anon";
GRANT ALL ON TABLE "public"."notes" TO "authenticated";
GRANT ALL ON TABLE "public"."notes" TO "service_role";



GRANT ALL ON TABLE "public"."parent_bookings_view" TO "anon";
GRANT ALL ON TABLE "public"."parent_bookings_view" TO "authenticated";
GRANT ALL ON TABLE "public"."parent_bookings_view" TO "service_role";



GRANT ALL ON TABLE "public"."parent_notifications_view" TO "anon";
GRANT ALL ON TABLE "public"."parent_notifications_view" TO "authenticated";
GRANT ALL ON TABLE "public"."parent_notifications_view" TO "service_role";



GRANT ALL ON TABLE "public"."parent_tracking_snapshot" TO "anon";
GRANT ALL ON TABLE "public"."parent_tracking_snapshot" TO "authenticated";
GRANT ALL ON TABLE "public"."parent_tracking_snapshot" TO "service_role";



GRANT ALL ON TABLE "public"."payments" TO "anon";
GRANT ALL ON TABLE "public"."payments" TO "authenticated";
GRANT ALL ON TABLE "public"."payments" TO "service_role";



GRANT ALL ON TABLE "public"."saved_drivers" TO "anon";
GRANT ALL ON TABLE "public"."saved_drivers" TO "authenticated";
GRANT ALL ON TABLE "public"."saved_drivers" TO "service_role";



GRANT ALL ON TABLE "public"."tracking_view" TO "anon";
GRANT ALL ON TABLE "public"."tracking_view" TO "authenticated";
GRANT ALL ON TABLE "public"."tracking_view" TO "service_role";



GRANT ALL ON TABLE "public"."trip_tracking" TO "anon";
GRANT ALL ON TABLE "public"."trip_tracking" TO "authenticated";
GRANT ALL ON TABLE "public"."trip_tracking" TO "service_role";



GRANT ALL ON TABLE "public"."verified_driver_ads" TO "anon";
GRANT ALL ON TABLE "public"."verified_driver_ads" TO "authenticated";
GRANT ALL ON TABLE "public"."verified_driver_ads" TO "service_role";



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







