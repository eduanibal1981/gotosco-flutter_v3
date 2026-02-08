// lib/features/parent/dashboard/presentation/widgets/driver_status_monitor.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../dashboard_controller.dart';
import '../../../tracking/presentation/tracking_controller.dart';
import '../../../tracking/data/tracking_repository.dart';
import '../../../tracking/data/driver_location_model.dart'; // Add this import
import 'active_booking_card.dart';

/// A widget that monitors the driver's online status and location
/// to determine which version of the ActiveBookingCard to show.
/// - If stream has data & isOnline -> Green "Tracking" card.
/// - If stream error/loading/offline -> Blue "Scheduled" card.
class DriverStatusMonitor extends ConsumerWidget {
  final Map<String, dynamic> booking;

  const DriverStatusMonitor({super.key, required this.booking});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driverId = booking['driver_id'] as String;
    final driverName = booking['driver_name'] ?? 'Driver';
    final driverPhoto = booking['driver_photo'] as String?;
    final bookingId = booking['id'] as String;

    // Watch the real-time location stream for this driver
    final driverLocationAsync = ref.watch(driverLocationProvider(driverId));
    final rideEventAsync = ref.watch(latestRideEventProvider(bookingId));
    final nextStopAsync = ref.watch(parentNextStopInfoProvider(bookingId));

    return driverLocationAsync.when(
      data: (location) {
        return _buildActiveCard(
          context,
          ref,
          driverName,
          driverPhoto,
          bookingId,
          driverId,
          location: location,
          rideEvent: rideEventAsync.asData?.value,
          nextStopInfo: nextStopAsync.asData?.value,
          isConnected: true,
        );
      },
      error: (_, __) => _handleOfflineState(
        context,
        ref,
        driverName,
        driverPhoto,
        bookingId,
        driverId,
        rideEventAsync.asData?.value,
      ),
      loading: () => _handleOfflineState(
        context,
        ref,
        driverName,
        driverPhoto,
        bookingId,
        driverId,
        rideEventAsync.asData?.value,
        isLoading: true,
      ),
    );
  }

  Widget _handleOfflineState(
    BuildContext context,
    WidgetRef ref,
    String driverName,
    String? driverPhoto,
    String bookingId,
    String driverId,
    Map<String, dynamic>? rideEvent, {
    bool isLoading = false,
  }) {
    // If we have a ride event, show it even if driver is offline
    if (rideEvent != null) {
      return _buildActiveCard(
        context,
        ref,
        driverName,
        driverPhoto,
        bookingId,
        driverId,
        location: null, // No location data
        rideEvent: rideEvent,
        nextStopInfo: null,
        isConnected: false,
      );
    }

    return _buildScheduledCard(
      context,
      ref,
      driverName,
      driverPhoto,
      bookingId,
      driverId,
      isLoading: isLoading,
    );
  }

  Widget _buildActiveCard(
    BuildContext context,
    WidgetRef ref,
    String driverName,
    String? driverPhoto,
    String bookingId,
    String driverId, {
    required Map<String, dynamic>? rideEvent,
    required ParentNextStopInfo? nextStopInfo,
    required DriverLocation? location,
    required bool isConnected,
  }) {
    final bool isActive = location?.isOnTrip ?? false;

    String title = '';
    String subtitle = '';
    String badgeText = '';
    Color badgeColor = Colors.grey;

    // 1. Determine Status from Event (Priority)
    if (rideEvent != null) {
      print('rideEvent: $rideEvent');
      final eventType = rideEvent['event_type'] as String? ?? '';
      if (eventType == 'approaching') {
        title = 'Driver Approaching';
        subtitle = _buildApproachingText(nextStopInfo);
        badgeColor = Colors.orange;
        badgeText = 'APPROACHING';
      } else if (eventType == 'arrived') {
        title = 'Driver Arrived';
        subtitle = _getArrivedSubtitle(nextStopInfo);
        badgeColor = Colors.orange;
        badgeText = 'ARRIVED';
      } else if (eventType == 'picked_up') {
        title = 'Child Picked Up';
        subtitle = _getOnTripSubtitle(nextStopInfo);
        badgeColor = Colors.green;
        badgeText = 'ON TRIP';
      } else if (eventType == 'dropped_off') {
        title = 'Child Dropped Off';
        // Context-aware completion message
        subtitle = nextStopInfo?.isGoTrip == true
            ? 'Arrived at school'
            : (nextStopInfo?.isReturnTrip == true
                  ? 'Arrived home safely'
                  : 'Trip completed');
        badgeColor = Colors.green;
        badgeText = 'COMPLETED';
      } else if (eventType == 'skipped') {
        title = 'Stop Skipped';
        subtitle = 'Contact driver for details';
        badgeColor = Colors.amber;
        badgeText = 'SKIPPED';
      }
    } else if (isActive) {
      print('isActive: $isActive');
      // 2. Fallback to Location Status (if no specific event yet)
      badgeColor = Colors.green;
      badgeText = 'LIVE TRIP';
      // Use trip type for context-aware title
      if (nextStopInfo?.isGoTrip == true) {
        title = nextStopInfo?.stopType == 'pickup'
            ? 'Arriving for Pickup'
            : 'Heading to School';
      } else if (nextStopInfo?.isReturnTrip == true) {
        title = nextStopInfo?.stopType == 'pickup'
            ? 'Picking Up from School'
            : 'Heading Home';
      } else if (location?.tripType == 'pickup') {
        title = 'Arriving for Pickup';
      } else if (location?.tripType == 'dropoff') {
        title = 'Heading to Destination';
      } else {
        title = 'Trip in Progress';
      }
      subtitle = _buildEtaText(nextStopInfo);
    } else if (location?.isOnline == true) {
      // 3. Online but waiting / scheduled
      if (location?.tripsStarted == true) {
        title = 'Trip Started';
        subtitle = 'Driver on the way';
        badgeText = 'ON TRIP';
        badgeColor = Colors.green;
      } else {
        title = 'Trip Scheduled';
        subtitle = 'Driver is online';
        badgeText = 'SCHEDULED';
        badgeColor = Colors.blue;
      }
    } else {
      // 4. Explicitly Offline
      title = 'Scheduled Trip';
      subtitle = 'Driver is currently offline';
      badgeText = 'OFFLINE';
      badgeColor = Colors.grey;
    }

    // Offline Override (if not completed)
    if (!isConnected && badgeText != 'COMPLETED') {
      subtitle = 'Driver signal lost...';
      // Keep the last known status badge
    }

    return ActiveBookingCard(
      driverName: driverName,
      driverPhoto: driverPhoto,
      title: title,
      subtitle: subtitle,
      badgeText: badgeText,
      badgeColor: badgeColor,
      isActive: isActive || (badgeText == 'COMPLETED'),
      etaMinutes: nextStopInfo?.etaMinutes ?? location?.etaMinutes,
      stopsUntilParent: nextStopInfo?.stopsUntilParent,
      nextStopLabel: nextStopInfo?.nextStopIsParent == true
          ? nextStopInfo?.nextStopLabel
          : null,
      onViewAll: () {
        ref.read(parentDashboardIndexProvider.notifier).setIndex(3);
      },
      onTrack: () {
        context.push(
          '/tracking',
          extra: {'bookingId': bookingId, 'driverId': driverId},
        );
      },
    );
  }

  /// Builds the Blue "Scheduled" card when driver is offline or stream is initializing
  Widget _buildScheduledCard(
    BuildContext context,
    WidgetRef ref,
    String driverName,
    String? driverPhoto,
    String bookingId,
    String driverId, {
    bool isLoading = false,
  }) {
    return ActiveBookingCard(
      driverName: driverName,
      driverPhoto: driverPhoto,
      title: 'Scheduled Trip',
      subtitle: isLoading ? 'Checking status...' : 'Driver Offline',
      badgeText: 'SCHEDULED',
      badgeColor: Colors.blue,
      isActive: false,
      etaMinutes: null,
      stopsUntilParent: null,
      nextStopLabel: null,
      onViewAll: () {
        // Navigate to My Bookings tab
        ref.read(parentDashboardIndexProvider.notifier).setIndex(3);
      },
      onTrack: () {
        // Allow opening map even if offline to show status
        context.push(
          '/tracking',
          extra: {'bookingId': bookingId, 'driverId': driverId},
        );
      },
    );
  }

  /// Builds ETA text with stops remaining
  String _buildEtaText(ParentNextStopInfo? info) {
    if (info == null) return 'View on map';
    final eta = info.etaMinutes;
    final stops = info.stopsUntilParent;
    if (eta != null && stops != null && stops > 0) {
      return '$eta min · $stops stops away';
    }
    if (eta != null) {
      return '$eta min away';
    }
    if (stops != null && stops > 0) {
      return '$stops stops away';
    }
    return 'View on map';
  }

  /// Builds approaching subtitle with ETA context
  String _buildApproachingText(ParentNextStopInfo? info) {
    if (info == null) return 'View on map';
    final eta = info.etaMinutes;
    if (eta != null) {
      return 'Arriving in ~$eta min';
    }
    return 'Almost there';
  }

  /// Returns context-aware arrived subtitle
  String _getArrivedSubtitle(ParentNextStopInfo? info) {
    if (info == null) return 'At pickup/dropoff location';

    // Go trip (morning): Home pickup → School dropoff
    if (info.isGoTrip) {
      if (info.stopType == 'pickup') {
        return 'Ready for pickup at home';
      } else {
        return 'Arrived at school';
      }
    }

    // Return trip (afternoon): School pickup → Home dropoff
    if (info.isReturnTrip) {
      if (info.stopType == 'pickup') {
        return 'Picking up from school';
      } else {
        return 'Arrived at home';
      }
    }

    return 'At the child location';
  }

  /// Returns context-aware on-trip subtitle after pickup
  String _getOnTripSubtitle(ParentNextStopInfo? info) {
    if (info == null) return 'On the way';
    final destination = info.destinationLabel;
    final eta = info.etaMinutes;
    if (eta != null) {
      return 'Heading to $destination · $eta min';
    }
    return 'Heading to $destination';
  }
}
