// lib/features/parent/find_driver/data/drivers_repository.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'driver_ad_model.dart';

part 'drivers_repository.g.dart';

@riverpod
DriversRepository driversRepository(Ref ref) {
  return DriversRepository(Supabase.instance.client);
}

/// Provider for searching driver ads with filters.
/// The UI watches this to display filtered results.
@riverpod
Future<List<DriverAdModel>> driverAds(Ref ref, Map<String, dynamic> filters) {
  return ref.watch(driversRepositoryProvider).searchDrivers(filters);
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
    Map<String, dynamic> filters,
  ) async {
    try {
      // Map Dart filters to SQL RPC parameters
      final params = {
        'filter_gender': filters['gender'] == 'All' ? null : filters['gender'],
        'max_price': filters['maxPrice'],
        'filter_area_id': filters['areaId'], // New: UUID string or null
        'filter_school_id': filters['schoolId'], // New: UUID string or null
        'filter_online_only': filters['onlineOnly'] ?? false, // New: boolean
      };

      // Call the RPC
      final response = await _supabase.rpc('search_drivers', params: params);

      return (response as List)
          .map((data) => DriverAdModel.fromMap(data))
          .toList();
    } catch (e) {
      print('Error searching drivers: $e');
      return [];
    }
  }

  /// FEATURED DRIVERS (For Dashboard)
  /// Fetches a list of recent driver ads.
  /// Ideally, use actual geolocation here if available.
  Future<List<DriverAdModel>> getNearbyDrivers({int limit = 5}) async {
    try {
      // For now, we reuse search_drivers with no filters to get all available
      // You could optimize this with a specific RPC or direct table query
      final response = await _supabase.rpc(
        'search_drivers',
        params: {
          'filter_gender': null,
          'max_price': 1000.0, // High limit to get everything
          'filter_area_id': null,
          'filter_school_id': null,
        },
      );

      final allDrivers = (response as List)
          .map((data) => DriverAdModel.fromMap(data))
          .toList();

      // Return only top N
      // (If you had a 'created_at' in your view, you could sort by that)
      return allDrivers.take(limit).toList();
    } catch (e) {
      print('Error fetching featured drivers: $e');
      return [];
    }
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
