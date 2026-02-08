# Database Changes During Trip Lifecycle

## Overview

This document details all database changes that occur during a complete Go + Return trip cycle.

---

## Phase 1: START TRIP (Go to School)

### RPC: `start_trip`

| Table | Column | Change |
|-------|--------|--------|
| `trips` | `status` | `'scheduled'` → `'in_progress'` |
| `trips` | `actual_start_time` | `NULL` → `NOW()` |
| `trips` | `updated_at` | `NOW()` |
| `driver_locations` | `trip_type` | → `'pickup'` |
| `driver_locations` | `is_tracking_active` | → `true` |
| `driver_locations` | `trips_started` | → `true` |
| `driver_locations` | `latitude/longitude` | Updated if provided |
| `trip_tracking` | _(INSERT)_ | New tracking point logged |

---

## Phase 2: ARRIVE AT STOP

### RPC: `process_stop` (action: `'arrived'`)

| Table | Column | Change |
|-------|--------|--------|
| `route_stops` | `status` | → `'arrived'` |
| `route_stops` | `arrived_at` | → `NOW()` |
| `ride_events` | _(INSERT)_ | `event_type = 'arrived'` |
| `driver_locations` | `next_stop_id` | Updated to next pending stop |
| `driver_locations` | `latitude/longitude` | Updated if provided |

---

## Phase 3: PICKUP CHILD

### RPC: `process_stop` (action: `'picked_up'`)

| Table | Column | Change |
|-------|--------|--------|
| `route_stops` | `status` | → `'completed'` |
| `route_stops` | `completed_at` | → `NOW()` |
| `ride_events` | _(INSERT)_ | `event_type = 'picked_up'` |
| `driver_locations` | `next_stop_id` | Updated to next pending stop |

---

## Phase 4: DROPOFF AT SCHOOL

### RPC: `process_stop` (action: `'dropped_off'`)

| Table | Column | Change |
|-------|--------|--------|
| `route_stops` | `status` | → `'completed'` |
| `route_stops` | `completed_at` | → `NOW()` |
| `ride_events` | _(INSERT)_ | `event_type = 'dropped_off'` |
| `driver_locations` | `next_stop_id` | → `NULL` (if no more stops) |

---

## Phase 5: COMPLETE TRIP

### RPC: `complete_trip_with_auto_offline`

| Table | Column | Change |
|-------|--------|--------|
| `trips` | `status` | → `'completed'` |
| `trips` | `actual_end_time` | → `NOW()` |
| `trips` | `updated_at` | → `NOW()` |
| `driver_locations` | `trip_type` | → `'idle'` |
| `driver_locations` | `trips_started` | → `false` |
| `driver_locations` | `is_tracking_active` | → `false` ⚠️ **IF `auto_offline_after_trip = true`** |
| `drivers` | `is_profile_online` | → `false` ⚠️ **IF `auto_offline_after_trip = true`** |

---

## Return Trip (Afternoon)

Same sequence as above, but:
- `trip_type` = `'dropoff'` instead of `'pickup'`
- Stops are reversed: School pickup → Home dropoff

---

## Summary: Tables Affected

| Table | When Modified |
|-------|--------------|
| `trips` | Start, Complete |
| `route_stops` | Every stop action (arrive/pickup/dropoff/skip) |
| `ride_events` | Arrive, Pickup, Dropoff (INSERT only) |
| `driver_locations` | Start, every stop, complete |
| `trip_tracking` | Start (initial location logged) |
| `drivers` | Complete (if `auto_offline_after_trip = true`) |

---

## ⚠️ Key Finding: Profile Offline Issue

The `is_profile_online` column in `drivers` table is set to `false` after trip completion **because**:

1. `auto_offline_after_trip` defaults to `true`
2. `complete_trip_with_auto_offline` checks this setting
3. If `true`, calls `set_profile_online_status(false)`

**Solution**: Change default to `false` or have driver disable this setting.
