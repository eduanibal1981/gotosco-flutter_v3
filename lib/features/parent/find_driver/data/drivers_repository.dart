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

  Future<List<DriverAdModel>> searchDrivers(Map<String, dynamic> filters) async {
    try {
      // Map Dart filters to SQL RPC parameters
      final params = {
        'filter_gender': filters['gender'] == 'All' ? null : filters['gender'],
        'max_price': filters['maxPrice'],
        'filter_area_id': filters['areaId'],     // New: UUID string or null
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
}