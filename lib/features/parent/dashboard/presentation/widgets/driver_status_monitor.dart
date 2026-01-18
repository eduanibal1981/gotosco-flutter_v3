// lib/features/parent/dashboard/presentation/widgets/driver_status_monitor.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../dashboard_controller.dart';
import '../../../tracking/presentation/tracking_controller.dart';
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

    return driverLocationAsync.when(
      data: (location) {
        // Driver is active and stream is working
        final bool isActive = location.isOnTrip;

        String title = ''; // Empty to avoid redundancy with badge
        String subtitle = location.isOnline
            ? 'Waiting for trip to start'
            : 'Driver is currently offline';
        String badgeText = location.isOnline
            ? 'DRIVER ONLINE'
            : 'DRIVER OFFLINE';
        Color badgeColor = location.isOnline ? Colors.orange : Colors.grey;

        if (isActive) {
          badgeColor = Colors.green;
          badgeText = 'LIVE TRIP';

          if (location.tripType == 'pickup') {
            title = 'Arriving for Pickup';
          } else if (location.tripType == 'dropoff') {
            title = 'Heading to Destination';
          } else {
            title = 'Trip in Progress';
          }
          // For now, simpler subtitle until we calc full ETA
          subtitle = 'View on map';
        }

        return ActiveBookingCard(
          driverName: driverName,
          driverPhoto: driverPhoto,
          title: title,
          subtitle: subtitle,
          badgeText: badgeText,
          badgeColor: badgeColor,
          isActive: isActive,
          onViewAll: () {
            // Switch to My Bookings tab
            ref.read(parentDashboardIndexProvider.notifier).setIndex(3);
          },
          onTrack: () {
            context.push(
              '/tracking',
              extra: {'bookingId': bookingId, 'driverId': driverId},
            );
          },
        );
      },
      error: (_, __) => _buildScheduledCard(
        context,
        ref,
        driverName,
        driverPhoto,
        bookingId,
        driverId,
      ),
      loading: () => _buildScheduledCard(
        context,
        ref,
        driverName,
        driverPhoto,
        bookingId,
        driverId,
        isLoading: true,
      ),
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
      onViewAll: () {
        // Switch to My Bookings tab
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
}
