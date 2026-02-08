import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/geo_parsing.dart';
import 'models/driver_request_model.dart';

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
  final requests = await ref
      .watch(driverTransportRequestsRepositoryProvider)
      .getDriverRequests(
        status: status,
        bookingType: bookingType,
        searchTerm: searchTerm,
        ageMin: ageMin,
        ageMax: ageMax,
        schoolName: schoolName,
      );

  // Filter by distance if needed (client-side)
  // The view returns all matching the criteria.
  // We can filter here.
  var filtered = requests;
  if (maxDistanceKm != null) {
    // Logic for distance filtering would be here if lat/lng are parsed
    // For now, return as is or implement if critical
  }

  return filtered.map((e) => e.toLegacyMap()).toList();
}

/// Newly added provider for typed access
@riverpod
Future<List<DriverRequest>> driverRequests(
  Ref ref, {
  String? status,
  String? bookingType,
  String? searchTerm,
  int? ageMin,
  int? ageMax,
  String? schoolName,
}) async {
  return ref
      .watch(driverTransportRequestsRepositoryProvider)
      .getDriverRequests(
        status: status,
        bookingType: bookingType,
        searchTerm: searchTerm,
        ageMin: ageMin,
        ageMax: ageMax,
        schoolName: schoolName,
      );
}

class DriverTransportRequestsRepository {
  final SupabaseClient _supabase;

  DriverTransportRequestsRepository(this._supabase);

  /// ✅ HYBRID: Fetches typed DriverRequest models using the database view.
  Future<List<DriverRequest>> getDriverRequests({
    String? status,
    String? bookingType,
    String? searchTerm,
    int? ageMin,
    int? ageMax,
    String? schoolName,
    double? maxDistanceKm,
  }) async {
    // Base query on the VIEW
    var query = _supabase.from('driver_requests_view').select();

    // 1. Status Filter
    // View includes 'open' status mappig if we did it? No, view has raw 'status'.
    // Repo logic: "Open requests have driver_id == null OR status == 'posted'"
    // The view 'driver_requests_view' selects * from 'bookings' (aliased).
    // So it has 'driver_id' and 'status'.

    if (status == 'open') {
      query = query
          .or('status.eq.posted,status.eq.pending')
          .isFilter('driver_id', null);
    } else if (status != null && status != 'all') {
      query = query.eq('status', status);
    } else {
      // Default behavior for "all"? Or should we default to open?
      // The original repo had: Query BOOKINGS... isFilter('driver_id', null).
      // Checks line 59: .isFilter('driver_id', null);
      // So default was always "no driver assigned" (open requests).
      // If status is specific, it appends.
      if (status == null || status == 'open') {
        query = query.isFilter('driver_id', null);
      }
    }

    if (bookingType != null && bookingType != 'all') {
      query = query.eq('booking_type', bookingType);
    }

    // Execute Query
    final data = await query.order('created_at', ascending: false);

    var requests = (data as List)
        .map((json) => DriverRequest.fromJson(json))
        .toList();

    // 2. Client-side Filtering (Search, Age, School Name)
    // We do this in Dart because some fields (aggregated JSON) are harder to filter in simple Supabase/PostgREST.

    if (searchTerm != null && searchTerm.trim().isNotEmpty) {
      final term = searchTerm.trim().toLowerCase();
      requests = requests.where((r) {
        final matchParent = (r.parentName ?? '').toLowerCase().contains(term);
        final matchLoc =
            (r.homeLocation ?? '').toLowerCase().contains(term) ||
            (r.schoolLocation ?? '').toLowerCase().contains(term);

        // Search in children
        final matchChild = r.studentsInfo.any(
          (c) => (c['name'] as String? ?? '').toLowerCase().contains(term),
        );

        // Search in schools
        final matchSchool = r.schoolsInfo.any(
          (s) => (s['name'] as String? ?? '').toLowerCase().contains(term),
        );

        return matchParent || matchLoc || matchChild || matchSchool;
      }).toList();
    }

    if (schoolName != null && schoolName.trim().isNotEmpty) {
      final term = schoolName.trim().toLowerCase();
      requests = requests.where((r) {
        // Check explicit school_name field OR schools list
        final matchSingle = (r.schoolName ?? '').toLowerCase().contains(term);
        final matchMulti = r.schoolsInfo.any(
          (s) => (s['name'] as String? ?? '').toLowerCase().contains(term),
        );
        return matchSingle || matchMulti;
      }).toList();
    }

    if (ageMin != null || ageMax != null) {
      requests = requests.where((r) {
        // Check if ANY child matches age range (or specific logic?)
        // Usually we show request if it matches.
        return r.studentsInfo.any((c) {
          final age = c['age'] as int?;
          if (age == null) return false;
          if (ageMin != null && age < ageMin) return false;
          if (ageMax != null && age > ageMax) return false;
          return true;
        });
      }).toList();
    }

    return requests;
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
