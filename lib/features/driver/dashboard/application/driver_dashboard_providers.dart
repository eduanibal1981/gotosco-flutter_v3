import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/repositories/driver_dashboard_repository.dart';
import '../data/repositories/driver_dashboard_repository_impl.dart';
export '../data/repositories/driver_dashboard_repository_impl.dart';
import '../data/models/driver_stats_model.dart';
import '../data/models/driver_trip_model.dart';
import '../../transport_requests/data/models/driver_request_model.dart';

part 'driver_dashboard_providers.g.dart';

/// Provider for checking if driver has a profile in drivers table
@riverpod
Future<Map<String, dynamic>?> driverProfile(Ref ref) async {
  return ref.watch(driverDashboardRepositoryProvider).getDriverProfile();
}

/// Provider for driver dashboard state (1-5)
@riverpod
Future<DriverDashboardState> driverDashboardState(Ref ref) async {
  return ref.watch(driverDashboardRepositoryProvider).getDashboardState();
}

/// Provider for driver stats (students, pending requests, earnings)
@riverpod
Future<DriverStats> driverStats(Ref ref) async {
  return ref.watch(driverDashboardRepositoryProvider).getDriverStats();
}

/// Provider for driver's booking requests (pending)
@riverpod
Stream<List<DriverRequest>> driverBookingRequests(Ref ref) {
  return ref
      .watch(driverDashboardRepositoryProvider)
      .getBookingRequestsStream();
}

/// Provider for driver's enrolled students
/// Returns List<Map> for compatibility with existing UI for now
@riverpod
Future<List<Map<String, dynamic>>> driverStudents(Ref ref) {
  return ref.watch(driverDashboardRepositoryProvider).getEnrolledStudents();
}

/// Provider for today's trips
@riverpod
Future<List<DriverTrip>> todaysTrips(Ref ref) {
  return ref.watch(driverDashboardRepositoryProvider).getTodaysTrips();
}

/// Provider for active trip (if any)
@riverpod
Future<DriverTrip?> activeTrip(Ref ref) {
  return ref.watch(driverDashboardRepositoryProvider).getActiveTrip();
}

/// Provider for the next scheduled trip (Go to School first, then Return)
@riverpod
Future<DriverTrip?> nextScheduledTrip(Ref ref) async {
  final trips = await ref.watch(todaysTripsProvider.future);
  if (trips.isEmpty) return null;

  // Filter to only scheduled trips (not in_progress or completed)
  final scheduledTrips = trips.where((t) => t.status == 'scheduled').toList();
  if (scheduledTrips.isEmpty) return null;

  // Sort: Go to School(s) first, then Return from School(s)
  scheduledTrips.sort((a, b) {
    if (a.tripType.contains('Go') && !b.tripType.contains('Go')) return -1;
    if (!a.tripType.contains('Go') && b.tripType.contains('Go')) return 1;
    return 0;
  });

  return scheduledTrips.first;
}
