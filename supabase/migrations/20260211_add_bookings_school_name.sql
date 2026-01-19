ALTER TABLE public.bookings
ADD COLUMN IF NOT EXISTS school_name text;

UPDATE public.bookings b
SET school_name = s.name
FROM public.schools s
WHERE b.school_id = s.id
  AND b.school_name IS NULL;
