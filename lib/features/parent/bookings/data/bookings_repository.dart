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
    String? driverId, // Made nullable for Requests
    required List<String> childIds,
    required String bookingType,
    String? tripCategory, // 'school', 'journey', 'other'
    bool isForParent = false, // Parent booking for themselves
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
    double? proposalPrice,
    double? price, // Added 'price' for agreed/direct bookings
    // 🔁 Recurring fields
    required DateTime startDate,
    required DateTime endDate,
    bool isRecurring = false,
    List<String>? recurringDays,
    bool isMonthlySubscription = false,
    // 🕐 One-time trip fields
    bool isOneTime = false,
    DateTime? scheduledPickupDatetime,
    DateTime? scheduledDropoffDatetime,

    // 🏫 Multi-School
    List<Map<String, dynamic>>? multiSchoolData,
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
          'status': driverId == null ? 'posted' : 'pending', // 'posted' for Ad
          'booking_type': bookingType,
          'trip_category': tripCategory ?? 'school',
          'is_for_parent': isForParent,
          'school_id': schoolId,
          'school_name': schoolName,
          'is_multi_school':
              multiSchoolData != null && multiSchoolData.isNotEmpty,

          'hometxt_location': homeLocation,
          'schooltxt_location': schoolLocation,

          if (homeLat != null && homeLng != null)
            'homegeo_location': 'SRID=4326;POINT($homeLng $homeLat)',

          if (schoolLat != null && schoolLng != null)
            'schoolgeo_location': 'SRID=4326;POINT($schoolLng $schoolLat)',

          'home_pickup_time': formatTime(homePickupTime),
          'school_pickup_time': formatTime(schoolPickupTime),
          'notes': notes,
          'proposal_price': proposalPrice,
          'price': price,

          // 🔁 Recurring
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
          'is_recurring': isRecurring,
          'recurring_days': recurringDays,
          'is_monthly_subscription': isMonthlySubscription,

          // 🕐 One-time
          'is_one_time': isOneTime,
          if (scheduledPickupDatetime != null)
            'scheduled_pickup_datetime': scheduledPickupDatetime
                .toIso8601String(),
          if (scheduledDropoffDatetime != null)
            'scheduled_dropoff_datetime': scheduledDropoffDatetime
                .toIso8601String(),
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

    // 3️⃣ Multi-school locations
    if (multiSchoolData != null && multiSchoolData.isNotEmpty) {
      final schoolsToInsert = multiSchoolData.map((data) {
        return {
          'booking_id': bookingId,
          'school_id': data['school_id'],
          'sequence_order': data['sequence_order'],
        };
      }).toList();

      await _supabase.from('booking_schools').insert(schoolsToInsert);
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

  /// Update a pending booking with new data (for edit flow)
  Future<void> updateBooking({
    required String bookingId,
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
    double? price,
    required DateTime startDate,
    required DateTime endDate,
    bool isRecurring = false,
    List<String>? recurringDays,
    bool isMonthlySubscription = false,
    bool isForParent = false,
    String? tripCategory,
    List<Map<String, dynamic>>? multiSchoolData,
  }) async {
    String? formatTime(TimeOfDay? time) {
      if (time == null) return null;
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }

    // 1️⃣ Update booking
    await _supabase
        .from('bookings')
        .update({
          'booking_type': bookingType,
          'school_id': schoolId,
          'school_name': schoolName,
          'is_multi_school':
              multiSchoolData != null && multiSchoolData.isNotEmpty,
          'is_for_parent': isForParent,
          'trip_category': tripCategory,

          'hometxt_location': homeLocation,
          'schooltxt_location': schoolLocation,

          if (homeLat != null && homeLng != null)
            'homegeo_location': 'SRID=4326;POINT($homeLng $homeLat)',

          if (schoolLat != null && schoolLng != null)
            'schoolgeo_location': 'SRID=4326;POINT($schoolLng $schoolLat)',

          'home_pickup_time': formatTime(homePickupTime),
          'school_pickup_time': formatTime(schoolPickupTime),
          'notes': notes,
          'price': price,

          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
          'is_recurring': isRecurring,
          'recurring_days': recurringDays,
          'is_monthly_subscription': isMonthlySubscription,
        })
        .eq('id', bookingId);

    // 2️⃣ Delete and re-insert children
    await _supabase
        .from('booking_children')
        .delete()
        .eq('booking_id', bookingId);
    if (childIds.isNotEmpty) {
      await _supabase
          .from('booking_children')
          .insert(
            childIds
                .map((id) => {'booking_id': bookingId, 'child_id': id})
                .toList(),
          );
    }

    // 3️⃣ Delete and re-insert multi-school locations
    await _supabase
        .from('booking_schools')
        .delete()
        .eq('booking_id', bookingId);
    if (multiSchoolData != null && multiSchoolData.isNotEmpty) {
      final schoolsToInsert = multiSchoolData.map((data) {
        return {
          'booking_id': bookingId,
          'school_id': data['school_id'],
          'sequence_order': data['sequence_order'],
        };
      }).toList();

      await _supabase.from('booking_schools').insert(schoolsToInsert);
    }
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

    // Children Map: booking_id -> List<Map<String, dynamic>>
    final childrenMap = <String, List<Map<String, dynamic>>>{};
    for (final item in childrenData) {
      final bId = item['booking_id'] as String;
      final child = item['children']; // {id, name, gender, grade}

      if (child != null) {
        childrenMap.putIfAbsent(bId, () => []);
        childrenMap[bId]!.add(child);
      }
    }

    // 4. Enrich Bookings
    return bookings.map((b) {
      final driverId = b['driver_id'];
      final schoolId = b['school_id'];
      final bId = b['id'];

      final driverInfo = driverMap[driverId];
      final schoolInfo = schoolMap[schoolId];
      final childrenList = childrenMap[bId] ?? [];

      final newMap = Map<String, dynamic>.from(b);

      newMap['driver_name'] = driverInfo?['name'];
      newMap['driver_photo'] = driverInfo?['photo'];

      newMap['school_name'] = schoolInfo?['name'] ?? b['school_name'];
      newMap['school_address'] = schoolInfo?['address'];

      newMap['kids_count'] = childrenList.length;
      newMap['child_names'] = childrenList.map((c) => c['name']).toList();
      newMap['students_info'] = childrenList; // Added for detailed views

      // Flatten first child for list display if needed (Legacy compatibility)
      if (childrenList.isNotEmpty) {
        newMap['child_name'] = childrenList.first['name'];
        newMap['child_gender'] = childrenList.first['gender'];
        newMap['child_grade'] = childrenList.first['grade'];
      }

      newMap['home_location'] = b['hometxt_location'];
      newMap['school_location'] = b['schooltxt_location'];

      return newMap;
    }).toList();
  }
}
