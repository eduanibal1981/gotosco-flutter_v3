-- Create a secure RPC to update route order
-- This avoids RLS issues with 'upsert' by handling the update internally with explicit ownership checks.

CREATE OR REPLACE FUNCTION public.update_route_order(
  updates jsonb -- Array of objects: [{"id": "uuid", "sequence_order": 1}, ...]
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER -- Runs with superuser privileges (bypassing RLS)
SET search_path = public
AS $$
DECLARE
  item jsonb;
  _stop_id UUID;
  _seq INT;
  _driver_id UUID;
BEGIN
  -- Get the current user ID
  _driver_id := auth.uid();

  -- Iterate through the updates
  FOR item IN SELECT * FROM jsonb_array_elements(updates)
  LOOP
    _stop_id := (item->>'id')::UUID;
    _seq := (item->>'sequence_order')::INT;

    -- Update the stop ONLY if it belongs to a trip assigned to this driver
    UPDATE public.route_stops rs
    SET sequence_order = _seq
    FROM public.trips t
    WHERE rs.trip_id = t.id
      AND rs.id = _stop_id
      AND t.driver_id = _driver_id; -- Security Check: Must belong to caller
  END LOOP;
END;
$$;
