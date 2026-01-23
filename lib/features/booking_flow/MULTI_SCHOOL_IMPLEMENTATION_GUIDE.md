# Multi-School Booking Implementation Guide

## Overview

This document provides a comprehensive guide for implementing multi-school support in the booking system, where a parent can book transportation for multiple children attending different schools in a single booking.

## Database Schema Changes

### Recommended Approach: Junction Table

#### 1. Create `booking_schools` Table

```sql
-- Junction table for many-to-many relationship between bookings and schools
CREATE TABLE public.booking_schools (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
  school_id UUID NOT NULL REFERENCES schools(id) ON DELETE RESTRICT,
  
  -- For route optimization and sequencing
  sequence_order INTEGER,
  
  -- Copy of school location for historical accuracy
  -- (in case school moves or is deleted)
  school_name TEXT NOT NULL,
  school_address TEXT,
  school_latitude DOUBLE PRECISION,
  school_longitude DOUBLE PRECISION,
  
  -- Which students from this booking go to this school
  student_ids UUID[] NOT NULL,
  
  -- Metadata
  estimated_arrival_time TIME,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Constraints
  CONSTRAINT unique_booking_school UNIQUE(booking_id, school_id),
  CONSTRAINT at_least_one_student CHECK (array_length(student_ids, 1) > 0)
);

-- Indexes for performance
CREATE INDEX idx_booking_schools_booking_id ON booking_schools(booking_id);
CREATE INDEX idx_booking_schools_school_id ON booking_schools(school_id);
CREATE INDEX idx_booking_schools_student_ids ON booking_schools USING GIN(student_ids);

-- Updated timestamp trigger
CREATE TRIGGER update_booking_schools_updated_at
  BEFORE UPDATE ON booking_schools
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

#### 2. Modify `bookings` Table

```sql
-- Add flag to indicate multi-school booking
ALTER TABLE public.bookings
  ADD COLUMN is_multi_school BOOLEAN DEFAULT FALSE,
  ADD COLUMN school_count INTEGER DEFAULT 1;

-- Add constraint: if multi-school, must have entries in booking_schools
-- We'll enforce this in application logic

-- Update comment for clarity
COMMENT ON COLUMN bookings.dropoff_location_text IS 
  'For is_multi_school=true bookings, this is NULL. Use booking_schools table instead. For single-location bookings, this is the dropoff location.';
  
COMMENT ON COLUMN bookings.is_multi_school IS 
  'TRUE if booking covers multiple schools (School Transport with multiple children at different schools). When TRUE, dropoff locations are in booking_schools table.';
```

#### 3. Row Level Security (RLS) Policies

```sql
-- Enable RLS on booking_schools
ALTER TABLE booking_schools ENABLE ROW LEVEL SECURITY;

-- Parents can view schools for their bookings
CREATE POLICY "Parents can view their booking schools"
  ON booking_schools
  FOR SELECT
  USING (
    booking_id IN (
      SELECT id FROM bookings 
      WHERE parent_id = auth.uid()
    )
  );

-- Parents can insert schools when creating bookings
CREATE POLICY "Parents can insert booking schools"
  ON booking_schools
  FOR INSERT
  WITH CHECK (
    booking_id IN (
      SELECT id FROM bookings 
      WHERE parent_id = auth.uid()
    )
  );

-- Drivers can view schools for their bookings
CREATE POLICY "Drivers can view booking schools"
  ON booking_schools
  FOR SELECT
  USING (
    booking_id IN (
      SELECT id FROM bookings 
      WHERE driver_id = auth.uid()
    )
  );
```

## Data Model Changes

### 1. Update `BookingDraftModel`

```dart
// lib/features/booking_flow/data/models/booking_draft_model.dart

@freezed
abstract class BookingDraftModel with _$BookingDraftModel {
  const factory BookingDraftModel({
    // ... existing fields ...
    
    // NEW: Multi-school support
    @Default(false) bool isMultiSchool,
    @Default([]) List<SchoolLocation> schoolLocations, // List of schools
    
    // Existing single location fields (for non-school trips)
    String? pickupLocationText,
    double? pickupLat,
    double? pickupLng,
    String? dropoffLocationText, // NULL for multi-school
    double? dropoffLat, // NULL for multi-school
    double? dropoffLng, // NULL for multi-school
    
    // ... rest of fields ...
  }) = _BookingDraftModel;
}

// New model for school locations
@freezed
class SchoolLocation with _$SchoolLocation {
  const factory SchoolLocation({
    required String schoolId,
    required String schoolName,
    String? schoolAddress,
    double? latitude,
    double? longitude,
    @Default([]) List<String> studentIds, // Which children go here
    int? sequenceOrder,
  }) = _SchoolLocation;
  
  factory SchoolLocation.fromJson(Map<String, dynamic> json) =>
      _$SchoolLocationFromJson(json);
}
```

### 2. Create School Location Model

```dart
// lib/features/booking_flow/data/models/school_location_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'school_location_model.freezed.dart';
part 'school_location_model.g.dart';

@freezed
class SchoolLocationModel with _$SchoolLocationModel {
  const factory SchoolLocationModel({
    required String schoolId,
    required String schoolName,
    String? schoolAddress,
    double? latitude,
    double? longitude,
    @Default([]) List<String> studentIds,
    int? sequenceOrder,
  }) = _SchoolLocationModel;

  factory SchoolLocationModel.fromJson(Map<String, dynamic> json) =>
      _$SchoolLocationModelFromJson(json);
      
  // Convert from School model
  factory SchoolLocationModel.fromSchool({
    required String schoolId,
    required String schoolName,
    String? address,
    double? lat,
    double? lng,
    List<String> studentIds = const [],
  }) {
    return SchoolLocationModel(
      schoolId: schoolId,
      schoolName: schoolName,
      schoolAddress: address,
      latitude: lat,
      longitude: lng,
      studentIds: studentIds,
    );
  }
}
```

## Implementation Steps

### Step 1: Update Controller Logic

```dart
// lib/features/booking_flow/presentation/controllers/booking_flow_controller.dart

class BookingFlowController extends _$BookingFlowController {
  
  // ... existing methods ...
  
  // NEW: Build school locations from selected children
  void buildSchoolLocationsFromChildren(List<dynamic> allChildren) async {
    final selectedIds = state.studentIds;
    final selectedChildren = allChildren
        .where((c) => selectedIds.contains(c.id))
        .toList();
    
    if (selectedChildren.isEmpty) {
      state = state.copyWith(
        isMultiSchool: false,
        schoolLocations: [],
      );
      return;
    }
    
    // Group children by school
    final Map<String, List<dynamic>> childrenBySchool = {};
    
    for (final child in selectedChildren) {
      final schoolId = child.schoolId;
      if (schoolId != null && schoolId.isNotEmpty) {
        childrenBySchool.putIfAbsent(schoolId, () => []).add(child);
      }
    }
    
    final uniqueSchools = childrenBySchool.keys.toList();
    
    // If School Transport with multiple schools
    if (state.tripCategory == 'school' && uniqueSchools.length > 1) {
      // Fetch school details
      final schoolLocations = await _fetchSchoolDetails(
        uniqueSchools,
        childrenBySchool,
      );
      
      state = state.copyWith(
        isMultiSchool: true,
        schoolLocations: schoolLocations,
        dropoffLocationText: null, // Clear single dropoff
        dropoffLat: null,
        dropoffLng: null,
      );
    } else if (state.tripCategory == 'school' && uniqueSchools.length == 1) {
      // Single school - use existing single-location logic
      final schoolId = uniqueSchools.first;
      final schoolData = await _fetchSingleSchoolDetails(schoolId);
      
      state = state.copyWith(
        isMultiSchool: false,
        schoolLocations: [],
        dropoffLocationText: schoolData['address'],
        dropoffLat: schoolData['latitude'],
        dropoffLng: schoolData['longitude'],
      );
    }
  }
  
  Future<List<SchoolLocationModel>> _fetchSchoolDetails(
    List<String> schoolIds,
    Map<String, List<dynamic>> childrenBySchool,
  ) async {
    final supabase = Supabase.instance.client;
    
    final response = await supabase
        .from('schools')
        .select('id, name, address, latitude, longitude')
        .in_('id', schoolIds);
    
    return (response as List).map((schoolData) {
      final schoolId = schoolData['id'] as String;
      final studentsForSchool = childrenBySchool[schoolId] ?? [];
      final studentIds = studentsForSchool.map((c) => c.id as String).toList();
      
      return SchoolLocationModel(
        schoolId: schoolId,
        schoolName: schoolData['name'],
        schoolAddress: schoolData['address'],
        latitude: schoolData['latitude'],
        longitude: schoolData['longitude'],
        studentIds: studentIds,
      );
    }).toList();
  }
}
```

### Step 2: Update Step 4 UI (Locations)

```dart
// lib/features/booking_flow/presentation/widgets/step_4_locations.dart

Widget _buildLocationFields(BuildContext context, BookingDraftModel draft) {
  if (draft.isMultiSchool && draft.tripCategory == 'school') {
    // Show multi-school selector
    return _buildMultiSchoolSelector(draft);
  } else {
    // Show traditional single pickup/dropoff
    return _buildSingleLocationSelector(draft);
  }
}

Widget _buildMultiSchoolSelector(BookingDraftModel draft) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Pickup Location (Home)
      const Text('Pickup Location', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      _buildLocationCard(
        icon: Icons.home,
        title: 'Home',
        subtitle: draft.pickupLocationText ?? 'Set your home location',
        onTap: () => _pickLocationOnMap(isPickup: true),
      ),
      
      const SizedBox(height: 24),
      
      // Schools (Dropoff Locations)
      const Text('Dropoff Locations (Schools)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      const Text('Multiple schools detected', style: TextStyle(fontSize: 13, color: Colors.grey)),
      const SizedBox(height: 12),
      
      ...draft.schoolLocations.asMap().entries.map((entry) {
        final index = entry.key;
        final school = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildSchoolCard(school, index + 1),
        );
      }).toList(),
    ],
  );
}

Widget _buildSchoolCard(SchoolLocationModel school, int number) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.indigo.shade200),
      borderRadius: BorderRadius.circular(12),
      color: Colors.indigo.shade50,
    ),
    child: Row(
      children: [
        // Number badge
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.indigo.shade600,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        
        // School info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                school.schoolName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (school.schoolAddress != null) ...[
                const SizedBox(height: 4),
                Text(
                  school.schoolAddress!,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                '${school.studentIds.length} student(s)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.indigo.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        
        // Verified checkmark
        Icon(
          Icons.check_circle,
          color: Colors.green.shade600,
          size: 24,
        ),
      ],
    ),
  );
}
```

### Step 3: Update Booking Submission

```dart
// When submitting the booking

Future<void> submitBooking() async {
  final draft = ref.read(bookingFlowControllerProvider);
  final supabase = Supabase.instance.client;
  
  // 1. Create the booking record
  final bookingData = {
    'parent_id': supabase.auth.currentUser!.id,
    'driver_id': draft.driverId,
    'trip_category': draft.tripCategory,
    'booking_type': draft.bookingType,
    'is_multi_school': draft.isMultiSchool,
    'school_count': draft.isMultiSchool ? draft.schoolLocations.length : 1,
    
    // Pickup (always home for school transport)
    'pickup_location_text': draft.pickupLocationText,
    'pickup_lat': draft.pickupLat,
    'pickup_lng': draft.pickupLng,
    
    // Single dropoff (only if NOT multi-school)
    'dropoff_location_text': draft.isMultiSchool ? null : draft.dropoffLocationText,
    'dropoff_lat': draft.isMultiSchool ? null : draft.dropoffLat,
    'dropoff_lng': draft.isMultiSchool ? null : draft.dropoffLng,
    
    // ... other fields ...
  };
  
  final bookingResponse = await supabase
      .from('bookings')
      .insert(bookingData)
      .select()
      .single();
  
  final bookingId = bookingResponse['id'];
  
  // 2. If multi-school, insert into booking_schools
  if (draft.isMultiSchool) {
    final schoolInserts = draft.schoolLocations.asMap().entries.map((entry) {
      final index = entry.key;
      final school = entry.value;
      
      return {
        'booking_id': bookingId,
        'school_id': school.schoolId,
        'school_name': school.schoolName,
        'school_address': school.schoolAddress,
        'school_latitude': school.latitude,
        'school_longitude': school.longitude,
        'student_ids': school.studentIds,
        'sequence_order': index + 1,
      };
    }).toList();
    
    await supabase.from('booking_schools').insert(schoolInserts);
  }
  
  // 3. Create student-booking associations
  final studentBookings = draft.studentIds.map((studentId) => {
    'booking_id': bookingId,
    'student_id': studentId,
  }).toList();
  
  await supabase.from('booking_students').insert(studentBookings);
}
```

## Migration Strategy

### Phase 1: Database Changes (Non-Breaking)
```sql
-- Run these migrations first
-- They don't break existing functionality

-- 1. Create booking_schools table
-- (see SQL above)

-- 2. Add new columns to bookings
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS is_multi_school BOOLEAN DEFAULT FALSE;
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS school_count INTEGER DEFAULT 1;
```

### Phase 2: Application Updates
1. Deploy new models with backward compatibility
2. Update booking flow to detect multi-school scenarios
3. Update UI to show multiple schools when applicable

### Phase 3: Data Migration (if needed)
```sql
-- If you have existing bookings to migrate
-- This is optional and depends on your needs
```

## Benefits of This Approach

1. ✅ **Scalable**: Handles any number of schools
2. ✅ **Performant**: Proper indexing for fast queries
3. ✅ **Flexible**: Each school can have metadata
4. ✅ **Backward Compatible**: Existing single-location bookings work as-is
5. ✅ **Route Optimizable**: Sequence order enables smart routing
6. ✅ **Accurate**: Historical snapshot of school locations

## Testing Checklist

- [ ] Single child, single school (existing behavior)
- [ ] Multiple children, same school (existing behavior)
- [ ] Multiple children, different schools (NEW multi-school flow)
- [ ] Mix of children with/without schools assigned
- [ ] School deletion doesn't break bookings (historical data preserved)
- [ ] RLS policies prevent unauthorized access
- [ ] Performance with 10+ schools in one booking

---

**Status**: Design Complete - Ready for Implementation  
**Date**: January 23, 2026
