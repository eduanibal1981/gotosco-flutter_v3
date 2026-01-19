ALTER TABLE public.bookings
ADD COLUMN IF NOT EXISTS cancellation_type text,
ADD COLUMN IF NOT EXISTS cancellation_fee numeric,
ADD COLUMN IF NOT EXISTS cancel_requested_at timestamptz,
ADD COLUMN IF NOT EXISTS pause_start_date date,
ADD COLUMN IF NOT EXISTS pause_end_date date;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'bookings_cancellation_type_check'
  ) THEN
    ALTER TABLE public.bookings
    ADD CONSTRAINT bookings_cancellation_type_check
    CHECK (
      cancellation_type IS NULL OR
      cancellation_type = ANY (
        ARRAY[
          'parent_cancel_grace',
          'scheduled_stop',
          'immediate_stop_fee',
          'pause',
          'safety_stop'
        ]
      )
    );
  END IF;
END $$;
