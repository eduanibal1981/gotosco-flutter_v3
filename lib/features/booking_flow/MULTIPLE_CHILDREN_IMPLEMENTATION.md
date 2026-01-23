# Multiple Children Selection Implementation

## Summary

Successfully implemented support for **multiple children selection** in the booking flow while maintaining backward compatibility with single-child bookings.

## Key Features

### 1. **Multi-Select UI with Checkboxes** ✅
- Replaced single-selection radio buttons with checkboxes
- Users can now select one or multiple children for the same trip
- Visual feedback shows number of children selected
- "Clear" button to deselect all children

### 2. **Smart Location Auto-Population** ✅

The system intelligently handles location auto-population based on children's schools:

#### Scenario A: All Children Attend Same School
```
Parent selects: Child A (School X) + Child B (School X)
Result: ✅ Pickup = Home, Dropoff = School X (auto-filled)
```

#### Scenario B: Children Attend Different Schools
``

`
Parent selects: Child A (School X) + Child B (School Y)
Result: ✅ Pickup = Home, Dropoff = (user must select manually on map)
```

#### Scenario C: No School Linked
```
Parent selects: Child A (no school)
Result: ✅ Pickup = Home, Dropoff = (user must select manually)
```

### 3. **Backward Compatibility** ✅
- Single child selection still works exactly as before
- Existing code using `studentId` continues to function
- New code uses `studentIds` array for multiple selection

## Implementation Details

### Data Model Changes

**`BookingDraftModel`**:
```dart
const factory BookingDraftModel({
  // Backward compatibility
  String? studentId,
  // New: Multiple students support
  @Default([]) List<String> studentIds,
  // ... other fields
}) = _BookingDraftModel;
```

### Controller Methods

**New Methods**:
1. `toggleChildSelection(String studentId)` - Toggle child in/out of selection
2. `clearChildSelections()` - Remove all selected children
3. Enhanced `autoPopulateLocations()` with `requiresManualSelection` parameter

**Updated Validation**:
```dart
case 1:
  // Support both single and multiple child selection
  return (state.studentId != null && state.studentId!.isNotEmpty) ||
         (state.studentIds.isNotEmpty);
```

### UI Components

**Step 1: Enhanced Header**
- Shows "Select Child(ren)" title
- Dynamic subtitle showing selection count
- Clear button when children are selected

**Child Card Updates**
- Added checkbox visual (24x24 rounded square)
- Blue background when selected
- OnTap toggles selection instead of replacing

**Smart Auto-Population Logic**
```dart
Future<void> _autoPopulateLocationsForMultiple(
    WidgetRef ref, List<dynamic> allChildren) async {
  
  // 1. Always get user's home location
  
  // 2. Get selected children
  final selectedChildren = allChildren
      .where((c) => selectedIds.contains(c.id))
      .toList();
  
  // 3. Check unique school IDs
  final schoolIds = selectedChildren
      .map((c) => c.schoolId)
      .toSet();
  
  // 4. Smart decision:
  if (schoolIds.length == 1) {
    // Same school → auto-fill
    fetchSchoolLocation(schoolIds.first);
  } else {
    // Different schools or none → require manual
    requiresManualSelection = true;
  }
}
```

## User Experience Flow

### Example 1: Two Children, Same School

1. **Step 1**: Parent taps Child A ✓, then Child B ✓
   - Header shows "2 children selected"
   - Both checkboxes marked
   - 🎯 Auto-populated: Home → School X

2. **Step 2-3**: School Transport, Go & Return (pre-selected)

3. **Step 4**: Locations
   - Pickup: Parent's home address ✅
   - Dropoff: School X address ✅
   - Can still manually change if needed

4. **Step 5-6**: Continue as normal

### Example 2: Two Children, Different Schools

1. **Step 1**: Parent taps Child A (School X) ✓, then Child C (School Y) ✓
   - Header shows "2 children selected"
   - 🎯 Auto-populated: Home only

2. **Step 4**: Locations
   - Pickup: Parent's home address ✅
   - Dropoff: *Empty* ⚠️ (user must pick manually)
   - System detected different schools, requires map selection

## Database Schema

No database changes required! Uses existing:
- `users` table: `location_text, location_lat, location_lng`
- `students` table: `school_id`
- `schools` table: `name, address, latitude, longitude`

## Benefits

1. **Flexibility**: Parents can book for siblings in one booking
2. **Time Savings**: No need to create separate bookings for each child
3. **Smart Automation**: System detects same vs. different schools
4. **User Control**: Always allows manual override
5. **Clear Feedback**: Visual indicators show what's selected

## Edge Cases Handled

✅ No children selected → validation prevents proceeding  
✅ One child selected → works like before  
✅ Multiple children, same school → auto-fills  
✅ Multiple children, different schools → requires manual  
✅ Children with no school linked → requires manual  
✅ Network error during fetch → graceful degradation  

## Files Modified

1. ✅ `lib/features/booking_flow/data/models/booking_draft_model.dart`
2. ✅ `lib/features/booking_flow/presentation/controllers/booking_flow_controller.dart`
3. ✅ `lib/features/booking_flow/presentation/widgets/step_1_select_child.dart`

## Build Status

✅ **Build Runner Successful** (4 outputs generated)  
✅ **All lint errors resolved**  
✅ **Backward compatibility maintained**

## Next Steps (Optional Enhancements)

1. **Badge on Step Indicator**: Show number of children selected
2. **Bulk Pricing**: Calculate discount for multiple children
3. **Batch Operations**: Allow same schedule for all children
4. **Visual Grouping**: Show which children go to which school in review
5. **Smart Notifications**: Alert if children have conflicting schedules

---

**Implementation Date**: January 23, 2026  
**Status**: ✅ Complete and Tested  
**Compatibility**: ✅ Both single and multiple selection supported
