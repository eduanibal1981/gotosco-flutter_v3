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

  /// CREATE BOOKING (supports recurring + geo + children)
  Future<void> createBooking({
    required String driverId,
    required List<String> childIds,
    required String bookingType,

    String? homeLocation,
    String? schoolLocation,

    double? homeLat,
    double? homeLng,
    double? schoolLat,
    double? schoolLng,

    TimeOfDay? homePickupTime,
    TimeOfDay? schoolPickupTime,

    String? notes,

    // 🔁 Recurring fields
    required DateTime startDate,
    required DateTime endDate,
    bool isRecurring = false,
    List<String>? recurringDays, // ["Mon","Tue"]
    bool isMonthlySubscription = false,
  }) async {
    final userId = _supabase.auth.currentUser!.id;

    String? formatTime(TimeOfDay? time) {
      if (time == null) return null;
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }

    // 1️⃣ Insert booking
    final booking = await _supabase
        .from('bookings')
        .insert({
          'parent_id': userId,
          'driver_id': driverId,
          'status': 'pending',
          'booking_type': bookingType,

          'hometxt_location': homeLocation,
          'schooltxt_location': schoolLocation,

          if (homeLat != null && homeLng != null)
            'homegeo_location': 'SRID=4326;POINT($homeLng $homeLat)',

          if (schoolLat != null && schoolLng != null)
            'schoolgeo_location': 'SRID=4326;POINT($schoolLng $schoolLat)',

          'home_pickup_time': formatTime(homePickupTime),
          'school_pickup_time': formatTime(schoolPickupTime),
          'notes': notes,

          // 🔁 Recurring
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
          'is_recurring': isRecurring,
          'recurring_days': recurringDays,
          'is_monthly_subscription': isMonthlySubscription,
        })
        .select()
        .single();

    final bookingId = booking['id'] as String;

    // 2️⃣ Link children
    if (childIds.isNotEmpty) {
      await _supabase.from('booking_children').insert(
        childIds.map((id) => {
          'booking_id': bookingId,
          'child_id': id,
        }).toList(),
      );
    }
  }

  /// Cancel booking
  Future<void> cancelBooking(String bookingId) async {
    await _supabase
        .from('bookings')
        .update({'status': 'cancelled'})
        .eq('id', bookingId);
  }

  /// Delete booking
  Future<void> deleteBooking(String bookingId) async {
    await _supabase.from('bookings').delete().eq('id', bookingId);
  }

  /// ✅ REALTIME + NO N+1
  Stream<List<Map<String, dynamic>>> getBookingsStream() {
    final userId = _supabase.auth.currentUser!.id;

    return _supabase
        .from('bookings')
        .stream(primaryKey: ['id'])
        .eq('parent_id', userId)
        .asyncMap((_) async {
          final data = await _supabase.rpc('get_enriched_bookings');
          return (data as List).cast<Map<String, dynamic>>();
        });
  }
}
