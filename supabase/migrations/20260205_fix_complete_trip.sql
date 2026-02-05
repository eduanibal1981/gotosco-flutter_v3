-- Fix complete_trip_with_auto_offline to use correct function name (set_profile_online_status)
-- And ensure both complete_trip functions update driver_locations monitoring status

-- 1. Update complete_trip_with_auto_offline
CREATE OR REPLACE FUNCTION public.complete_trip_with_auto_offline(
    trip_id_input uuid, 
    driver_lat double precision DEFAULT NULL, 
    driver_lng double precision DEFAULT NULL
) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_driver_id UUID := auth.uid();
    v_settings RECORD;
BEGIN
    -- 1. Complete the trip
    UPDATE public.trips
    SET status = 'completed', end_time = NOW()
    WHERE id = trip_id_input;

    -- 2. Update driver location (Stop tracking)
    UPDATE public.driver_locations
    SET is_tracking_active = false,
        trip_type = 'idle',
        updated_at = NOW()
    WHERE driver_id = v_driver_id;
    
    -- 3. Check if should auto-offline (Profile/Ads Visibility)
    SELECT auto_offline_after_trip, availability_mode
    INTO v_settings
    FROM public.drivers
    WHERE user_id = v_driver_id;
    
    IF v_settings.availability_mode = 'smart' AND v_settings.auto_offline_after_trip THEN
        -- Check if there are more scheduled trips today
        IF NOT EXISTS (
            SELECT 1 FROM public.trips
            WHERE driver_id = v_driver_id
              AND trip_date = CURRENT_DATE
              AND status = 'scheduled'
        ) THEN
            -- No more trips, go Profile Offline (Hide from search)
            -- FIX: Use set_profile_online_status instead of set_driver_online_status
            PERFORM public.set_profile_online_status(false);
        END IF;
    END IF;
END;
$$;

-- 2. Update complete_trip (Standard version)
CREATE OR REPLACE FUNCTION public.complete_trip(
    trip_id_input uuid, 
    driver_lat double precision DEFAULT NULL, 
    driver_lng double precision DEFAULT NULL
) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_driver_id UUID := auth.uid();
BEGIN
    -- 1. Complete the trip
    UPDATE public.trips
    SET status = 'completed',
        end_time = NOW()
    WHERE id = trip_id_input;

    -- 2. Update driver location (Stop tracking)
    -- This ensures the UI reflects that the trip has ended immediately
    UPDATE public.driver_locations
    SET is_tracking_active = false,
        trip_type = 'idle',
        updated_at = NOW()
    WHERE driver_id = v_driver_id;
END;
$$;
