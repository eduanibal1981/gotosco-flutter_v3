import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/contracts/location_contract.dart';

part 'location_repository_impl.g.dart';

@riverpod
LocationContract locationRepository(Ref ref) {
  return LocationRepositoryImpl(Supabase.instance.client);
}

class LocationRepositoryImpl implements LocationContract {
  final SupabaseClient _supabase;
  LocationRepositoryImpl(this._supabase);

  @override
  Future<List<Map<String, dynamic>>> getCities() async {
    final data = await _supabase
        .from('cities')
        .select('id, name')
        .order('name');
    return List<Map<String, dynamic>>.from(data);
  }

  @override
  Future<List<Map<String, dynamic>>> getAreas({String? cityId}) async {
    var query = _supabase.from('areas').select('id, name');
    if (cityId != null) {
      query = query.eq('city_id', cityId);
    }
    final data = await query.order('name');
    return List<Map<String, dynamic>>.from(data);
  }

  @override
  Future<List<Map<String, dynamic>>> getSchools({
    String? areaId,
    String? cityId,
  }) async {
    var query = _supabase
        .from('schools')
        .select('id, name, address, city_id, location, latitude, longitude');

    if (areaId != null) {
      query = query.eq('area_id', areaId);
    }
    if (cityId != null) {
      query = query.eq('city_id', cityId);
    }

    final data = await query.order('name');
    return List<Map<String, dynamic>>.from(data);
  }
}
