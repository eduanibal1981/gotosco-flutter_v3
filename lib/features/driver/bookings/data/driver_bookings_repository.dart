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
      // Get all bookings ordered by created_at (newest first)
      final response = await _supabase
          .from('bookings')
          .select()
          .eq('driver_id', _driverId)
          .order('created_at', ascending: false);

      final bookings = <BookingModel>[];

      for (var booking in response) {
        // Fetch Parent Info
        final parent = await _supabase
            .from('users')
            .select('full_name, photo_url, phone')
            .eq('id', booking['parent_id'])
            .maybeSingle();

        // Fetch Children
        final childLinks = await _supabase
            .from('booking_children')
            .select('child_id')
            .eq('booking_id', booking['id']);

        final childIds = (childLinks as List)
            .map((c) => c['child_id'])
            .toList();

        List<Map<String, dynamic>> childrenData = [];
        if (childIds.isNotEmpty) {
          childrenData = await _supabase
              .from('children')
              .select('id, name, school_name, grade')
              .inFilter('id', childIds);
        }

        // Combine Data
        final fullData = {
          ...booking,
          'parent_name': parent?['full_name'],
          'parent_photo': parent?['photo_url'],
          'parent_phone': parent?['phone'],
          'children': childrenData,
        };

        bookings.add(BookingModel.fromMap(fullData));
      }

      return bookings;
    } catch (e) {
      print('Error fetching bookings: $e');
      return [];
    }
  }

  Future<void> acceptBooking(String bookingId) async {
    final response = await _supabase
        .from('bookings')
        .update({'status': 'accepted'})
        .eq('id', bookingId)
        .select();

    if (response.isEmpty) {
      throw Exception('Update failed: No rows affected or permission denied');
    }
  }

  Future<void> rejectBooking(String bookingId) async {
    final response = await _supabase
        .from('bookings')
        .update({'status': 'rejected'})
        .eq('id', bookingId)
        .select();

    if (response.isEmpty) {
      throw Exception('Update failed: No rows affected or permission denied');
    }
  }

  Future<void> deleteBooking(String bookingId) async {
    await _supabase.from('bookings').delete().eq('id', bookingId);
  }
}
