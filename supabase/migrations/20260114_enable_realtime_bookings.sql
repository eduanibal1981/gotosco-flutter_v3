-- Enable Realtime for bookings table
-- This allows the app to instantly receive updates when a booking status changes (e.g. to 'cancelled')

-- Add bookings table to the supabase_realtime publication
ALTER PUBLICATION supabase_realtime ADD TABLE public.bookings;
