-- Migration to add 'cancelled' status to bookings check constraint

-- 1. Drop the old constraint
ALTER TABLE public.bookings
DROP CONSTRAINT IF EXISTS bookings_status_check;

-- 2. Add the new constraint with 'cancelled' included
ALTER TABLE public.bookings
ADD CONSTRAINT bookings_status_check
CHECK (status IN ('pending', 'accepted', 'rejected', 'completed', 'cancelled'));
