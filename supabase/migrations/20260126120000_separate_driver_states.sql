-- SEPARATE DRIVER STATES MIGRATION
-- 1) Profile Online (Advertisement) -> drivers.is_profile_online
-- 2) Trip Online (Tracking) -> driver_locations.is_tracking_active

-- A. Rename drivers.is_online to is_profile_online (to clarify specific purpose)
-- A. Rename drivers.is_online to is_profile_online (Safe check)
-- A. Rename drivers.is_online to is_profile_online (Safe check)
DO $$
BEGIN
    -- 1. If target column 'is_profile_online' already exists
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'drivers' AND column_name = 'is_profile_online') THEN
        -- If old column 'is_online' ALSO exists, drop it (assuming data is synced or negligible for this hotfix)
        IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'drivers' AND column_name = 'is_online') THEN
            ALTER TABLE public.drivers DROP COLUMN is_online;
        END IF;

    -- 2. If target 'is_profile_online' does NOT exist, but 'is_online' DOES
    ELSIF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'drivers' AND column_name = 'is_online') THEN
        ALTER TABLE public.drivers RENAME COLUMN is_online TO is_profile_online;
    
    -- 3. If neither exists (shouldn't happen given the flow, but good for completeness)
    ELSE
        ALTER TABLE public.drivers ADD COLUMN is_profile_online BOOLEAN DEFAULT false;
    END IF;
END $$;

-- B. Add is_tracking_active to driver_locations
-- This controls whether the driver is broadcasting location for trips
ALTER TABLE public.driver_locations
ADD COLUMN is_tracking_active BOOLEAN DEFAULT false;

-- C. Update search_drivers functions to use is_profile_online
CREATE OR REPLACE FUNCTION "public"."search_drivers"("filter_gender" "text" DEFAULT NULL::"text", "max_price" numeric DEFAULT 1000, "filter_area_id" "uuid" DEFAULT NULL::"uuid", "filter_school_id" "uuid" DEFAULT NULL::"uuid", "filter_online_only" boolean DEFAULT false) RETURNS TABLE("driver_id" "uuid", "name" "text", "photo_url" "text", "gender" "text", "vehicle_type" "text", "rating" numeric, "total_reviews" integer, "price_monthly_two_way" numeric, "price_monthly_one_way" numeric, "bio" "text", "phone" "text", "is_online" boolean)
    LANGUAGE "plpgsql" SECURITY DEFINER
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
        (SELECT COUNT(*)::INTEGER FROM public.reviews r WHERE r.driver_id = d.user_id) as total_reviews,
        d.price_monthly_two_way,
        d.price_monthly_one_way,
        d.bio,
        u.phone,
        -- Retain alias "is_online" for frontend compatibility, but map to is_profile_online
        COALESCE(d.is_profile_online, false) as is_online
    FROM public.drivers d
    JOIN public.users u ON d.user_id = u.id
    WHERE
        d.is_active = true
        AND d.is_verified = true
        AND (filter_gender IS NULL OR u.gender = filter_gender)
        AND (max_price IS NULL OR d.price_monthly_two_way <= max_price)
        AND (
            filter_area_id IS NULL OR 
            EXISTS (SELECT 1 FROM public.driver_service_areas dsa WHERE dsa.driver_id = d.user_id AND dsa.area_id = filter_area_id)
        )
        AND (
            filter_school_id IS NULL OR 
            EXISTS (SELECT 1 FROM public.driver_covered_schools dcs WHERE dcs.driver_id = d.user_id AND dcs.school_id = filter_school_id)
        )
        AND (
            filter_online_only IS FALSE OR 
            COALESCE(d.is_profile_online, false) = TRUE
        );
END;
$$;

-- D. Update search_drivers_for_parent_v2 to use is_profile_online
CREATE OR REPLACE FUNCTION "public"."search_drivers_for_parent_v2"("filter_gender" "text" DEFAULT NULL::"text", "filter_vehicle_type" "text" DEFAULT NULL::"text", "filter_min_rating" numeric DEFAULT NULL::numeric, "max_price_monthly_two_way" numeric DEFAULT NULL::numeric, "filter_area_id" "uuid" DEFAULT NULL::"uuid", "filter_school_id" "uuid" DEFAULT NULL::"uuid", "search_term" "text" DEFAULT NULL::"text", "parent_location_lat" double precision DEFAULT NULL::double precision, "parent_location_lng" double precision DEFAULT NULL::double precision, "max_distance_km" integer DEFAULT NULL::integer, "filter_online_only" boolean DEFAULT false, "require_verified" boolean DEFAULT false, "page_limit" integer DEFAULT 20, "page_offset" integer DEFAULT 0) RETURNS TABLE("driver_id" "uuid", "name" "text", "photo_url" "text", "gender" "text", "bio" "text", "phone" "text", "vehicle_type" "text", "vehicle_capacity" integer, "rating" numeric, "total_reviews" integer, "price_monthly_two_way" numeric, "price_monthly_one_way" numeric, "price_daily" numeric, "currency" "text", "advs_photos" "text"[], "is_online" boolean, "is_verified" boolean, "distance_km" numeric, "covered_schools" "jsonb", "service_areas" "jsonb")
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    parent_geo geography;
BEGIN
    IF parent_location_lat IS NOT NULL AND parent_location_lng IS NOT NULL THEN
        IF parent_location_lat BETWEEN -90 AND 90 AND parent_location_lng BETWEEN -180 AND 180 THEN
            parent_geo := ST_SetSRID(ST_MakePoint(parent_location_lng, parent_location_lat), 4326)::geography;
        END IF;
    END IF;

    RETURN QUERY
    SELECT
        d.user_id,
        u.full_name,
        u.photo_url,
        u.gender,
        d.bio,
        u.phone,
        d.vehicle_type,
        d.vehicle_capacity,
        d.rating,
        COALESCE(rs.total_reviews, 0),
        d.price_monthly_two_way,
        d.price_monthly_one_way,
        d.price_daily,
        d.currency,
        COALESCE(d.advs_photos, '{}'::text[]),
        -- Map to is_profile_online
        COALESCE(d.is_profile_online, false),
        d.is_verified,
        CASE
            WHEN parent_geo IS NOT NULL AND u.location_geo IS NOT NULL
            THEN ROUND((ST_Distance(u.location_geo, parent_geo) / 1000)::numeric, 2)
            ELSE NULL
        END,
        COALESCE(schools_data.json_agg, '[]'::jsonb),
        COALESCE(areas_data.json_agg, '[]'::jsonb)
    FROM public.drivers d
    INNER JOIN public.users u ON d.user_id = u.id
    LEFT JOIN public.driver_review_stats rs ON d.user_id = rs.driver_id
    LEFT JOIN LATERAL (
        SELECT jsonb_agg(jsonb_build_object('id', s.id, 'name', s.name, 'address', s.address, 'city_name', c.name)) as json_agg
        FROM public.driver_covered_schools dcs
        JOIN public.schools s ON dcs.school_id = s.id
        LEFT JOIN public.cities c ON s.city_id = c.id
        WHERE dcs.driver_id = d.user_id
        LIMIT 50
    ) schools_data ON TRUE
    LEFT JOIN LATERAL (
        SELECT jsonb_agg(jsonb_build_object('id', a.id, 'name', a.name)) as json_agg
        FROM public.driver_service_areas dsa
        JOIN public.areas a ON dsa.area_id = a.id
        WHERE dsa.driver_id = d.user_id
        LIMIT 50
    ) areas_data ON TRUE
    WHERE d.is_active = TRUE
      AND (require_verified IS FALSE OR d.is_verified = TRUE)
      AND (filter_min_rating IS NULL OR d.rating >= filter_min_rating)
      AND (filter_gender IS NULL OR u.gender = filter_gender)
      AND (filter_vehicle_type IS NULL OR d.vehicle_type = filter_vehicle_type)
      AND (max_price_monthly_two_way IS NULL OR d.price_monthly_two_way <= max_price_monthly_two_way)
      AND (filter_online_only IS FALSE OR COALESCE(d.is_profile_online, false) = TRUE)
      AND (
          filter_area_id IS NULL OR EXISTS (SELECT 1 FROM public.driver_service_areas dsa WHERE dsa.driver_id = d.user_id AND dsa.area_id = filter_area_id)
      )
      AND (
          filter_school_id IS NULL OR EXISTS (SELECT 1 FROM public.driver_covered_schools dcs WHERE dcs.driver_id = d.user_id AND dcs.school_id = filter_school_id)
      )
      AND (
          max_distance_km IS NULL OR parent_geo IS NULL OR u.location_geo IS NULL
          OR ST_DWithin(u.location_geo, parent_geo, max_distance_km * 1000)
      )
      AND (
          search_term IS NULL OR search_term = '' OR u.full_name ILIKE '%' || search_term || '%'
          OR EXISTS (SELECT 1 FROM public.driver_covered_schools dcs JOIN public.schools s ON dcs.school_id = s.id WHERE dcs.driver_id = d.user_id AND s.name ILIKE '%' || search_term || '%')
          OR EXISTS (SELECT 1 FROM public.driver_service_areas dsa JOIN public.areas a ON dsa.area_id = a.id WHERE dsa.driver_id = d.user_id AND a.name ILIKE '%' || search_term || '%')
      )
    ORDER BY
       COALESCE(d.is_profile_online, false) DESC,
       CASE WHEN parent_geo IS NOT NULL AND u.location_geo IS NOT NULL THEN u.location_geo <-> parent_geo ELSE NULL END ASC NULLS LAST,
       d.rating DESC,
       d.created_at DESC
    LIMIT page_limit OFFSET page_offset;
END;
$$;

-- E. Rename set_driver_online_status to set_profile_online_status
DROP FUNCTION IF EXISTS public.set_driver_online_status(boolean);

CREATE OR REPLACE FUNCTION public.set_profile_online_status(p_is_online boolean)
RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER
AS $$
DECLARE
  v_driver_id UUID := auth.uid();
BEGIN
  UPDATE public.drivers
  SET is_profile_online = p_is_online
  WHERE user_id = v_driver_id;
END;
$$;

-- F. Create set_tracking_status (Trip Online)
CREATE OR REPLACE FUNCTION public.set_tracking_status(p_is_tracking boolean)
RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER
AS $$
DECLARE
  v_driver_id UUID := auth.uid();
BEGIN
    INSERT INTO public.driver_locations (driver_id, latitude, longitude, is_tracking_active, updated_at)
    VALUES (v_driver_id, 0, 0, p_is_tracking, NOW())
    ON CONFLICT (driver_id) 
    DO UPDATE SET is_tracking_active = p_is_tracking, updated_at = NOW();
END;
$$;

-- G. Update get_driver_availability_settings to return BOTH
DROP FUNCTION IF EXISTS public.get_driver_availability_settings();

CREATE OR REPLACE FUNCTION public.get_driver_availability_settings()
RETURNS TABLE(
  auto_offline_after_trip boolean, 
  auto_online_before_trip boolean, 
  auto_online_minutes_before integer, 
  availability_mode text, 
  is_profile_online boolean,
  is_tracking_active boolean
)
LANGUAGE plpgsql SECURITY DEFINER
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
        COALESCE(d.is_profile_online, false) as is_profile_online,
        COALESCE(l.is_tracking_active, false) as is_tracking_active
    FROM public.drivers d
    LEFT JOIN public.driver_locations l ON d.user_id = l.driver_id
    WHERE d.user_id = v_driver_id;
END;
$$;

-- H. Update Tracking Policy to check is_tracking_active instead of is_profile_online
DROP POLICY IF EXISTS "Parents can view relevant drivers" ON "public"."driver_locations";

CREATE POLICY "Parents can view relevant drivers" ON "public"."driver_locations"
FOR SELECT
TO public
USING (
  (is_tracking_active = true) -- Driver explicitly started tracking
  OR 
  (EXISTS ( 
     SELECT 1 FROM bookings
     WHERE bookings.driver_id = driver_locations.driver_id 
     AND bookings.parent_id = auth.uid() 
     AND bookings.status = 'accepted'
  ))
);
