-- Up Migration for grouping multiple children stops

-- 1. Modified generate_go_trips
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
  CREATE TEMP TABLE IF NOT EXISTS _temp_go_stops_v8 (
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
    
    DELETE FROM _temp_go_stops_v8 WHERE TRUE;
    
    -- INSERT STOPS (Now selecting trip_category)
    INSERT INTO _temp_go_stops_v8 (booking_id, child_id, pickup_lat, pickup_lng, school_lat, school_lng, trip_category)
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
        
    SELECT EXISTS (SELECT 1 FROM _temp_go_stops_v8) INTO has_children;
    
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
        FOR child_rec IN 
            SELECT t.booking_id, t.pickup_lat, t.pickup_lng, 
                   jsonb_build_object(
                     'child_names', string_agg(c.name, ', ' ORDER BY c.name),
                     'child_ids', jsonb_agg(t.child_id)
                   ) as stop_context,
                   MIN(t.child_id) as min_child_id
            FROM _temp_go_stops_v8 t
            JOIN public.children c ON t.child_id = c.id
            GROUP BY t.booking_id, t.pickup_lat, t.pickup_lng
        LOOP
            INSERT INTO public.route_stops (trip_id, booking_id, child_id, stop_type, sequence_order, location_lat, location_lng, status, stop_context)
            VALUES (
                new_trip_id, 
                child_rec.booking_id, 
                child_rec.min_child_id, 
                'pick up from home', 
                stop_sequence, 
                child_rec.pickup_lat, 
                child_rec.pickup_lng, 
                'pending',
                child_rec.stop_context
            );
            stop_sequence := stop_sequence + 1;
        END LOOP;
        
        -- Dropoffs (School or Destination)
        FOR child_rec IN 
            SELECT t.booking_id, t.school_lat, t.school_lng, t.trip_category,
                   jsonb_build_object(
                     'child_names', string_agg(c.name, ', ' ORDER BY c.name),
                     'child_ids', jsonb_agg(t.child_id)
                   ) as stop_context,
                   MIN(t.child_id) as min_child_id
            FROM _temp_go_stops_v8 t
            JOIN public.children c ON t.child_id = c.id
            GROUP BY t.booking_id, t.school_lat, t.school_lng, t.trip_category
            ORDER BY t.school_lat, t.school_lng
        LOOP
            INSERT INTO public.route_stops (trip_id, booking_id, child_id, stop_type, sequence_order, location_lat, location_lng, status, stop_context)
            VALUES (
                new_trip_id, 
                child_rec.booking_id, 
                child_rec.min_child_id, 
                CASE 
                    WHEN child_rec.trip_category = 'school' THEN 'Drop off at school'
                    ELSE 'Drop off at destination'
                END,
                stop_sequence, 
                child_rec.school_lat, 
                child_rec.school_lng, 
                'pending',
                child_rec.stop_context
            );
            stop_sequence := stop_sequence + 1;
        END LOOP;
    END IF;
  END LOOP;
END;
$$;


-- 2. Modified generate_return_trips
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
  CREATE TEMP TABLE IF NOT EXISTS _temp_return_stops_v8 (
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
    
    DELETE FROM _temp_return_stops_v8 WHERE TRUE;
    
    -- INSERT STOPS (Now selecting trip_category)
    INSERT INTO _temp_return_stops_v8 (booking_id, child_id, pickup_lat, pickup_lng, school_lat, school_lng, trip_category)
    SELECT 
        b.id, 
        bc.child_id, 
        b.home_lat, 
        b.home_lng, 
        COALESCE(s_child.latitude, s_booking.latitude, b.school_lat),
        COALESCE(s_child.longitude, s_booking.longitude, b.school_lng),
        b.trip_category
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
        
    SELECT EXISTS (SELECT 1 FROM _temp_return_stops_v8) INTO has_children;
    
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
        FOR child_rec IN 
            SELECT t.booking_id, t.school_lat, t.school_lng, t.trip_category,
                   jsonb_build_object(
                     'child_names', string_agg(c.name, ', ' ORDER BY c.name),
                     'child_ids', jsonb_agg(t.child_id)
                   ) as stop_context,
                   MIN(t.child_id) as min_child_id
            FROM _temp_return_stops_v8 t
            JOIN public.children c ON t.child_id = c.id
            GROUP BY t.booking_id, t.school_lat, t.school_lng, t.trip_category
            ORDER BY t.school_lat, t.school_lng 
        LOOP
            INSERT INTO public.route_stops (trip_id, booking_id, child_id, stop_type, sequence_order, location_lat, location_lng, status, stop_context)
            VALUES (
                new_trip_id, 
                child_rec.booking_id, 
                child_rec.min_child_id, 
                CASE 
                    WHEN child_rec.trip_category = 'school' THEN 'pick up from school'
                    ELSE 'pick up from destination'
                END,
                stop_sequence, 
                child_rec.school_lat, 
                child_rec.school_lng, 
                'pending',
                child_rec.stop_context
            );
            stop_sequence := stop_sequence + 1;
        END LOOP;
        
        -- Dropoffs (Home) - Sequential
        FOR child_rec IN 
            SELECT t.booking_id, t.pickup_lat, t.pickup_lng, 
                   jsonb_build_object(
                     'child_names', string_agg(c.name, ', ' ORDER BY c.name),
                     'child_ids', jsonb_agg(t.child_id)
                   ) as stop_context,
                   MIN(t.child_id) as min_child_id
            FROM _temp_return_stops_v8 t
            JOIN public.children c ON t.child_id = c.id
            GROUP BY t.booking_id, t.pickup_lat, t.pickup_lng
        LOOP
            INSERT INTO public.route_stops (trip_id, booking_id, child_id, stop_type, sequence_order, location_lat, location_lng, status, stop_context)
            VALUES (
                new_trip_id, 
                child_rec.booking_id, 
                child_rec.min_child_id, 
                'Drop off at home',
                stop_sequence, 
                child_rec.pickup_lat, 
                child_rec.pickup_lng, 
                'pending',
                child_rec.stop_context
            );
            stop_sequence := stop_sequence + 1;
        END LOOP;
    END IF;
  END LOOP;
END;
$$;


-- 3. Replace the driver_trips_view
CREATE OR REPLACE VIEW "public"."driver_trips_view" AS
SELECT 
    t.id,
    t.driver_id,
    t.trip_date,
    t.trip_type,
    t.status,
    t.start_time AS planned_start_time,
    t.actual_start_time,
    t.actual_end_time,
    t.total_distance_km,
    COALESCE(( 
        SELECT jsonb_agg(
            jsonb_build_object(
                'id', rs.id, 
                'stop_type', rs.stop_type, 
                'latitude', rs.location_lat, 
                'longitude', rs.location_lng, 
                'sequence_order', rs.sequence_order, 
                'actual_arrival_time', rs.arrived_at, 
                'status', rs.status, 
                'child_name', COALESCE(rs.stop_context->>'child_names', (SELECT c.name FROM children c WHERE c.id = rs.child_id)), 
                'student_id', rs.child_id, 
                'booking_id', rs.booking_id, 
                'home_location', (SELECT b.hometxt_location FROM bookings b WHERE b.id = rs.booking_id), 
                'school_location', (SELECT b.schooltxt_location FROM bookings b WHERE b.id = rs.booking_id)
            ) ORDER BY rs.sequence_order
        ) AS jsonb_agg
        FROM route_stops rs
        WHERE rs.trip_id = t.id
    ), '[]'::jsonb) AS route_stops
FROM trips t;
