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
    final query = _supabase.from('transport_requests').select();

    if (status != null && status != 'all') {
      query.eq('status', status);
    }

    if (bookingType != null && bookingType != 'all') {
      query.eq('booking_type', bookingType);
    }

    if (searchTerm != null && searchTerm.trim().isNotEmpty) {
      final term = searchTerm.trim();
      query.or(
        'child_name.ilike.%$term%,school_name.ilike.%$term%,hometxt_location.ilike.%$term%,schooltxt_location.ilike.%$term%',
      );
    }

    final requests = await query.order('created_at', ascending: false);
    if (requests is! List || requests.isEmpty) return [];

    var filtered = List<Map<String, dynamic>>.from(requests);

    if (schoolName != null && schoolName.trim().isNotEmpty) {
      final term = schoolName.trim().toLowerCase();
      filtered = filtered
          .where(
            (r) =>
                (r['school_name'] as String? ?? '').toLowerCase().contains(term),
          )
          .toList();
    }

    if (ageMin != null || ageMax != null) {
      filtered = filtered.where((r) {
        final age = r['child_age'];
        if (age is! int) return false;
        if (ageMin != null && age < ageMin) return false;
        if (ageMax != null && age > ageMax) return false;
        return true;
      }).toList();
    }

    if (maxDistanceKm != null) {
      final driverLocation = await _getDriverLocation();
      if (driverLocation == null) {
        return [];
      }

      filtered = filtered.where((r) {
        final lat = r['home_lat'];
        final lng = r['home_lng'];
        if (lat is! num || lng is! num) return false;
        final distance = _distanceKm(
          driverLocation.$1,
          driverLocation.$2,
          lat.toDouble(),
          lng.toDouble(),
        );
        r['distance_km'] = distance;
        return distance <= maxDistanceKm;
      }).toList();
    }

    final parentIds = requests
        .map((r) => r['parent_id'] as String?)
        .where((id) => id != null)
        .cast<String>()
        .toSet()
        .toList();

    final parentMap = <String, Map<String, dynamic>>{};
    if (parentIds.isNotEmpty) {
      final parents = await _supabase
          .from('users')
          .select('id, full_name, photo_url, phone')
          .inFilter('id', parentIds);

      for (final p in parents as List) {
        parentMap[p['id'] as String] = {
          'name': p['full_name'],
          'photo': p['photo_url'],
          'phone': p['phone'],
        };
      }
    }

    return filtered.map((r) {
      final parentId = r['parent_id'] as String?;
      final parent = parentId != null ? parentMap[parentId] : null;
      return {
        ...r,
        'parent_name': parent?['name'] ?? 'Parent',
        'parent_photo': parent?['photo'],
        'parent_phone': parent?['phone'],
      };
    }).toList();
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

  double _distanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371.0;
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _degToRad(double deg) => deg * pi / 180.0;
}
