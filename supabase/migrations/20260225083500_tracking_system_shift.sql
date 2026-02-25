-- STEP 2 — Create Index for Fast Latest Event Lookup
CREATE INDEX IF NOT EXISTS idx_ride_events_booking_created_desc
ON public.ride_events (booking_id, created_at DESC);

-- STEP 3 — Create View: latest_booking_event
CREATE OR REPLACE VIEW public.latest_booking_event AS
SELECT DISTINCT ON (booking_id)
    id,
    booking_id,
    driver_id,
    parent_id,
    daily_trip_id,
    event_type,
    event_data,
    created_at
FROM public.ride_events
ORDER BY booking_id, created_at DESC;

-- STEP 4 — Create Parent Tracking Snapshot View
CREATE OR REPLACE VIEW public.parent_tracking_snapshot AS
SELECT
    b.id AS booking_id,
    b.parent_id,
    lbe.driver_id,
    lbe.daily_trip_id AS trip_id,
    lbe.event_type,
    lbe.event_data,
    lbe.created_at AS event_created_at,

    -- Driver Live Data
    dl.latitude,
    dl.longitude,
    dl.eta_minutes,
    dl.trips_started,

    -- Trip Info
    t.trip_type,
    t.trip_direction,
    t.status AS trip_status,

    -- ======================
    -- UI State Derivation
    -- ======================

    CASE
        WHEN d.is_active IS FALSE THEN 'OFFLINE'
        WHEN lbe.event_type = 'dropped_off' THEN 'COMPLETED'
        WHEN lbe.event_type = 'arrived' THEN 'ARRIVED'
        WHEN lbe.event_type = 'picked_up' THEN 'ON_TRIP'
        WHEN lbe.event_type = 'trip_started' THEN 'LIVE_TRIP'
        ELSE 'SCHEDULED'
    END AS status_badge,

    CASE
        WHEN d.is_active IS FALSE THEN 'Scheduled Trip'
        WHEN lbe.event_type = 'dropped_off' THEN 'Child Dropped Off'
        WHEN lbe.event_type = 'arrived' THEN 'Driver Arrived'
        WHEN lbe.event_type = 'picked_up' THEN 'Child Picked Up'
        WHEN lbe.event_type = 'trip_started' THEN 'Trip Started'
        ELSE 'Trip Scheduled'
    END AS ui_title,

    CASE
        WHEN d.is_active IS FALSE THEN 'Driver is currently offline'
        WHEN lbe.event_type = 'dropped_off'
            THEN 'Arrived safely'
        WHEN lbe.event_type = 'arrived'
            THEN lbe.event_data->>'description'
        WHEN lbe.event_type = 'picked_up'
            THEN 'Heading to destination · ' || COALESCE(dl.eta_minutes, 0) || ' min'
        WHEN lbe.event_type = 'trip_started'
            THEN COALESCE(dl.eta_minutes, 0) || ' min away'
        ELSE 'Waiting for trip to begin'
    END AS ui_subtitle,

    CASE
        WHEN t.trip_type = 'Go to School(s)' THEN true
        ELSE false
    END AS is_go_trip

FROM public.bookings b
LEFT JOIN public.latest_booking_event lbe
       ON lbe.booking_id = b.id
LEFT JOIN public.driver_locations dl
       ON dl.driver_id = lbe.driver_id
LEFT JOIN public.trips t
       ON t.id = lbe.daily_trip_id
LEFT JOIN public.drivers d
       ON d.user_id = lbe.driver_id;

-- STEP 6 — Keep get_parent_tracking_ui_state Temporarily
COMMENT ON FUNCTION "public"."get_parent_tracking_ui_state"("booking_id_input" "uuid") IS '@deprecated Use parent_tracking_snapshot view instead. Scheduled for removal in 1 week.';
