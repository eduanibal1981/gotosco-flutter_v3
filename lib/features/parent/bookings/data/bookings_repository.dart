import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final bookingsRepositoryProvider = Provider((ref) => BookingsRepository(Supabase.instance.client));
final myBookingsProvider = StreamProvider((ref) => ref.watch(bookingsRepositoryProvider).getBookingsStream());

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
    final bookingData = await _supabase.from('bookings').insert({
      'parent_id': userId,
      'driver_id': driverId,
      'status': 'pending',
      'booking_type': bookingType,
      'home_location': homeLocation,
      'school_location': schoolLocation,
      'home_lat': homeLat,
      'home_lng': homeLng,
      'school_lat': schoolLat,
      'school_lng': schoolLng,
      'home_pickup_time': formatTime(homePickupTime),
      'school_pickup_time': formatTime(schoolPickupTime),
      'notes': notes,
      // price is omitted, so it will be null
    }).select().single();

    final bookingId = bookingData['id'] as String;

    // 2. Link Children
    if (childIds.isNotEmpty) {
      final childrenMap = childIds.map((childId) => {
        'booking_id': bookingId,
        'child_id': childId,
      }).toList();
      
      await _supabase.from('booking_children').insert(childrenMap);
    }
  }

  // Stream remains mostly the same, just fetching the new columns happens automatically via *
  Stream<List<Map<String, dynamic>>> getBookingsStream() {
    final userId = _supabase.auth.currentUser!.id;
    return _supabase
        .from('bookings')
        .stream(primaryKey: ['id'])
        .eq('parent_id', userId)
        .order('created_at', ascending: false)
        .asyncMap((bookings) async {
          final enriched = <Map<String, dynamic>>[];
          for (var booking in bookings) {
            final driver = await _supabase
                .from('users')
                .select('full_name, photo_url')
                .eq('id', booking['driver_id'])
                .single();
            
            final kidsCount = await _supabase
                .from('booking_children')
                .count(CountOption.exact)
                .eq('booking_id', booking['id']);

            enriched.add({
              ...booking,
              'driver_name': driver['full_name'],
              'driver_photo': driver['photo_url'],
              'kids_count': kidsCount,
            });
          }
          return enriched;
        });
  }
}