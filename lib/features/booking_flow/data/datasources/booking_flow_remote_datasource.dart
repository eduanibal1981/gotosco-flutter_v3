import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/booking_flow_child_model.dart';
import '../../domain/models/booking_flow_school_model.dart';
import '../../domain/models/booking_flow_user_location_model.dart';

class BookingFlowRemoteDatasource {
  BookingFlowRemoteDatasource(this._supabase);

  final SupabaseClient _supabase;

  Future<List<BookingFlowChildModel>> getMyChildren() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      return const [];
    }

    final response = await _supabase
        .from('children')
        .select('id, name, grade, photo_url, gender, date_of_birth, '
            'medical_conditions, notes, school_id, schools(name, cities(name))')
        .eq('parent_id', userId)
        .order('name', ascending: true);

    return (response as List).map((raw) {
      final map = Map<String, dynamic>.from(raw as Map);
      final schools = map['schools'] as Map<String, dynamic>?;
      final cities = schools?['cities'] as Map<String, dynamic>?;
      final dobRaw = map['date_of_birth']?.toString();

      return BookingFlowChildModel(
        id: (map['id'] ?? '').toString(),
        name: (map['name'] ?? 'Unknown').toString(),
        schoolName: (schools?['name'] ?? map['school_name'] ?? '').toString(),
        grade: (map['grade'] ?? '').toString(),
        photoUrl: map['photo_url']?.toString(),
        gender: map['gender']?.toString(),
        dob: dobRaw == null ? null : DateTime.tryParse(dobRaw),
        medicalConditions: map['medical_conditions']?.toString(),
        notes: map['notes']?.toString(),
        schoolId: map['school_id']?.toString(),
        cityName: cities?['name']?.toString(),
      );
    }).toList();
  }

  Future<BookingFlowUserLocationModel?> getCurrentUserLocation() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      return null;
    }

    final response = await _supabase
        .from('users')
        .select('location_text, location_lat, location_lng')
        .eq('id', userId)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    final map = Map<String, dynamic>.from(response);
    return BookingFlowUserLocationModel(
      locationText: map['location_text']?.toString(),
      locationLat: (map['location_lat'] as num?)?.toDouble(),
      locationLng: (map['location_lng'] as num?)?.toDouble(),
    );
  }

  Future<List<BookingFlowSchoolModel>> getSchoolsByIds(
    List<String> schoolIds,
  ) async {
    if (schoolIds.isEmpty) {
      return const [];
    }

    final response = await _supabase
        .from('schools')
        .select('id, name, address, city_id, latitude, longitude')
        .inFilter('id', schoolIds);

    return (response as List).map((raw) {
      final map = Map<String, dynamic>.from(raw as Map);
      return BookingFlowSchoolModel(
        id: (map['id'] ?? '').toString(),
        name: (map['name'] ?? '').toString(),
        address: map['address']?.toString(),
        cityId: map['city_id']?.toString(),
        latitude: (map['latitude'] as num?)?.toDouble(),
        longitude: (map['longitude'] as num?)?.toDouble(),
      );
    }).toList();
  }

  Future<List<BookingFlowSchoolModel>> searchSchools(
    String query, {
    String? cityId,
  }) async {
    if (query.trim().isEmpty) {
      return const [];
    }

    var dbQuery = _supabase
        .from('schools')
        .select('id, name, address, city_id, latitude, longitude')
        .ilike('name', '%$query%');

    if (cityId != null && cityId.isNotEmpty) {
      dbQuery = dbQuery.eq('city_id', cityId);
    }

    final response = await dbQuery.limit(20);

    return (response as List).map((raw) {
      final map = Map<String, dynamic>.from(raw as Map);
      return BookingFlowSchoolModel(
        id: (map['id'] ?? '').toString(),
        name: (map['name'] ?? '').toString(),
        address: map['address']?.toString(),
        cityId: map['city_id']?.toString(),
        latitude: (map['latitude'] as num?)?.toDouble(),
        longitude: (map['longitude'] as num?)?.toDouble(),
      );
    }).toList();
  }
}
