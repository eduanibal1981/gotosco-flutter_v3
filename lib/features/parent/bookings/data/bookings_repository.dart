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
    // NEW: Recurring Booking Fields
    required DateTime startDate,
    required DateTime endDate,
    bool isRecurring = false,
    List<String>? recurringDays,
    bool isMonthlySubscription = false,
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
          'home_pickup_time': formatTime(homePickupTime),
          'school_pickup_time': formatTime(schoolPickupTime),
          'notes': notes,
          // NEW FIELDS
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
          'is_recurring': isRecurring,
          'recurring_days': recurringDays, // e.g. ["Mon", "Tue"]
          'is_monthly_subscription': isMonthlySubscription,
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

  // Stream remains mostly the same, just fetching the new columns happens automatically via *
  Stream<List<Map<String, dynamic>>> getBookingsStream() {
    final userId = _supabase.auth.currentUser!.id;
    return _supabase
        .from('bookings')
        .stream(primaryKey: ['id'])
        .eq('parent_id', userId)
        .order('created_at', ascending: false)
        .asyncMap((bookings) async {
          final enrichedFutures = bookings.map((booking) async {
            final driver = await _supabase
                .from('users')
                .select('full_name, photo_url')
                .eq('id', booking['driver_id'])
                .single();

            // Fetch children details
            final childrenData = await _supabase
                .from('booking_children')
                .select('children(name)')
                .eq('booking_id', booking['id']);

            // Extract names list
            final childNames = (childrenData as List).map((e) {
              final child = e['children'];
              return child != null ? child['name'] as String : 'Unknown';
            }).toList();

            return {
              ...booking,
              'driver_name': driver['full_name'],
              'driver_photo': driver['photo_url'],
              'kids_count': childNames.length,
              'child_names': childNames, // List<String>
              // Map new columns to old keys for UI compatibility
              'home_location': booking['hometxt_location'],
              'school_location': booking['schooltxt_location'],
            };
          });

          return Future.wait(enrichedFutures);
        });
  }
}
