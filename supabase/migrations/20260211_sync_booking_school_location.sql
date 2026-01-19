CREATE OR REPLACE FUNCTION public.sync_booking_school_location()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  school_row record;
BEGIN
  IF NEW.school_id IS NULL THEN
    RETURN NEW;
  END IF;

  SELECT name, address, location, latitude, longitude
  INTO school_row
  FROM public.schools
  WHERE id = NEW.school_id;

  IF FOUND THEN
    IF NEW.school_name IS NULL THEN
      NEW.school_name := school_row.name;
    END IF;

    IF NEW.schooltxt_location IS NULL OR NEW.schooltxt_location = '' THEN
      NEW.schooltxt_location := school_row.address;
    END IF;

    IF NEW.schoolgeo_location IS NULL THEN
      IF school_row.location IS NOT NULL THEN
        NEW.schoolgeo_location := school_row.location;
      ELSIF school_row.latitude IS NOT NULL AND school_row.longitude IS NOT NULL THEN
        NEW.schoolgeo_location := ST_SetSRID(
          ST_MakePoint(school_row.longitude, school_row.latitude),
          4326
        );
      END IF;
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trigger_sync_booking_school_location ON public.bookings;
CREATE TRIGGER trigger_sync_booking_school_location
BEFORE INSERT OR UPDATE OF school_id, schoolgeo_location, schooltxt_location
ON public.bookings
FOR EACH ROW
EXECUTE FUNCTION public.sync_booking_school_location();

UPDATE public.bookings b
SET
  school_name = COALESCE(b.school_name, s.name),
  schooltxt_location = COALESCE(b.schooltxt_location, s.address),
  schoolgeo_location = COALESCE(
    b.schoolgeo_location,
    s.location,
    CASE
      WHEN s.latitude IS NOT NULL AND s.longitude IS NOT NULL THEN
        ST_SetSRID(ST_MakePoint(s.longitude, s.latitude), 4326)
      ELSE
        NULL
    END
  )
FROM public.schools s
WHERE b.school_id = s.id;
