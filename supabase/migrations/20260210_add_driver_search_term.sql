-- Add search_term support for parent driver search
CREATE OR REPLACE FUNCTION "public"."search_drivers_for_parent_v2"(
  "filter_gender" "text" DEFAULT NULL::"text",
  "filter_vehicle_type" "text" DEFAULT NULL::"text",
  "filter_min_rating" numeric DEFAULT NULL::numeric,
  "max_price_monthly_two_way" numeric DEFAULT NULL::numeric,
  "filter_area_id" "uuid" DEFAULT NULL::"uuid",
  "filter_school_id" "uuid" DEFAULT NULL::"uuid",
  "search_term" "text" DEFAULT NULL::"text",
  "parent_location_lat" double precision DEFAULT NULL::double precision,
  "parent_location_lng" double precision DEFAULT NULL::double precision,
  "max_distance_km" integer DEFAULT NULL::integer,
  "filter_online_only" boolean DEFAULT false,
  "require_verified" boolean DEFAULT false,
  "page_limit" integer DEFAULT 20,
  "page_offset" integer DEFAULT 0
) RETURNS TABLE(
  "driver_id" "uuid",
  "name" "text",
  "photo_url" "text",
  "gender" "text",
  "bio" "text",
  "phone" "text",
  "vehicle_type" "text",
  "vehicle_capacity" integer,
  "rating" numeric,
  "total_reviews" integer,
  "price_monthly_two_way" numeric,
  "price_monthly_one_way" numeric,
  "price_daily" numeric,
  "currency" "text",
  "advs_photos" "text"[],
  "is_online" boolean,
  "is_verified" boolean,
  "distance_km" numeric,
  "covered_schools" "jsonb",
  "service_areas" "jsonb"
)
LANGUAGE "plpgsql" STABLE SECURITY DEFINER
SET "search_path" TO 'public'
AS $$
DECLARE
    parent_geo geography;
BEGIN
    IF parent_location_lat IS NOT NULL AND parent_location_lng IS NOT NULL THEN
        IF parent_location_lat BETWEEN -90 AND 90
           AND parent_location_lng BETWEEN -180 AND 180 THEN
            parent_geo := ST_SetSRID(
                ST_MakePoint(parent_location_lng, parent_location_lat),
                4326
            )::geography;
        ELSE
            RAISE WARNING 'Invalid coordinates provided: %, %', parent_location_lat, parent_location_lng;
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
        COALESCE(l.is_online, false),
        d.is_verified,
        CASE
            WHEN parent_geo IS NOT NULL AND d.location_geo IS NOT NULL
            THEN ROUND((ST_Distance(d.location_geo, parent_geo) / 1000)::numeric, 2)
            ELSE NULL
        END,
        COALESCE(schools_data.json_agg, '[]'::jsonb),
        COALESCE(areas_data.json_agg, '[]'::jsonb)
    FROM public.drivers d
    INNER JOIN public.users u ON d.user_id = u.id
    LEFT JOIN public.driver_locations l ON d.user_id = l.driver_id
    LEFT JOIN public.driver_review_stats rs ON d.user_id = rs.driver_id
    LEFT JOIN LATERAL (
        SELECT jsonb_agg(
            jsonb_build_object(
                'id', s.id,
                'name', s.name,
                'address', s.address,
                'city_name', c.name
            )
        ) as json_agg
        FROM public.driver_covered_schools dcs
        JOIN public.schools s ON dcs.school_id = s.id
        LEFT JOIN public.cities c ON s.city_id = c.id
        WHERE dcs.driver_id = d.user_id
        LIMIT 50
    ) schools_data ON TRUE
    LEFT JOIN LATERAL (
        SELECT jsonb_agg(
            jsonb_build_object(
                'id', a.id,
                'name', a.name
            )
        ) as json_agg
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
      AND (filter_online_only IS FALSE OR COALESCE(l.is_online, false) = TRUE)
      AND (
          filter_area_id IS NULL
          OR EXISTS (
              SELECT 1 FROM public.driver_service_areas dsa
              WHERE dsa.driver_id = d.user_id
              AND dsa.area_id = filter_area_id
          )
      )
      AND (
          filter_school_id IS NULL
          OR EXISTS (
              SELECT 1 FROM public.driver_covered_schools dcs
              WHERE dcs.driver_id = d.user_id
              AND dcs.school_id = filter_school_id
          )
      )
      AND (
          max_distance_km IS NULL
          OR parent_geo IS NULL
          OR d.location_geo IS NULL
          OR ST_DWithin(d.location_geo, parent_geo, max_distance_km * 1000)
      )
      AND (
          search_term IS NULL
          OR search_term = ''
          OR u.full_name ILIKE '%' || search_term || '%'
          OR EXISTS (
              SELECT 1
              FROM public.driver_covered_schools dcs
              JOIN public.schools s ON dcs.school_id = s.id
              WHERE dcs.driver_id = d.user_id
                AND s.name ILIKE '%' || search_term || '%'
          )
          OR EXISTS (
              SELECT 1
              FROM public.driver_service_areas dsa
              JOIN public.areas a ON dsa.area_id = a.id
              WHERE dsa.driver_id = d.user_id
                AND a.name ILIKE '%' || search_term || '%'
          )
      )
    ORDER BY
       COALESCE(l.is_online, false) DESC,
       CASE
           WHEN parent_geo IS NOT NULL AND d.location_geo IS NOT NULL
           THEN d.location_geo <-> parent_geo
           ELSE NULL
       END ASC NULLS LAST,
       d.rating DESC,
       d.created_at DESC
    LIMIT page_limit OFFSET page_offset;
END;
$$;

ALTER FUNCTION "public"."search_drivers_for_parent_v2"(
  "filter_gender" "text",
  "filter_vehicle_type" "text",
  "filter_min_rating" numeric,
  "max_price_monthly_two_way" numeric,
  "filter_area_id" "uuid",
  "filter_school_id" "uuid",
  "search_term" "text",
  "parent_location_lat" double precision,
  "parent_location_lng" double precision,
  "max_distance_km" integer,
  "filter_online_only" boolean,
  "require_verified" boolean,
  "page_limit" integer,
  "page_offset" integer
) OWNER TO "postgres";

GRANT ALL ON FUNCTION "public"."search_drivers_for_parent_v2"(
  "filter_gender" "text",
  "filter_vehicle_type" "text",
  "filter_min_rating" numeric,
  "max_price_monthly_two_way" numeric,
  "filter_area_id" "uuid",
  "filter_school_id" "uuid",
  "search_term" "text",
  "parent_location_lat" double precision,
  "parent_location_lng" double precision,
  "max_distance_km" integer,
  "filter_online_only" boolean,
  "require_verified" boolean,
  "page_limit" integer,
  "page_offset" integer
) TO "anon";
GRANT ALL ON FUNCTION "public"."search_drivers_for_parent_v2"(
  "filter_gender" "text",
  "filter_vehicle_type" "text",
  "filter_min_rating" numeric,
  "max_price_monthly_two_way" numeric,
  "filter_area_id" "uuid",
  "filter_school_id" "uuid",
  "search_term" "text",
  "parent_location_lat" double precision,
  "parent_location_lng" double precision,
  "max_distance_km" integer,
  "filter_online_only" boolean,
  "require_verified" boolean,
  "page_limit" integer,
  "page_offset" integer
) TO "authenticated";
GRANT ALL ON FUNCTION "public"."search_drivers_for_parent_v2"(
  "filter_gender" "text",
  "filter_vehicle_type" "text",
  "filter_min_rating" numeric,
  "max_price_monthly_two_way" numeric,
  "filter_area_id" "uuid",
  "filter_school_id" "uuid",
  "search_term" "text",
  "parent_location_lat" double precision,
  "parent_location_lng" double precision,
  "max_distance_km" integer,
  "filter_online_only" boolean,
  "require_verified" boolean,
  "page_limit" integer,
  "page_offset" integer
) TO "service_role";
