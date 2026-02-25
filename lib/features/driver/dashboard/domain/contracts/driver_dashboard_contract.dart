import 'package:gotosco_v3/features/driver/transport_requests/domain/models/driver_request_model.dart';
import '../../domain/models/driver_stats_model.dart';
import '../../domain/models/driver_trip_model.dart';

/// Enum for dashboard states
enum DriverDashboardState {
  noProfile, // State 1: No driver profile record
  profileIncomplete, // State 2: Profile exists but required fields missing
  profileOnly, // State 3: Has complete profile but no bookings
  hasRequests, // State 4: Has pending requests
  hasTrips, // State 5: Has scheduled trips
  activeTrip, // State 6: Trip in progress
}

abstract class DriverDashboardContract {
  /// Check if driver has a profile in drivers table
  @Deprecated('Use currentDriverProfileProvider instead')
  Future<Map<String, dynamic>?> getDriverProfile();

  /// Check if driver has at least one active schedule
  Future<bool> hasSchedules();

  /// Determine the current dashboard state
  @Deprecated('Use driverDashboardStateProvider instead')
  Future<DriverDashboardState> getDashboardState();

  /// Get driver stats from driver_stats_view
  Future<DriverStats> getDriverStats();

  /// Get today's trips from driver_trips_view
  Future<List<DriverTrip>> getTodaysTrips();

  /// Get active trip from driver_trips_view
  Future<DriverTrip?> getActiveTrip();

  /// Generate all daily trips using database RPC functions
  Future<Map<String, bool>> generateDailyTrips();

  /// Generate "Go to School(s)" trips for today
  Future<bool> generateGoTrips();

  /// Generate "Return from School(s)" trips for today
  Future<bool> generateReturnTrips();

  /// Delete today's trips
  Future<bool> deleteTodaysTrips();

  /// Delete and regenerate today's trips
  Future<Map<String, bool>> regenerateDailyTrips();

  /// Start a trip
  Future<void> startTrip(String tripId, {double? lat, double? lng});

  /// End a trip
  Future<void> endTrip(String tripId, {double? lat, double? lng});

  /// Mark a stop as arrived
  Future<void> markStopArrived(String stopId, {double? lat, double? lng});

  /// Update sequence order for a list of stops
  Future<void> updateStopSequences(List<Map<String, dynamic>> updatedStops);

  /// Save current trip order as default
  Future<void> saveTripOrderAsDefault(String tripId);

  /// Process stop action
  Future<void> processStop(
    String stopId,
    String action, {
    double? lat,
    double? lng,
  });

  /// Stream of pending booking requests using driver_requests_view
  Stream<List<DriverRequest>> getBookingRequestsStream();

  /// Get all enrolled students using driver_requests_view
  Future<List<Map<String, dynamic>>> getEnrolledStudents();

  /// Accept booking
  Future<void> acceptBooking(String bookingId);

  /// Reject booking
  Future<void> rejectBooking(String bookingId);

  /// Broadcast trip started event for associated bookings
  Future<void> broadcastTripStarted(String tripId, List<String> bookingIds);

  /// Update driver's location periodically
  Future<void> updateDriverLocation({
    required String tripId,
    required double lat,
    required double lng,
    double? heading,
    double? speed,
  });
}
