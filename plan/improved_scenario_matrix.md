# Student Transport App - UI States & Parent Notifications
## Complete Driver Action → Parent Display Matrix

---

## 🎯 Overview

This document maps **every driver action** to **exactly what the parent sees** on their dashboard card. It covers both **Go to School** and **Return from School** trips with precise label text.

---

## 📋 Understanding the Scenarios

### Trip Types
- **Go Trip** (Morning): Home (Pickup) → School (Dropoff)
- **Return Trip** (Afternoon): School (Pickup) → Home (Dropoff)

### Parent's Child Position
- **Is Parent's Stop**: The current action involves THIS parent's child
- **Other Child's Stop**: The action involves a different parent's child

---

## 🌅 MORNING TRIP - "Go to School(s)"

### PHASE 1: Before Trip Starts

| # | Driver State | Driver Action | Parent Dashboard Label | Badge | Color |
|---|-------------|---------------|----------------------|-------|-------|
| 1.1 | Booking exists, Driver offline | None (driver app closed) | **"Scheduled Trip"**<br>"Driver is currently offline" | SCHEDULED | Blue |
| 1.2 | Booking exists, Driver online but invisible | Driver sets visibility = false | **"Scheduled Trip"**<br>"Driver is currently offline" | SCHEDULED | Blue |
| 1.3 | Booking exists, Driver online & visible | Driver opens app (is_online_visible = true) | **"Scheduled Trip"**<br>"Driver is online" | SCHEDULED | Blue |
| 1.4 | Trip generated, Driver offline | Driver clicked "Generate Trips" then went offline | **"Scheduled Trip"**<br>"Driver is currently offline" | SCHEDULED | Blue |
| 1.5 | Trip generated, Driver online | Driver clicked "Generate Trips" and is online | **"Scheduled Trip"**<br>"Driver is online" | SCHEDULED | Blue |

**Key Point:** Until driver presses "Start Trip", parent always sees blue "Scheduled" card regardless of trip generation.

---

### PHASE 2: Trip Started (Morning - Pickup Phase)

| # | Driver Action | Is Parent's Stop? | Parent Dashboard Label | Badge | Color |
|---|---------------|-------------------|----------------------|-------|-------|
| 2.1 | Presses **"Start Trip"** | N/A | **"Trip in Progress"**<br>"3 stops until pickup"<br>*or*<br>"View on map" | LIVE TRIP | Green |

**Important:** 
- Parent now sees **stop count** if their child is not the first pickup
- Parent sees **"View on map"** if data unavailable
- ETA may show if calculated: "15 min - 3 stops"

---

### PHASE 3: Driver at Other Children's Pickup Stops

| # | Driver Action | Is Parent's Stop? | Parent Dashboard Label | Badge | Color |
|---|---------------|-------------------|----------------------|-------|-------|
| 3.1 | Presses **"I Have Arrived"** at another child's home | ❌ No | **"Trip in Progress"**<br>"2 stops until pickup"<br>*count decreases* | LIVE TRIP | Green |
| 3.2 | Presses **"Pick Up"** at another child's home | ❌ No | **"Trip in Progress"**<br>"2 stops until pickup"<br>*count stays same* | LIVE TRIP | Green |

**Key Point:** Parent sees countdown of stops remaining. No specific notification about other children.

---

### PHASE 4: Driver Reaches Parent's Child (Pickup)

| # | Driver Action | Is Parent's Stop? | Parent Dashboard Label | Badge | Color |
|---|---------------|-------------------|----------------------|-------|-------|
| 4.1 | Presses **"I Have Arrived"** at parent's home | ✅ Yes | **"Driver Arrived"**<br>"At pickup location" | ARRIVED | Orange |
| 4.2 | Presses **"Pick Up"** (child enters vehicle) | ✅ Yes | **"Child Picked Up"**<br>"Heading to school" | ON TRIP | Green |

**Push Notifications:**
- 4.1: "🚗 Driver has arrived at your location!"
- 4.2: "✅ Your child has been picked up"

---

### PHASE 5: Journey to School (After Parent's Pickup)

| # | Driver Action | Is Parent's Stop? | Parent Dashboard Label | Badge | Color |
|---|---------------|-------------------|----------------------|-------|-------|
| 5.1 | Presses **"I Have Arrived"** at another child's home | ❌ No | **"Child Picked Up"**<br>"Heading to school"<br>*no change* | ON TRIP | Green |
| 5.2 | Presses **"Pick Up"** at another child's home | ❌ No | **"Child Picked Up"**<br>"Heading to school"<br>*no change* | ON TRIP | Green |

**Key Point:** Once parent's child is picked up, label stays the same until school dropoff.

---

### PHASE 6: Arrival at School (Dropoff Phase)

| # | Driver Action | Is Parent's Stop? | Parent Dashboard Label | Badge | Color |
|---|---------------|-------------------|----------------------|-------|-------|
| 6.1 | Presses **"I Have Arrived"** at school | ✅ Yes (if child goes to this school) | **"Driver Arrived"**<br>"At school dropoff location"<br>*no change from 4.1 if already shown* | ARRIVED | Orange |
| 6.2 | Presses **"Drop Off"** for parent's child | ✅ Yes | **"Child Dropped Off"**<br>"Trip completed" | COMPLETED | Green |

**Push Notifications:**
- 6.1: *(Optional)* "Driver arrived at school"
- 6.2: "✅ Your child has been dropped off at school"

**Important:**
- If driver already triggered "Arrived" at parent's home (4.1), showing "Arrived" again at school is redundant
- Current implementation: Badge goes straight from "ON TRIP" to "COMPLETED" on dropoff

---

### PHASE 7: Other Children's School Dropoffs

| # | Driver Action | Is Parent's Stop? | Parent Dashboard Label | Badge | Color |
|---|---------------|-------------------|----------------------|-------|-------|
| 7.1 | Presses **"Drop Off"** for another child | ❌ No | **"Child Dropped Off"**<br>"Trip completed"<br>*no change* | COMPLETED | Green |

**Key Point:** Once parent's child is dropped, their status doesn't change for other children's dropoffs.

---

## 🌆 AFTERNOON TRIP - "Return from School(s)"

### PHASE 8: Return Trip Starts

| # | Driver Action | Is Parent's Stop? | Parent Dashboard Label | Badge | Color |
|---|---------------|-------------------|----------------------|-------|-------|
| 8.1 | Presses **"Start Trip"** (Return trip) | N/A | **"Trip in Progress"**<br>"View on map"<br>*or*<br>"2 stops until pickup" | LIVE TRIP | Green |

**Note:** 
- Parent sees a **new card** for the return trip
- Morning trip card may show as "Completed" in history
- Stop count shows how many stops until driver picks up THEIR child

---

### PHASE 9: Driver at Other Children's School Pickups

| # | Driver Action | Is Parent's Stop? | Parent Dashboard Label | Badge | Color |
|---|---------------|-------------------|----------------------|-------|-------|
| 9.1 | Presses **"I Have Arrived"** at another child's school | ❌ No | **"Trip in Progress"**<br>"1 stop until pickup"<br>*count decreases* | LIVE TRIP | Green |
| 9.2 | Presses **"Pick Up"** at another child's school | ❌ No | **"Trip in Progress"**<br>"1 stop until pickup"<br>*count stays same* | LIVE TRIP | Green |

---

### PHASE 10: Driver Reaches Parent's Child's School (Pickup)

| # | Driver Action | Is Parent's Stop? | Parent Dashboard Label | Badge | Color |
|---|---------------|-------------------|----------------------|-------|-------|
| 10.1 | Presses **"I Have Arrived"** at parent's child's school | ✅ Yes | **"Driver Arrived"**<br>"At school pickup location" | ARRIVED | Orange |
| 10.2 | Presses **"Pick Up"** (child enters vehicle) | ✅ Yes | **"Child Picked Up"**<br>"1 stop left to reach home"<br>*or*<br>"Heading home" | ON TRIP | Green |

**Push Notifications:**
- 10.1: "🚗 Driver has arrived at school!"
- 10.2: "✅ Your child has been picked up from school"

**Important:**
- Label shows **remaining stops to HOME** if other dropoffs exist
- If parent's home is last stop: "Heading home"

---

### PHASE 11: Journey to Home (After Parent's School Pickup)

| # | Driver Action | Is Parent's Stop? | Parent Dashboard Label | Badge | Color |
|---|---------------|-------------------|----------------------|-------|-------|
| 11.1 | Presses **"I Have Arrived"** at another child's home | ❌ No | **"Child Picked Up"**<br>"Heading home"<br>*no change* | ON TRIP | Green |
| 11.2 | Presses **"Drop Off"** at another child's home | ❌ No | **"Child Picked Up"**<br>"Heading home"<br>*no change* | ON TRIP | Green |

**Key Point:** Parent doesn't see updates about other children's dropoffs.

---

### PHASE 12: Arrival at Parent's Home (Dropoff)

| # | Driver Action | Is Parent's Stop? | Parent Dashboard Label | Badge | Color |
|---|---------------|-------------------|----------------------|-------|-------|
| 12.1 | Presses **"I Have Arrived"** at parent's home | ✅ Yes | **"Child Picked Up"**<br>"Heading home"<br>*no change (no notification)* | ON TRIP | Green |
| 12.2 | Presses **"Drop Off"** for parent's child | ✅ Yes | **"Child Dropped Off"**<br>"Trip completed" | COMPLETED | Green |

**Push Notifications:**
- 12.1: ❌ **No notification** (already know child is coming home)
- 12.2: "✅ Your child has been dropped off at home"

**Design Decision:** 
- "I Have Arrived" at home doesn't trigger parent notification (redundant)
- Only "Drop Off" triggers notification and label change

---

### PHASE 13: Trip Completion

| # | Driver Action | Parent Dashboard Display | Notes |
|---|---------------|-------------------------|-------|
| 13.1 | Presses **"End Trip"** (after all dropoffs) | **"All Trips Completed"**<br>"No more scheduled trips for today"<br>"All trips have been completed" | Blue/Gray card<br>No action buttons |

**Alternative:**
- Card may disappear entirely
- Or shows summary: "Today's trips: ✅ Go to School ✅ Return Home"

---

## 📊 State Matrix Summary

### Badge States Progression

```
SCHEDULED (Blue)
    ↓ [Driver starts trip]
LIVE TRIP (Green)
    ↓ [Driver arrives at parent's stop]
ARRIVED (Orange)
    ↓ [Driver picks up / drops off child]
ON TRIP (Green)
    ↓ [Driver completes dropoff]
COMPLETED (Green)
```

---

## 🔔 Push Notification Rules

| Event | Notification Sent? | Message |
|-------|-------------------|---------|
| Driver goes online | ❌ No | - |
| Trip started | ❌ No | - |
| Arrived at other child's stop | ❌ No | - |
| **Arrived at parent's pickup** | ✅ Yes | "🚗 Driver has arrived!" |
| **Picked up parent's child** | ✅ Yes | "✅ Your child has been picked up" |
| Arrived at other child's dropoff | ❌ No | - |
| **Dropped off parent's child** | ✅ Yes | "✅ Your child has been dropped off" |
| Arrived at parent's home (return) | ❌ No | *(No notification - redundant)* |
| Trip ended | ❌ No | - |

**Total Notifications Per Day:**
- **Morning (Go Trip):** 2 notifications (Arrived + Picked Up)
- **Afternoon (Return Trip):** 2 notifications (Arrived at School + Dropped at Home)
- **Total:** 4 notifications/day

**Note:** "Arrived at home" (return dropoff) doesn't send notification to avoid notification fatigue.

---

## 🎨 Visual Design Guide

### Card Color Coding

| State | Background | Badge | Icon |
|-------|-----------|-------|------|
| **Scheduled** | Light Blue Gradient | Blue | 📅 |
| **Live Trip** | White with Green Accent | Green | 🚗 |
| **Arrived** | White with Orange Accent | Orange | 📍 |
| **On Trip** | White with Green Accent | Green | ✅ |
| **Completed** | Light Green / Gray | Green | ✓ |

### Label Format

```
┌─────────────────────────────┐
│ [Badge: STATUS]             │
│                             │
│ Title (Bold)                │
│ Subtitle (Gray)             │
│                             │
│ 🕐 15 min | 📍 3 stops      │
│ 🚗 Driver: Ahmed            │
└─────────────────────────────┘
```

---

## 🔍 Edge Cases & Special Scenarios

### Case 1: Driver Skips Parent's Stop
```
Driver Action: Presses "Skip" at parent's pickup
Parent Dashboard: 
- Badge: LIVE TRIP → COMPLETED (skipped)
- Label: "Stop Skipped - Contact Driver"
- Color: Red/Orange warning
```

### Case 2: Multiple Children from Same Parent
```
Parent has 2 children in different grades/schools
Dashboard shows: Two separate cards
- Card 1: Child A - Elementary School
- Card 2: Child B - High School
Each tracks independently
```

### Case 3: Driver Goes Offline Mid-Trip
```
Driver loses connection during trip
Parent Dashboard:
- Badge: Shows last known state
- Subtitle: "Driver signal lost..." (Gray text)
- Map: Shows last known location
- Reconnects automatically when driver comes back online
```

### Case 4: Trip Regenerated
```
Driver clicks "Regenerate Trips"
Parent Dashboard:
- Old trip cards disappear
- New trip cards appear with fresh SCHEDULED status
- History preserved in separate section
```

---

## 🔧 Implementation Logic

### driver_status_monitor.dart - Decision Tree

```dart
Widget build(BuildContext context, WidgetRef ref) {
  // Stream 1: Driver Location (GPS + online status)
  final driverLocation = ref.watch(driverLocationProvider);
  
  // Stream 2: Ride Events (arrived, picked_up, dropped_off)
  final rideEvent = ref.watch(latestRideEventProvider);
  
  // Stream 3: Next Stop Info (ETA, stop count)
  final nextStopInfo = ref.watch(parentNextStopInfoProvider);

  // DECISION LOGIC:
  if (rideEvent != null) {
    // Priority 1: Show event status
    switch (rideEvent['event_type']) {
      case 'approaching':
      case 'arrived':
        return buildCard(
          badge: 'ARRIVED',
          title: 'Driver Arrived',
          subtitle: 'At pickup/dropoff location',
          color: Colors.orange,
        );
      
      case 'picked_up':
        return buildCard(
          badge: 'ON TRIP',
          title: 'Child Picked Up',
          subtitle: buildSubtitle(nextStopInfo),
          color: Colors.green,
        );
      
      case 'dropped_off':
        return buildCard(
          badge: 'COMPLETED',
          title: 'Child Dropped Off',
          subtitle: 'Trip completed',
          color: Colors.green,
        );
    }
  }
  
  else if (driverLocation.isOnline && driverLocation.tripsStarted) {
    // Priority 2: Trip in progress (no recent event)
    return buildCard(
      badge: 'LIVE TRIP',
      title: 'Trip in Progress',
      subtitle: buildSubtitle(nextStopInfo),
      color: Colors.green,
    );
  }
  
  else if (driverLocation.isOnline) {
    // Priority 3: Driver online but not started
    return buildCard(
      badge: 'SCHEDULED',
      title: 'Scheduled Trip',
      subtitle: 'Driver is online',
      color: Colors.blue,
    );
  }
  
  else {
    // Priority 4: Driver offline
    return buildCard(
      badge: 'SCHEDULED',
      title: 'Scheduled Trip',
      subtitle: 'Driver is currently offline',
      color: Colors.blue,
    );
  }
}

String buildSubtitle(ParentNextStopInfo? info) {
  if (info == null) return 'View on map';
  
  final eta = info.etaMinutes;
  final stops = info.stopsUntilParent;
  
  if (eta != null && stops != null) {
    return '$eta min - $stops stops until pickup';
  }
  if (stops != null) {
    return '$stops stops until pickup';
  }
  if (eta != null) {
    return '$eta min';
  }
  return 'View on map';
}
```

---

## 📱 Parent App Screens

### Dashboard Tab
- Shows **one card per active/upcoming trip**
- Morning trip card (Go to School)
- Afternoon trip card (Return from School)
- Completed trips move to history section

### Tracking Screen (When Card Tapped)
- Full map view with driver location
- Route visualization
- Live ETA updates
- All stops marked on map
- Driver contact button

---

## ✅ Testing Checklist

### Go Trip Testing
- [ ] Parent sees "Driver offline" when booking exists
- [ ] Parent sees "Driver online" when driver opens app
- [ ] Parent sees "Trip in Progress" when trip starts
- [ ] Parent sees stop countdown during other pickups
- [ ] Parent gets notification when driver arrives at their home
- [ ] Parent sees "Child Picked Up" after pickup
- [ ] Parent sees "Child Dropped Off" at school
- [ ] No notifications for other children's stops

### Return Trip Testing
- [ ] Parent sees new card for return trip
- [ ] Parent sees stop countdown during other school pickups
- [ ] Parent gets notification when driver arrives at school
- [ ] Parent sees "Child Picked Up" with home countdown
- [ ] No notification when driver arrives at home
- [ ] Parent gets notification only when child dropped at home
- [ ] All completed message shows after both trips done

### Edge Cases Testing
- [ ] Driver goes offline mid-trip → "signal lost" shown
- [ ] Driver skips stop → appropriate warning shown
- [ ] Multiple children → separate cards work correctly
- [ ] Trip regeneration → cards refresh properly

---

## 🎯 Key Principles

1. **Minimal Notifications**: Only notify parents about THEIR child's key events
2. **Clear Labels**: Always tell parent current status in plain English
3. **Stop Countdown**: Show remaining stops for context
4. **No Redundant Alerts**: Don't notify for expected events (e.g., "arrived at home")
5. **Real-Time Updates**: Cards update instantly via Supabase streams
6. **Offline Graceful**: Show last known state if connection lost

---

**Document Version:** 2.0  
**Last Updated:** February 2026  
**Status:** Production Implementation Guide
