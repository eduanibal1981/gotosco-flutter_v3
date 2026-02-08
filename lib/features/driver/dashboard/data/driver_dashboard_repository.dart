// lib/features/driver/dashboard/data/driver_dashboard_repository.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/driver_stats_model.dart';
import 'models/driver_trip_model.dart';
import '../../transport_requests/data/models/driver_request_model.dart';

part 'driver_dashboard_repository.g.dart';

@riverpod
DriverDashboardRepository driverDashboardRepository(Ref ref) {
  return DriverDashboardRepository(Supabase.instance.client);
}

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

/// Enum for dashboard states
enum DriverDashboardState {
  noProfile, // State 1: No driver profile record
  profileIncomplete, // State 2: Profile exists but required fields missing
  profileOnly, // State 3: Has complete profile but no bookings
  hasRequests, // State 4: Has pending requests
  hasTrips, // State 5: Has scheduled trips
  activeTrip, // State 6: Trip in progress
}

class DriverDashboardRepository {
  final SupabaseClient _supabase;
  DriverDashboardRepository(this._supabase);

  String get _driverId => _supabase.auth.currentUser!.id;

  /// Check if driver has a profile in drivers table
  Future<Map<String, dynamic>?> getDriverProfile() async {
    try {
      final response = await _supabase
          .from('drivers')
          .select()
          .eq('user_id', _driverId)
          .maybeSingle();
      if (response == null) return null;
      final coverage = await _getCoverageNames();
      return {
        ...response,
        'service_areas': coverage['areas'],
        'schools': coverage['schools'],
      };
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, List<String>>> _getCoverageNames() async {
    final serviceAreas = <String>[];
    final schools = <String>[];

    try {
      final areaRows = await _supabase
          .from('driver_service_areas')
          .select('area:areas(name)')
          .eq('driver_id', _driverId);
      for (final row in areaRows as List) {
        final area = row['area'] as Map<String, dynamic>?;
        final name = area?['name'] as String?;
        if (name != null && name.trim().isNotEmpty) {
          serviceAreas.add(name);
        }
      }
    } catch (e) {
      print('Error loading driver service areas: $e');
    }

    try {
      final schoolRows = await _supabase
          .from('driver_covered_schools')
          .select('school:schools(name)')
          .eq('driver_id', _driverId);
      for (final row in schoolRows as List) {
        final school = row['school'] as Map<String, dynamic>?;
        final name = school?['name'] as String?;
        if (name != null && name.trim().isNotEmpty) {
          schools.add(name);
        }
      }
    } catch (e) {
      print('Error loading driver covered schools: $e');
    }

    return {'areas': serviceAreas, 'schools': schools};
  }

  /// Check if driver has at least one active schedule
  Future<bool> hasSchedules() async {
    try {
      final response = await _supabase
          .from('driver_schedules')
          .select('id')
          .eq('driver_id', _driverId)
          .eq('is_active', true)
          .limit(1);

      return (response as List).isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Check if driver profile has all required fields filled
  Future<bool> isProfileComplete(Map<String, dynamic> profile) async {
    final hasVehicleType =
        profile['vehicle_type'] != null &&
        (profile['vehicle_type'] as String).isNotEmpty;
    final hasVehicleNumber =
        profile['vehicle_number'] != null &&
        (profile['vehicle_number'] as String).isNotEmpty;
    final hasVehicleCapacity =
        profile['vehicle_capacity'] != null &&
        (profile['vehicle_capacity'] as int) > 0;
    final hasLicenseNumber =
        profile['license_number'] != null &&
        (profile['license_number'] as String).isNotEmpty;
    final hasLicenseImage =
        profile['license_image_url'] != null &&
        (profile['license_image_url'] as String).isNotEmpty;
    final hasMulkiaImage =
        profile['mulkia_image_url'] != null &&
        (profile['mulkia_image_url'] as String).isNotEmpty;

    return hasVehicleType &&
        hasVehicleNumber &&
        hasVehicleCapacity &&
        hasLicenseNumber &&
        hasLicenseImage &&
        hasMulkiaImage;
  }

  /// Determine the current dashboard state
  Future<DriverDashboardState> getDashboardState() async {
    final profile = await getDriverProfile();
    if (profile == null) {
      return DriverDashboardState.noProfile;
    }

    final profileComplete = await isProfileComplete(profile);
    if (!profileComplete) {
      return DriverDashboardState.profileIncomplete;
    }

    final activeTrip = await getActiveTrip();
    if (activeTrip != null) {
      return DriverDashboardState.activeTrip;
    }

    final todaysTrips = await getTodaysTrips();
    if (todaysTrips.isNotEmpty) {
      return DriverDashboardState.hasTrips;
    }

    final stats = await getDriverStats();
    if (stats.pendingRequests > 0) {
      return DriverDashboardState.hasRequests;
    }

    return DriverDashboardState.profileOnly;
  }

  /// Get driver stats from driver_stats_view
  Future<DriverStats> getDriverStats() async {
    try {
      final response = await _supabase
          .from('driver_stats_view')
          .select()
          .eq('driver_id', _driverId)
          .maybeSingle();

      if (response == null) {
        return DriverStats(driverId: _driverId);
      }
      return DriverStats.fromJson(response);
    } catch (e) {
      print('Error in getDriverStats: $e');
      return DriverStats(driverId: _driverId);
    }
  }

  /// Get today's trips from driver_trips_view
  Future<List<DriverTrip>> getTodaysTrips() async {
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    try {
      final trips = await _supabase
          .from('driver_trips_view')
          .select()
          .eq('driver_id', _driverId)
          .eq('trip_date', todayStr)
          .order('trip_type');

      return (trips as List).map((t) => DriverTrip.fromJson(t)).toList();
    } catch (e) {
      print('DEBUG getTodaysTrips error: $e');
      return [];
    }
  }

  /// Get active trip from driver_trips_view
  Future<DriverTrip?> getActiveTrip() async {
    try {
      final trip = await _supabase
          .from('driver_trips_view')
          .select()
          .eq('driver_id', _driverId)
          .eq('status', 'in_progress')
          .maybeSingle();

      if (trip == null) return null;
      return DriverTrip.fromJson(trip);
    } catch (e) {
      return null;
    }
  }

  /// Generate all daily trips using database RPC functions
  Future<Map<String, bool>> generateDailyTrips() async {
    final goSuccess = await generateGoTrips();
    final returnSuccess = await generateReturnTrips();
    return {'go': goSuccess, 'return': returnSuccess};
  }

  /// Generate "Go to School(s)" trips for today
  Future<bool> generateGoTrips() async {
    try {
      final today = DateTime.now();
      final todayStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      await _supabase.rpc(
        'generate_go_trips',
        params: {'target_date': todayStr, 'target_driver_id': _driverId},
      );
      return true;
    } catch (e) {
      print('DEBUG generateGoTrips ERROR: $e');
      return false;
    }
  }

  /// Generate "Return from School(s)" trips for today
  Future<bool> generateReturnTrips() async {
    try {
      final today = DateTime.now();
      final todayStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      await _supabase.rpc(
        'generate_return_trips',
        params: {'target_date': todayStr, 'target_driver_id': _driverId},
      );
      return true;
    } catch (e) {
      print('Error generating Return trips: $e');
      return false;
    }
  }

  /// Delete today's trips
  Future<bool> deleteTodaysTrips() async {
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    try {
      // Manual delete logic for dependencies if RPC doesn't handle it
      // But assuming we want to use direct delete if allowed
      final trips = await _supabase
          .from('trips')
          .select('id')
          .eq('driver_id', _driverId)
          .eq('trip_date', todayStr);

      for (final trip in trips) {
        await _supabase.from('route_stops').delete().eq('trip_id', trip['id']);
      }

      await _supabase
          .from('trips')
          .delete()
          .eq('driver_id', _driverId)
          .eq('trip_date', todayStr);

      return true;
    } catch (e) {
      print('Error deleting trips: $e');
      return false;
    }
  }

  /// Delete and regenerate today's trips
  Future<Map<String, bool>> regenerateDailyTrips() async {
    try {
      final today = DateTime.now();
      final todayStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      await _supabase.rpc(
        'regenerate_daily_trips',
        params: {'target_date': todayStr},
      );

      return {'delete': true, 'go': true, 'return': true};
    } catch (e) {
      print('Error regenerating trips: $e');
      return {'delete': false, 'go': false, 'return': false};
    }
  }

  /// Start a trip
  Future<void> startTrip(String tripId, {double? lat, double? lng}) async {
    await _supabase.rpc(
      'start_trip',
      params: {'trip_id_input': tripId, 'driver_lat': lat, 'driver_lng': lng},
    );
  }

  /// End a trip
  Future<void> endTrip(String tripId, {double? lat, double? lng}) async {
    await _supabase.rpc(
      'complete_trip',
      params: {'trip_id_input': tripId, 'driver_lat': lat, 'driver_lng': lng},
    );
  }

  /// Mark a stop as arrived
  Future<void> markStopArrived(
    String stopId, {
    double? lat,
    double? lng,
  }) async {
    await processStop(stopId, 'arrived', lat: lat, lng: lng);
  }

  /// Update sequence order for a list of stops
  Future<void> updateStopSequences(
    List<Map<String, dynamic>> updatedStops,
  ) async {
    final payload = updatedStops
        .map((s) => {'id': s['id'], 'sequence_order': s['sequence_order']})
        .toList();

    await _supabase.rpc('update_route_order', params: {'updates': payload});
  }

  /// Save current trip order as default
  Future<void> saveTripOrderAsDefault(String tripId) async {
    await _supabase.rpc(
      'save_trip_order_as_default',
      params: {'trip_id_input': tripId},
    );
  }

  /// Process stop action
  Future<void> processStop(
    String stopId,
    String action, {
    double? lat,
    double? lng,
  }) async {
    await _supabase.rpc(
      'process_stop',
      params: {
        'stop_id_input': stopId,
        'action': action,
        'driver_lat': lat,
        'driver_lng': lng,
      },
    );
  }

  /// Toggle driver online status
  Future<void> setOnlineStatus(bool isOnline) async {
    await _supabase
        .from('drivers')
        .update({'is_profile_online': isOnline})
        .eq('user_id', _driverId);
  }

  /// Stream of pending booking requests using driver_requests_view
  Stream<List<DriverRequest>> getBookingRequestsStream() {
    return _supabase
        .from('driver_requests_view')
        .stream(primaryKey: ['id'])
        .eq('driver_id', _driverId)
        .order('created_at', ascending: false)
        .map(
          (data) => data.map((json) => DriverRequest.fromJson(json)).toList(),
        )
        .map(
          (requests) => requests.where((r) => r.status == 'pending').toList(),
        );
  }

  /// Get all enrolled students using driver_requests_view
  Future<List<Map<String, dynamic>>> getEnrolledStudents() async {
    try {
      final requests = await _supabase
          .from('driver_requests_view')
          .select()
          .eq('driver_id', _driverId)
          .inFilter('status', ['accepted', 'confirmed', 'active']);

      final students = <Map<String, dynamic>>[];
      for (final requestJson in requests) {
        final request = DriverRequest.fromJson(requestJson);
        // Flatten students info
        for (final studentInfo in request.studentsInfo) {
          // We map it to the expected structure
          // Legacy structure: {id, name, parent_name, parent_phone, booking_id, home_location, school_location, ...}
          students.add({
            ...studentInfo,
            'id': studentInfo['id'],
            'name': studentInfo['name'],
            'parent_name': request.parentName,
            'parent_phone': request.parentPhone,
            'parent_photo': request.parentPhoto,
            'booking_id': request.id,
            'home_location': request.homeLocation,
            'school_location': request.schoolLocation,
            // Add other fields if needed
          });
        }
      }
      return students;
    } catch (e) {
      print('Error in getEnrolledStudents: $e');
      return [];
    }
  }

  // Accept/Reject methods
  Future<void> acceptBooking(String bookingId) async {
    await _supabase
        .from('bookings')
        .update({'status': 'confirmed', 'subscription_status': 'active'})
        .eq('id', bookingId);
  }

  Future<void> rejectBooking(String bookingId) async {
    await _supabase
        .from('bookings')
        .update({'status': 'rejected'})
        .eq('id', bookingId);
  }
}
