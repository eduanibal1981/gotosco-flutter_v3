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
      await _supabase
          .from('booking_children')
          .insert(
            childIds
                .map((id) => {'booking_id': bookingId, 'child_id': id})
                .toList(),
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
        .asyncMap((List<Map<String, dynamic>> bookings) async {
          if (bookings.isEmpty) return <Map<String, dynamic>>[];

          // 1. Extract IDs
          final driverIds = bookings
              .map((b) => b['driver_id'] as String?)
              .where((id) => id != null)
              .cast<String>()
              .toSet()
              .toList();
          final schoolIds = bookings
              .map((b) => b['school_id'] as String?)
              .where((id) => id != null)
              .cast<String>()
              .toSet()
              .toList();
          final bookingIds = bookings.map((b) => b['id'] as String).toList();

          // 2. Fetch Related Data in Parallel
          final results = await Future.wait([
            // Drivers
            if (driverIds.isNotEmpty)
              _supabase
                  .from('users')
                  .select('id, full_name, photo_url')
                  .inFilter('id', driverIds)
            else
              Future.value(<Map<String, dynamic>>[]),

            // Schools
            if (schoolIds.isNotEmpty)
              _supabase
                  .from('schools')
                  .select('id, name, address')
                  .inFilter('id', schoolIds)
            else
              Future.value(<Map<String, dynamic>>[]),

            // Children (via booking_children)
            if (bookingIds.isNotEmpty)
              _supabase
                  .from('booking_children')
                  .select('booking_id, children(id, name)')
                  .inFilter('booking_id', bookingIds)
            else
              Future.value(<Map<String, dynamic>>[]),
          ]);

          final driversData = results[0] as List<dynamic>;
          final schoolsData = results[1] as List<dynamic>;
          final childrenData = results[2] as List<dynamic>;

          // 3. Create Lookup Maps
          final driverMap = {
            for (final d in driversData)
              d['id']: {'name': d['full_name'], 'photo': d['photo_url']},
          };

          final schoolMap = {
            for (final s in schoolsData)
              s['id']: {'name': s['name'], 'address': s['address']},
          };

          // Children Map: booking_id -> {count, names[]}
          final childrenMap = <String, Map<String, dynamic>>{};
          for (final item in childrenData) {
            final bId = item['booking_id'] as String;
            final child = item['children'];

            if (child != null) {
              if (!childrenMap.containsKey(bId)) {
                childrenMap[bId] = {'count': 0, 'names': <String>[]};
              }
              final cName = child['name'] as String?;
              if (cName != null) {
                childrenMap[bId]!['count'] =
                    (childrenMap[bId]!['count'] as int) + 1;
                (childrenMap[bId]!['names'] as List<String>).add(cName);
              }
            }
          }

          // Sort child names
          for (final val in childrenMap.values) {
            (val['names'] as List<String>).sort();
          }

          // 4. Enrich Bookings
          return bookings.map((b) {
            final driverId = b['driver_id'];
            final schoolId = b['school_id'];
            final bId = b['id'];

            final driverInfo = driverMap[driverId];
            final schoolInfo = schoolMap[schoolId];
            final childInfo = childrenMap[bId];

            // Clone to avoid mutating original stream data
            final newMap = Map<String, dynamic>.from(b);

            // Add fields to match RPC signature
            newMap['driver_name'] = driverInfo?['name'];
            newMap['driver_photo'] = driverInfo?['photo'];

            newMap['school_name'] = schoolInfo?['name'];
            newMap['school_address'] = schoolInfo?['address'];

            newMap['kids_count'] = childInfo?['count'] ?? 0;
            newMap['child_names'] = childInfo?['names'] ?? [];

            // UI aliases
            newMap['home_location'] = b['hometxt_location'];
            newMap['school_location'] = b['schooltxt_location'];

            return newMap;
          }).toList();
        });
  }
}
