# Implementation Report Update: Driver Location Online Status

## Changes
- **Refactored `DriverLocation` Model**:
  - Removed `isMap['is_online']` lookup in `fromMap` since `driver_locations` table does not have an `is_online` column.
  - `isOnline` defaults to `false` in `fromMap` and is populated via `copyWith` in the repository logic.
- **Updated `TrackingRepository`**:
  - Changed the secondary stream source for driver status from `drivers` table (`is_profile_online`) to **`users` table (`is_app_online`)**.
  - This ensures that the online status reflected in the parent dashboard now corresponds to the driver's actual app presence (as requested), rather than their advertisement visibility.
  - Updated both `getDriverLocationStream` (real-time) and `getDriverLocation` (one-time fetch).

## Impact
- Parent Dashboard "Trip Monitoring" will now show "Driver Online" / "Trip Scheduled" based on whether the driver has the app open (`is_app_online`), instead of whether they have toggled their "Ad Online" switch.
- Only when `trips_started` is true will it show "Trip Started".
