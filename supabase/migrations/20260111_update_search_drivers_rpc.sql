-- Update search_drivers to include online-only filter
-- Also ensures is_online status is checked against driver_locations table

CREATE OR REPLACE FUNCTION public.search_drivers(
    filter_gender TEXT DEFAULT NULL,
    max_price NUMERIC DEFAULT 1000,
    filter_area_id UUID DEFAULT NULL,
    filter_school_id UUID DEFAULT NULL,
    filter_online_only BOOLEAN DEFAULT FALSE -- New parameter
)
RETURNS TABLE (
    driver_id UUID,
    name TEXT,
    photo_url TEXT,
    gender TEXT,
    vehicle_type TEXT,
    rating NUMERIC,
    total_reviews INTEGER,
    price_monthly_two_way NUMERIC,
    price_monthly_one_way NUMERIC,
    bio TEXT,
    phone TEXT,
    is_online BOOLEAN
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT
        d.user_id as driver_id,
        u.full_name as name,
        u.photo_url,
        u.gender,
        d.vehicle_type,
        d.rating,
        -- Count reviews for this driver
        (SELECT COUNT(*)::INTEGER FROM public.reviews r WHERE r.driver_id = d.user_id) as total_reviews,
        d.price_monthly_two_way,
        d.price_monthly_one_way,
        d.bio,
        u.phone,
        COALESCE(l.is_online, false) as is_online
    FROM public.drivers d
    JOIN public.users u ON d.user_id = u.id
    LEFT JOIN public.driver_locations l ON d.user_id = l.driver_id
    WHERE
        d.is_active = true
        AND d.is_verified = true
        AND (filter_gender IS NULL OR u.gender = filter_gender)
        AND (max_price IS NULL OR d.price_monthly_two_way <= max_price)
        -- Check service areas if filter provided
        AND (
            filter_area_id IS NULL OR 
            EXISTS (
                SELECT 1 FROM public.driver_service_areas dsa 
                WHERE dsa.driver_id = d.user_id AND dsa.area_id = filter_area_id
            )
        )
        -- Check covered schools if filter provided
        AND (
            filter_school_id IS NULL OR 
            EXISTS (
                SELECT 1 FROM public.driver_covered_schools dcs 
                WHERE dcs.driver_id = d.user_id AND dcs.school_id = filter_school_id
            )
        )
        -- Check online status if filter is TRUE
        AND (
            filter_online_only IS FALSE OR 
            COALESCE(l.is_online, false) = TRUE
        );
END;
$$;
