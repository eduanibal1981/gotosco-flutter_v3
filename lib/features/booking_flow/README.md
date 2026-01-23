# Booking Flow Feature

## Overview
The booking flow feature provides a step-by-step wizard interface for parents to create booking requests for their children's transportation needs.

## Architecture
This feature follows the project's constitutional guidelines with a 3-layer architecture:

```
lib/features/booking_flow/
├── data/                          # Data Layer
│   └── models/
│       ├── booking_draft_model.dart       # Temporary booking state model
│       ├── trip_category_model.dart       # Trip category options
│       └── *.freezed.dart                 # Generated files
│       └── *.g.dart                       # Generated files
├── domain/                        # Domain Layer (planned)
│   └── repositories/              # Repository interfaces
└── presentation/                  # Presentation Layer
    ├── controllers/
    │   └── booking_flow_controller.dart   # Flow state management
    ├── screens/
    │   └── booking_flow_screen.dart       # Main wizard screen
    └── widgets/
        ├── progress_indicator_widget.dart  # Progress bar
        ├── step_1_select_child.dart       # Step 1: Child selection
        ├── step_2_trip_category.dart      # Step 2: Trip type
        ├── step_3_direction.dart          # Step 3: Direction
        ├── step_4_locations.dart          # Step 4: Locations
        ├── step_5_schedule.dart           # Step 5: Schedule
        └── step_6_review.dart             # Step 6: Review
```

## Features

### 6-Step Booking Wizard

#### Step 1: Select Child
- Displays all children associated with the parent
- Shows child details (name, age, grade, school)
- Visual selection indicator

#### Step 2: Trip Category
- School Transport (🏫)
- Journey Trip (🚗)
- Other (📍)
- Grid layout with visual feedback

#### Step 3: Direction
- Two Way (Go & Return) 🔄
- One Way to School ➡️
- One Way Back Home ⬅️
- Affects what locations are required in Step 4

#### Step 4: Locations
- Dynamic location fields based on selected direction
- Integration point for location picker (TODO)
- Default suggestions for school trips
- Custom locations for other trip types

#### Step 5: Schedule
Three schedule types:
1. **One-Time Trip** 📅
   - Single date and time picker
   - For one-off journeys

2. **Recurring Trip** 🔄
   - Day-of-week selector (Mon-Sun)
   - Fixed pickup time
   - For regular weekly patterns

3. **Monthly Subscription** 📆
   - Contract start and end dates
   - Daily pickup time
   - Long-term commitment with driver

#### Step 6: Review
- Summary of all selections
- Notes field for special instructions
- Estimated price display
- Submit button

## State Management

The booking flow uses Riverpod with code generation:

```dart
// Access the current booking draft
final bookingDraft = ref.watch(bookingFlowControllerProvider);

// Update the draft
ref.read(bookingFlowControllerProvider.notifier).selectChild('child-id');
ref.read(bookingFlowControllerProvider.notifier).nextStep();
```

### Key Controller Methods

```dart
// Navigation
controller.nextStep();
controller.previousStep();
controller.goToStep(3);

// Step 1
controller.selectChild(String studentId);

// Step 2
controller.selectTripCategory(String category);

// Step 3
controller.selectDirection(String bookingType);

// Step 4
controller.setPickupLocation(locationText: '...', lat: 0.0, lng: 0.0);
controller.setDropoffLocation(locationText: '...', lat: 0.0, lng: 0.0);

// Step 5
controller.selectScheduleType(isOneTime: true, isRecurring: false, isMonthlySubscription: false);
controller.setOneTimeSchedule(pickupDatetime: DateTime.now());
controller.setRecurringSchedule(recurringDays: ['monday', 'wednesday'], pickupTime: '07:00 AM');
controller.setMonthlySubscription(contractStartDate: ..., contractEndDate: ..., pickupTime: '07:00 AM');

// Step 6
controller.setDriverAndPrice(driverId: '...', estimatedPrice: 25.0);
controller.setNotes('Special instructions');
controller.reset(); // Reset the entire flow
```

## Validation

Each step has validation logic in `canProceedFromStep(int step)`:
- Step 1: Child must be selected
- Step 2: Trip category must be selected
- Step 3: Direction must be selected
- Step 4: Required locations based on direction must have valid coordinates
- Step 5: Schedule type and required fields must be filled
- Step 6: Always valid (review screen)

The "Continue" button is disabled if validation fails.

## Database Integration

The booking draft model maps to your updated `bookings` table schema:

| Model Field | Database Column |
|------------|----------------|
| `studentId` | `student_id` |
| `tripCategory` | `trip_category` |
| `bookingType` | `booking_type` |
| `pickupLocationText` / `pickupLat` / `pickupLng` | `custom_pickup_location_text` / `custom_pickup_geo` |
| `dropoffLocationText` / `dropoffLat` / `dropoffLng` | `custom_dropoff_location_text` / `custom_dropoff_geo` |
| `isOneTime` | `is_one_time` |
| `scheduledPickupDatetime` | `scheduled_pickup_datetime` |
| `isRecurring` | `is_recurring` |
| `recurringDays` | `recurring_days` |
| `isMonthlySubscription` | `is_monthly_subscription` |
| `contractStartDate` / `contractEndDate` | `contract_start_date` / `contract_end_date` |
| `homePickupTime` | `home_pickup_time` |
| `flowStep` | `booking_flow_step` |

## Usage

### Opening the Booking Flow

```dart
// Navigate to booking flow screen
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => const BookingFlowScreen(),
  ),
);

// Or with GoRouter
context.push('/booking-flow');
```

### Integration Points

#### 1. Location Picker (Step 4)
Currently shows a placeholder. You need to integrate with your existing location picker:

```dart
// In step_4_locations.dart, replace _pickLocation method
Future<void> _pickLocation(BuildContext context, WidgetRef ref, {required bool isPickup}) async {
  // Use your existing location picker
  final result = await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => YourLocationPickerScreen()),
  );
  
  if (result != null) {
    final controller = ref.read(bookingFlowControllerProvider.notifier);
    if (isPickup) {
      controller.setPickupLocation(
        locationText: result.address,
        lat: result.latitude,
        lng: result.longitude,
      );
    } else {
      controller.setDropoffLocation(
        locationText: result.address,
        lat: result.latitude,
        lng: result.longitude,
      );
    }
  }
}
```

#### 2. Submit Booking (Step 6)
Currently shows a success message. You need to implement actual booking creation:

```dart
// In booking_flow_screen.dart, replace _handleSubmit method
Future<void> _handleSubmit(BuildContext context, WidgetRef ref) async {
  final bookingDraft = ref.read(bookingFlowControllerProvider);
  final bookingsRepository = ref.read(bookingsRepositoryProvider);
  
  try {
    // Convert draft to booking model and submit
    await bookingsRepository.createBooking(
      studentId: bookingDraft.studentId!,
      driverId: bookingDraft.driverId!,
      tripCategory: bookingDraft.tripCategory,
      bookingType: bookingDraft.bookingType!,
      // ... map all other fields
    );
    
    // Show success and navigate back
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking submitted successfully!')),
      );
      Navigator.of(context).pop();
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
```

#### 3. Driver Selection
You may want to add driver selection before the review step:

```dart
// Create a new step or add to existing step
void selectDriver(String driverId, double price) {
  ref.read(bookingFlowControllerProvider.notifier).setDriverAndPrice(
    driverId: driverId,
    estimatedPrice: price,
  );
}
```

#### 4. Price Calculation
Implement your pricing logic based on:
- Trip category
- Direction (one-way vs two-way)
- Schedule type (one-time, recurring, monthly)
- Distance between locations

## UI/UX Features

✅ **Modern Design**
- Gradient backgrounds
- Smooth transitions
- Card-based layouts
- Visual feedback on selection

✅ **Responsive**
- Works on different screen sizes
- Scrollable content areas

✅ **Accessible**
- Clear labels and icons
- Visual indicators for selection
- Helpful hints and descriptions

✅ **Validation**
- Step-by-step validation
- Disabled buttons when invalid
- Clear error states

## Next Steps

1. **Integrate Location Picker** (Step 4)
   - Replace placeholder with your existing location picker
   - Handle location selection results

2. **Implement Booking Submission** (Step 6)
   - Create repository method to submit booking
   - Handle success/error states
   - Navigate back to bookings list

3. **Add Driver Selection**
   - Option 1: Auto-assign driver based on location
   - Option 2: Let parent choose from available drivers
   - Option 3: Add as a new step between 5 and 6

4. **Implement Price Calculation**
   - Create pricing service
   - Calculate based on distance, schedule type
   - Update in real-time as user makes selections

5. **Add Router Integration**
   - Add route to GoRouter configuration
   - Handle deep linking if needed

6. **Testing**
   - Unit tests for BookingFlowController
   - Widget tests for each step
   - Integration test for complete flow

## Testing

```dart
// Example unit test for controller
void main() {
  test('BookingFlowController - select child updates state', () {
    final container = ProviderContainer();
    final controller = container.read(bookingFlowControllerProvider.notifier);
    
    controller.selectChild('child-123');
    
    final state = container.read(bookingFlowControllerProvider);
    expect(state.studentId, 'child-123');
  });
}
```

## Troubleshooting

### Build Runner Issues
If you see errors about missing generated files:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Import Errors
Ensure all imports use correct paths:
- Use relative imports within the same feature
- Use absolute imports for core/shared modules

### State Not Updating
Make sure you're using `ref.read(...).notifier` when calling controller methods:
```dart
// ✅ Correct
ref.read(bookingFlowControllerProvider.notifier).nextStep();

// ❌ Wrong
ref.watch(bookingFlowControllerProvider).nextStep(); // Error!
```

## License
Part of Gotosco v3 project
