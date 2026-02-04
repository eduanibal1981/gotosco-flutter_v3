# Fix Booking Requests Placeholder Text

## Context
When a driver has confirmed bookings but no daily trips generated (e.g., viewing dashboard before generating today's trips), they fall into the `profileOnly` state.
The "Booking Requests" card in this state displayed a static message: "Waiting for requests... Go online to receive bookings", which was confusing for drivers who already had bookings or were already online.

## Changes
Modified `lib/features/driver/dashboard/presentation/tabs/driver_home_tab.dart`:
1.  Updated `_buildProfileOnlyState` to watch `driverStatsProvider` and `driverAvailabilityControllerProvider`.
2.  Made "Booking Requests" card subtitle dynamic:
    - **Has Active Bookings + Online**: "You have X active bookings. Waiting for new requests..."
    - **Has Active Bookings + Offline**: "You have X active bookings. Go online to receive more."
    - **No Bookings + Online**: "Waiting for new requests..."
    - **No Bookings + Offline**: "Go online to receive booking requests"
3.  Added "My Students" quick action button if active bookings > 0.
4.  Added "Active Bookings" summary section at the bottom if active bookings > 0.
5.  Fixed `AsyncValue.valueOrNull` error by using `asData?.value` for riverpod compatibility.

## Verification
- Run `flutter build apk --debug` -> SUCCESS.
- Logic handled for online/offline and active/no-active booking states.
