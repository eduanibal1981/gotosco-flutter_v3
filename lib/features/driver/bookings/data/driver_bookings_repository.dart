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
          // Ignore parent fetch errors to avoid empty bookings list.
        }
      }

      final bookings = bookingsRaw.map((booking) {
        final parentId = booking['parent_id'] as String?;
        final parent = parentId != null ? parentMap[parentId] : null;
        final childrenData = childrenMap[booking['id'] as String] ?? [];

        // Combine Data
        final fullData = <String, dynamic>{
          ...booking,
          'parent_name': parent?['full_name'],
          'parent_photo': parent?['photo_url'],
          'parent_phone': parent?['phone'],
          'children': childrenData,
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
