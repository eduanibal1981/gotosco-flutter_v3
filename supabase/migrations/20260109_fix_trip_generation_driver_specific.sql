-- Migration to optimize trip generation by allowing generation for a specific driver
-- and ensuring the logic aligns strictly with the calling user.

-- 1. generate_go_trips (Updated with target_driver_id)
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
  -- 1. Create temp table to buffer students
  CREATE TEMP TABLE IF NOT EXISTS _temp_go_stops (
    booking_id UUID,
    child_id UUID,
    pickup_lat FLOAT,
    pickup_lng FLOAT
  ) ON COMMIT DROP;

  target_day_name := LOWER(TRIM(to_char(target_date, 'Day')));

  FOR driver_rec IN 
    SELECT DISTINCT driver_id 
    FROM public.bookings 
    WHERE subscription_status = 'active'
      AND (target_driver_id IS NULL OR driver_id = target_driver_id) -- Filter by specific driver if provided
  LOOP
    
    -- 2. SKIP if trip already exists for this driver/date/type
    SELECT id INTO existing_trip_id
    FROM public.trips
    WHERE driver_id = driver_rec.driver_id
      AND trip_date = target_date
      AND trip_type = 'Go to School(s)'
    LIMIT 1;

    IF existing_trip_id IS NOT NULL THEN
      CONTINUE;
    END IF;

    -- 3. Clear temp table for this specific driver
    DELETE FROM _temp_go_stops WHERE TRUE;

    -- 4. Gather eligible children into temp table
    INSERT INTO _temp_go_stops (booking_id, child_id, pickup_lat, pickup_lng)
    SELECT b.id, bc.child_id, c.pickup_lat, c.pickup_lng
      FROM public.bookings b
      JOIN public.booking_children bc ON b.id = bc.booking_id
      JOIN public.children c ON bc.child_id = c.id
      WHERE b.driver_id = driver_rec.driver_id
        AND b.subscription_status = 'active'
        AND b.booking_type IN ('Two Way', 'One Way to School')
        AND NOT EXISTS (
          SELECT 1 FROM public.child_absences ca 
          WHERE ca.child_id = bc.child_id AND ca.date = target_date
        )
      ORDER BY b.route_order ASC NULLS LAST;

    -- 5. Check if we actually found any children
    SELECT EXISTS (SELECT 1 FROM _temp_go_stops) INTO has_children;

    -- 6. IF children exist, fetch schedule and create trip
    IF has_children THEN
        
        -- Get Driver Schedule for proper display in App
        SELECT available_from, available_until
        INTO sched_start, sched_end
        FROM public.driver_schedules
        WHERE driver_id = driver_rec.driver_id
          AND LOWER(day_of_week) = target_day_name
          AND shift_type = 'Go to School(s)'
        LIMIT 1;

        -- Create the Trip Header
        INSERT INTO public.trips (
            driver_id, 
            trip_date, 
            status, 
            trip_type, 
            start_time, 
            end_time
        )
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

        -- Bulk insert stops from temp table
        FOR child_rec IN SELECT * FROM _temp_go_stops LOOP
            INSERT INTO public.route_stops (
                trip_id, booking_id, child_id, stop_type, sequence_order, 
                location_lat, location_lng, status
            )
            VALUES (
                new_trip_id, child_rec.booking_id, child_rec.child_id, 
                'pickup', stop_sequence, child_rec.pickup_lat, child_rec.pickup_lng, 'pending'
            );
            stop_sequence := stop_sequence + 1;
        END LOOP;
    END IF;
    
  END LOOP;
END;
$$;

-- 2. generate_return_trips (Updated with target_driver_id)
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
  CREATE TEMP TABLE IF NOT EXISTS _temp_return_stops (
    booking_id UUID,
    child_id UUID,
    pickup_lat FLOAT,
    pickup_lng FLOAT
  ) ON COMMIT DROP;

  target_day_name := LOWER(TRIM(to_char(target_date, 'Day')));

  FOR driver_rec IN 
    SELECT DISTINCT driver_id 
    FROM public.bookings 
    WHERE subscription_status = 'active'
      AND (target_driver_id IS NULL OR driver_id = target_driver_id) -- Filter by specific driver if provided
  LOOP
    
    -- Check if trip already exists
    SELECT id INTO existing_trip_id
    FROM public.trips
    WHERE driver_id = driver_rec.driver_id
      AND trip_date = target_date
      AND trip_type = 'Return from School(s)'
    LIMIT 1;
    
    IF existing_trip_id IS NOT NULL THEN
      CONTINUE;
    END IF;

    DELETE FROM _temp_return_stops WHERE TRUE;

    -- Buffer children (Corrected booking_type here)
    INSERT INTO _temp_return_stops (booking_id, child_id, pickup_lat, pickup_lng)
    SELECT b.id, bc.child_id, c.pickup_lat, c.pickup_lng
      FROM public.bookings b
      JOIN public.booking_children bc ON b.id = bc.booking_id
      JOIN public.children c ON bc.child_id = c.id
      WHERE b.driver_id = driver_rec.driver_id
        AND b.subscription_status = 'active'
        AND b.booking_type IN ('Two Way', 'One Way Back Home') 
        AND NOT EXISTS (
          SELECT 1 FROM public.child_absences ca 
          WHERE ca.child_id = bc.child_id AND ca.date = target_date
        )
      ORDER BY b.route_order DESC NULLS LAST;

    SELECT EXISTS (SELECT 1 FROM _temp_return_stops) INTO has_children;

    IF has_children THEN
        
        -- Get Schedule
        SELECT available_from, available_until
        INTO sched_start, sched_end
        FROM public.driver_schedules
        WHERE driver_id = driver_rec.driver_id
          AND LOWER(day_of_week) = target_day_name
          AND shift_type = 'Return from School(s)'
        LIMIT 1;

        -- Create Trip
        INSERT INTO public.trips (
            driver_id, 
            trip_date, 
            status, 
            trip_type,
            start_time,
            end_time
        )
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

        FOR child_rec IN SELECT * FROM _temp_return_stops LOOP
            INSERT INTO public.route_stops (
                trip_id, booking_id, child_id, stop_type, sequence_order, 
                location_lat, location_lng, status
            )
            VALUES (
                new_trip_id, child_rec.booking_id, child_rec.child_id, 
                'dropoff', stop_sequence, child_rec.pickup_lat, child_rec.pickup_lng, 'pending'
            );
            stop_sequence := stop_sequence + 1;
        END LOOP;
    END IF;

  END LOOP;
END;
$$;
