-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.areas (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  city_id uuid,
  name text NOT NULL,
  boundary USER-DEFINED,
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  CONSTRAINT areas_pkey PRIMARY KEY (id),
  CONSTRAINT areas_city_id_fkey FOREIGN KEY (city_id) REFERENCES public.cities(id)
);
CREATE TABLE public.booking_children (
  booking_id uuid NOT NULL,
  child_id uuid NOT NULL,
  CONSTRAINT booking_children_pkey PRIMARY KEY (booking_id, child_id),
  CONSTRAINT booking_children_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES public.bookings(id),
  CONSTRAINT booking_children_child_id_fkey FOREIGN KEY (child_id) REFERENCES public.children(id)
);
CREATE TABLE public.bookings (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  parent_id uuid NOT NULL,
  driver_id uuid NOT NULL,
  booking_type text NOT NULL CHECK (booking_type = ANY (ARRAY['Two Way'::text, 'One Way to School'::text, 'One Way Back Home'::text, 'Other'::text])),
  status text DEFAULT 'pending'::text CHECK (status = ANY (ARRAY['pending'::text, 'accepted'::text, 'rejected'::text, 'completed'::text])),
  hometxt_location text,
  schooltxt_location text,
  home_pickup_time text,
  school_pickup_time text,
  price numeric,
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  is_recurring boolean DEFAULT false,
  recurrence_pattern jsonb,
  subscription_status text CHECK (subscription_status = ANY (ARRAY['active'::text, 'paused'::text, 'cancelled'::text, 'expired'::text])),
  contract_start_date date,
  contract_end_date date,
  route_order integer DEFAULT 999,
  homegeo_location USER-DEFINED,
  schoolgeo_location USER-DEFINED,
  home_lat double precision DEFAULT st_y((homegeo_location)::geometry),
  home_lng double precision DEFAULT st_x((homegeo_location)::geometry),
  school_lat double precision DEFAULT st_y((schoolgeo_location)::geometry),
  school_lng double precision DEFAULT st_x((schoolgeo_location)::geometry),
  CONSTRAINT bookings_pkey PRIMARY KEY (id),
  CONSTRAINT bookings_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.drivers(user_id),
  CONSTRAINT bookings_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES auth.users(id)
);
CREATE TABLE public.child_absences (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  child_id uuid NOT NULL,
  date date NOT NULL,
  reason text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT child_absences_pkey PRIMARY KEY (id)
);
CREATE TABLE public.children (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  parent_id uuid,
  name text NOT NULL,
  school_name text,
  grade text,
  emergency_contact text,
  photo_url text,
  date_of_birth date,
  gender text,
  medical_conditions text,
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT children_pkey PRIMARY KEY (id),
  CONSTRAINT children_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES auth.users(id)
);
CREATE TABLE public.cities (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  state text,
  country text,
  location USER-DEFINED,
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  CONSTRAINT cities_pkey PRIMARY KEY (id)
);
CREATE TABLE public.driver_availability (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  driver_id uuid,
  day_of_week integer CHECK (day_of_week >= 0 AND day_of_week <= 6),
  start_time time without time zone NOT NULL,
  end_time time without time zone NOT NULL,
  CONSTRAINT driver_availability_pkey PRIMARY KEY (id),
  CONSTRAINT driver_availability_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.drivers(user_id)
);
CREATE TABLE public.driver_covered_schools (
  driver_id uuid NOT NULL,
  school_id uuid NOT NULL,
  CONSTRAINT driver_covered_schools_pkey PRIMARY KEY (driver_id, school_id),
  CONSTRAINT driver_covered_schools_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.drivers(user_id),
  CONSTRAINT driver_covered_schools_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id)
);
CREATE TABLE public.driver_documents (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  driver_id uuid,
  document_type text NOT NULL,
  file_url text NOT NULL,
  verified boolean DEFAULT false,
  uploaded_at timestamp with time zone DEFAULT now(),
  CONSTRAINT driver_documents_pkey PRIMARY KEY (id),
  CONSTRAINT driver_documents_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.drivers(user_id)
);
CREATE TABLE public.driver_locations (
  driver_id uuid NOT NULL UNIQUE,
  latitude double precision NOT NULL,
  longitude double precision NOT NULL,
  heading double precision DEFAULT 0.0,
  speed double precision DEFAULT 0.0,
  trip_type text CHECK (trip_type = ANY (ARRAY['pickup'::text, 'dropoff'::text, 'idle'::text])),
  is_online boolean DEFAULT false,
  updated_at timestamp with time zone DEFAULT now(),
  current_trip_id uuid,
  CONSTRAINT driver_locations_pkey PRIMARY KEY (driver_id),
  CONSTRAINT driver_locations_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES auth.users(id),
  CONSTRAINT driver_locations_current_trip_id_fkey FOREIGN KEY (current_trip_id) REFERENCES public.trips(id)
);
CREATE TABLE public.driver_schedules (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  driver_id uuid NOT NULL,
  day_of_week text NOT NULL CHECK (day_of_week = ANY (ARRAY['saturday'::text, 'sunday'::text, 'monday'::text, 'tuesday'::text, 'wednesday'::text, 'thursday'::text, 'friday'::text])),
  shift_type text NOT NULL CHECK (shift_type = ANY (ARRAY['Go to School(s)'::text, 'Return from School(s)'::text, 'custom'::text])),
  available_from time without time zone NOT NULL,
  available_until time without time zone NOT NULL,
  max_capacity integer DEFAULT 8,
  is_active boolean DEFAULT true,
  CONSTRAINT driver_schedules_pkey PRIMARY KEY (id),
  CONSTRAINT driver_schedules_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.drivers(user_id)
);
CREATE TABLE public.driver_service_areas (
  driver_id uuid NOT NULL,
  area_id uuid NOT NULL,
  CONSTRAINT driver_service_areas_pkey PRIMARY KEY (driver_id, area_id),
  CONSTRAINT driver_service_areas_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.drivers(user_id),
  CONSTRAINT driver_service_areas_area_id_fkey FOREIGN KEY (area_id) REFERENCES public.areas(id)
);
CREATE TABLE public.drivers (
  user_id uuid NOT NULL,
  vehicle_type text NOT NULL,
  vehicle_number text NOT NULL,
  service_radius_km integer DEFAULT 10,
  rating numeric DEFAULT 0,
  is_verified boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  license_verified boolean DEFAULT false,
  insurance_verified boolean DEFAULT false,
  background_check_verified boolean DEFAULT false,
  price_base numeric DEFAULT 10,
  price_per_km numeric DEFAULT 2,
  price_monthly_two_way numeric,
  price_monthly_one_way numeric,
  price_daily numeric,
  currency text DEFAULT 'OMR'::text,
  bio text,
  is_active boolean DEFAULT true,
  experience_years integer DEFAULT 0,
  license_number text,
  license_expiry date,
  license_image_url text,
  vehicle_capacity integer DEFAULT 0,
  mulkia_image_url text,
  location_text text,
  location_geo USER-DEFINED,
  location_lat double precision DEFAULT st_y((location_geo)::geometry),
  location_lng double precision DEFAULT st_x((location_geo)::geometry),
  start_location_text text,
  start_location_geo USER-DEFINED,
  start_location_lat double precision DEFAULT st_y((start_location_geo)::geometry),
  start_location_lng double precision DEFAULT st_x((start_location_geo)::geometry),
  CONSTRAINT drivers_pkey PRIMARY KEY (user_id),
  CONSTRAINT drivers_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);
CREATE TABLE public.messages (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  sender_id uuid NOT NULL,
  receiver_id uuid NOT NULL,
  content text NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  is_read boolean DEFAULT false,
  CONSTRAINT messages_pkey PRIMARY KEY (id),
  CONSTRAINT messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES auth.users(id),
  CONSTRAINT messages_receiver_id_fkey FOREIGN KEY (receiver_id) REFERENCES auth.users(id)
);
CREATE TABLE public.payments (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  booking_id uuid,
  payer_id uuid,
  amount numeric NOT NULL,
  currency text DEFAULT 'OMR'::text,
  payment_method text CHECK (payment_method = ANY (ARRAY['card'::text, 'cash'::text, 'wallet'::text])),
  payment_status text CHECK (payment_status = ANY (ARRAY['pending'::text, 'completed'::text, 'failed'::text, 'refunded'::text])),
  transaction_ref text,
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  CONSTRAINT payments_pkey PRIMARY KEY (id),
  CONSTRAINT payments_payer_id_fkey FOREIGN KEY (payer_id) REFERENCES public.users(id)
);
CREATE TABLE public.reviews (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  booking_id uuid UNIQUE,
  parent_id uuid,
  driver_id uuid,
  rating integer CHECK (rating >= 1 AND rating <= 5),
  comment text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT reviews_pkey PRIMARY KEY (id),
  CONSTRAINT reviews_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.users(id),
  CONSTRAINT reviews_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.users(id)
);
CREATE TABLE public.ride_events (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  booking_id uuid,
  child_id uuid,
  driver_id uuid,
  parent_id uuid,
  event_type text NOT NULL CHECK (event_type = ANY (ARRAY['approaching'::text, 'picked_up'::text, 'dropped_off'::text])),
  event_data jsonb DEFAULT '{}'::jsonb,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT ride_events_pkey PRIMARY KEY (id),
  CONSTRAINT ride_events_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.drivers(user_id),
  CONSTRAINT ride_events_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.users(id)
);
CREATE TABLE public.route_stops (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  trip_id uuid NOT NULL,
  stop_type text NOT NULL CHECK (stop_type = ANY (ARRAY['pickup'::text, 'dropoff'::text])),
  sequence_order integer NOT NULL,
  location_lat double precision NOT NULL,
  location_lng double precision NOT NULL,
  location_address text,
  child_id uuid,
  booking_id uuid NOT NULL,
  scheduled_time timestamp with time zone,
  estimated_arrival_time timestamp with time zone,
  actual_arrival_time timestamp with time zone,
  actual_departure_time timestamp with time zone,
  status text DEFAULT 'pending'::text CHECK (status = ANY (ARRAY['pending'::text, 'approaching'::text, 'arrived'::text, 'completed'::text, 'skipped'::text, 'no_show'::text])),
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  arrived_at timestamp with time zone,
  completed_at timestamp with time zone,
  CONSTRAINT route_stops_pkey PRIMARY KEY (id),
  CONSTRAINT route_stops_trip_id_fkey FOREIGN KEY (trip_id) REFERENCES public.trips(id)
);
CREATE TABLE public.saved_drivers (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  parent_id uuid,
  driver_id uuid,
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  CONSTRAINT saved_drivers_pkey PRIMARY KEY (id),
  CONSTRAINT saved_drivers_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.users(id),
  CONSTRAINT saved_drivers_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.drivers(user_id)
);
CREATE TABLE public.schools (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  area_id uuid,
  name text NOT NULL,
  address text,
  location USER-DEFINED,
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  CONSTRAINT schools_pkey PRIMARY KEY (id),
  CONSTRAINT schools_area_id_fkey FOREIGN KEY (area_id) REFERENCES public.areas(id)
);
CREATE TABLE public.spatial_ref_sys (
  srid integer NOT NULL CHECK (srid > 0 AND srid <= 998999),
  auth_name character varying,
  auth_srid integer,
  srtext character varying,
  proj4text character varying,
  CONSTRAINT spatial_ref_sys_pkey PRIMARY KEY (srid)
);
CREATE TABLE public.trips (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  booking_id uuid,
  start_time timestamp with time zone,
  end_time timestamp with time zone,
  current_location USER-DEFINED,
  updated_at timestamp with time zone DEFAULT now(),
  driver_id uuid,
  trip_type text CHECK (trip_type = ANY (ARRAY['Go to School(s)'::text, 'Return from School(s)'::text, 'custom'::text])),
  trip_date date NOT NULL DEFAULT CURRENT_DATE,
  status text DEFAULT 'scheduled'::text CHECK (status = ANY (ARRAY['scheduled'::text, 'in_progress'::text, 'completed'::text, 'cancelled'::text])),
  total_distance_km numeric,
  estimated_duration_minutes integer,
  route_polyline text,
  CONSTRAINT trips_pkey PRIMARY KEY (id),
  CONSTRAINT trips_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.drivers(user_id)
);
CREATE TABLE public.users (
  id uuid NOT NULL,
  role USER-DEFINED NOT NULL,
  full_name text NOT NULL,
  phone text NOT NULL UNIQUE,
  photo_url text,
  created_at timestamp with time zone DEFAULT now(),
  gender text,
  fcm_token text,
  CONSTRAINT users_pkey PRIMARY KEY (id),
  CONSTRAINT users_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);