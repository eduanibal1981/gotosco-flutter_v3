-- Add missing actual_start_time and actual_end_time columns to trips table
ALTER TABLE public.trips 
ADD COLUMN IF NOT EXISTS actual_start_time timestamp with time zone,
ADD COLUMN IF NOT EXISTS actual_end_time timestamp with time zone;
