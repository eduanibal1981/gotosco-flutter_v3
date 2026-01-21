import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'bookings_repository.g.dart';

@riverpod
BookingsRepository bookingsRepository(Ref ref) {
  return BookingsRepository(Supabase.instance.client);
}

@riverpod
Future<List<Map<String, dynamic>>> myBookings(Ref ref) {
  return ref.watch(bookingsRepositoryProvider).getBookings();
}

class BookingsRepository {
  final SupabaseClient _supabase;
  BookingsRepository(this._supabase);

  // ... (keeping createBooking and cancelBooking as they are, assume they are above) ...

  /// CREATE BOOKING (supports recurring + geo + children)
  Future<void> createBooking({
    required String driverId,
    required List<String> childIds,
    required String bookingType,
    String? schoolId,
    String? schoolName,

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
    List<String>? recurringDays,
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
          'school_id': schoolId,
          'school_name': schoolName,

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
  Future<void> cancelBooking(
    String bookingId, {
    String status = 'cancelled',
    String? cancellationType,
    String? cancellationReason,
    double? cancellationFee,
    DateTime? contractEndDate,
    DateTime? pauseStartDate,
    DateTime? pauseEndDate,
    DateTime? cancelRequestedAt,
    String? subscriptionStatus,
  }) async {
    final update = <String, dynamic>{'status': status};

    if (status == 'cancelled') {
      update['cancelled_at'] = DateTime.now().toIso8601String();
    }
    if (cancellationType != null) {
      update['cancellation_type'] = cancellationType;
    }
    if (cancellationReason != null) {
      update['cancellation_reason'] = cancellationReason;
    }
    if (cancellationFee != null) {
      update['cancellation_fee'] = cancellationFee;
    }
    if (cancelRequestedAt != null) {
      update['cancel_requested_at'] = cancelRequestedAt.toIso8601String();
    }
    if (contractEndDate != null) {
      update['contract_end_date'] = contractEndDate.toIso8601String();
    }
    if (pauseStartDate != null) {
      update['pause_start_date'] = pauseStartDate.toIso8601String();
    }
    if (pauseEndDate != null) {
      update['pause_end_date'] = pauseEndDate.toIso8601String();
    }
    if (subscriptionStatus != null) {
      update['subscription_status'] = subscriptionStatus;
    }

    await _supabase.from('bookings').update(update).eq('id', bookingId);
  }

  Future<void> updateBookingFields(
    String bookingId,
    Map<String, dynamic> fields,
  ) async {
    if (fields.isEmpty) return;
    await _supabase.from('bookings').update(fields).eq('id', bookingId);
  }

  /// Delete booking
  Future<void> deleteBooking(String bookingId) async {
    await _supabase.from('bookings').delete().eq('id', bookingId);
  }

  /// ✅ FUTURE (FETCH) - Replaces Stream for reliability
  Future<List<Map<String, dynamic>>> getBookings() async {
    final userId = _supabase.auth.currentUser!.id;

    // 1. Fetch basic bookings
    final bookings = await _supabase
        .from('bookings')
        .select()
        .eq('parent_id', userId)
        .order('created_at', ascending: false);

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
            .from('booking_children') // Fixed table name
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
      final child =
          item['children']; // This usually returns a Map or List depending on relationship

      if (child != null) {
        if (!childrenMap.containsKey(bId)) {
          childrenMap[bId] = {'count': 0, 'names': <String>[]};
        }
        // Handle if 'children' is a single object or list (depending on query, here it's singular relation usually but let's be safe)
        // With select('..., children(id, name)'), Supabase returns it as a single object if it's 1-to-1 or N-to-1, or list if 1-to-N.
        // But here 'booking_children' is a join table.
        // Actually, 'booking_children' -> 'children'.
        // The join is: booking_children has child_id FK to children.
        // So 'children' will be a single object per booking_children row.

        final cName = child['name'] as String?;
        if (cName != null) {
          childrenMap[bId]!['count'] = (childrenMap[bId]!['count'] as int) + 1;
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

      final newMap = Map<String, dynamic>.from(b);

      newMap['driver_name'] = driverInfo?['name'];
      newMap['driver_photo'] = driverInfo?['photo'];

      newMap['school_name'] = schoolInfo?['name'] ?? b['school_name'];
      newMap['school_address'] = schoolInfo?['address'];

      newMap['kids_count'] = childInfo?['count'] ?? 0;
      newMap['child_names'] = childInfo?['names'] ?? [];

      newMap['home_location'] = b['hometxt_location'];
      newMap['school_location'] = b['schooltxt_location'];

      return newMap;
    }).toList();
  }
}
