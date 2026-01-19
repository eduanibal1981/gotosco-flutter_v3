// lib/features/parent/find_driver/data/drivers_repository.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'driver_ad_model.dart';

part 'drivers_repository.g.dart';

@riverpod
DriversRepository driversRepository(Ref ref) {
  return DriversRepository(Supabase.instance.client);
}

/// Provider for dashboard "Nearby/Featured" drivers
@riverpod
Future<List<DriverAdModel>> nearbyDrivers(Ref ref) {
  return ref.watch(driversRepositoryProvider).getNearbyDrivers();
}

class DriversRepository {
  final SupabaseClient _supabase;
  DriversRepository(this._supabase);

  Future<List<DriverAdModel>> searchDrivers(
    Map<String, dynamic> filters, {
    int limit = 20,
    int offset = 0,
    double? parentLat,
    double? parentLng,
  }) async {
    try {
      final searchQuery = filters['searchQuery'] as String?;
      final isSearching = searchQuery != null && searchQuery.isNotEmpty;

      // Map Dart filters to SQL RPC parameters (v2)
      final params = {
        // Basic
        'filter_gender': filters['gender'] == 'All' ? null : filters['gender'],
        'filter_vehicle_type': filters['vehicleType'] == 'All'
            ? null
            : filters['vehicleType'],
        'filter_min_rating': filters['minRating'],
        'search_term':
            (filters['searchQuery'] as String?)?.trim().isEmpty == false
                ? filters['searchQuery']
                : null,

        // Pricing
        'max_price_monthly_two_way': filters['maxPrice'],

        // Location
        'filter_area_id': filters['areaId'],
        'filter_school_id': filters['schoolId'],
        'parent_location_lat': parentLat,
        'parent_location_lng': parentLng,
        'max_distance_km': filters['maxDistance'],

        // Availability
        'filter_online_only': filters['onlineOnly'] ?? false,
        'require_verified': filters['verifiedOnly'] ?? false,

        // Pagination
        'page_limit': limit,
        'page_offset': offset,
      };

      // Call the new RPC
      final response = await _supabase.rpc(
        'search_drivers_for_parent_v2',
        params: params,
      );

      var results =
          (response as List).map((data) => DriverAdModel.fromMap(data)).toList();

      // Perform client-side text filtering if search query exists
      if (isSearching) {
        final query = searchQuery!.toLowerCase();
        results =
            results.where((driver) {
              final nameMatch = driver.name.toLowerCase().contains(query);
              final bioMatch = driver.bio.toLowerCase().contains(query);
              final schoolMatch = driver.coveredSchools.any(
                (s) => s.toLowerCase().contains(query),
              );
              final areaMatch = driver.coveredAreas.any(
                (a) => a.toLowerCase().contains(query),
              );

              return nameMatch || bioMatch || schoolMatch || areaMatch;
            }).toList();
      }

      return results;
    } catch (e) {
      if (e is PostgrestException) {
        debugPrint(
          'Postgrest Error: ${e.message} code: ${e.code} details: ${e.details} hint: ${e.hint}',
        );
      }
      debugPrint('Error searching drivers: $e');
      return [];
    }
  }

  /// FEATURED DRIVERS (For Dashboard)
  /// Fetches a list of recent driver ads.
  /// Ideally, use actual geolocation here if available.
  Future<List<DriverAdModel>> getNearbyDrivers({int limit = 5}) async {
    // Reuse the robust search with no filters (nulls)
    return searchDrivers({}, limit: limit);
  }

  // Get list of Driver IDs that I have favorited
  Future<List<String>> getSavedDriverIds() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final data = await _supabase
        .from('saved_drivers')
        .select('driver_id')
        .eq('parent_id', userId);

    return (data as List).map((e) => e['driver_id'] as String).toList();
  }

  // Get full details of favorite drivers
  Future<List<DriverAdModel>> getFavoriteDrivers() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      // Fetch saved_drivers and join with drivers table
      // We assume the foreign key is set up correctly.
      final data = await _supabase
          .from('saved_drivers')
          .select('driver_id, drivers(*)')
          .eq('parent_id', userId);

      return (data as List).map((e) {
        final driverData = e['drivers'];
        if (driverData == null) return null;
        // Map the driver data to DriverAdModel
        // Note: Aggregated fields like covered_schools might be missing if not in 'drivers' table
        return DriverAdModel.fromMap(driverData as Map<String, dynamic>);
      }).whereType<DriverAdModel>().toList();
    } catch (e) {
      debugPrint('Error fetching favorite drivers: $e');
      return [];
    }
  }

  // Toggle Favorite (Add if missing, Remove if exists)
  Future<void> toggleFavorite(String driverId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      // Check if exists
      final existing = await _supabase
          .from('saved_drivers')
          .select()
          .eq('parent_id', userId)
          .eq('driver_id', driverId)
          .maybeSingle();

      if (existing != null) {
        // DELETE
        await _supabase.from('saved_drivers').delete().eq('id', existing['id']);
      } else {
        // INSERT
        await _supabase.from('saved_drivers').insert({
          'parent_id': userId,
          'driver_id': driverId,
        });
      }
    } catch (e) {
      throw Exception('Failed to toggle favorite: $e');
    }
  }

  // --- Reference Data ---

  Future<List<Map<String, dynamic>>> getCities() async {
    try {
      final data = await _supabase
          .from('cities')
          .select('id, name')
          .order('name');
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('Error fetching cities: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAreas({String? cityId}) async {
    try {
      var query = _supabase.from('areas').select('id, name');
      if (cityId != null) {
        query = query.eq('city_id', cityId);
      }
      final data = await query.order('name');
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('Error fetching areas: $e');
      return [];
    }
  }

  Future<({double min, double max})> getPriceLimits() async {
    try {
      final minReq = _supabase
          .from('drivers')
          .select('price_monthly_two_way')
          .gte('price_monthly_two_way', 0)
          .order('price_monthly_two_way', ascending: true)
          .limit(1)
          .maybeSingle();

      final maxReq = _supabase
          .from('drivers')
          .select('price_monthly_two_way')
          .gte('price_monthly_two_way', 0)
          .order('price_monthly_two_way', ascending: false)
          .limit(1)
          .maybeSingle();

      final results = await Future.wait([minReq, maxReq]);

      final minVal =
          (results[0]?['price_monthly_two_way'] as num?)?.toDouble() ?? 0.0;
      final maxVal =
          (results[1]?['price_monthly_two_way'] as num?)?.toDouble() ?? 5000.0;

      return (min: minVal, max: maxVal);
    } catch (e) {
      debugPrint('Error fetching price limits: $e');
      return (min: 0.0, max: 5000.0);
    }
  }

  Future<List<Map<String, dynamic>>> getSchools({String? cityId}) async {
    try {
      var query = _supabase
          .from('schools')
          .select('id, name, address, city_id, location, latitude, longitude');
      if (cityId != null) {
        query = query.eq('city_id', cityId);
      }
      final data = await query.order('name');
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('Error fetching schools: $e');
      return [];
    }
  }
}
