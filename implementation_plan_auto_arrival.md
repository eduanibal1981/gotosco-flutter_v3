# Implementation Plan: Automatic School Arrival & Driver Logic Refinement

## 1. Problem Analysis: "Ready for pickup" Message Bug
**Issue:** The user observed that when the driver reached the school (Drop-off point), the parent app displayed "Ready for pickup at home".
**Root Cause:** The `DriverStatusMonitor` relies on `ParentNextStopInfo` to determine the context of the message. The logic checks `info.stopType`.
```dart
if (info.stopType == 'pickup') {
  return 'Ready for pickup at home';
} else {
  return 'Arrived at school';
}
```
For the message to be "Ready for pickup at home", the database must still consider the **current active stop** (`pending` or `arrived`) to be a `pickup` stop.
**Scenario:** This happens if the driver physically drives to the school but **has not marked the previous "Pickup" stops as Completed/Picked-up**. The system correctly thinks the driver is still on the "Pickup" phase of the trip.

## 2. Proposed Solution: Automatic School Arrival (Geofencing)

To streamline the driver's workflow and ensure the "Arrived at School" status is triggered reliably, we will implement client-side geofencing in the Driver App.

### A. Logic Flow
1.  **Driver App Location Listener:**
    - While a trip is active (`status = in_progress`), listen to location updates.
    - Identify the **Next Stop** from the route.
2.  **Geofence Check:**
    - Monitor the distance between `Driver Location` and `Next Stop Location`.
    - **Threshold:** e.g., **200 meters**.
3.  **Trigger Conditions:**
    - Distance < 200m.
    - Stop Type == `dropoff` (School Drop-off) OR `pickup` (Home Pickup).
    - Stop Status == `pending`.
    - **Debounce:** Ensure we don't spam the API.
4.  **Action:**
    - Automatically call `process_stop` with action `arrived`.
    - Show a toast/sound in the Driver App: "Arrived at School Area".
    - Parent App receives `arrived` event -> Shows "Driver Arrived at School" (if stop is School).

### B. Handling "Skipped" Pickups
To fix the "Ready for pickup" bug when at school:
- If the driver arrives at the **School Drop-off** location, the system should check if there are any pending **Pickups** for this trip.
- **Smart Logic:** If we detect arrival at the *Final Destination* (School) and some pickups are still `pending`, we should prompt the driver:
    - *"You have arrived at school, but some students are not marked as Picked Up. Mark them as Skipped?"*
    - Alternatively, auto-skip them (risky), or just switch the view to the Drop-off stop (requires backend support to process out-of-order).
- **Recommendation:** Enforce usage regarding Pickups. The driver *must* mark pickups (or skips) before the Drop-off stop becomes active.

## 3. Detailed Implementation Steps

### Step 1: Driver App - Geofencing Service
**File:** `lib/features/driver/trip/presentation/controllers/trip_tracking_controller.dart` (or similar)
- Add a `LocationListener` to the active trip screen.
- Use `Geolocator.distanceBetween` to calculate distance to target.
- Triggers `repository.markStopArrived(stopId)` automatically.

### Step 2: Driver App - Auto-Arrival UI Feedback
**File:** `lib/features/driver/trip/presentation/screens/active_trip_screen.dart`
- Remove/Disable the manual "I Have Arrived" button **IF** we want to rely solely on Geofencing (Not recommended to remove entirely, better to keep as fallback).
- Add visual indicator: "Auto-detecting arrival..."
- When triggered, change UI state to "Arrived - Waiting for Child Drop-off".

### Step 3: Parent App - Message Refinement
**File:** `lib/features/parent/dashboard/presentation/widgets/driver_status_monitor.dart`
- Validate `stopType` logic.
- Ensure "Arrived at school" is strictly tied to `stopType == 'dropoff'` AND `rideEvent == 'arrived'`.

### Step 4: Testing Strategy (Without driving)
1.  **Mock Location Provider:**
    - Add a "Developer Mode" in the app (hidden setting).
    - "Simulate Arrival": Button to inject a location coordinate matching the destination.
2.  **Emulator:**
    - Use Android Emulator / iOS Simulator GPS tools to set location to the School's coordinates.

## 4. UI/UX Sequence for Parent
1.  **Driver En Route:** Status: "Heading to School".
2.  **Driver Hits 200m Geofence:**
    - System Auto-triggers `Arrived`.
    - Parent Status changes to: **"Driver Arrived at School"** (or "Driver is at the school area").
    - Parent Notification: "Driver is at the school area".
3.  **Driver Unloads Students:**
    - Driver presses **"Drop Off"** button (Manual action required for safety).
    - Parent Status changes to: **"Child Dropped Off"** / **"Arrived at School"** (Completed).

## 5. Timeline & Priority
1.  **Fix message logic bug:** Ensure correct stop is identified (Immediate).
2.  **Implement Auto-Arrival:** Add geofencing to Driver App (High Priority).
3.  **Refine Messages:** Update text to match user preference (Medium).
