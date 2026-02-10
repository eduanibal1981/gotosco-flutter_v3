CREATE OR REPLACE FUNCTION "public"."get_parent_next_stop_info"("booking_id_input" "uuid") RETURNS TABLE("next_stop_is_parent" boolean, "next_stop_label" "text", "stops_until_parent" integer, "eta_minutes" integer, "stop_status" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  v_parent_id UUID := auth.uid();
  v_booking RECORD;
  v_trip RECORD;
  v_parent_stop RECORD;
  v_next_stop_id UUID;
  v_eta INTEGER;
  v_stops_until INTEGER := 0;
  v_parent_stop_label TEXT;
BEGIN
  SELECT b.id, b.parent_id, b.driver_id
  INTO v_booking
  FROM public.bookings b
  WHERE b.id = booking_id_input;

  IF v_booking.id IS NULL OR v_booking.parent_id != v_parent_id THEN
    RETURN;
  END IF;

  SELECT dl.next_stop_id, dl.eta_minutes
  INTO v_next_stop_id, v_eta
  FROM public.driver_locations dl
  WHERE dl.driver_id = v_booking.driver_id;

  SELECT t.id, t.trip_type
  INTO v_trip
  FROM public.trips t
  JOIN public.route_stops rs ON rs.trip_id = t.id
  WHERE rs.booking_id = booking_id_input
    AND t.status IN ('scheduled', 'in_progress')
  ORDER BY t.trip_date DESC, t.start_time DESC NULLS LAST
  LIMIT 1;

  IF v_trip.id IS NULL THEN
    RETURN QUERY SELECT false, NULL::text, NULL::int, v_eta, NULL::text;
    RETURN;
  END IF;

  SELECT rs.id, rs.sequence_order, rs.stop_type, rs.status
  INTO v_parent_stop
  FROM public.route_stops rs
  WHERE rs.trip_id = v_trip.id
    AND rs.booking_id = booking_id_input
    AND rs.status IN ('pending', 'arrived')
  ORDER BY rs.sequence_order
  LIMIT 1;

  IF v_parent_stop.id IS NULL THEN
    RETURN QUERY SELECT false, NULL::text, 0::int, v_eta, NULL::text;
    RETURN;
  END IF;

  SELECT COUNT(*)
  INTO v_stops_until
  FROM public.route_stops rs
  WHERE rs.trip_id = v_trip.id
    AND rs.status IN ('pending', 'arrived')
    AND rs.sequence_order < v_parent_stop.sequence_order;

  v_parent_stop_label := CASE
    WHEN v_trip.trip_type = 'Go to School(s)' AND v_parent_stop.stop_type = 'pickup'
      THEN 'Home Pickup'
    WHEN v_trip.trip_type = 'Go to School(s)' AND v_parent_stop.stop_type = 'dropoff'
      THEN 'School Dropoff'
    WHEN v_trip.trip_type = 'Return from School(s)' AND v_parent_stop.stop_type = 'pickup'
      THEN 'School Pickup'
    WHEN v_trip.trip_type = 'Return from School(s)' AND v_parent_stop.stop_type = 'dropoff'
      THEN 'Home Dropoff'
    ELSE 'Next Stop'
  END;

  RETURN QUERY
    SELECT (v_next_stop_id = v_parent_stop.id),
           v_parent_stop_label,
           v_stops_until,
           v_eta,
           v_parent_stop.status::text;
END;
$$;


ALTER FUNCTION "public"."get_parent_next_stop_info"("booking_id_input" "uuid") OWNER TO "postgres";
