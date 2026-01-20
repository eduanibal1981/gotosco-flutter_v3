import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'school_model.dart';
import 'package:gotosco_v3/features/driver/profile/data/city_model.dart';

part 'schools_repository.g.dart';

@riverpod
SchoolsRepository schoolsRepository(Ref ref) {
  return SchoolsRepository(Supabase.instance.client);
}

class SchoolsRepository {
  final SupabaseClient _supabase;

  SchoolsRepository(this._supabase);

  /// Search schools by name (partial match) and optional cityId
  Future<List<SchoolModel>> searchSchools(
    String query, {
    String? cityId,
  }) async {
    if (query.isEmpty) return [];

    try {
      var dbQuery = _supabase
          .from('schools')
          .select()
          .ilike('name', '%$query%');

      if (cityId != null) {
        dbQuery = dbQuery.eq('city_id', cityId);
      }

      final response = await dbQuery.limit(20);

      return (response as List)
          .map((data) => SchoolModel.fromJson(data))
          .toList();
    } catch (e) {
      print('Error searching schools: $e');
      return [];
    }
  }

  /// Upsert a school.
  /// If [id] is provided, it updates.
  /// If [id] is null (or new), it inserts.
  /// User wants to upsert with name, location and user UUID.
  Future<SchoolModel> upsertSchool({
    String? id,
    required String name,
    String? address,
    required String cityId,
    required double latitude,
    required double longitude,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User must be logged in to add a school');

    final data = {
      if (id != null) 'id': id,
      'name': name,
      'address': address,
      'city_id': cityId,
      'latitude': latitude,
      'longitude': longitude,
      'createdby': user.id, // Track who created/updated it
      // Note: 'location' column (geography) might need a trigger or separate handling
      // For now we persist lat/long as requested directly to columns.
    };

    final response = await _supabase
        .from('schools')
        .upsert(data)
        .select()
        .single();

    return SchoolModel.fromJson(response);
  }

  /// Fetch cities for dropdown
  Future<List<CityModel>> getCities() async {
    try {
      final response = await _supabase.from('cities').select().order('name');
      return (response as List).map((e) => CityModel.fromJson(e)).toList();
    } catch (e) {
      print('Error fetching cities: $e');
      return [];
    }
  }

  /// Get school by ID
  Future<SchoolModel?> getSchoolById(String id) async {
    try {
      final response = await _supabase
          .from('schools')
          .select()
          .eq('id', id)
          .single();
      return SchoolModel.fromJson(response);
    } catch (e) {
      print('Error getting school by id: $e');
      return null;
    }
  }
}
