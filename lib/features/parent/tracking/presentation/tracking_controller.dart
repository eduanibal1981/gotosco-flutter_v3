import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/driver_location_model.dart';
import '../data/tracking_repository.dart';

part 'tracking_controller.g.dart';

/// StreamProvider that listens to real-time driver location updates.
/// Using a family provider allows tracking different drivers.
///
/// Usage in UI:
/// ```dart
/// final locationAsync = ref.watch(driverLocationProvider(driverId));
/// ```
@riverpod
Stream<DriverLocation> driverLocation(Ref ref, String driverId) {
  return ref
      .watch(trackingRepositoryProvider)
      .getDriverLocationStream(driverId);
}

/// Controller for simulation and other tracking actions.
@riverpod
class TrackingController extends _$TrackingController {
  @override
  FutureOr<void> build() {}

  /// Starts a simulated driver movement for testing.
  /// Moves from startPosition to endPosition over the specified duration.
  Future<void> startSimulation({
    required String driverId,
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    int steps = 20,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(trackingRepositoryProvider);

      await repository.simulateDriverMovement(
        driverId: driverId,
        startLat: startLat,
        startLng: startLng,
        endLat: endLat,
        endLng: endLng,
        steps: steps,
        interval: const Duration(seconds: 2),
      );
    });
  }
}
