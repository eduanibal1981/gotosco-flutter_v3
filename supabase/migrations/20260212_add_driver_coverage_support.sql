CREATE TABLE IF NOT EXISTS public.cities (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  state text NULL,
  country text NULL,
  location geography NULL,
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  CONSTRAINT cities_pkey PRIMARY KEY (id)
) TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS public.areas (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  city_id uuid NULL,
  name text NOT NULL,
  boundary geography NULL,
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  CONSTRAINT areas_pkey PRIMARY KEY (id),
  CONSTRAINT areas_city_id_fkey FOREIGN KEY (city_id) REFERENCES cities (id) ON DELETE CASCADE
) TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS public.schools (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  address text NULL,
  location geography NULL,
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  city_id uuid NULL,
  latitude double precision NULL,
  longitude double precision NULL,
  CONSTRAINT schools_pkey PRIMARY KEY (id),
  CONSTRAINT schools_city_id_fkey FOREIGN KEY (city_id) REFERENCES cities (id) ON DELETE CASCADE
) TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS idx_areas_city_id ON public.areas USING btree (city_id) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_schools_city_id ON public.schools USING btree (city_id) TABLESPACE pg_default;

ALTER TABLE public.cities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.areas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.schools ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'cities'
      AND policyname = 'Enable read access for cities'
  ) THEN
    CREATE POLICY "Enable read access for cities"
    ON public.cities
    FOR SELECT
    USING (true);
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'areas'
      AND policyname = 'Enable read access for areas'
  ) THEN
    CREATE POLICY "Enable read access for areas"
    ON public.areas
    FOR SELECT
    USING (true);
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'schools'
      AND policyname = 'Enable read access for schools'
  ) THEN
    CREATE POLICY "Enable read access for schools"
    ON public.schools
    FOR SELECT
    USING (true);
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'schools'
      AND policyname = 'Authenticated users can insert schools'
  ) THEN
    CREATE POLICY "Authenticated users can insert schools"
    ON public.schools
    FOR INSERT
    TO authenticated
    WITH CHECK (true);
  END IF;
END $$;

ALTER TABLE public.driver_service_areas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.driver_covered_schools ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'driver_service_areas'
      AND policyname = 'Drivers manage service areas'
  ) THEN
    CREATE POLICY "Drivers manage service areas"
    ON public.driver_service_areas
    FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = driver_id);
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'driver_service_areas'
      AND policyname = 'Drivers delete service areas'
  ) THEN
    CREATE POLICY "Drivers delete service areas"
    ON public.driver_service_areas
    FOR DELETE
    TO authenticated
    USING (auth.uid() = driver_id);
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'driver_covered_schools'
      AND policyname = 'Drivers manage covered schools'
  ) THEN
    CREATE POLICY "Drivers manage covered schools"
    ON public.driver_covered_schools
    FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = driver_id);
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'driver_covered_schools'
      AND policyname = 'Drivers delete covered schools'
  ) THEN
    CREATE POLICY "Drivers delete covered schools"
    ON public.driver_covered_schools
    FOR DELETE
    TO authenticated
    USING (auth.uid() = driver_id);
  END IF;
END $$;
