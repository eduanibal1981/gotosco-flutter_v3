// lib/features/parent/dashboard/presentation/widgets/driver_status_monitor.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
        // RLS ensures we only get data if conditions are met
        return ActiveBookingCard(
          driverName: driverName,
          driverPhoto: driverPhoto,
          status: 'active',
          onViewAll: () {
            // TODO: Navigate to All Bookings or handle accordingly
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
        driverName,
        driverPhoto,
        bookingId,
        driverId,
      ),
      loading: () => _buildScheduledCard(
        context,
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
    String driverName,
    String? driverPhoto,
    String bookingId,
    String driverId, {
    bool isLoading = false,
  }) {
    return ActiveBookingCard(
      driverName: driverName,
      driverPhoto: driverPhoto,
      status: 'accepted', // This triggers the Blue UI
      onViewAll: () {
        // TODO: Navigate to All Bookings
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
