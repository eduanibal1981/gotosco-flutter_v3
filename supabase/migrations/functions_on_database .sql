-- last optimization arrange defult draft sequence_order , giving the driver the ability to arrange manually
CREATE OR REPLACE FUNCTION public.generate_go_trips(target_date DATE DEFAULT CURRENT_DATE, target_driver_id UUID DEFAULT NULL)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
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
  CREATE TEMP TABLE IF NOT EXISTS _temp_go_stops_v4 (
    booking_id UUID,
    child_id UUID,
    pickup_lat FLOAT,
    pickup_lng FLOAT,
    school_lat FLOAT,
    school_lng FLOAT
  ) ON COMMIT DROP;

  target_day_name := LOWER(TRIM(to_char(target_date, 'Day')));

  -- 1. Loop through drivers, JOINING the drivers table to get locations
  FOR driver_rec IN 
    SELECT DISTINCT 
        b.driver_id, 
        d.start_location_geo, 
        d.location_geo 
    FROM public.bookings b
    JOIN public.drivers d ON b.driver_id = d.user_id
    WHERE b.subscription_status = 'active'
      AND (target_driver_id IS NULL OR b.driver_id = target_driver_id)
  LOOP
    
    -- Check for existing trip
    SELECT id INTO existing_trip_id
    FROM public.trips
    WHERE driver_id = driver_rec.driver_id
      AND trip_date = target_date
      AND trip_type = 'Go to School(s)'
    LIMIT 1;

    IF existing_trip_id IS NOT NULL THEN
      CONTINUE;
    END IF;

    DELETE FROM _temp_go_stops_v4 WHERE TRUE;

    -- 2. Gather Data (Sorted by NEAREST TO DRIVER)
    INSERT INTO _temp_go_stops_v4 (booking_id, child_id, pickup_lat, pickup_lng, school_lat, school_lng)
    SELECT 
        b.id, 
        bc.child_id, 
        b.home_lat, 
        b.home_lng, 
        b.school_lat, 
        b.school_lng
      FROM public.bookings b
      JOIN public.booking_children bc ON b.id = bc.booking_id
      JOIN public.children c ON bc.child_id = c.id
      WHERE b.driver_id = driver_rec.driver_id
        AND b.subscription_status = 'active'
        AND b.booking_type IN ('Two Way', 'One Way to School')
        AND b.home_lat IS NOT NULL AND b.home_lng IS NOT NULL
        AND b.school_lat IS NOT NULL AND b.school_lng IS NOT NULL
        AND NOT EXISTS (
          SELECT 1 FROM public.child_absences ca 
          WHERE ca.child_id = bc.child_id AND ca.date = target_date
        )
      ORDER BY 
        -- Priority 1: Manual Route Order (if set)
        b.route_order ASC NULLS LAST,
        -- Priority 2: Nearest to Driver's Start Location (Fallback to Profile Location)
        ST_Distance(
            b.homegeo_location, 
            COALESCE(driver_rec.start_location_geo, driver_rec.location_geo)
        ) ASC;

    -- 3. Create Trip if children found
    SELECT EXISTS (SELECT 1 FROM _temp_go_stops_v4) INTO has_children;

    IF has_children THEN
        SELECT available_from, available_until
        INTO sched_start, sched_end
        FROM public.driver_schedules
        WHERE driver_id = driver_rec.driver_id
          AND LOWER(day_of_week) = target_day_name
          AND shift_type = 'Go to School(s)'
        LIMIT 1;

        INSERT INTO public.trips (driver_id, trip_date, status, trip_type, start_time, end_time)
        VALUES (
            driver_rec.driver_id, 
            target_date, 
            'scheduled', 
            'Go to School(s)',
            CASE WHEN sched_start IS NOT NULL THEN (target_date + sched_start) ELSE NULL END,
            CASE WHEN sched_end IS NOT NULL THEN (target_date + sched_end) ELSE NULL END
        )
        RETURNING id INTO new_trip_id;

        stop_sequence := 1;

        -- Pickups (Home)
        FOR child_rec IN SELECT * FROM _temp_go_stops_v4 LOOP
            INSERT INTO public.route_stops (trip_id, booking_id, child_id, stop_type, sequence_order, location_lat, location_lng, status)
            VALUES (new_trip_id, child_rec.booking_id, child_rec.child_id, 'pickup', stop_sequence, child_rec.pickup_lat, child_rec.pickup_lng, 'pending');
            stop_sequence := stop_sequence + 1;
        END LOOP;

        -- Dropoffs (School)
        FOR child_rec IN SELECT * FROM _temp_go_stops_v4 ORDER BY school_lat, school_lng LOOP
            INSERT INTO public.route_stops (trip_id, booking_id, child_id, stop_type, sequence_order, location_lat, location_lng, status)
            VALUES (new_trip_id, child_rec.booking_id, child_rec.child_id, 'dropoff', stop_sequence, child_rec.school_lat, child_rec.school_lng, 'pending');
            stop_sequence := stop_sequence + 1;
        END LOOP;
    END IF;
  END LOOP;
END;
$$;
CREATE OR REPLACE FUNCTION public.generate_return_trips(target_date DATE DEFAULT CURRENT_DATE, target_driver_id UUID DEFAULT NULL)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
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
  CREATE TEMP TABLE IF NOT EXISTS _temp_return_stops_v4 (
    booking_id UUID,
    child_id UUID,
    pickup_lat FLOAT,
    pickup_lng FLOAT,
    school_lat FLOAT,
    school_lng FLOAT
  ) ON COMMIT DROP;

  target_day_name := LOWER(TRIM(to_char(target_date, 'Day')));

  FOR driver_rec IN 
    SELECT DISTINCT b.driver_id
    FROM public.bookings b
    WHERE b.subscription_status = 'active'
      AND (target_driver_id IS NULL OR b.driver_id = target_driver_id)
  LOOP
    
    SELECT id INTO existing_trip_id
    FROM public.trips
    WHERE driver_id = driver_rec.driver_id
      AND trip_date = target_date
      AND trip_type = 'Return from School(s)'
    LIMIT 1;
    
    IF existing_trip_id IS NOT NULL THEN
      CONTINUE;
    END IF;

    DELETE FROM _temp_return_stops_v4 WHERE TRUE;

    -- 2. Gather Data (Sorted by NEAREST TO SCHOOL)
    INSERT INTO _temp_return_stops_v4 (booking_id, child_id, pickup_lat, pickup_lng, school_lat, school_lng)
    SELECT 
        b.id, 
        bc.child_id, 
        b.home_lat, 
        b.home_lng, 
        b.school_lat, 
        b.school_lng
      FROM public.bookings b
      JOIN public.booking_children bc ON b.id = bc.booking_id
      JOIN public.children c ON bc.child_id = c.id
      WHERE b.driver_id = driver_rec.driver_id
        AND b.subscription_status = 'active'
        AND b.booking_type IN ('Two Way', 'One Way Back Home') 
        AND b.home_lat IS NOT NULL AND b.home_lng IS NOT NULL
        AND b.school_lat IS NOT NULL AND b.school_lng IS NOT NULL
        AND NOT EXISTS (
          SELECT 1 FROM public.child_absences ca 
          WHERE ca.child_id = bc.child_id AND ca.date = target_date
        )
      ORDER BY 
        -- Priority 1: Manual Route Order (Reverse)
        b.route_order DESC NULLS LAST,
        -- Priority 2: Closest to School First (Minimize time on bus)
        ST_Distance(b.schoolgeo_location, b.homegeo_location) ASC;

    SELECT EXISTS (SELECT 1 FROM _temp_return_stops_v4) INTO has_children;

    IF has_children THEN
        SELECT available_from, available_until
        INTO sched_start, sched_end
        FROM public.driver_schedules
        WHERE driver_id = driver_rec.driver_id
          AND LOWER(day_of_week) = target_day_name
          AND shift_type = 'Return from School(s)'
        LIMIT 1;

        INSERT INTO public.trips (driver_id, trip_date, status, trip_type, start_time, end_time)
        VALUES (
            driver_rec.driver_id, 
            target_date, 
            'scheduled', 
            'Return from School(s)',
            CASE WHEN sched_start IS NOT NULL THEN (target_date + sched_start) ELSE NULL END,
            CASE WHEN sched_end IS NOT NULL THEN (target_date + sched_end) ELSE NULL END
        )
        RETURNING id INTO new_trip_id;

        stop_sequence := 1;

        -- Pickups (School)
        FOR child_rec IN SELECT * FROM _temp_return_stops_v4 ORDER BY school_lat, school_lng LOOP
            INSERT INTO public.route_stops (trip_id, booking_id, child_id, stop_type, sequence_order, location_lat, location_lng, status)
            VALUES (new_trip_id, child_rec.booking_id, child_rec.child_id, 'pickup', stop_sequence, child_rec.school_lat, child_rec.school_lng, 'pending');
            stop_sequence := stop_sequence + 1;
        END LOOP;

        -- Dropoffs (Home)
        FOR child_rec IN SELECT * FROM _temp_return_stops_v4 LOOP
            INSERT INTO public.route_stops (trip_id, booking_id, child_id, stop_type, sequence_order, location_lat, location_lng, status)
            VALUES (new_trip_id, child_rec.booking_id, child_rec.child_id, 'dropoff', stop_sequence, child_rec.pickup_lat, child_rec.pickup_lng, 'pending');
            stop_sequence := stop_sequence + 1;
        END LOOP;
    END IF;
  END LOOP;
END;
$$;
