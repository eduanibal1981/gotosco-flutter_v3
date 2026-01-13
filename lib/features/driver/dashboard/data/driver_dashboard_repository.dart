// lib/features/driver/dashboard/data/driver_dashboard_repository.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
Future<Map<String, dynamic>> driverStats(Ref ref) async {
  return ref.watch(driverDashboardRepositoryProvider).getDriverStats();
}

/// Provider for driver's booking requests (pending)
@riverpod
Stream<List<Map<String, dynamic>>> driverBookingRequests(Ref ref) {
  return ref
      .watch(driverDashboardRepositoryProvider)
      .getBookingRequestsStream();
}

/// Provider for driver's enrolled students
@riverpod
Future<List<Map<String, dynamic>>> driverStudents(Ref ref) {
  return ref.watch(driverDashboardRepositoryProvider).getEnrolledStudents();
}

/// Provider for today's trips
@riverpod
Future<List<Map<String, dynamic>>> todaysTrips(Ref ref) {
  return ref.watch(driverDashboardRepositoryProvider).getTodaysTrips();
}

/// Provider for active trip (if any)
@riverpod
Future<Map<String, dynamic>?> activeTrip(Ref ref) {
  return ref.watch(driverDashboardRepositoryProvider).getActiveTrip();
}

/// Provider for the next scheduled trip (Go to School first, then Return)
@riverpod
Future<Map<String, dynamic>?> nextScheduledTrip(Ref ref) async {
  final trips = await ref.watch(todaysTripsProvider.future);
  if (trips.isEmpty) return null;

  // Filter to only scheduled trips (not in_progress or completed)
  final scheduledTrips = trips
      .where((t) => t['status'] == 'scheduled')
      .toList();
  if (scheduledTrips.isEmpty) return null;

  // Sort: Go to School(s) first, then Return from School(s)
  scheduledTrips.sort((a, b) {
    final aType = a['trip_type'] as String? ?? '';
    final bType = b['trip_type'] as String? ?? '';
    if (aType.contains('Go') && !bType.contains('Go')) return -1;
    if (!aType.contains('Go') && bType.contains('Go')) return 1;
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
      return response;
    } catch (e) {
      return null;
    }
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
  /// Required: vehicle_type, vehicle_number, vehicle_capacity, license_number, AND at least one schedule
  Future<bool> isProfileComplete(Map<String, dynamic> profile) async {
    // Check vehicle details
    final hasVehicleType =
        profile['vehicle_type'] != null &&
        (profile['vehicle_type'] as String).isNotEmpty;
    final hasVehicleNumber =
        profile['vehicle_number'] != null &&
        (profile['vehicle_number'] as String).isNotEmpty;
    final hasVehicleCapacity =
        profile['vehicle_capacity'] != null &&
        (profile['vehicle_capacity'] as int) > 0;

    // Check driver license
    final hasLicenseNumber =
        profile['license_number'] != null &&
        (profile['license_number'] as String).isNotEmpty;

    // Check schedules - driver must have at least one active schedule
    final hasSchedule = await hasSchedules();

    return hasVehicleType &&
        hasVehicleNumber &&
        hasVehicleCapacity &&
        hasLicenseNumber &&
        hasSchedule;
  }

  /// Determine the current dashboard state
  Future<DriverDashboardState> getDashboardState() async {
    // 1. Check for driver profile existence
    final profile = await getDriverProfile();
    if (profile == null) {
      return DriverDashboardState.noProfile;
    }

    // 2. Check if profile is complete (has all required fields + schedule)
    final profileComplete = await isProfileComplete(profile);
    if (!profileComplete) {
      return DriverDashboardState.profileIncomplete;
    }

    // 3. Check for active trip
    final activeTrip = await getActiveTrip();
    if (activeTrip != null) {
      return DriverDashboardState.activeTrip;
    }

    // 4. Check for today's trips
    final todaysTrips = await getTodaysTrips();
    if (todaysTrips.isNotEmpty) {
      return DriverDashboardState.hasTrips;
    }

    // 5. Check for pending requests
    final stats = await getDriverStats();
    if ((stats['pending_requests'] as int) > 0) {
      return DriverDashboardState.hasRequests;
    }

    // 6. Default: Profile only (complete but no bookings)
    return DriverDashboardState.profileOnly;
  }

  /// Get driver stats: active students, pending requests, monthly earnings
  Future<Map<String, dynamic>> getDriverStats() async {
    try {
      // 1. Get all accepted bookings to calculate earnings and get booking IDs
      final acceptedBookings = await _supabase
          .from('bookings')
          .select('id, price')
          .eq('driver_id', _driverId)
          .eq('status', 'accepted');

      // 2. Get unique children count across all accepted bookings
      final acceptedBookingIds = (acceptedBookings as List)
          .map((b) => b['id'])
          .toList();
      int uniqueStudents = 0;
      if (acceptedBookingIds.isNotEmpty) {
        final children = await _supabase
            .from('booking_children')
            .select('child_id')
            .inFilter('booking_id', acceptedBookingIds);

        // Use a set to count unique child IDs
        final uniqueChildIds = (children as List)
            .map((c) => c['child_id'])
            .toSet();
        uniqueStudents = uniqueChildIds.length;
      }

      // 3. Get pending requests count
      final pendingCount = await _supabase
          .from('bookings')
          .select('id')
          .eq('driver_id', _driverId)
          .eq('status', 'pending');

      final int pendingRequests = (pendingCount as List).length;

      // 4. Calculate total monthly earnings (sum of price of accepted bookings)
      double totalEarnings = 0;
      for (var booking in acceptedBookings) {
        totalEarnings += (booking['price'] as num?)?.toDouble() ?? 0;
      }

      return {
        'active_students': uniqueStudents,
        'pending_requests': pendingRequests,
        'active_bookings': acceptedBookings.length,
        'monthly_earnings': totalEarnings.toInt(),
      };
    } catch (e) {
      print('Error in getDriverStats: $e');
      return {
        'active_students': 0,
        'pending_requests': 0,
        'active_bookings': 0,
        'monthly_earnings': 0,
      };
    }
  }

  /// Get today's trips
  Future<List<Map<String, dynamic>>> getTodaysTrips() async {
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    try {
      // First, check ALL trips for this driver (diagnostic)
      final allTrips = await _supabase
          .from('trips')
          .select('id, trip_date, trip_type, status')
          .eq('driver_id', _driverId);
      print('DEBUG getTodaysTrips: ALL trips for driver: $allTrips');

      // Now get today's trips
      final trips = await _supabase
          .from('trips')
          .select(
            '*, route_stops(*, children(name), bookings(hometxt_location, schooltxt_location))',
          )
          .eq('driver_id', _driverId)
          .eq('trip_date', todayStr)
          .order('trip_type');

      print('DEBUG getTodaysTrips: Found ${trips.length} trips for $todayStr');
      return List<Map<String, dynamic>>.from(trips);
    } catch (e) {
      print('DEBUG getTodaysTrips error: $e');
      return [];
    }
  }

  /// Get active trip (status = 'in_progress')
  Future<Map<String, dynamic>?> getActiveTrip() async {
    try {
      final trip = await _supabase
          .from('trips')
          .select(
            '*, route_stops(*, children(name), bookings(hometxt_location, schooltxt_location))',
          )
          .eq('driver_id', _driverId)
          .eq('status', 'in_progress')
          .maybeSingle();
      return trip;
    } catch (e) {
      return null;
    }
  }

  /// Generate all daily trips using database RPC functions
  /// Calls both generate_go_trips and generate_return_trips
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
      print('DEBUG generateGoTrips: Calling RPC for driver $_driverId');
      final result = await _supabase.rpc(
        'generate_go_trips',
        params: {
          'target_date': todayStr, // Add target_date back
          'target_driver_id': _driverId,
        },
      );
      print('DEBUG generateGoTrips: RPC completed, result: $result');
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

  /// Delete today's trips for the current driver
  Future<bool> deleteTodaysTrips() async {
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    try {
      // First delete route_stops for today's trips
      final trips = await _supabase
          .from('trips')
          .select('id')
          .eq('driver_id', _driverId)
          .eq('trip_date', todayStr);

      for (final trip in trips) {
        await _supabase.from('route_stops').delete().eq('trip_id', trip['id']);
      }

      // Then delete the trips
      await _supabase
          .from('trips')
          .delete()
          .eq('driver_id', _driverId)
          .eq('trip_date', todayStr);

      print('DEBUG deleteTodaysTrips: Deleted ${trips.length} trips');
      return true;
    } catch (e) {
      print('Error deleting trips: $e');
      return false;
    }
  }

  /// Delete and regenerate today's trips
  Future<Map<String, bool>> regenerateDailyTrips() async {
    final deleteSuccess = await deleteTodaysTrips();
    if (!deleteSuccess) {
      return {'delete': false, 'go': false, 'return': false};
    }

    final goSuccess = await generateGoTrips();
    final returnSuccess = await generateReturnTrips();

    return {'delete': true, 'go': goSuccess, 'return': returnSuccess};
  }

  /// Start a trip (update status to in_progress)
  Future<void> startTrip(String tripId, {double? lat, double? lng}) async {
    await _supabase.rpc(
      'start_trip',
      params: {'trip_id_input': tripId, 'driver_lat': lat, 'driver_lng': lng},
    );
  }

  /// End a trip (update status to completed)
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
    await _supabase.rpc(
      'process_stop',
      params: {
        'stop_id_input': stopId,
        'action': 'arrived',
        'driver_lat': lat,
        'driver_lng': lng,
      },
    );
  }

  /// Update sequence order for a list of stops
  Future<void> updateStopSequences(
    List<Map<String, dynamic>> updatedStops,
  ) async {
    // Extract only id and sequence_order to avoid overwriting other fields
    final payload = updatedStops
        .map(
          (s) => {
            'id': s['id'],
            'sequence_order': s['sequence_order'],
            // We also need other required fields?
            // No, for update (upsert on id), partial is usually fine
            // BUT to be safe given constraints, let's hope it's a PATCH.
            // Actually standard upsert replaces.
            // Better to use a specific RPC or just use .update() in a loop?
            // No, let's use upsert with specific columns.
          },
        )
        .toList();

    // Use RPC to avoid RLS issues with upsert
    await _supabase.rpc('update_route_order', params: {'updates': payload});
  }

  /// Save current trip order as default for future trips
  Future<void> saveTripOrderAsDefault(String tripId) async {
    await _supabase.rpc(
      'save_trip_order_as_default',
      params: {'trip_id_input': tripId},
    );
  }

  /// Process stop action (picked_up, dropped_off, skipped, reset)
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
        .update({'is_online': isOnline})
        .eq('user_id', _driverId);
  }

  /// Stream of pending booking requests
  Stream<List<Map<String, dynamic>>> getBookingRequestsStream() {
    // We use select with joins to get parent and children in one go
    // Note: booking_children join might need to be handled carefully in stream
    // For simplicity and correctness with Supabase Stream, we'll keep the enrichment
    // but use safer fetching (maybeSingle or join)
    return _supabase
        .from('bookings')
        .stream(primaryKey: ['id'])
        .eq('driver_id', _driverId)
        .order('created_at', ascending: false)
        .asyncMap((bookings) async {
          final enriched = <Map<String, dynamic>>[];
          for (var booking in bookings) {
            try {
              // Get parent info - use maybeSingle to avoid PGRST116
              final parent = await _supabase
                  .from('users')
                  .select('full_name, photo_url, phone')
                  .eq('id', booking['parent_id'] ?? '')
                  .maybeSingle();

              // Get children for this booking using a join
              final childrenData = await _supabase
                  .from('booking_children')
                  .select('children(*)')
                  .eq('booking_id', booking['id']);

              final children = (childrenData as List)
                  .map((c) => c['children'] as Map<String, dynamic>)
                  .toList();

              enriched.add({
                ...booking,
                'parent_name': parent?['full_name'] ?? 'Unknown Parent',
                'parent_photo': parent?['photo_url'],
                'parent_phone': parent?['phone'] ?? '',
                'children': children,
                // Compatibility mapping
                'home_location': booking['hometxt_location'],
                'school_location': booking['schooltxt_location'],
              });
            } catch (e) {
              print('Error enriching booking ${booking['id']}: $e');
              // Add without enrichment if it fails
              enriched.add(booking);
            }
          }
          return enriched;
        });
  }

  /// Get all enrolled students (children from accepted bookings)
  Future<List<Map<String, dynamic>>> getEnrolledStudents() async {
    try {
      // Use efficient join query
      final response = await _supabase
          .from('bookings')
          .select(
            '*, parent:users(full_name, phone), children_links:booking_children(child:children(*))',
          )
          .eq('driver_id', _driverId)
          .eq('status', 'accepted');

      final students = <Map<String, dynamic>>[];
      final seenChildIds = <String>{};

      for (var booking in response as List) {
        final parent = booking['parent'] as Map<String, dynamic>?;
        final childrenLinks = booking['children_links'] as List? ?? [];

        for (var link in childrenLinks) {
          final child = link['child'] as Map<String, dynamic>?;
          if (child != null && !seenChildIds.contains(child['id'])) {
            seenChildIds.add(child['id']);
            students.add({
              ...child,
              'parent_name': parent?['full_name'] ?? 'Unknown Parent',
              'parent_phone': parent?['phone'] ?? '',
              'booking_id': booking['id'],
              'home_location': booking['hometxt_location'],
              'school_location': booking['schooltxt_location'],
            });
          }
        }
      }

      return students;
    } catch (e) {
      print('Error in getEnrolledStudents: $e');
      // If the join query fails (perhaps due to schema mismatch), fall back to safe loop
      return _getEnrolledStudentsFallback();
    }
  }

  Future<List<Map<String, dynamic>>> _getEnrolledStudentsFallback() async {
    final bookings = await _supabase
        .from('bookings')
        .select()
        .eq('driver_id', _driverId)
        .eq('status', 'accepted');

    final students = <Map<String, dynamic>>[];
    final seenChildIds = <String>{};

    for (var booking in bookings) {
      try {
        final parent = await _supabase
            .from('users')
            .select('full_name, phone')
            .eq('id', booking['parent_id'] ?? '')
            .maybeSingle();

        final childLinks = await _supabase
            .from('booking_children')
            .select('child_id')
            .eq('booking_id', booking['id']);

        for (var link in childLinks) {
          final child = await _supabase
              .from('children')
              .select()
              .eq('id', link['child_id'] ?? '')
              .maybeSingle();

          if (child != null && !seenChildIds.contains(child['id'])) {
            seenChildIds.add(child['id']);
            students.add({
              ...child,
              'parent_name': parent?['full_name'] ?? 'Unknown Parent',
              'parent_phone': parent?['phone'] ?? '',
              'booking_id': booking['id'],
              'home_location': booking['hometxt_location'],
              'school_location': booking['schooltxt_location'],
            });
          }
        }
      } catch (e) {
        print('Error in fallback for booking ${booking['id']}: $e');
      }
    }

    return students;
  }

  /// Accept a booking request
  Future<void> acceptBooking(String bookingId) async {
    await _supabase
        .from('bookings')
        .update({'status': 'accepted'})
        .eq('id', bookingId);
  }

  /// Reject a booking request
  Future<void> rejectBooking(String bookingId) async {
    await _supabase
        .from('bookings')
        .update({'status': 'rejected'})
        .eq('id', bookingId);
  }
}
