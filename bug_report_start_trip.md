# Bug Report: Start Trip Failure

## Symptom
User reported that pressing "Start Trip" did not create a `driver_location` row and gave no response.

## Root Cause Analysis
- **Missing UPSERT Logic**: The `start_trip` function (version `20260206_add_trips_started_flag.sql`) was modified to use only an `UPDATE` statement on `driver_locations`.
- **Consequence**: For any driver who did not **already** have a row in `driver_locations` (e.g. new drivers or cleared data), the `UPDATE` found 0 rows and did nothing. No row was created.
- **Why No Error?**: The SQL function executed successfully (it just updated 0 rows), so no exception was thrown to the Flutter app.

## Resolution
- **Fix Applied (v20260207)**: Restored the `IF NOT FOUND THEN INSERT` block in `start_trip`.
- **Logic**: Now, if the driver's location row doesn't exist, it is automatically created with `is_tracking_active = true` and `trips_started = true`.
- **Additional Fix (New)**: `PostgrestException: column "actual_start_time" of relation "trips" does not exist` was encountered.
  - Added `actual_start_time` and `actual_end_time` columns to `trips` table via migration `20260207_add_actual_times_to_trips.sql`.
- **Additional Fix (New)**: `PostgrestException: relation "public.trip_tracking" does not exist` was encountered.
  - Created `trip_tracking` table via migration `20260207_create_trip_tracking_table.sql`.
- **Verification**: Added `try-catch` and `SnackBar` feedback in `trips_tab.dart` to visualize success or capture any future errors.
