import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/drivers_repository.dart';
import '../../domain/models/driver_ad_model.dart';

part 'drivers_repository_impl.g.dart';

@riverpod
DriversRepository driversRepository(Ref ref) {
  return DriversRepositoryImpl(Supabase.instance.client);
}

class DriversRepositoryImpl implements DriversRepository {
  final SupabaseClient _supabase;
  DriversRepositoryImpl(this._supabase);

  @override
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

      var results = (response as List)
          .map((data) => DriverAdModel.fromMap(data))
          .toList();

      // Perform client-side text filtering if search query exists
      if (isSearching) {
        final query = searchQuery.toLowerCase();
        results = results.where((driver) {
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

  @override
  Future<List<DriverAdModel>> getNearbyDrivers({int limit = 5}) async {
    // Reuse the robust search with no filters (nulls)
    return searchDrivers({}, limit: limit);
  }

  @override
  Future<List<String>> getSavedDriverIds() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final data = await _supabase
        .from('saved_drivers')
        .select('driver_id')
        .eq('parent_id', userId);

    return (data as List).map((e) => e['driver_id'] as String).toList();
  }

  @override
  Future<List<DriverAdModel>> getFavoriteDrivers() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final data = await _supabase
          .from('saved_drivers')
          .select('driver_id, drivers(*)')
          .eq('parent_id', userId);

      return (data as List)
          .map((e) {
            final driverData = e['drivers'];
            if (driverData == null) return null;
            return DriverAdModel.fromMap(driverData as Map<String, dynamic>);
          })
          .whereType<DriverAdModel>()
          .toList();
    } catch (e) {
      debugPrint('Error fetching favorite drivers: $e');
      return [];
    }
  }

  @override
  Future<void> toggleFavorite(String driverId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final existing = await _supabase
          .from('saved_drivers')
          .select()
          .eq('parent_id', userId)
          .eq('driver_id', driverId)
          .maybeSingle();

      if (existing != null) {
        await _supabase.from('saved_drivers').delete().eq('id', existing['id']);
      } else {
        await _supabase.from('saved_drivers').insert({
          'parent_id': userId,
          'driver_id': driverId,
        });
      }
    } catch (e) {
      throw Exception('Failed to toggle favorite: $e');
    }
  }

  @override
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
}
