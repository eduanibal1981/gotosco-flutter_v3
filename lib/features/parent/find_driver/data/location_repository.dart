import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'location_repository.g.dart';

@riverpod
LocationRepository locationRepository(Ref ref) {
  return LocationRepository(Supabase.instance.client);
}

/// Fetch all cities
@Riverpod(keepAlive: true)
Future<List<Map<String, dynamic>>> cities(Ref ref) {
  return ref.watch(locationRepositoryProvider).getCities();
}

/// Fetch areas for a specific city
@Riverpod(keepAlive: true)
Future<List<Map<String, dynamic>>> areas(Ref ref, String cityId) {
  return ref.watch(locationRepositoryProvider).getAreas(cityId);
}

/// Fetch schools for a specific area
@Riverpod(keepAlive: true)
Future<List<Map<String, dynamic>>> schools(Ref ref, String areaId) {
  return ref.watch(locationRepositoryProvider).getSchools(areaId);
}

class LocationRepository {
  final SupabaseClient _supabase;
  LocationRepository(this._supabase);

  Future<List<Map<String, dynamic>>> getCities() async {
    final data = await _supabase
        .from('cities')
        .select('id, name')
        .order('name');
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
