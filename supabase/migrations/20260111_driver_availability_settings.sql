-- Migration: Driver Availability Settings
-- Adds smart online/offline behavior columns to drivers table

-- 1. Add availability settings columns to drivers table
ALTER TABLE public.drivers ADD COLUMN IF NOT EXISTS auto_offline_after_trip BOOLEAN DEFAULT true;
ALTER TABLE public.drivers ADD COLUMN IF NOT EXISTS auto_online_before_trip BOOLEAN DEFAULT true;
ALTER TABLE public.drivers ADD COLUMN IF NOT EXISTS auto_online_minutes_before INTEGER DEFAULT 15;
ALTER TABLE public.drivers ADD COLUMN IF NOT EXISTS availability_mode TEXT DEFAULT 'smart';

-- Add check constraint for availability_mode
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.check_constraints 
        WHERE constraint_name = 'drivers_availability_mode_check'
    ) THEN
        ALTER TABLE public.drivers ADD CONSTRAINT drivers_availability_mode_check 
        CHECK (availability_mode IN ('smart', 'manual'));
    END IF;
END $$;

-- 2. Ensure driver_locations has is_online column (should already exist)
ALTER TABLE public.driver_locations ADD COLUMN IF NOT EXISTS is_online BOOLEAN DEFAULT false;

-- 3. RPC: Update driver availability settings
CREATE OR REPLACE FUNCTION public.update_driver_availability_settings(
    p_auto_offline_after_trip BOOLEAN DEFAULT NULL,
    p_auto_online_before_trip BOOLEAN DEFAULT NULL,
    p_auto_online_minutes_before INTEGER DEFAULT NULL,
    p_availability_mode TEXT DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_driver_id UUID := auth.uid();
BEGIN
    UPDATE public.drivers
    SET 
        auto_offline_after_trip = COALESCE(p_auto_offline_after_trip, auto_offline_after_trip),
        auto_online_before_trip = COALESCE(p_auto_online_before_trip, auto_online_before_trip),
        auto_online_minutes_before = COALESCE(p_auto_online_minutes_before, auto_online_minutes_before),
        availability_mode = COALESCE(p_availability_mode, availability_mode)
    WHERE user_id = v_driver_id;
END;
$$;

-- 4. RPC: Set driver online status (upsert into driver_locations)
CREATE OR REPLACE FUNCTION public.set_driver_online_status(
    p_is_online BOOLEAN
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_driver_id UUID := auth.uid();
BEGIN
    INSERT INTO public.driver_locations (driver_id, latitude, longitude, is_online, updated_at)
    VALUES (v_driver_id, 0, 0, p_is_online, NOW())
    ON CONFLICT (driver_id) 
    DO UPDATE SET is_online = p_is_online, updated_at = NOW();
END;
$$;

-- 5. RPC: Get driver availability settings
CREATE OR REPLACE FUNCTION public.get_driver_availability_settings()
RETURNS TABLE(
    auto_offline_after_trip BOOLEAN,
    auto_online_before_trip BOOLEAN,
    auto_online_minutes_before INTEGER,
    availability_mode TEXT,
    is_online BOOLEAN
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_driver_id UUID := auth.uid();
BEGIN
    RETURN QUERY
    SELECT 
        d.auto_offline_after_trip,
        d.auto_online_before_trip,
        d.auto_online_minutes_before,
        d.availability_mode,
        COALESCE(dl.is_online, false) as is_online
    FROM public.drivers d
    LEFT JOIN public.driver_locations dl ON dl.driver_id = d.user_id
    WHERE d.user_id = v_driver_id;
END;
$$;

-- 6. RPC: Check and auto-set online based on first trip time
-- Called when app starts or at scheduled intervals
CREATE OR REPLACE FUNCTION public.check_auto_online()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_driver_id UUID := auth.uid();
    v_settings RECORD;
    v_first_trip RECORD;
    v_should_go_online BOOLEAN := false;
BEGIN
    -- Get driver settings
    SELECT auto_online_before_trip, auto_online_minutes_before, availability_mode
    INTO v_settings
    FROM public.drivers
    WHERE user_id = v_driver_id;
    
    -- If not in smart mode or auto-online disabled, skip
    IF v_settings.availability_mode != 'smart' OR NOT v_settings.auto_online_before_trip THEN
        RETURN false;
    END IF;
    
    -- Find first scheduled trip for today
    SELECT id, trip_type, start_time
    INTO v_first_trip
    FROM public.trips
    WHERE driver_id = v_driver_id
      AND trip_date = CURRENT_DATE
      AND status = 'scheduled'
    ORDER BY 
        CASE WHEN trip_type = 'Go to School(s)' THEN 0 ELSE 1 END,
        start_time
    LIMIT 1;
    
    -- If no trips, don't auto-online
    IF v_first_trip.id IS NULL THEN
        RETURN false;
    END IF;
    
    -- Check if we're within the auto-online window (e.g., 15 minutes before)
    -- Using NOW() and comparing to scheduled time
    IF v_first_trip.start_time IS NOT NULL AND 
       v_first_trip.start_time - INTERVAL '1 minute' * v_settings.auto_online_minutes_before <= NOW() AND
       v_first_trip.start_time > NOW() THEN
        -- Set online
        PERFORM public.set_driver_online_status(true);
        RETURN true;
    END IF;
    
    RETURN false;
END;
$$;

-- 7. RPC: Auto-offline after trip completion
-- Updates existing complete_trip to respect settings
CREATE OR REPLACE FUNCTION public.complete_trip_with_auto_offline(
    trip_id_input UUID,
    driver_lat FLOAT DEFAULT NULL,
    driver_lng FLOAT DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_driver_id UUID := auth.uid();
    v_settings RECORD;
BEGIN
    -- Complete the trip
    UPDATE public.trips
    SET status = 'completed', end_time = NOW()
    WHERE id = trip_id_input;
    
    -- Check if should auto-offline
    SELECT auto_offline_after_trip, availability_mode
    INTO v_settings
    FROM public.drivers
    WHERE user_id = v_driver_id;
    
    IF v_settings.availability_mode = 'smart' AND v_settings.auto_offline_after_trip THEN
        -- Check if there are more trips today
        IF NOT EXISTS (
            SELECT 1 FROM public.trips
            WHERE driver_id = v_driver_id
              AND trip_date = CURRENT_DATE
              AND status = 'scheduled'
        ) THEN
            -- No more trips, go offline
            PERFORM public.set_driver_online_status(false);
        END IF;
    END IF;
END;
$$;
