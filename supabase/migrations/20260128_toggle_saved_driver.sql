-- Function to toggle saved driver (favorite) status atomically
-- This replaces the read-then-write logic in the client, reducing network round trips and race conditions.

create or replace function toggle_saved_driver(target_driver_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  current_user_id uuid;
begin
  -- Get the ID of the authenticated user
  current_user_id := auth.uid();

  -- Check if the driver is already saved by this parent
  if exists (
    select 1
    from saved_drivers
    where parent_id = current_user_id
      and driver_id = target_driver_id
  ) then
    -- If exists, remove it (unfavorite)
    delete from saved_drivers
    where parent_id = current_user_id
      and driver_id = target_driver_id;
  else
    -- If not exists, add it (favorite)
    insert into saved_drivers (parent_id, driver_id)
    values (current_user_id, target_driver_id);
  end if;
end;
$$;
