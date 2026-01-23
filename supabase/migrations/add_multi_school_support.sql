-- Migration: Add Multi-School Support to Bookings
-- Date: 2026-01-23
-- Description: Enables booking system to support multiple schools per booking (for School Transport with multiple children)

-- ============================================
-- 1. CREATE booking_schools TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS public.booking_schools (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
  school_id UUID NOT NULL REFERENCES schools(id) ON DELETE RESTRICT,
  
  -- For route optimization
  sequence_order INTEGER,
  
  -- Historical snapshot of school data
  -- (preserved even if school is modified/deleted)
  school_name TEXT NOT NULL,
  school_address TEXT,
  school_latitude DOUBLE PRECISION,
  school_longitude DOUBLE PRECISION,
  
  -- Which students from this booking attend this school
  student_ids UUID[] NOT NULL,
  
  -- Metadata
  estimated_arrival_time TIME,
  notes TEXT,
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Constraints
  CONSTRAINT unique_booking_school UNIQUE(booking_id, school_id),
  CONSTRAINT at_least_one_student CHECK (array_length(student_ids, 1) > 0)
);

-- ============================================
-- 2. CREATE INDEXES
-- ============================================

CREATE INDEX IF NOT EXISTS idx_booking_schools_booking_id 
  ON booking_schools(booking_id);

CREATE INDEX IF NOT EXISTS idx_booking_schools_school_id 
  ON booking_schools(school_id);

CREATE INDEX IF NOT EXISTS idx_booking_schools_student_ids 
  ON booking_schools USING GIN(student_ids);

-- ============================================
-- 3. UPDATE bookings TABLE
-- ============================================

-- Add multi-school tracking columns
ALTER TABLE public.bookings
  ADD COLUMN IF NOT EXISTS is_multi_school BOOLEAN DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS school_count INTEGER DEFAULT 1;

-- Add helpful comments
COMMENT ON TABLE booking_schools IS 
  'Stores multiple school locations for School Transport bookings with children at different schools';

COMMENT ON COLUMN bookings.is_multi_school IS 
  'TRUE when booking covers multiple schools. Dropoff locations stored in booking_schools table instead of single dropoff fields.';

COMMENT ON COLUMN bookings.dropoff_location_text IS 
  'For multi-school bookings (is_multi_school=true), this is NULL. Use booking_schools table. For single-location bookings, this is the dropoff.';

-- ============================================
-- 4. ENABLE RLS ON booking_schools
-- ============================================

ALTER TABLE booking_schools ENABLE ROW LEVEL SECURITY;

-- ============================================
-- 5. RLS POLICIES FOR booking_schools
-- ============================================

-- Parents can view schools for their bookings
CREATE POLICY "parents_view_booking_schools"
  ON booking_schools
  FOR SELECT
  TO authenticated
  USING (
    booking_id IN (
      SELECT id FROM bookings 
      WHERE parent_id = auth.uid()
    )
  );

-- Parents can insert schools when creating bookings
CREATE POLICY "parents_insert_booking_schools"
  ON booking_schools
  FOR INSERT
  TO authenticated
  WITH CHECK (
    booking_id IN (
      SELECT id FROM bookings 
      WHERE parent_id = auth.uid()
    )
  );

-- Parents can update their booking schools
CREATE POLICY "parents_update_booking_schools"
  ON booking_schools
  FOR UPDATE
  TO authenticated
  USING (
    booking_id IN (
      SELECT id FROM bookings 
      WHERE parent_id = auth.uid()
    )
  );

-- Parents can delete their booking schools
CREATE POLICY "parents_delete_booking_schools"
  ON booking_schools
  FOR DELETE
  TO authenticated
  USING (
    booking_id IN (
      SELECT id FROM bookings 
      WHERE parent_id = auth.uid()
    )
  );

-- Drivers can view schools for their accepted bookings
CREATE POLICY "drivers_view_booking_schools"
  ON booking_schools
  FOR SELECT
  TO authenticated
  USING (
    booking_id IN (
      SELECT id FROM bookings 
      WHERE driver_id = auth.uid()
    )
  );

-- ============================================
-- 6. HELPER FUNCTIONS (Optional but useful)
-- ============================================

-- Function to get all schools for a booking
CREATE OR REPLACE FUNCTION get_booking_schools(booking_uuid UUID)
RETURNS TABLE (
  id UUID,
  school_id UUID,
  school_name TEXT,
  school_address TEXT,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  student_count INTEGER,
  sequence_order INTEGER
) 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    bs.id,
    bs.school_id,
    bs.school_name,
    bs.school_address,
    bs.school_latitude,
    bs.school_longitude,
    array_length(bs.student_ids, 1) as student_count,
    bs.sequence_order
  FROM booking_schools bs
  WHERE bs.booking_id = booking_uuid
  ORDER BY bs.sequence_order NULLS LAST;
END;
$$;

-- Function to automatically set school_count on bookings
CREATE OR REPLACE FUNCTION update_booking_school_count()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  -- Update school_count in bookings table
  UPDATE bookings
  SET school_count = (
    SELECT COUNT(*)
    FROM booking_schools
    WHERE booking_id = NEW.booking_id
  ),
  is_multi_school = (
    SELECT COUNT(*) > 1
    FROM booking_schools
    WHERE booking_id = NEW.booking_id
  )
  WHERE id = NEW.booking_id;
  
  RETURN NEW;
END;
$$;

-- Trigger to auto-update school_count
DROP TRIGGER IF EXISTS trigger_update_school_count ON booking_schools;
CREATE TRIGGER trigger_update_school_count
  AFTER INSERT OR DELETE ON booking_schools
  FOR EACH ROW
  EXECUTE FUNCTION update_booking_school_count();

-- ============================================
-- 7. VALIDATION
-- ============================================

-- Verify tables exist
DO $$
BEGIN
    IF EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'booking_schools'
    ) THEN
        RAISE NOTICE 'SUCCESS: booking_schools table created';
    ELSE
        RAISE EXCEPTION 'FAILED: booking_schools table not found';
    END IF;
    
    IF EXISTS (
        SELECT FROM information_schema.columns
        WHERE table_name = 'bookings'
        AND column_name = 'is_multi_school'
    ) THEN
        RAISE NOTICE 'SUCCESS: is_multi_school column added to bookings';
    ELSE
        RAISE EXCEPTION 'FAILED: is_multi_school column not found in bookings';
    END IF;
END $$;

-- ============================================
-- ROLLBACK (if needed)
-- ============================================

-- To rollback this migration, run:
/*
DROP TRIGGER IF EXISTS trigger_update_school_count ON booking_schools;
DROP FUNCTION IF EXISTS update_booking_school_count();
DROP FUNCTION IF EXISTS get_booking_schools(UUID);
DROP TABLE IF EXISTS public.booking_schools CASCADE;
ALTER TABLE public.bookings DROP COLUMN IF EXISTS is_multi_school;
ALTER TABLE public.bookings DROP COLUMN IF EXISTS school_count;
*/
