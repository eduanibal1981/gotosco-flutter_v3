create or replace function get_enriched_bookings()
returns table (
  id uuid,
  created_at timestamptz,
  parent_id uuid,
  driver_id uuid,
  status text,
  booking_type text,
  hometxt_location text,
  schooltxt_location text,
  homegeo_location geography,
  schoolgeo_location geography,
  home_pickup_time time,
  school_pickup_time time,
  notes text,
  price real,
  driver_name text,
  driver_photo text,
  kids_count int
) as $$
begin
  return query
  select
    b.id,
    b.created_at,
    b.parent_id,
    b.driver_id,
    b.status,
    b.booking_type,
    b.hometxt_location,
    b.schooltxt_location,
    b.homegeo_location,
    b.schoolgeo_location,
    b.home_pickup_time,
    b.school_pickup_time,
    b.notes,
    b.price,
    u.full_name,
    u.photo_url,
    coalesce(bc.kids_count, 0)
  from
    bookings as b
    inner join users as u on b.driver_id = u.id
    left join (
      select booking_id, count(*)::int as kids_count
      from booking_children
      group by booking_id
    ) as bc on b.id = bc.booking_id
  where
    b.parent_id = auth.uid()
  order by
    b.created_at desc;
end;
$$ language plpgsql security definer;

-- Grant execution to authenticated role
grant execute on function get_enriched_bookings() to authenticated;
