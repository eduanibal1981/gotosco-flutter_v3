import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/driver_location_model.dart';
import '../data/tracking_repository.dart';

part 'tracking_controller.g.dart';

/// StreamProvider that listens to real-time driver location updates.
/// Using a family provider allows tracking different drivers.
/// Uses Supabase Realtime for instant updates.
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

/// Provider to fetch booking locations (home and school coordinates).
/// This is a one-time fetch, not a stream.
@riverpod
Future<BookingLocations> bookingLocations(Ref ref, String bookingId) {
  return ref.watch(trackingRepositoryProvider).getBookingLocations(bookingId);
}
