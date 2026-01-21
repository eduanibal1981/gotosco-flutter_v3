-- Add school_id to children table
ALTER TABLE public.children 
ADD COLUMN IF NOT EXISTS school_id UUID REFERENCES public.schools(id);

-- Create index for performance
CREATE INDEX IF NOT EXISTS idx_children_school_id ON public.children(school_id);

-- Optional: If you have existing data and want to try linking by name (fuzzy match)
-- UNCOMMENT TO RUN:
-- UPDATE public.children c
-- SET school_id = s.id
-- FROM public.schools s
-- WHERE c.school_name IS NOT NULL 
--   AND s.name ILIKE c.school_name
--   AND c.school_id IS NULL;
