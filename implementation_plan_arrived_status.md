# Implementation Plan: Enhanced Driver Status Logic (Arrived State)

## Goal
Ensure the "Check 2: Active Trip" logic in `DriverStatusMonitor` explicitly handles the **"Arrived"** state for School (Morning) and Home (Afternoon) drops, even if the real-time event stream is momentarily silent.

## 1. Database Changes (Supabase)
**File:** `supabase/migrations/20260208_update_next_stop_info.sql` (New Migration)
- Update the RPC function `get_parent_next_stop_info`.
- **Change:** Add `stop_status` to the returned table.
- **Logic:** Return the `status` column from `route_stops` (values: 'pending', 'arrived').

```sql
-- Pseudo-code for RPC update
CREATE OR REPLACE FUNCTION get_parent_next_stop_info(...) 
RETURNS TABLE(..., stop_status text) AS $$
  -- ... existing logic ...
  SELECT rs.status INTO v_status ...
  RETURN QUERY SELECT ..., v_status;
$$;
```

## 2. Data Layer Changes (Flutter)
**File:** `lib/features/parent/tracking/data/tracking_repository.dart`
- **Class:** `ParentNextStopInfo`
- **Action:** Add `stopStatus` field.
- **Update:** `fromMap` constructor to map `stop_status`.

```dart
class ParentNextStopInfo {
  // ... existing fields
  final String? stopStatus; // 'pending' | 'arrived'

  factory ParentNextStopInfo.fromMap(Map<String, dynamic> map) {
    return ParentNextStopInfo(
      // ...
      stopStatus: map['stop_status'] as String?,
    );
  }
}
```

## 3. UI Logic Changes (Flutter)
**File:** `lib/features/parent/dashboard/presentation/widgets/driver_status_monitor.dart`
- **Location:** Inside `_buildActiveCard` -> `else if (isActive)` block (Check 2).
- **Logic:** Check `nextStopInfo?.stopStatus`.

**Updated Flow:**
```dart
} else if (isActive) {
  // ... 
  
  // NEW: Handle Arrived State via Stop Info
  if (nextStopInfo?.stopStatus == 'arrived') {
      badgeColor = Colors.orange;
      badgeText = 'ARRIVED';
      
      if (nextStopInfo?.isGoTrip == true) {
         title = "Arrived at School";
         subtitle = "Waiting for child drop-off";
      } else {
         title = "Arrived at Home";
         subtitle = "Waiting for child drop-off";
      }
      
  } else {
      // Existing logic for 'Heading to...' / 'Arriving for...'
      badgeColor = Colors.green;
      badgeText = 'LIVE TRIP';
      // ...
  }
}
```

## Summary of Impact
This change ensures that if the driver status is *Active* and the database says they are *Arrived* at the parent's stop, the UI reflects "Arrived" immediately, serving as a reliable fallback to the ephemeral "Ride Event".
