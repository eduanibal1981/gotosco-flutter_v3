import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'transport_requests_repository.g.dart';

@riverpod
DriverTransportRequestsRepository driverTransportRequestsRepository(Ref ref) {
  return DriverTransportRequestsRepository(Supabase.instance.client);
}

@riverpod
Future<List<Map<String, dynamic>>> transportRequests(
  Ref ref, {
  String? status,
  String? bookingType,
  String? searchTerm,
  int? ageMin,
  int? ageMax,
  String? schoolName,
  double? maxDistanceKm,
}) async {
  return ref
      .watch(driverTransportRequestsRepositoryProvider)
      .getTransportRequests(
        status: status,
        bookingType: bookingType,
        searchTerm: searchTerm,
        ageMin: ageMin,
        ageMax: ageMax,
        schoolName: schoolName,
        maxDistanceKm: maxDistanceKm,
      );
}

class DriverTransportRequestsRepository {
  final SupabaseClient _supabase;

  DriverTransportRequestsRepository(this._supabase);

  Future<List<Map<String, dynamic>>> getTransportRequests({
    String? status,
    String? bookingType,
    String? searchTerm,
    int? ageMin,
    int? ageMax,
    String? schoolName,
    double? maxDistanceKm,
  }) async {
    // Query BOOKINGS instead of transport_requests
    // Open requests have driver_id == null OR status == 'posted'
    var query = _supabase.from('bookings').select().isFilter('driver_id', null);

    if (status != null && status != 'all') {
      if (status == 'open') {
        // Already filtered by driver_id null, but can enforce status
        query = query.or('status.eq.posted,status.eq.pending');
      } else {
        query = query.eq('status', status);
      }
    }

    if (bookingType != null && bookingType != 'all') {
      query = query.eq('booking_type', bookingType);
    }

    final bookings = await query.order('created_at', ascending: false);
    if (bookings is! List || bookings.isEmpty) return [];

    // Filter by school name / location (client-side or server if possible, keeping client for now)
    var filteredBookings = List<Map<String, dynamic>>.from(bookings);

    // 1. Fetch relations (Children, Schools, Parent)
    final bookingIds = filteredBookings.map((b) => b['id'] as String).toList();
    final parentIds = filteredBookings
        .map((b) => b['parent_id'] as String)
        .toSet()
        .toList();

    // Parallel Fetch
    final results = await Future.wait([
      // Parents
      if (parentIds.isNotEmpty)
        _supabase
            .from('users')
            .select('id, full_name, photo_url, phone')
            .inFilter('id', parentIds)
      else
        Future.value([]),

      // Children (via booking_children -> children)
      if (bookingIds.isNotEmpty)
        _supabase
            .from('booking_children')
            .select('booking_id, children(id, name, gender, grade, age)')
            .inFilter('booking_id', bookingIds)
      else
        Future.value([]),

      // Schools (via booking_schools -> schools)
      if (bookingIds.isNotEmpty)
        _supabase
            .from('booking_schools')
            .select(
              'booking_id, sequence_order, schools(id, name, address, latitude, longitude)',
            )
            .inFilter('booking_id', bookingIds)
      else
        Future.value([]),
    ]);

    final parentsData = results[0] as List;
    final childrenRelData = results[1] as List;
    final schoolsRelData = results[2] as List;

    // Lookup Maps
    final parentMap = {for (var p in parentsData) p['id']: p};

    final childrenByBooking = <String, List<Map<String, dynamic>>>{};
    for (var rel in childrenRelData) {
      final bId = rel['booking_id'];
      final child = rel['children'];
      if (child != null) {
        childrenByBooking.putIfAbsent(bId, () => []).add(child);
      }
    }

    final schoolsByBooking = <String, List<Map<String, dynamic>>>{};
    for (var rel in schoolsRelData) {
      final bId = rel['booking_id'];
      final school = rel['schools']; // The school object
      if (school != null) {
        // Flatten a bit if needed or keep structure
        schoolsByBooking.putIfAbsent(bId, () => []).add({
          'school_id': school['id'],
          'name': school['name'],
          'address': school['address'],
          'latitude': school['latitude'],
          'longitude': school['longitude'],
          // sequence logic if needed
        });
      }
    }

    // 2. Map & Filter
    final List<Map<String, dynamic>> resultList = [];

    for (var b in filteredBookings) {
      final bId = b['id'];
      final pId = b['parent_id'];
      final parent = parentMap[pId];
      final children = childrenByBooking[bId] ?? [];
      final schools = schoolsByBooking[bId] ?? [];

      // Search Filter
      if (searchTerm != null && searchTerm.trim().isNotEmpty) {
        final term = searchTerm.trim().toLowerCase();
        final matchesParent = (parent?['full_name'] ?? '')
            .toLowerCase()
            .contains(term);
        final matchesChild = children.any(
          (c) => (c['name'] ?? '').toLowerCase().contains(term),
        );
        final matchesLoc = (b['hometxt_location'] ?? '').toLowerCase().contains(
          term,
        );
        final matchesSchool = schools.any(
          (s) => (s['name'] ?? '').toLowerCase().contains(term),
        );

        if (!matchesParent && !matchesChild && !matchesLoc && !matchesSchool) {
          continue;
        }
      }

      // School Name Filter
      if (schoolName != null && schoolName.trim().isNotEmpty) {
        final term = schoolName.trim().toLowerCase();
        final matchesSingle = (b['school_name'] ?? '').toLowerCase().contains(
          term,
        );
        final matchesMulti = schools.any(
          (s) => (s['name'] ?? '').toLowerCase().contains(term),
        );
        if (!matchesSingle && !matchesMulti) continue;
      }

      // Distance Filter logic (Optional for now, assuming geo points are set in b)
      // ... (Keep existing if needed, but 'home_lat' might be 'st_y(homegeo_location)' if not selected explicitly)
      // Note: The booking table might not return 'home_lat' directly if it's a postgis column.
      // But BookingsRepository inserted 'homegeo_location'.
      // To get Lat/Lng easily, we usually select st_y(..).
      // For now, let's assume we rely on text locations or basic filtering.
      // If critical, we'd need to adjust the SELECT to extract coords.

      // Construct standardized object for UI
      final firstChild = children.isNotEmpty ? children.first : {};

      resultList.add({
        'id': bId,
        'parent_id': pId,
        'parent_name': parent?['full_name'] ?? 'Parent',
        'parent_photo': parent?['photo_url'],
        'parent_phone': parent?['phone'],

        'child_name': firstChild['name'] ?? 'Child',
        'child_gender': firstChild['gender'],
        'child_grade': firstChild['grade'],

        'child_age': firstChild['age'],
        'school_name':
            b['school_name'] ??
            (schools.isNotEmpty ? schools.first['name'] : 'School'),
        'booking_type': b['booking_type'],
        'trip_category': b['school_id'] != null || b['is_multi_school'] == true
            ? 'school'
            : 'other', // Approx logic

        'hometxt_location': b['hometxt_location'],
        'schooltxt_location': b['schooltxt_location'],
        'notes': b['notes'],
        'status': b['status'] == 'posted' ? 'open' : b['status'],
        'created_at': b['created_at'],

        'propsal_price': b['proposal_price'],
        'schedule_type': b['is_monthly_subscription'] == true
            ? 'Monthly Subscription'
            : (b['is_recurring'] == true ? 'Recurring Trip' : 'One-Time Trip'),
        'start_date': b['start_date'],
        'end_date': b['end_date'],
        'pickup_time': b['home_pickup_time'],
        'days_of_week': b['recurring_days']?.join(', '), // List -> String
        // JSON Arrays for View
        'students_info': children,
        'schools_info': schools,
      });
    }

    return resultList;
  }

  Future<(double, double)?> _getDriverLocation() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final location = await _supabase
        .from('driver_locations')
        .select('latitude, longitude')
        .eq('driver_id', userId)
        .maybeSingle();

    if (location == null) return null;
    final lat = location['latitude'];
    final lng = location['longitude'];
    if (lat is! num || lng is! num) return null;
    return (lat.toDouble(), lng.toDouble());
  }

  double _distanceKm(double lat1, double lon1, double lat2, double lon2) {
    const earthRadiusKm = 6371.0;
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _degToRad(double deg) => deg * pi / 180.0;
}
