create or replace function toggle_saved_driver(p_driver_id uuid)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid;
  v_exists boolean;
begin
  -- Get current user ID
  v_user_id := auth.uid();
  if v_user_id is null then
    raise exception 'Not authenticated';
  end if;

  -- Check if exists
  select exists(
    select 1 from saved_drivers
    where parent_id = v_user_id
    and driver_id = p_driver_id
  ) into v_exists;

  if v_exists then
    delete from saved_drivers
    where parent_id = v_user_id
    and driver_id = p_driver_id;
    return false; -- Indicates it is now NOT saved
  else
    insert into saved_drivers (parent_id, driver_id)
    values (v_user_id, p_driver_id);
    return true; -- Indicates it is now saved
  end if;
end;
$$;
