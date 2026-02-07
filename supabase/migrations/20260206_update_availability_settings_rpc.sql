CREATE OR REPLACE FUNCTION public.get_driver_availability_settings()
RETURNS TABLE(
  auto_offline_after_trip boolean, 
  auto_online_before_trip boolean, 
  auto_online_minutes_before integer, 
  availability_mode text, 
  is_profile_online boolean,
  is_tracking_active boolean,
  is_app_online boolean,
  is_online_visible boolean
)
LANGUAGE plpgsql SECURITY DEFINER
AS $function$
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
        COALESCE(l.is_tracking_active, false) as is_tracking_active,
        COALESCE(u.is_app_online, false) as is_app_online,
        COALESCE(u.is_online_visible, true) as is_online_visible
    FROM public.drivers d
    JOIN public.users u ON u.id = d.user_id
    LEFT JOIN public.driver_locations l ON d.user_id = l.driver_id
    WHERE d.user_id = v_driver_id;
END;
$function$;
