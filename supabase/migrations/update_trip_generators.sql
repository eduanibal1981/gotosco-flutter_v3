-- Migration: Update Trip Generation Logic for Multi-School Support
-- Date: 2026-01-23
-- Description: Updates trip generation functions to leverage the booking_schools junction table
--              This enables generating trips where siblings in the same booking are dropped off at different schools.

-- =========================================================
-- 1. UPDATE generate_go_trips
-- =========================================================
-- Changes:
-- - Joins with booking_schools to resolve specific school locations per child
-- - Uses COALESCE/CASE logic to handle both single-school and multi-school bookings
-- - Preserves existing sorting logic but applies it to resolved locations

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

    -- FETCH DATA: Dynamic School Resolution Logic
    -- We join booking_schools to get the specific school for each child in multi-school bookings
    INSERT INTO _temp_go_stops_v5 (booking_id, child_id, pickup_lat, pickup_lng, school_lat, school_lng)
    SELECT 
        b.id, 
        bc.child_id, 
        b.home_lat, 
        b.home_lng,
        -- Resolve School Latitude
        CASE 
            WHEN b.is_multi_school IS TRUE AND bs.school_latitude IS NOT NULL 
            THEN bs.school_latitude 
            ELSE b.school_lat 
        END,
        -- Resolve School Longitude
        CASE 
            WHEN b.is_multi_school IS TRUE AND bs.school_longitude IS NOT NULL 
            THEN bs.school_longitude 
            ELSE b.school_lng 
        END
      FROM public.bookings b
      JOIN public.booking_children bc ON b.id = bc.booking_id
      JOIN public.children c ON bc.child_id = c.id
      -- Junction Table Join: Matches child to their specific school in the junction table
      LEFT JOIN public.booking_schools bs ON b.id = bs.booking_id AND bc.child_id = ANY(bs.student_ids)
      WHERE b.driver_id = driver_rec.driver_id
        AND b.subscription_status = 'active'
        AND b.booking_type IN ('Two Way', 'One Way to School')
        AND b.home_lat IS NOT NULL AND b.home_lng IS NOT NULL
        -- Ensure we have a valid school location (either from booking or junction table)
        AND (
            (b.is_multi_school IS NOT TRUE AND b.school_lat IS NOT NULL) OR 
            (b.is_multi_school IS TRUE AND bs.school_latitude IS NOT NULL)
        )
        AND NOT EXISTS (SELECT 1 FROM public.child_absences ca WHERE ca.child_id = bc.child_id AND ca.date = target_date)
      ORDER BY 
        b.routego_order ASC NULLS LAST, -- PRIMARY SORT: Morning Sequence (Booking level)
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
        -- AUTO-CLUSTERING: Ordering by school_lat/lng groups children going to the same school together
        FOR child_rec IN SELECT * FROM _temp_go_stops_v5 ORDER BY school_lat, school_lng LOOP
            INSERT INTO public.route_stops (trip_id, booking_id, child_id, stop_type, sequence_order, location_lat, location_lng, status)
            VALUES (new_trip_id, child_rec.booking_id, child_rec.child_id, 'dropoff', stop_sequence, child_rec.school_lat, child_rec.school_lng, 'pending');
            stop_sequence := stop_sequence + 1;
        END LOOP;
    END IF;
  END LOOP;
END;
$$;


-- =========================================================
-- 2. UPDATE generate_return_trips
-- =========================================================
-- Changes:
-- - Same Join logic as above
-- - Updates ORDER BY clause to use resolved school location for distance calculation

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

    -- FETCH DATA: Ordered by 'routeret_order' with Dynamic School Support
    INSERT INTO _temp_return_stops_v5 (booking_id, child_id, pickup_lat, pickup_lng, school_lat, school_lng)
    SELECT 
        b.id, 
        bc.child_id, 
        b.home_lat, 
        b.home_lng, 
        -- Resolve School Lat
        CASE 
            WHEN b.is_multi_school IS TRUE AND bs.school_latitude IS NOT NULL 
            THEN bs.school_latitude 
            ELSE b.school_lat 
        END,
        -- Resolve School Lng
        CASE 
            WHEN b.is_multi_school IS TRUE AND bs.school_longitude IS NOT NULL 
            THEN bs.school_longitude 
            ELSE b.school_lng 
        END
      FROM public.bookings b
      JOIN public.booking_children bc ON b.id = bc.booking_id
      JOIN public.children c ON bc.child_id = c.id
      -- Junction Table Join
      LEFT JOIN public.booking_schools bs ON b.id = bs.booking_id AND bc.child_id = ANY(bs.student_ids)
      WHERE b.driver_id = driver_rec.driver_id
        AND b.subscription_status = 'active'
        AND b.booking_type IN ('Two Way', 'One Way Back Home') 
        AND b.home_lat IS NOT NULL AND b.home_lng IS NOT NULL
        -- Ensure valid school location
        AND (
            (b.is_multi_school IS NOT TRUE AND b.school_lat IS NOT NULL) OR 
            (b.is_multi_school IS TRUE AND bs.school_latitude IS NOT NULL)
        )
        AND NOT EXISTS (SELECT 1 FROM public.child_absences ca WHERE ca.child_id = bc.child_id AND ca.date = target_date)
      ORDER BY 
        b.routeret_order ASC NULLS LAST, -- PRIMARY SORT: Afternoon Sequence (Booking level)
        -- SECONDARY SORT: Distance from RESOLVED SCHOOL to Home
        ST_Distance(
            ST_SetSRID(ST_MakePoint(
                CASE WHEN b.is_multi_school IS TRUE AND bs.school_longitude IS NOT NULL THEN bs.school_longitude ELSE b.school_lng END,
                CASE WHEN b.is_multi_school IS TRUE AND bs.school_latitude IS NOT NULL THEN bs.school_latitude ELSE b.school_lat END
            ), 4326)::geography, 
            b.homegeo_location
        ) ASC;

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
        -- Pickups (School) - Grouped by Location
        FOR child_rec IN SELECT * FROM _temp_return_stops_v5 ORDER BY school_lat, school_lng LOOP
            INSERT INTO public.route_stops (trip_id, booking_id, child_id, stop_type, sequence_order, location_lat, location_lng, status)
            VALUES (new_trip_id, child_rec.booking_id, child_rec.child_id, 'pickup', stop_sequence, child_rec.school_lat, child_rec.school_lng, 'pending');
            stop_sequence := stop_sequence + 1;
        END LOOP;
        
        -- Dropoffs (Home) - Sequential
        FOR child_rec IN SELECT * FROM _temp_return_stops_v5 LOOP
            INSERT INTO public.route_stops (trip_id, booking_id, child_id, stop_type, sequence_order, location_lat, location_lng, status)
            VALUES (new_trip_id, child_rec.booking_id, child_rec.child_id, 'dropoff', stop_sequence, child_rec.pickup_lat, child_rec.pickup_lng, 'pending');
            stop_sequence := stop_sequence + 1;
        END LOOP;
    END IF;
  END LOOP;
END;
$$;
