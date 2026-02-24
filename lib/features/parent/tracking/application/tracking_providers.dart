import 'package:gotosco_v3/features/parent/tracking/domain/models/booking_location_model.dart';
import 'package:gotosco_v3/features/parent/tracking/domain/models/parent_next_stop_info.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repositories/tracking_repository_impl.dart';
import '../domain/models/tracking_view_model.dart';

export '../data/repositories/tracking_repository_impl.dart';

part 'tracking_providers.g.dart';

/// StreamProvider that listens to real-time driver location updates.
@riverpod
Stream<TrackingViewModel?> driverLocation(Ref ref, String driverId) {
  final repository = ref.watch(trackingRepositoryProvider);
  return repository.getDriverLocationStream(driverId);
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
Future<ParentNextStopInfo?> parentNextStopInfo(
  Ref ref,
  String bookingId,
  String driverId,
) async {
  // Watch streams so that this provider refetches automatically on every real-time update
  ref.watch(latestRideEventProvider(bookingId));
  ref.watch(driverLocationProvider(driverId));

  return ref.watch(trackingRepositoryProvider).getParentNextStopInfo(bookingId);
}
