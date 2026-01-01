import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Providers for the UI to watch
final locationRepositoryProvider = Provider((ref) => LocationRepository(Supabase.instance.client));

// Fetch cities
final citiesProvider = FutureProvider((ref) => ref.watch(locationRepositoryProvider).getCities());

// Fetch areas (depends on selectedCityId)
final areasProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, cityId) {
  return ref.watch(locationRepositoryProvider).getAreas(cityId);
});

// Fetch schools (depends on selectedAreaId)
final schoolsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, areaId) {
  return ref.watch(locationRepositoryProvider).getSchools(areaId);
});

class LocationRepository {
  final SupabaseClient _supabase;
  LocationRepository(this._supabase);

  Future<List<Map<String, dynamic>>> getCities() async {
    final data = await _supabase.from('cities').select('id, name').order('name');
    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> getAreas(String cityId) async {
    final data = await _supabase
        .from('areas')
        .select('id, name')
        .eq('city_id', cityId)
        .order('name');
    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> getSchools(String areaId) async {
    final data = await _supabase
        .from('schools')
        .select('id, name')
        .eq('area_id', areaId)
        .order('name');
    return List<Map<String, dynamic>>.from(data);
  }
}