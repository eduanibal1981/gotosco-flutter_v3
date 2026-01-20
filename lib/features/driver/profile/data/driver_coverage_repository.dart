import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'area_model.dart';
import 'city_model.dart';
import 'driver_profile_repository.dart';
import 'school_model.dart';
import '../../dashboard/data/driver_dashboard_repository.dart';

part 'driver_coverage_repository.g.dart';

@riverpod
DriverCoverageRepository driverCoverageRepository(Ref ref) {
  return DriverCoverageRepository(Supabase.instance.client);
}

@riverpod
Future<List<CityModel>> coverageCities(Ref ref) async {
  return ref.read(driverCoverageRepositoryProvider).getCities();
}

@riverpod
Future<List<AreaModel>> coverageAreas(Ref ref, {required String cityId}) async {
  return ref.read(driverCoverageRepositoryProvider).getAreas(cityId);
}

@riverpod
Future<List<SchoolModel>> coverageSchools(
  Ref ref, {
  required String cityId,
}) async {
  return ref.read(driverCoverageRepositoryProvider).getSchools(cityId);
}

@riverpod
Future<Set<String>> driverCoverageAreaIds(Ref ref) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return {};
  return ref.read(driverCoverageRepositoryProvider).getDriverAreaIds(userId);
}

@riverpod
Future<Set<String>> driverCoverageSchoolIds(Ref ref) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return {};
  return ref.read(driverCoverageRepositoryProvider).getDriverSchoolIds(userId);
}

@riverpod
class DriverCoverageController extends _$DriverCoverageController {
  @override
  Future<void> build() async {}

  Future<void> saveCoverage({
    required Set<String> areaIds,
    required Set<String> schoolIds,
  }) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(driverCoverageRepositoryProvider).setDriverCoverage(
            driverId: userId,
            areaIds: areaIds,
            schoolIds: schoolIds,
          );
      ref.invalidate(driverCoverageAreaIdsProvider);
      ref.invalidate(driverCoverageSchoolIdsProvider);
      ref.invalidate(currentDriverProfileProvider);
      ref.invalidate(driverProfileProvider);
      ref.invalidate(driverDashboardStateProvider);
    });
  }
}

class DriverCoverageRepository {
  final SupabaseClient _supabase;

  DriverCoverageRepository(this._supabase);

  Future<List<CityModel>> getCities() async {
    final response = await _supabase
        .from('cities')
        .select('id, name, state, country')
        .order('name');
    return (response as List)
        .map(
          (row) => CityModel.fromJson({
            'id': row['id'],
            'name': row['name'],
            'state': row['state'],
            'country': row['country'],
          }),
        )
        .toList();
  }

  Future<List<AreaModel>> getAreas(String cityId) async {
    final response = await _supabase
        .from('areas')
        .select('id, name, city_id')
        .eq('city_id', cityId)
        .order('name');
    return (response as List)
        .map(
          (row) => AreaModel.fromJson({
            'id': row['id'],
            'name': row['name'],
            'cityId': row['city_id'],
          }),
        )
        .toList();
  }

  Future<List<SchoolModel>> getSchools(String cityId) async {
    final response = await _supabase
        .from('schools')
        .select('id, name, address, city_id, latitude, longitude')
        .eq('city_id', cityId)
        .order('name');
    return (response as List)
        .map(
          (row) => SchoolModel.fromJson({
            'id': row['id'],
            'name': row['name'],
            'address': row['address'],
            'cityId': row['city_id'],
            'latitude': row['latitude'],
            'longitude': row['longitude'],
          }),
        )
        .toList();
  }

  Future<Set<String>> getDriverAreaIds(String driverId) async {
    final response = await _supabase
        .from('driver_service_areas')
        .select('area_id')
        .eq('driver_id', driverId);
    return (response as List)
        .map((row) => row['area_id'] as String?)
        .whereType<String>()
        .toSet();
  }

  Future<Set<String>> getDriverSchoolIds(String driverId) async {
    final response = await _supabase
        .from('driver_covered_schools')
        .select('school_id')
        .eq('driver_id', driverId);
    return (response as List)
        .map((row) => row['school_id'] as String?)
        .whereType<String>()
        .toSet();
  }

  Future<void> setDriverCoverage({
    required String driverId,
    required Set<String> areaIds,
    required Set<String> schoolIds,
  }) async {
    await _supabase
        .from('driver_service_areas')
        .delete()
        .eq('driver_id', driverId);
    await _supabase
        .from('driver_covered_schools')
        .delete()
        .eq('driver_id', driverId);

    if (areaIds.isNotEmpty) {
      final rows = areaIds
          .map((areaId) => {'driver_id': driverId, 'area_id': areaId})
          .toList();
      await _supabase.from('driver_service_areas').insert(rows);
    }

    if (schoolIds.isNotEmpty) {
      final rows = schoolIds
          .map((schoolId) => {'driver_id': driverId, 'school_id': schoolId})
          .toList();
      await _supabase.from('driver_covered_schools').insert(rows);
    }
  }

  Future<SchoolModel> addSchool({
    required String cityId,
    required String name,
    String? address,
  }) async {
    final response = await _supabase
        .from('schools')
        .insert({
          'city_id': cityId,
          'name': name,
          'address': address,
        })
        .select('id, name, address, city_id, latitude, longitude')
        .single();

    return SchoolModel.fromJson({
      'id': response['id'],
      'name': response['name'],
      'address': response['address'],
      'cityId': response['city_id'],
      'latitude': response['latitude'],
      'longitude': response['longitude'],
    });
  }
}
