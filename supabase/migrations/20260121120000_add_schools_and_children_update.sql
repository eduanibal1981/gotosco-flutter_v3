-- Create cities table if not exists (likely exists)
CREATE TABLE IF NOT EXISTS public.cities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    state TEXT,
    country TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create schools table with enhanced fields
CREATE TABLE IF NOT EXISTS public.schools (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    address TEXT,
    city_id UUID REFERENCES public.cities(id),
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    createdby UUID REFERENCES auth.users(id),
    start_time TIME, -- From Constitution
    end_time TIME,   -- From Constitution
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add school_id to children table (referencing schools)
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'children' AND column_name = 'school_id') THEN
        ALTER TABLE public.children ADD COLUMN school_id UUID REFERENCES public.schools(id);
    END IF;
END $$;
