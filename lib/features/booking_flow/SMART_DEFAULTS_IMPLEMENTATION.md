# Booking Flow Smart Defaults Implementation

## Summary of Changes

This document outlines the implementation of smart defaults for the **School Transport with Monthly Subscription** scenario in the booking flow.

## Changes Made

### 1. **BookingDraftModel** (`lib/features/booking_flow/data/models/booking_draft_model.dart`)
- **Default Values**: Set `tripCategory` to `'school'` and `bookingType` to `'Two Way'` as defaults
- **Pre-selected Options**: Users will automatically have "School Transport" and "Go & Return" selected when they start the booking flow

### 2. **BookingFlowController** (`lib/features/booking_flow/presentation/controllers/booking_flow_controller.dart`)
- **Initialization**: Updated `build()` method to initialize with smart defaults
  ```dart
  return const BookingDraftModel(
    tripCategory: 'school',
    bookingType: 'Two Way',
  );
  ```
- **New Methods Added**:
  - `autoPopulateLocations()`: Automatically fills pickup/dropoff locations from user's home and child's school
  - `setDefaultContractDates()`: Sets contract period from August of current year to May of next year

### 3. **Step 1: Child Selection** (`lib/features/booking_flow/presentation/widgets/step_1_select_child.dart`)
- **Auto-population**: When a child is selected, the system automatically:
  1. Fetches the parent's home location from the `users` table
  2. Fetches the child's school location from the `schools` table
  3. Pre-fills the pickup location with home address
  4. Pre-fills the dropoff location with school address
- **Database Queries**: Added queries to fetch `location_text`, `location_lat`, `location_lng` from users and school address/coordinates from schools
- **User Override**: Users can still manually change locations using the map picker in Step 4

### 4. **Step 5: Schedule Selection** (`lib/features/booking_flow/presentation/widgets/step_5_schedule.dart`)
- **Default Contract Dates**: Added `initState()` to automatically set contract dates to August-May academic year
- **Updated UI Labels**:
  - Header changed to: "Monthly subscription from August to May"
  - Contract section labeled: "Contract Period (August - May)"
- **Separate Pickup Times**: Added two distinct time pickers for monthly subscription:
  - **Go Pickup Time (Morning)**: For picking up child from home to school (uses `homePickupTime`)
  - **Return Pickup Time (Afternoon)**: For picking up child from school to home (uses `schoolPickupTime`)
- **Visual Indicators**: Different icons for morning (sun) and afternoon (moon) pickups
- **Updated `_pickTime()` method**: Now handles both morning and afternoon times based on the `isPickup` parameter

## User Experience Flow

### Typical School Transport Booking Flow:

1. **Step 1**: Parent selects their child
   - ✅ System auto-populates home and school locations in background

2. **Step 2**: Trip category selection
   - ✅ "School Transport" is pre-selected

3. **Step 3**: Direction selection
   - ✅ "Go & Return" is pre-selected

4. **Step 4**: Locations
   - ✅ Pickup location shows parent's home address
   - ✅ Dropoff location shows child's school address
   - ✨ Parent can still change these using the map picker

5. **Step 5**: Schedule
   - ✅ "Monthly Subscription" is pre-selected
   - ✅ Contract dates default to August → May
   - ✨ Parent sets morning pickup time (e.g., 6:30 AM)
   - ✨ Parent sets afternoon pickup time (e.g., 2:00 PM)

6. **Step 6**: Review and submit
   - All details are displayed for final confirmation

## Technical Implementation Details

### Database Schema Dependencies

The auto-population feature relies on the following database structure:

**Users Table:**
```sql
users (
  id UUID,
  location_text TEXT,
  location_lat DOUBLE PRECISION,
  location_lng DOUBLE PRECISION
)
```

**Students/Children Table:**
```sql
students (
  id UUID,
  school_id UUID
)
```

**Schools Table:**
```sql
schools (
  id UUID,
  name TEXT,
  address TEXT,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION
)
```

### Error Handling

- If user's home location is not set, location fields remain empty
- If child's school is not linked or school location is missing, only school name is shown
- All database errors are caught gracefully with `try-catch` blocks
- Auto-population failures don't prevent the user from continuing the flow

## Benefits

1. **Reduced User Effort**: Most common scenario requires minimal input
2. **Data Accuracy**: Leverages existing user profile and school data
3. **Flexibility**: Users can still override any defaults
4. **Better UX**: Clear visual indicators and intuitive time selection
5. **Time Savings**: Pre-filled data saves parents significant time

## Next Steps

To complete the booking flow implementation, consider:

1. **Integrate Location Picker**: Replace placeholder in Step 4 with actual map picker widget
2. **Price Calculation**: Implement dynamic pricing based on distance and subscription type
3. **Submit Logic**: Complete the `_handleSubmit()` method to save booking to database
4. **Validation**: Add validation for required fields before allowing submission
5. **Testing**: Add unit and widget tests for the new functionality

## Files Modified

✅ `lib/features/booking_flow/data/models/booking_draft_model.dart`
✅ `lib/features/booking_flow/presentation/controllers/booking_flow_controller.dart`
✅ `lib/features/booking_flow/presentation/widgets/step_1_select_child.dart`
✅ `lib/features/booking_flow/presentation/widgets/step_5_schedule.dart`

---

**Implementation Date**: January 23, 2026  
**Status**: ✅ Complete  
**Build Runner**: ✅ Successfully generated all code
