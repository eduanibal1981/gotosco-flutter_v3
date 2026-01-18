import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'bookings_repository.g.dart';

@riverpod
BookingsRepository bookingsRepository(Ref ref) {
  return BookingsRepository(Supabase.instance.client);
}

@riverpod
Stream<List<Map<String, dynamic>>> myBookings(Ref ref) {
  return ref.watch(bookingsRepositoryProvider).getBookingsStream();
}

class BookingsRepository {
  final SupabaseClient _supabase;
  BookingsRepository(this._supabase);

  // Updated Create Method
  Future<void> createBooking({
    required String driverId,
    required List<String> childIds,
    required String bookingType,
    String? homeLocation,
    String? schoolLocation,
    // Add these params
    double? homeLat,
    double? homeLng,
    double? schoolLat,
    double? schoolLng,
    TimeOfDay? homePickupTime,
    TimeOfDay? schoolPickupTime,
    String? notes,
  }) async {
    final userId = _supabase.auth.currentUser!.id;

    // Helper to format TimeOfDay to "HH:mm" string
    String? formatTime(TimeOfDay? time) {
      if (time == null) return null;
      final hour = time.hour.toString().padLeft(2, '0');
      final minute = time.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }

    // 1. Insert Booking
    final bookingData = await _supabase
        .from('bookings')
        .insert({
          'parent_id': userId,
          'driver_id': driverId,
          'status': 'pending',
          'booking_type': bookingType,
          'hometxt_location': homeLocation,
          'schooltxt_location': schoolLocation,
          // Use SRID 4326 for WGS 84
          if (homeLat != null && homeLng != null)
            'homegeo_location': 'SRID=4326;POINT($homeLng $homeLat)',
          if (schoolLat != null && schoolLng != null)
            'schoolgeo_location': 'SRID=4326;POINT($schoolLng $schoolLat)',
          // 'home_lat': homeLat, // GENERATED COLUMN
          // 'home_lng': homeLng, // GENERATED COLUMN
          // 'school_lat': schoolLat, // GENERATED COLUMN
          // 'school_lng': schoolLng, // GENERATED COLUMN
          'home_pickup_time': formatTime(homePickupTime),
          'school_pickup_time': formatTime(schoolPickupTime),
          'notes': notes,
          // price is omitted, so it will be null
        })
        .select()
        .single();

    final bookingId = bookingData['id'] as String;

    // 2. Link Children
    if (childIds.isNotEmpty) {
      final childrenMap = childIds
          .map((childId) => {'booking_id': bookingId, 'child_id': childId})
          .toList();

      await _supabase.from('booking_children').insert(childrenMap);
    }
  }

  /// Cancels a booking by updating its status to 'cancelled'.
  Future<void> cancelBooking(String bookingId) async {
    await _supabase
        .from('bookings')
        .update({'status': 'cancelled'})
        .eq('id', bookingId);
  }

  /// Permanently deletes a booking.
  /// Note: This might fail if there are related payments or other constrained records.
  Future<void> deleteBooking(String bookingId) async {
    await _supabase.from('bookings').delete().eq('id', bookingId);
  }

  Stream<List<Map<String, dynamic>>> getBookingsStream() {
    final userId = _supabase.auth.currentUser!.id;
    // Note: Supabase Realtime doesn't directly support RPC calls.
    // So, we're combining a Realtime stream on the 'bookings' table
    // with an efficient initial data fetch and subsequent fetches using our RPC.
    return _supabase
        .from('bookings')
        .stream(primaryKey: ['id'])
        .eq('parent_id', userId)
        .asyncMap((_) {
      // When the stream notifies of a change, we re-fetch the whole enriched list.
      // This is more efficient than the N+1 problem.
      return _supabase
          .rpc('get_enriched_bookings')
          .then((value) => (value as List).cast<Map<String, dynamic>>());
    });
  }
}
