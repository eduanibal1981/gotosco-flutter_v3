// lib/features/parent/find_driver/data/drivers_repository.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'driver_ad_model.dart';

final driversRepositoryProvider = Provider<DriversRepository>((ref) {
  return DriversRepository(Supabase.instance.client);
});

// The Provider the UI will watch
final driverAdsProvider =
    FutureProvider.family<List<DriverAdModel>, Map<String, dynamic>>((
      ref,
      filters,
    ) {
      return ref.watch(driversRepositoryProvider).searchDrivers(filters);
    });

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
  // ... inside DriversRepository class
  // ... existing code ...

  // 1. Get list of Driver IDs that I have favorited
  Future<List<String>> getSavedDriverIds() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final data = await _supabase
        .from('saved_drivers')
        .select('driver_id')
        .eq('parent_id', userId);

    return (data as List).map((e) => e['driver_id'] as String).toList();
  }

  // 2. Toggle Favorite (Add if missing, Remove if exists)
  Future<void> toggleFavorite(String driverId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      // Try to insert. If it fails due to conflict (already exists), we delete it.
      // However, Supabase simple insert doesn't return conflict details easily in Dart.
      // So we check first (or use upsert logic).

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
