import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../tracking/domain/models/driver_location_model.dart';
import '../../tracking/domain/models/booking_location_model.dart';
import '../../tracking/domain/models/parent_next_stop_info.dart';
import '../data/repositories/tracking_repository_impl.dart';
export '../data/repositories/tracking_repository_impl.dart';

part 'tracking_providers.g.dart';

/// StreamProvider that listens to real-time driver location updates.
@riverpod
Stream<DriverLocation?> driverLocation(Ref ref, String driverId) {
  return ref
      .watch(trackingRepositoryProvider)
      .getDriverLocationStream(driverId);
}

/// Provider to fetch booking locations (home and school coordinates).
@riverpod
Future<BookingLocation?> bookingLocations(Ref ref, String bookingId) {
  return ref.watch(trackingRepositoryProvider).getBookingLocations(bookingId);
}

@riverpod
Stream<Map<String, dynamic>?> latestRideEvent(Ref ref, String bookingId) {
  return ref.watch(trackingRepositoryProvider).streamLatestRideEvent(bookingId);
}

@riverpod
Future<ParentNextStopInfo?> parentNextStopInfo(Ref ref, String bookingId) {
  return ref.watch(trackingRepositoryProvider).getParentNextStopInfo(bookingId);
}
