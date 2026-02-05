-- Create a function to handle trip regeneration atomically and securely (bypassing RLS issues)

CREATE OR REPLACE FUNCTION public.regenerate_daily_trips(
    target_date date DEFAULT CURRENT_DATE
) RETURNS boolean
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_driver_id UUID := auth.uid();
BEGIN
    -- 1. Check if user is authenticated
    IF v_driver_id IS NULL THEN
        RAISE EXCEPTION 'Not authenticated';
    END IF;

    -- 2. Delete existing trips for this driver and date
    -- Note: route_stops will be deleted via CASCADE on trip_id
    DELETE FROM public.trips 
    WHERE driver_id = v_driver_id 
      AND trip_date = target_date;

    -- 3. Reset driver location status if they were in a trip
    -- (This prevents the driver from being stuck in "pickup"/"dropoff" mode if we just deleted the active trip)
    UPDATE public.driver_locations
    SET trip_type = 'idle',
        is_tracking_active = false,
        updated_at = NOW()
    WHERE driver_id = v_driver_id;
      
    -- 4. Generate new trips
    PERFORM public.generate_go_trips(target_date, v_driver_id);
    PERFORM public.generate_return_trips(target_date, v_driver_id);
    
    RETURN true;
END;
$$;
