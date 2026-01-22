-- Fix RLS policies for driver coverage tables
-- These tables were missing INSERT and DELETE policies, preventing drivers from saving their coverage

-- driver_service_areas policies
CREATE POLICY "Drivers can insert own service areas"
ON "public"."driver_service_areas"
FOR INSERT
TO "authenticated"
WITH CHECK ("driver_id" = auth.uid());

CREATE POLICY "Drivers can delete own service areas"
ON "public"."driver_service_areas"
FOR DELETE
TO "authenticated"
USING ("driver_id" = auth.uid());

-- driver_covered_schools policies
CREATE POLICY "Drivers can insert own covered schools"
ON "public"."driver_covered_schools"
FOR INSERT
TO "authenticated"
WITH CHECK ("driver_id" = auth.uid());

CREATE POLICY "Drivers can delete own covered schools"
ON "public"."driver_covered_schools"
FOR DELETE
TO "authenticated"
USING ("driver_id" = auth.uid());
