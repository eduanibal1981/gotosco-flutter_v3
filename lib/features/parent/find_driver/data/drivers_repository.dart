// lib/features/parent/find_driver/data/drivers_repository.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
      // Map Dart filters to SQL RPC parameters (v2)
      final params = {
        // Basic
        'filter_gender': filters['gender'] == 'All' ? null : filters['gender'],
        'filter_vehicle_type': filters['vehicleType'] == 'All'
            ? null
            : filters['vehicleType'],
        'filter_min_rating': filters['minRating'],

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

      return (response as List)
          .map((data) => DriverAdModel.fromMap(data))
          .toList();
    } catch (e) {
      if (e is PostgrestException) {
        print(
          'Postgrest Error: ${e.message} code: ${e.code} details: ${e.details} hint: ${e.hint}',
        );
      }
      print('Error searching drivers: $e');
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
}
