# Implementation Report Update: Fix Missing Driver Location

## Issue
- The `start_trip` function (v20260206) only attempted to `UPDATE` the `driver_locations` table.
- If a driver had no existing row in `driver_locations` (e.g., new driver), the update would find 0 rows and do nothing, failing to initialize tracking.

## Fix
- **Updated `start_trip` RPC (v20260207)**:
  - Restored the `IF NOT FOUND THEN INSERT...` logic (UPSERT pattern).
  - Now, if no row exists for the driver, it automatically creates one with:
    - `is_tracking_active = true`
    - `trips_started = true`
    - `trip_type` mapped from the trip type (pickup/dropoff).
  
## Verification
- Apply migration `20260207_fix_start_trip_insert.sql`.
- Pressing "Start Trip" should now successfully create the row and update the UI.
