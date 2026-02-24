// lib/features/parent/dashboard/presentation/widgets/driver_status_monitor.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../dashboard_controller.dart';
import 'package:gotosco_v3/features/parent/tracking/application/tracking_providers.dart';
import 'package:gotosco_v3/features/parent/tracking/domain/models/tracking_view_model.dart';
import 'package:gotosco_v3/features/parent/tracking/domain/models/parent_next_stop_info.dart';
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
    final nextStopAsync = ref.watch(
      parentNextStopInfoProvider(bookingId, driverId),
    );

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
          isLoading: false,
        );
      },
      error: (_, __) => _buildActiveCard(
        context,
        ref,
        driverName,
        driverPhoto,
        bookingId,
        driverId,
        location: null,
        rideEvent: rideEventAsync.asData?.value,
        nextStopInfo: nextStopAsync.asData?.value,
        isConnected: false,
        isLoading: false,
      ),
      loading: () => _buildActiveCard(
        context,
        ref,
        driverName,
        driverPhoto,
        bookingId,
        driverId,
        location: null,
        rideEvent: rideEventAsync.asData?.value,
        nextStopInfo: nextStopAsync.asData?.value,
        isConnected: false,
        isLoading: true,
      ),
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
    required TrackingViewModel? location,
    required bool isConnected,
    required bool isLoading,
  }) {
    String badgeText =
        nextStopInfo?.statusBadge?.replaceAll('_', ' ') ?? 'OFFLINE';
    debugPrint('nextstopinfo: $nextStopInfo');
    String title = nextStopInfo?.uiTitle ?? 'Scheduled Trip';
    String subtitle = nextStopInfo?.uiSubtitle ?? 'Driver is offline';
    Color badgeColor = Colors.grey;
    
    if (isLoading && nextStopInfo == null) {
      badgeText = 'SCHEDULED';
      title = 'Loading...';
      subtitle = 'Checking status...';
    }


    if (badgeText == 'SCHEDULED')
      badgeColor = Colors.blue;
    else if (badgeText == 'LIVE TRIP' ||
        badgeText == 'ON TRIP' ||
        badgeText == 'COMPLETED')
      badgeColor = Colors.green;
    else if (badgeText == 'ARRIVED' || badgeText == 'APPROACHING')
      badgeColor = Colors.orange;
    else if (badgeText == 'SKIPPED')
      badgeColor = Colors.amber;

    // Offline Override (if not completed)
    if (!isConnected &&
        badgeText != 'COMPLETED' &&
        badgeText != 'SCHEDULED' &&
        badgeText != 'OFFLINE') {
      subtitle = 'Driver signal lost...';
    }

    final bool isActive =
        (badgeText != 'SCHEDULED' && badgeText != 'OFFLINE') ||
        (badgeText == 'COMPLETED');

    return ActiveBookingCard(
      driverName: driverName,
      driverPhoto: driverPhoto,
      title: title,
      subtitle: subtitle,
      badgeText: badgeText,
      badgeColor: badgeColor,
      isActive: isActive,
      etaMinutes: nextStopInfo?.etaMinutes ?? location?.etaMinutes,
      stopsUntilParent: nextStopInfo?.stopsUntil,
      nextStopLabel: null,
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
}
