// lib/features/driver/bookings/data/driver_bookings_repository.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/models/driver_booking_model.dart';

// Keep old import for backward compatibility during migration
import '../domain/models/booking_model.dart';

part 'driver_bookings_repository.g.dart';

@riverpod
DriverBookingsRepository driverBookingsRepository(Ref ref) {
  return DriverBookingsRepository(Supabase.instance.client);
}

/// Legacy provider - returns old BookingModel for backward compatibility
@riverpod
Future<List<BookingModel>> driverBookings(Ref ref) {
  return ref.watch(driverBookingsRepositoryProvider).getAllBookingsLegacy();
}

/// ✅ NEW: Typed provider - returns Freezed DriverBooking models
@riverpod
Future<List<DriverBooking>> driverBookingsTyped(Ref ref) {
  return ref.watch(driverBookingsRepositoryProvider).getAllBookings();
}

class DriverBookingsRepository {
  final SupabaseClient _supabase;

  DriverBookingsRepository(this._supabase);

  String get _driverId => _supabase.auth.currentUser!.id;

  /// ✅ HYBRID: Fetches typed DriverBooking models
  Future<List<DriverBooking>> getAllBookings() async {
    try {
      final hasProfile = await _assertDriverProfile();
      if (!hasProfile) return [];

      // 1) Fetch bookings
      final response = await _supabase
          .from('bookings')
          .select('*')
          .eq('driver_id', _driverId)
          .order('created_at', ascending: false);

      final bookingsRaw = List<Map<String, dynamic>>.from(response as List);
      if (bookingsRaw.isEmpty) return [];

      // 2) Fetch children for all bookings in one query
      final bookingIds = bookingsRaw.map((b) => b['id'] as String).toList();
      final childrenLinks = await _supabase
          .from('booking_children')
          .select(
            'booking_id, children(id, name, school_name, grade, age, gender)',
          )
          .inFilter('booking_id', bookingIds);

      final childrenMap = <String, List<BookingChild>>{};
      for (final link in (childrenLinks as List)) {
        final bookingId = link['booking_id'] as String?;
        final childData = link['children'] as Map<String, dynamic>?;
        if (bookingId == null || childData == null) continue;
        childrenMap
            .putIfAbsent(bookingId, () => [])
            .add(BookingChild.fromJson(childData));
      }

      // 3) Fetch parent profiles
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
          // Ignore parent fetch errors (RLS)
        }
      }

      // 4) Fetch related schools
      final schoolLinks = await _supabase
          .from('booking_schools')
          .select('booking_id, school_id')
          .inFilter('booking_id', bookingIds);

      final singleSchoolIds = bookingsRaw
          .map((b) => b['school_id'] as String?)
          .whereType<String>()
          .toSet();

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

      // 5) Build typed DriverBooking models
      final bookings = bookingsRaw.map((booking) {
        final parentId = booking['parent_id'] as String?;
        final parent = parentId != null ? parentMap[parentId] : null;
        final bookingId = booking['id'] as String;
        final children = childrenMap[bookingId] ?? [];

        // Resolve school location data
        var schoolLocation = booking['schooltxt_location'] as String?;
        var schoolLat = booking['school_lat'];
        var schoolLng = booking['school_lng'];

        final linkedSchools = (schoolLinks as List)
            .where((link) => link['booking_id'] == bookingId)
            .map((link) => schoolMap[link['school_id'] as String])
            .whereType<Map<String, dynamic>>()
            .toList();

        final singleSchoolId = booking['school_id'] as String?;
        final singleSchool = singleSchoolId != null
            ? schoolMap[singleSchoolId]
            : null;

        List<String>? schoolIds;
        String? schoolName;

        if (linkedSchools.isNotEmpty) {
          schoolName = linkedSchools.map((s) => s['name']).join(', ');
          schoolLocation = schoolName;
          schoolIds = linkedSchools.map((s) => s['id'] as String).toList();
          if (schoolLat == null) {
            schoolLat = linkedSchools.first['latitude'];
            schoolLng = linkedSchools.first['longitude'];
          }
        } else if (singleSchool != null) {
          schoolName = singleSchool['name'] as String?;
          if (schoolLocation == null || schoolLocation.isEmpty) {
            schoolLocation = schoolName;
            if (singleSchool['address'] != null) {
              schoolLocation = '$schoolLocation, ${singleSchool['address']}';
            }
          }
          schoolLat ??= singleSchool['latitude'];
          schoolLng ??= singleSchool['longitude'];
          schoolIds = singleSchoolId != null ? [singleSchoolId] : null;
        }

        // Build enriched JSON for Freezed model
        final enrichedData = <String, dynamic>{
          ...booking,
          'parent_name': parent?['full_name'],
          'parent_photo': parent?['photo_url'],
          'parent_phone': parent?['phone'],
          'children': children.map((c) => c.toJson()).toList(),
          'schooltxt_location': schoolLocation ?? '',
          'school_lat': (schoolLat as num?)?.toDouble(),
          'school_lng': (schoolLng as num?)?.toDouble(),
          'school_ids': schoolIds,
          'school_name': schoolName,
        };

        return DriverBooking.fromJson(enrichedData);
      }).toList();

      return bookings;
    } catch (e) {
      print('Error fetching bookings: $e');
      rethrow;
    }
  }

  /// Legacy method - returns old BookingModel for backward compatibility
  Future<List<BookingModel>> getAllBookingsLegacy() async {
    final typedBookings = await getAllBookings();
    return typedBookings
        .map((b) => BookingModel.fromMap(b.toLegacyMap()))
        .toList();
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
