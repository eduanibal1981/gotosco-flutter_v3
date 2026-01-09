-- 1. Create Children Table (Profile Only)
CREATE TABLE IF NOT EXISTS public.children (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  parent_id uuid,
  name text NOT NULL,
  school text,
  grade text,
  emergency_contact text,
  photo_url text,
  date_of_birth date,
  gender text,
  medical_conditions text,
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT children_pkey PRIMARY KEY (id),
  CONSTRAINT children_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

-- 2. Create Bookings Table (The Source of Truth for Location)
-- Note: Assuming table exists or we are altering it. If logic below assumes CREATE, it might fail if exists.
-- For safety in this migration file, we use CREATE TABLE IF NOT EXISTS but the constraints might conflict.
-- Ideally this should run on a clean state or be adapted to ALTER.
-- Given the user instruction "i did little improve to the next tables", they might have run this.
-- We save it as reference.

CREATE TABLE IF NOT EXISTS public.bookings (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  parent_id uuid NOT NULL,
  driver_id uuid NOT NULL,
  booking_type text NOT NULL,
  status text DEFAULT 'pending'::text,
  
  -- Text Descriptions
  hometxt_location text,
  schooltxt_location text,
  home_pickup_time text,
  school_pickup_time text,
  price numeric,
  notes text,
  
  -- Metadata
  created_at timestamp with time zone DEFAULT now(),
  is_recurring boolean DEFAULT false,
  recurrence_pattern jsonb,
  subscription_status text,
  contract_start_date date,
  contract_end_date date,
  route_order integer DEFAULT 999,

  -- GEOGRAPHY (Source of Truth)
  homegeo_location geography(Point, 4326),
  schoolgeo_location geography(Point, 4326),

  -- AUTO-GENERATED LAT/LNG (For your Functions)
  home_lat double precision GENERATED ALWAYS AS (ST_Y(homegeo_location::geometry)) STORED,
  home_lng double precision GENERATED ALWAYS AS (ST_X(homegeo_location::geometry)) STORED,
  school_lat double precision GENERATED ALWAYS AS (ST_Y(schoolgeo_location::geometry)) STORED,
  school_lng double precision GENERATED ALWAYS AS (ST_X(schoolgeo_location::geometry)) STORED,

  CONSTRAINT bookings_pkey PRIMARY KEY (id),
  CONSTRAINT bookings_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.drivers(user_id) ON DELETE CASCADE,
  CONSTRAINT bookings_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES auth.users(id) ON DELETE CASCADE,
  
  CONSTRAINT bookings_booking_type_check CHECK (booking_type = ANY (ARRAY['Two Way', 'One Way to School', 'One Way Back Home', 'Other'])),
  CONSTRAINT bookings_status_check CHECK (status = ANY (ARRAY['pending', 'accepted', 'rejected', 'completed'])),
  CONSTRAINT bookings_subscription_status_check CHECK (subscription_status = ANY (ARRAY['active', 'paused', 'cancelled', 'expired']))
);

-- 3. Create Bridge Table
CREATE TABLE IF NOT EXISTS public.booking_children (
  booking_id uuid NOT NULL,
  child_id uuid NOT NULL,
  CONSTRAINT booking_children_pkey PRIMARY KEY (booking_id, child_id),
  CONSTRAINT booking_children_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES public.bookings(id) ON DELETE CASCADE,
  CONSTRAINT booking_children_child_id_fkey FOREIGN KEY (child_id) REFERENCES public.children(id) ON DELETE CASCADE
);

-- 4. Create Index for Generator Speed
CREATE INDEX IF NOT EXISTS idx_bookings_generator_lookup ON public.bookings (driver_id, subscription_status, booking_type);

-- till change of booking (get all main columns related to location of the trip)
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
  -- 1. Temp table to buffer stops
  CREATE TEMP TABLE IF NOT EXISTS _temp_go_stops_v3 (
    booking_id UUID,
    child_id UUID,
    pickup_lat FLOAT, -- This will hold Home Location
    pickup_lng FLOAT,
    school_lat FLOAT, -- This will hold School Location
    school_lng FLOAT
  ) ON COMMIT DROP;

  target_day_name := LOWER(TRIM(to_char(target_date, 'Day')));

  -- 2. Loop through drivers
  FOR driver_rec IN 
    SELECT DISTINCT driver_id 
    FROM public.bookings 
    WHERE subscription_status = 'active'
      AND (target_driver_id IS NULL OR driver_id = target_driver_id)
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

    DELETE FROM _temp_go_stops_v3 WHERE TRUE;

    -- 3. Gather Data (UPDATED FOR NEW SCHEMA)
    INSERT INTO _temp_go_stops_v3 (booking_id, child_id, pickup_lat, pickup_lng, school_lat, school_lng)
    SELECT 
        b.id, 
        bc.child_id, 
        b.home_lat,   -- UPDATED: Reading from Booking table
        b.home_lng,   -- UPDATED: Reading from Booking table
        b.school_lat, 
        b.school_lng
      FROM public.bookings b
      JOIN public.booking_children bc ON b.id = bc.booking_id
      -- We still join children to check for absences
      JOIN public.children c ON bc.child_id = c.id
      WHERE b.driver_id = driver_rec.driver_id
        AND b.subscription_status = 'active'
        AND b.booking_type IN ('Two Way', 'One Way to School')
        
        -- ROBUSTNESS: Ensure Home AND School locations exist in the Booking
        AND b.home_lat IS NOT NULL AND b.home_lng IS NOT NULL
        AND b.school_lat IS NOT NULL AND b.school_lng IS NOT NULL
        
        -- Absence Check
        AND NOT EXISTS (
          SELECT 1 FROM public.child_absences ca 
          WHERE ca.child_id = bc.child_id AND ca.date = target_date
        )
      ORDER BY b.route_order ASC NULLS LAST;

    -- 4. Create Trip if children found
    SELECT EXISTS (SELECT 1 FROM _temp_go_stops_v3) INTO has_children;

    IF has_children THEN
        -- Fetch Schedule
        SELECT available_from, available_until
        INTO sched_start, sched_end
        FROM public.driver_schedules
        WHERE driver_id = driver_rec.driver_id
          AND LOWER(day_of_week) = target_day_name
          AND shift_type = 'Go to School(s)'
        LIMIT 1;

        -- Insert Trip Header
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

        -- Insert PICKUPS (Home Location)
        FOR child_rec IN SELECT * FROM _temp_go_stops_v3 LOOP
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

        -- Insert DROPOFFS (School Location) - Grouped by school
        FOR child_rec IN SELECT * FROM _temp_go_stops_v3 ORDER BY school_lat, school_lng LOOP
            INSERT INTO public.route_stops (
                trip_id, booking_id, child_id, stop_type, sequence_order, 
                location_lat, location_lng, status
            )
            VALUES (
                new_trip_id, child_rec.booking_id, child_rec.child_id, 
                'dropoff', stop_sequence, child_rec.school_lat, child_rec.school_lng, 'pending'
            );
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
  -- 1. Temp table
  CREATE TEMP TABLE IF NOT EXISTS _temp_return_stops_v3 (
    booking_id UUID,
    child_id UUID,
    pickup_lat FLOAT, -- Holds Home Location
    pickup_lng FLOAT,
    school_lat FLOAT, -- Holds School Location
    school_lng FLOAT
  ) ON COMMIT DROP;

  target_day_name := LOWER(TRIM(to_char(target_date, 'Day')));

  -- 2. Loop through drivers
  FOR driver_rec IN 
    SELECT DISTINCT driver_id 
    FROM public.bookings 
    WHERE subscription_status = 'active'
      AND (target_driver_id IS NULL OR driver_id = target_driver_id)
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

    DELETE FROM _temp_return_stops_v3 WHERE TRUE;

    -- 3. Gather Data (UPDATED FOR NEW SCHEMA)
    INSERT INTO _temp_return_stops_v3 (booking_id, child_id, pickup_lat, pickup_lng, school_lat, school_lng)
    SELECT 
        b.id, 
        bc.child_id, 
        b.home_lat,   -- UPDATED: Reading from Booking table
        b.home_lng,   -- UPDATED: Reading from Booking table
        b.school_lat, 
        b.school_lng
      FROM public.bookings b
      JOIN public.booking_children bc ON b.id = bc.booking_id
      JOIN public.children c ON bc.child_id = c.id
      WHERE b.driver_id = driver_rec.driver_id
        AND b.subscription_status = 'active'
        AND b.booking_type IN ('Two Way', 'One Way Back Home') 
        
        -- ROBUSTNESS: Ensure Home AND School locations exist in the Booking
        AND b.home_lat IS NOT NULL AND b.home_lng IS NOT NULL
        AND b.school_lat IS NOT NULL AND b.school_lng IS NOT NULL
        
        -- Absence Check
        AND NOT EXISTS (
          SELECT 1 FROM public.child_absences ca 
          WHERE ca.child_id = bc.child_id AND ca.date = target_date
        )
      ORDER BY b.route_order DESC NULLS LAST;

    -- 4. Create Trip if children found
    SELECT EXISTS (SELECT 1 FROM _temp_return_stops_v3) INTO has_children;

    IF has_children THEN
        -- Fetch Schedule
        SELECT available_from, available_until
        INTO sched_start, sched_end
        FROM public.driver_schedules
        WHERE driver_id = driver_rec.driver_id
          AND LOWER(day_of_week) = target_day_name
          AND shift_type = 'Return from School(s)'
        LIMIT 1;

        -- Insert Trip Header
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

        -- Insert PICKUPS (School Location)
        FOR child_rec IN SELECT * FROM _temp_return_stops_v3 ORDER BY school_lat, school_lng LOOP
            INSERT INTO public.route_stops (
                trip_id, booking_id, child_id, stop_type, sequence_order, 
                location_lat, location_lng, status
            )
            VALUES (
                new_trip_id, child_rec.booking_id, child_rec.child_id, 
                'pickup', stop_sequence, child_rec.school_lat, child_rec.school_lng, 'pending'
            );
            stop_sequence := stop_sequence + 1;
        END LOOP;

        -- Insert DROPOFFS (Home Location)
        FOR child_rec IN SELECT * FROM _temp_return_stops_v3 LOOP
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
