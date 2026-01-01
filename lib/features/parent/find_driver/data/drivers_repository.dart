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
      // Logic: Fetch from 'drivers' table and join with 'users' table to get name/photo.
      // NOTE: Ensure you have a Foreign Key set up between drivers.user_id and users.id

      var query = _supabase
          .from('drivers')
          .select('*, users!inner(full_name, photo_url, gender)');

      // 1. Gender Filter
      if (filters['gender'] != null && filters['gender'] != 'All') {
        query = query.eq('users.gender', filters['gender']);
      }

      // 2. Max Price Filter
      if (filters['maxPrice'] != null) {
        query = query.lte('price_monthly_two_way', filters['maxPrice']);
      }

      // 3. Vehicle Type Filter
      if (filters['vehicleType'] != null && filters['vehicleType'] != 'All') {
        query = query.eq('vehicle_type', filters['vehicleType']);
      }

      // 4. Verification Filter (Optional default)
      // query = query.eq('verified', true);

      final response = await query;

      return (response as List).map((data) {
        // Flatten the data for the model
        final driverData = data as Map<String, dynamic>;
        final userData = driverData['users'] as Map<String, dynamic>;
        final combinedData = {...driverData, ...userData};
        return DriverAdModel.fromMap(combinedData);
      }).toList();
    } catch (e) {
      // In production, log this error
      print('Error searching drivers: $e');
      return [];
    }
  }
}
