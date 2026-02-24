import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:geolocator/geolocator.dart'; // Add for distance calculation
import '../../data/repositories/driver_dashboard_repository_impl.dart';
import '../../domain/models/driver_trip_model.dart';

import '../../application/driver_dashboard_providers.dart';
import '../../../availability/data/driver_availability_repository.dart';
import '../../../availability/application/driver_availability_controller.dart';

part 'active_trip_controller.g.dart';

@riverpod
class ActiveTripController extends _$ActiveTripController {
  @override
  FutureOr<DriverTrip?> build() {
    return ref.watch(activeTripProvider.future);
  }

  /// Start a trip
  Future<void> startTrip(DriverTrip trip, {double? lat, double? lng}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final bookingIds = trip.routeStops
          .map((s) => s.bookingId)
          .where((id) => id != null)
          .cast<String>()
          .toSet()
          .toList();

      await ref
          .read(driverDashboardRepositoryProvider)
          .broadcastTripStarted(trip.id, bookingIds);

      await ref
          .read(driverDashboardRepositoryProvider)
          .startTrip(trip.id, lat: lat, lng: lng);

      // Refresh to get the updated status
      ref.invalidate(todaysTripsProvider);
      ref.invalidate(
        driverDashboardStateProvider,
      ); // Force dashboard state update
      return ref.refresh(activeTripProvider.future);
    });
  }

  /// Mark arrival at a stop
  Future<void> arriveAtStop(String stopId, {double? lat, double? lng}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      // 1. Perform action
      await ref
          .read(driverDashboardRepositoryProvider)
          .markStopArrived(stopId, lat: lat, lng: lng);

      // 2. Refresh state
      ref.invalidate(activeTripProvider);
      return ref.refresh(activeTripProvider.future);
    });
  }

  /// Process stop (Pickup / Dropoff / Skip)
  Future<void> processStop(
    String stopId,
    String action, {
    double? lat,
    double? lng,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(driverDashboardRepositoryProvider)
          .processStop(stopId, action, lat: lat, lng: lng);

      ref.invalidate(activeTripProvider);
      return ref.refresh(activeTripProvider.future);
    });
  }

  /// Reorder stops
  Future<void> reorderStops(List<Map<String, dynamic>> newStops) async {
    await ref
        .read(driverDashboardRepositoryProvider)
        .updateStopSequences(newStops);

    ref.invalidate(activeTripProvider);
  }

  /// Save current trip order as default for future trips
  Future<void> saveTripOrderAsDefault(String tripId) async {
    await ref
        .read(driverDashboardRepositoryProvider)
        .saveTripOrderAsDefault(tripId);
  }

  /// End the trip (with smart auto-offline support)
  Future<void> endTrip(String tripId, {double? lat, double? lng}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      // Use availability repository for smart auto-offline
      await ref
          .read(driverAvailabilityRepositoryProvider)
          .completeTripWithAutoOffline(tripId, lat: lat, lng: lng);

      // Invalidate relevant providers
      ref.invalidate(todaysTripsProvider);
      ref.invalidate(activeTripProvider); // Should become null
      ref.invalidate(
        driverDashboardStateProvider,
      ); // Force dashboard state update
      ref.invalidate(
        driverAvailabilityControllerProvider,
      ); // Refresh online status
      return null;
    });
  }

  /// Compute the next pending stop from the current trip data
  RouteStop? get currentStop {
    final trip = state.value;
    if (trip == null) return null;

    final stops = trip.routeStops;
    if (stops.isEmpty) return null;

    // Sort by sequence_order just in case
    final sortedStops = List<RouteStop>.from(stops);
    sortedStops.sort(
      (a, b) => (a.sequenceOrder ?? 0).compareTo(b.sequenceOrder ?? 0),
    );

    // Find first non-completed/non-skipped stop
    try {
      return sortedStops.firstWhere((s) {
        final status = s.status;
        return status == 'pending' || status == 'arrived';
      });
    } catch (e) {
      return null; // All done
    }
  }

  /// Check geofence for auto-arrival (Distance < 200m)
  Future<void> checkArrivalGeofence(double lat, double lng) async {
    final trip = state.value;
    if (trip == null) return;

    final stops = trip.routeStops;
    // Only check pending stops
    final pendingStops = stops.where((s) => s.status == 'pending').toList();

    if (pendingStops.isEmpty) return;

    // Sort by sequence for safe processing
    pendingStops.sort(
      (a, b) => (a.sequenceOrder ?? 0).compareTo(b.sequenceOrder ?? 0),
    );

    // We check if we are close to ANY pending stop
    // If we are close to a later stop (e.g. School), we might need to skip previous ones
    for (final stop in pendingStops) {
      final stopLat = stop.latitude;
      final stopLng = stop.longitude;

      if (stopLat == null || stopLng == null) continue;

      final distance = Geolocator.distanceBetween(lat, lng, stopLat, stopLng);
      // Threshold: 200 meters
      if (distance < 200) {
        // We arrived at 'stop'.
        // Check if there are earlier pending stops we skipped
        final earlierStops = pendingStops
            .where((s) => (s.sequenceOrder ?? 0) < (stop.sequenceOrder ?? 0))
            .toList();

        if (earlierStops.isNotEmpty) {
          // Auto-skip logic for intermediate stops
          // This fixes the "Ready for pickup" bug when arriving at school
          for (final skipped in earlierStops) {
            await processStop(skipped.id, 'skipped');
          }
        }

        // Mark this stop as arrived
        await arriveAtStop(stop.id, lat: lat, lng: lng);
        break; // Process one arrival at a time
      }
    }
  }
}
