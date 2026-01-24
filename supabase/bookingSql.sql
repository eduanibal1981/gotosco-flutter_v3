create table public.bookings (
  id uuid not null default gen_random_uuid (),
  parent_id uuid not null,
  driver_id uuid null,
  booking_type text not null,
  status text null default 'pending'::text,
  hometxt_location text null,
  schooltxt_location text null,
  home_pickup_time text null,
  school_pickup_time text null,
  price numeric null,
  notes text null,
  created_at timestamp with time zone null default now(),
  is_recurring boolean null default false,
  recurrence_pattern jsonb null,
  subscription_status text null,
  start_date date null,
  end_date date null,
  homegeo_location geography null,
  schoolgeo_location geography null,
  home_lat double precision GENERATED ALWAYS as (st_y ((homegeo_location)::geometry)) STORED null,
  home_lng double precision GENERATED ALWAYS as (st_x ((homegeo_location)::geometry)) STORED null,
  school_lat double precision GENERATED ALWAYS as (st_y ((schoolgeo_location)::geometry)) STORED null,
  school_lng double precision GENERATED ALWAYS as (st_x ((schoolgeo_location)::geometry)) STORED null,
  routego_order integer null default 999,
  routeret_order integer null default 999,
  is_monthly_subscription boolean null default false,
  student_id uuid null,
  school_id uuid null,
  recurring_days text[] null,
  payment_status text null default 'unpaid'::text,
  cancellation_reason text null,
  cancelled_at timestamp with time zone null,
  contract_start_date date null,
  contract_end_date date null,
  school_name text null,
  cancellation_type text null,
  cancellation_fee numeric null,
  cancel_requested_at timestamp with time zone null,
  pause_start_date date null,
  pause_end_date date null,
  trip_category text null default 'school'::text,
  is_one_time boolean null default false,
  scheduled_pickup_datetime timestamp with time zone null,
  scheduled_dropoff_datetime timestamp with time zone null,
  custom_pickup_location_text text null,
  custom_pickup_geo geography null,
  custom_dropoff_location_text text null,
  custom_dropoff_geo geography null,
  booking_flow_step text null default 'draft'::text,
  total_estimated_distance_km numeric null,
  total_estimated_duration_minutes integer null,
  custom_pickup_lat double precision GENERATED ALWAYS as (st_y ((custom_pickup_geo)::geometry)) STORED null,
  custom_pickup_lng double precision GENERATED ALWAYS as (st_x ((custom_pickup_geo)::geometry)) STORED null,
  custom_dropoff_lat double precision GENERATED ALWAYS as (st_y ((custom_dropoff_geo)::geometry)) STORED null,
  custom_dropoff_lng double precision GENERATED ALWAYS as (st_x ((custom_dropoff_geo)::geometry)) STORED null,
  is_multi_school boolean null default false,
  proposal_price numeric null,
  constraint bookings_pkey primary key (id),
  constraint bookings_driver_id_fkey foreign KEY (driver_id) references drivers (user_id) on delete CASCADE,
  constraint bookings_parent_id_fkey foreign KEY (parent_id) references auth.users (id) on delete CASCADE,
  constraint bookings_status_check check (
    (
      status = any (
        array[
          'pending'::text,
          'confirmed'::text,
          'completed'::text,
          'cancelled'::text,
          'posted'::text,
          'open'::text
        ]
      )
    )
  ),
  constraint bookings_subscription_status_check check (
    (
      subscription_status = any (
        array[
          'active'::text,
          'paused'::text,
          'cancelled'::text,
          'expired'::text
        ]
      )
    )
  ),
  constraint bookings_booking_flow_step_check check (
    (
      booking_flow_step = any (
        array[
          'draft'::text,
          'submitted'::text,
          'confirmed'::text
        ]
      )
    )
  ),
  constraint bookings_trip_category_check check (
    (
      trip_category = any (
        array['school'::text, 'Journey'::text, 'Other'::text]
      )
    )
  ),
  constraint bookings_booking_type_check check (
    (
      booking_type = any (
        array[
          'Two Way'::text,
          'One Way to School'::text,
          'One Way Back Home'::text,
          'Other'::text
        ]
      )
    )
  ),
  constraint bookings_cancellation_type_check check (
    (
      (cancellation_type is null)
      or (
        cancellation_type = any (
          array[
            'parent_cancel_grace'::text,
            'scheduled_stop'::text,
            'immediate_stop_fee'::text,
            'pause'::text,
            'safety_stop'::text
          ]
        )
      )
    )
  )
) TABLESPACE pg_default;

create index IF not exists idx_bookings_parent_created_at on public.bookings using btree (parent_id, created_at desc) TABLESPACE pg_default;

create index IF not exists idx_bookings_driver_status_created on public.bookings using btree (driver_id, status, created_at desc) TABLESPACE pg_default;

create index IF not exists idx_bookings_recurring_true on public.bookings using btree (parent_id, created_at desc) TABLESPACE pg_default
where
  (is_recurring = true);

create index IF not exists idx_bookings_date_range on public.bookings using btree (start_date, end_date) TABLESPACE pg_default
where
  (is_recurring = true);

create index IF not exists idx_bookings_recurring_days_gin on public.bookings using gin (recurring_days) TABLESPACE pg_default
where
  (is_recurring = true);

create index IF not exists idx_bookings_monthly_subscription_true on public.bookings using btree (parent_id, contract_start_date, contract_end_date) TABLESPACE pg_default
where
  (is_monthly_subscription = true);

create index IF not exists idx_bookings_generator_lookup on public.bookings using btree (driver_id, subscription_status, booking_type) TABLESPACE pg_default;

create index IF not exists idx_bookings_home_geo on public.bookings using gist (homegeo_location) TABLESPACE pg_default;

create index IF not exists idx_bookings_school_geo on public.bookings using gist (schoolgeo_location) TABLESPACE pg_default;

create index IF not exists idx_bookings_driver_status on public.bookings using btree (driver_id, status) TABLESPACE pg_default
where
  (
    status = any (array['pending'::text, 'accepted'::text])
  );

create trigger trigger_sync_booking_school_location BEFORE INSERT
or
update OF school_id,
schoolgeo_location,
schooltxt_location on bookings for EACH row
execute FUNCTION sync_booking_school_location ();

-- ============================================================================
create table public.schools (
  id uuid not null default gen_random_uuid (),
  name text not null,
  address text null,
  location geography null,
  created_at timestamp with time zone not null default timezone ('utc'::text, now()),
  city_id uuid null,
  latitude double precision null,
  longitude double precision null,
  createdby uuid null,
  constraint schools_pkey primary key (id),
  constraint schools_city_id_fkey foreign KEY (city_id) references cities (id) on delete CASCADE
) TABLESPACE pg_default;

create index IF not exists idx_schools_city_id on public.schools using btree (city_id) TABLESPACE pg_default;


-- ============================================================================
create table public.children (
  id uuid not null default extensions.uuid_generate_v4 (),
  parent_id uuid null,
  name text not null,
  school_name text null,
  grade text null,
  emergency_contact text null,
  photo_url text null,
  date_of_birth date null,
  gender text null,
  medical_conditions text null,
  notes text null,
  created_at timestamp with time zone null default now(),
  school_id uuid null,
  constraint children_pkey primary key (id),
  constraint children_parent_id_fkey foreign KEY (parent_id) references auth.users (id) on delete CASCADE,
  constraint children_school_id_fkey foreign KEY (school_id) references schools (id)
) TABLESPACE pg_default;

create index IF not exists idx_children_school_id on public.children using btree (school_id) TABLESPACE pg_default;
-- ============================================================================
create table public.booking_schools (
  id uuid not null default gen_random_uuid (),
  booking_id uuid not null,
  school_id uuid not null,
  sequence_order integer null,
  created_at timestamp with time zone null default now(),
  constraint booking_schools_pkey primary key (id),
  constraint booking_schools_booking_id_school_id_key unique (booking_id, school_id),
  constraint booking_schools_booking_id_fkey foreign KEY (booking_id) references bookings (id) on delete CASCADE,
  constraint booking_schools_school_id_fkey foreign KEY (school_id) references schools (id) on delete RESTRICT
) TABLESPACE pg_default;

create index IF not exists idx_booking_schools_booking_id on public.booking_schools using btree (booking_id) TABLESPACE pg_default;

create index IF not exists idx_booking_schools_school_id on public.booking_schools using btree (school_id) TABLESPACE pg_default;

-- ============================================================================
create table public.booking_children (
  booking_id uuid not null,
  child_id uuid not null,
  constraint booking_children_pkey primary key (booking_id, child_id),
  constraint booking_children_booking_id_fkey foreign KEY (booking_id) references bookings (id) on delete CASCADE,
  constraint booking_children_child_id_fkey foreign KEY (child_id) references children (id) on delete CASCADE
) TABLESPACE pg_default;

create index IF not exists idx_booking_children_booking_id on public.booking_children using btree (booking_id) TABLESPACE pg_default;

create index IF not exists idx_booking_children_child_id on public.booking_children using btree (child_id) TABLESPACE pg_default;

create index IF not exists idx_booking_children_child on public.booking_children using btree (child_id) TABLESPACE pg_default;

create trigger trg_check_duplicate_child_booking BEFORE INSERT
or
update on booking_children for EACH row
execute FUNCTION check_duplicate_child_booking ();