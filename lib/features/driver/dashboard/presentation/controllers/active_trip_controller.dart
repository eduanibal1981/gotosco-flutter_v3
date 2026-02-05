import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/driver_dashboard_repository.dart';
import '../../../availability/data/driver_availability_repository.dart';
import '../../../availability/presentation/driver_availability_controller.dart';

part 'active_trip_controller.g.dart';

@riverpod
class ActiveTripController extends _$ActiveTripController {
  @override
  FutureOr<Map<String, dynamic>?> build() {
    return ref.watch(activeTripProvider.future);
  }

  /// Start a trip
  Future<void> startTrip(String tripId, {double? lat, double? lng}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(driverDashboardRepositoryProvider)
          .startTrip(tripId, lat: lat, lng: lng);

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

  /// compute the next pending stop from the current trip data
  Map<String, dynamic>? get currentStop {
    final trip = state.value;
    if (trip == null) return null;

    final stops = (trip['route_stops'] as List<dynamic>?) ?? [];
    if (stops.isEmpty) return null;

    // Sort by sequence_order just in case
    stops.sort(
      (a, b) =>
          (a['sequence_order'] as int).compareTo(b['sequence_order'] as int),
    );

    // Find first non-completed/non-skipped stop
    try {
      return stops.firstWhere((s) {
            final status = s['status'] as String;
            return status == 'pending' || status == 'arrived';
          })
          as Map<String, dynamic>;
    } catch (e) {
      return null; // All done
    }
  }
}
