// lib/features/driver/bookings/data/driver_bookings_repository.dart
import 'package:gotosco_v3/features/driver/bookings/data/booking_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'driver_bookings_repository.g.dart';

@riverpod
DriverBookingsRepository driverBookingsRepository(Ref ref) {
  return DriverBookingsRepository(Supabase.instance.client);
}

@riverpod
Future<List<BookingModel>> driverBookings(Ref ref) {
  return ref.watch(driverBookingsRepositoryProvider).getAllBookings();
}

class DriverBookingsRepository {
  final SupabaseClient _supabase;

  DriverBookingsRepository(this._supabase);

  String get _driverId => _supabase.auth.currentUser!.id;

  /// Get all bookings for the current driver
  Future<List<BookingModel>> getAllBookings() async {
    try {
      final hasProfile = await _assertDriverProfile();
      if (!hasProfile) return [];

      // 1) Fetch bookings without parent join to avoid RLS failure.
      final response = await _supabase
          .from('bookings')
          .select('*')
          .eq('driver_id', _driverId)
          .order('created_at', ascending: false);

      final bookingsRaw = List<Map<String, dynamic>>.from(response as List);
      if (bookingsRaw.isEmpty) return [];

      // 2) Fetch children for bookings in one query.
      final bookingIds = bookingsRaw.map((b) => b['id'] as String).toList();
      final childrenLinks = await _supabase
          .from('booking_children')
          .select('booking_id, children(id, name, school_name, grade)')
          .inFilter('booking_id', bookingIds);

      final childrenMap = <String, List<Map<String, dynamic>>>{};
      for (final link in (childrenLinks as List)) {
        final bookingId = link['booking_id'] as String?;
        final child = link['children'] as Map<String, dynamic>?;
        if (bookingId == null || child == null) continue;
        childrenMap.putIfAbsent(bookingId, () => []).add(child);
      }

      // 3) Try fetching parent profiles; if RLS blocks, proceed without them.
      final parentIds = bookingsRaw
          .map((b) => b['parent_id'] as String?)
          .whereType<String>()
          .toSet()
          .toList();
      Map<String, Map<String, dynamic>> parentMap = {};

      if (parentIds.isNotEmpty) {
        try {
          final parents = await _supabase
              .from('users')
              .select('id, full_name, photo_url, phone')
              .inFilter('id', parentIds);
          parentMap = {
            for (final p in (parents as List))
              p['id'] as String: p as Map<String, dynamic>,
          };
        } catch (_) {
          // Ignore parent fetch errors
        }
      }

      // 4) Fetch related schools using ROBUST junction table pattern
      // bookingIds is already defined above at step 2

      // Fetch links from booking_schools junction table
      final schoolLinks = await _supabase
          .from('booking_schools')
          .select('booking_id, school_id')
          .inFilter('booking_id', bookingIds);

      // Also collect single school_id from bookings table for backwards compatibility
      final singleSchoolIds = bookingsRaw
          .map((b) => b['school_id'] as String?)
          .whereType<String>()
          .toSet();

      // Combine all unique school IDs to fetch details in one go
      final allSchoolIds =
          (schoolLinks as List)
              .map((link) => link['school_id'] as String)
              .toSet()
            ..addAll(singleSchoolIds);

      Map<String, Map<String, dynamic>> schoolMap = {};
      if (allSchoolIds.isNotEmpty) {
        try {
          final schools = await _supabase
              .from('schools')
              .select('id, name, address, latitude, longitude')
              .inFilter('id', allSchoolIds.toList());

          schoolMap = {
            for (final s in (schools as List))
              s['id'] as String: s as Map<String, dynamic>,
          };
        } catch (e) {
          print('Error fetching schools: $e');
        }
      }

      final bookings = bookingsRaw.map((booking) {
        final parentId = booking['parent_id'] as String?;
        final parent = parentId != null ? parentMap[parentId] : null;
        final childrenData = childrenMap[booking['id'] as String] ?? [];

        // RESOLVE SCHOOL LOCATION DATA
        var schoolLocation = booking['schooltxt_location'];
        var schoolLat = booking['school_lat'];
        var schoolLng = booking['school_lng'];

        // 1. Get schools linked via junction table
        final linkedSchools = (schoolLinks as List)
            .where((link) => link['booking_id'] == booking['id'])
            .map((link) => schoolMap[link['school_id'] as String])
            .whereType<Map<String, dynamic>>()
            .toList();

        // 2. Get school linked via single column (fallback/primary)
        final singleSchoolId = booking['school_id'] as String?;
        final singleSchool = singleSchoolId != null
            ? schoolMap[singleSchoolId]
            : null;

        // 3. Logic: If junction table has schools, use them. Else use single school.
        if (linkedSchools.isNotEmpty) {
          // Combine names for text display (e.g. "School A, School B")
          final names = linkedSchools.map((s) => s['name']).join(', ');
          schoolLocation = names;

          // For map pin, simply take first school's coordinates for now.
          // Future: UI should support multiple pins.
          if (schoolLat == null) {
            schoolLat = linkedSchools.first['latitude'];
            schoolLng = linkedSchools.first['longitude'];
          }
        } else if (singleSchool != null) {
          // Fallback to single school logic
          if (schoolLocation == null ||
              (schoolLocation is String && schoolLocation.isEmpty)) {
            schoolLocation = singleSchool['name'];
            if (singleSchool['address'] != null &&
                (singleSchool['address'] as String).isNotEmpty) {
              schoolLocation = '$schoolLocation, ${singleSchool['address']}';
            }
          }
          schoolLat ??= singleSchool['latitude'];
          schoolLng ??= singleSchool['longitude'];
        }

        // Combine Data
        final fullData = <String, dynamic>{
          ...booking,
          'parent_name': parent?['full_name'],
          'parent_photo': parent?['photo_url'],
          'parent_phone': parent?['phone'],
          'children': childrenData,
          // Inject Smart School Data
          'schooltxt_location': schoolLocation,
          'school_lat': schoolLat,
          'school_lng': schoolLng,
          // Inject school IDs for specific handling if needed
          'school_ids': linkedSchools.isNotEmpty
              ? linkedSchools.map((s) => s['id']).toList()
              : (singleSchoolId != null ? [singleSchoolId] : []),
        };

        return BookingModel.fromMap(fullData);
      }).toList();

      return bookings;
    } catch (e) {
      print('Error fetching bookings: $e');
      rethrow;
    }
  }

  Future<void> acceptBooking(String bookingId) async {
    final response = await _supabase
        .from('bookings')
        .update({'status': 'confirmed', 'subscription_status': 'active'})
        .eq('id', bookingId)
        .select();

    if (response.isEmpty) {
      throw Exception('Update failed: No rows affected or permission denied');
    }
  }

  Future<void> rejectBooking(String bookingId) async {
    final response = await _supabase
        .from('bookings')
        .update({'status': 'cancelled'})
        .eq('id', bookingId)
        .select();

    if (response.isEmpty) {
      throw Exception('Update failed: No rows affected or permission denied');
    }
  }

  Future<void> deleteBooking(String bookingId) async {
    await _supabase.from('bookings').delete().eq('id', bookingId);
  }

  Future<bool> _assertDriverProfile() async {
    final profile = await _supabase
        .from('drivers')
        .select('user_id')
        .eq('user_id', _driverId)
        .maybeSingle();
    return profile != null;
  }
}
