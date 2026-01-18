create or replace function public.get_enriched_bookings()
returns table (
  -- bookings core
  id uuid,
  parent_id uuid,
  driver_id uuid,
  booking_type text,
  status text,

  hometxt_location text,
  schooltxt_location text,
  home_pickup_time text,
  school_pickup_time text,
  price numeric,
  notes text,
  created_at timestamptz,

  -- recurring/subscription
  is_recurring boolean,
  recurrence_pattern jsonb,
  subscription_status text,
  start_date date,
  end_date date,
  recurring_days text[],
  is_monthly_subscription boolean,

  -- geo + derived columns (exist in table)
  homegeo_location geography,
  schoolgeo_location geography,
  home_lat double precision,
  home_lng double precision,
  school_lat double precision,
  school_lng double precision,

  -- routing + extra fields
  routego_order integer,
  routeret_order integer,
  payment_status text,
  cancellation_reason text,
  cancelled_at timestamptz,
  contract_start_date date,
  contract_end_date date,

  -- optional relations on bookings
  student_id uuid,
  school_id uuid,

  -- enrichment
  driver_name text,
  driver_photo text,
  school_name text,
  school_address text,

  kids_count integer,
  child_names text[],

  -- UI-compat keys (optional, but handy)
  home_location text,
  school_location text
)
language sql
security definer
set search_path = public
as $$
  select
    b.id,
    b.parent_id,
    b.driver_id,
    b.booking_type,
    b.status,

    b.hometxt_location,
    b.schooltxt_location,
    b.home_pickup_time,
    b.school_pickup_time,
    b.price,
    b.notes,
    b.created_at,

    b.is_recurring,
    b.recurrence_pattern,
    b.subscription_status,
    b.start_date,
    b.end_date,
    b.recurring_days::text[],
    b.is_monthly_subscription,

    b.homegeo_location::geography,
    b.schoolgeo_location::geography,
    b.home_lat,
    b.home_lng,
    b.school_lat,
    b.school_lng,

    b.routego_order,
    b.routeret_order,
    b.payment_status,
    b.cancellation_reason,
    b.cancelled_at,
    b.contract_start_date,
    b.contract_end_date,

    b.student_id,
    b.school_id,

    u.full_name as driver_name,
    u.photo_url as driver_photo,

    s.name as school_name,
    s.address as school_address,

    count(distinct c.id)::int as kids_count,
    coalesce(
      array_agg(distinct c.name order by c.name) filter (where c.name is not null),
      '{}'::text[]
    ) as child_names,

    -- UI compatibility
    b.hometxt_location as home_location,
    b.schooltxt_location as school_location

  from public.bookings b
  join public.users u
    on u.id = b.driver_id
  left join public.schools s
    on s.id = b.school_id
  left join public.booking_children bc
    on bc.booking_id = b.id
  left join public.children c
    on c.id = bc.child_id

  where b.parent_id = auth.uid()

  group by
    b.id,
    u.full_name,
    u.photo_url,
    s.name,
    s.address

  order by b.created_at desc;
$$;

grant execute on function public.get_enriched_bookings() to authenticated;

create index if not exists idx_bookings_parent_created_at
on public.bookings (parent_id, created_at desc);
create index if not exists idx_bookings_driver_status_created
on public.bookings (driver_id, status, created_at desc);
create index if not exists idx_bookings_recurring_true
on public.bookings (parent_id, created_at desc)
where is_recurring = true;
create index if not exists idx_bookings_date_range
on public.bookings (start_date, end_date)
where is_recurring = true;
create index if not exists idx_bookings_recurring_days_gin
on public.bookings using gin (recurring_days)
where is_recurring = true;
create index if not exists idx_bookings_monthly_subscription_true
on public.bookings (parent_id, contract_start_date, contract_end_date)
where is_monthly_subscription = true;
create index if not exists idx_booking_children_booking_id
on public.booking_children (booking_id);

create index if not exists idx_booking_children_child_id
on public.booking_children (child_id);
