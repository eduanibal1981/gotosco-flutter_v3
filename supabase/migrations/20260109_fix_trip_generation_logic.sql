-- Migration to fix empty trips issue
-- The previous logic created a trip record for every active driver BEFORE checking if they had any valid bookings/children for that specific trip type/day.
-- This resulted in "ghost trips" with no stops if a driver only had return-trip bookings or if all students were absent.
-- This update buffers the eligible students first, and only creates the trip if students exist.

-- 1. Updated generate_go_trips
CREATE OR REPLACE FUNCTION public.generate_go_trips(target_date DATE DEFAULT CURRENT_DATE)
RETURNS void
LANGUAGE plpgsql
AS $function$
DECLARE
  driver_rec RECORD;
  new_trip_id UUID;
  child_rec RECORD;
  stop_sequence INT;
  existing_trip_id UUID;
  has_children BOOLEAN;
BEGIN
  -- Create a temp table to hold stops for the current driver to avoid double querying
  CREATE TEMP TABLE IF NOT EXISTS _temp_go_stops (
    booking_id UUID,
    child_id UUID,
    pickup_lat FLOAT,
    pickup_lng FLOAT
  ) ON COMMIT DROP;

  FOR driver_rec IN 
    SELECT DISTINCT driver_id 
    FROM public.bookings 
    WHERE subscription_status = 'active'
  LOOP
    -- 1. Check if trip already exists
    SELECT id INTO existing_trip_id
    FROM public.trips
    WHERE driver_id = driver_rec.driver_id
      AND trip_date = target_date
      AND trip_type = 'Go to School(s)'
    LIMIT 1;
    
    IF existing_trip_id IS NOT NULL THEN
      CONTINUE;
    END IF;

    -- 2. Clear temp table for this driver
    DELETE FROM _temp_go_stops;

    -- 3. Gather eligible children into temp table
    INSERT INTO _temp_go_stops (booking_id, child_id, pickup_lat, pickup_lng)
    SELECT b.id, bc.child_id, c.pickup_lat, c.pickup_lng
      FROM public.bookings b
      JOIN public.booking_children bc ON b.id = bc.booking_id
      JOIN public.children c ON bc.child_id = c.id
      WHERE b.driver_id = driver_rec.driver_id
        AND b.subscription_status = 'active'
        AND b.booking_type IN ('Two Way', 'One Way to School') -- Filter for GO trips
        AND NOT EXISTS (
          SELECT 1 FROM public.child_absences ca 
          WHERE ca.child_id = bc.child_id AND ca.date = target_date
        )
      ORDER BY b.route_order ASC NULLS LAST;

    -- 4. Check if we found any children
    SELECT EXISTS (SELECT 1 FROM _temp_go_stops) INTO has_children;

    -- 5. Only create trip if children exist
    IF has_children THEN
        INSERT INTO public.trips (driver_id, trip_date, status, trip_type)
        VALUES (driver_rec.driver_id, target_date, 'scheduled', 'Go to School(s)')
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
$function$;

-- 2. Updated generate_return_trips
CREATE OR REPLACE FUNCTION public.generate_return_trips(target_date DATE DEFAULT CURRENT_DATE)
RETURNS void
LANGUAGE plpgsql
AS $function$
DECLARE
  driver_rec RECORD;
  new_trip_id UUID;
  child_rec RECORD;
  stop_sequence INT;
  existing_trip_id UUID;
  has_children BOOLEAN;
BEGIN
  CREATE TEMP TABLE IF NOT EXISTS _temp_return_stops (
    booking_id UUID,
    child_id UUID,
    pickup_lat FLOAT,
    pickup_lng FLOAT
  ) ON COMMIT DROP;

  FOR driver_rec IN 
    SELECT DISTINCT driver_id 
    FROM public.bookings 
    WHERE subscription_status = 'active'
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

    DELETE FROM _temp_return_stops;

    INSERT INTO _temp_return_stops (booking_id, child_id, pickup_lat, pickup_lng)
    SELECT b.id, bc.child_id, c.pickup_lat, c.pickup_lng
      FROM public.bookings b
      JOIN public.booking_children bc ON b.id = bc.booking_id
      JOIN public.children c ON bc.child_id = c.id
      WHERE b.driver_id = driver_rec.driver_id
        AND b.subscription_status = 'active'
        AND b.booking_type IN ('Two Way', 'One Way from School') -- Filter for RETURN trips
        AND NOT EXISTS (
          SELECT 1 FROM public.child_absences ca 
          WHERE ca.child_id = bc.child_id AND ca.date = target_date
        )
      ORDER BY b.route_order DESC NULLS LAST;

    SELECT EXISTS (SELECT 1 FROM _temp_return_stops) INTO has_children;

    IF has_children THEN
        INSERT INTO public.trips (driver_id, trip_date, status, trip_type)
        VALUES (driver_rec.driver_id, target_date, 'scheduled', 'Return from School(s)')
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
$function$;
