import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'transport_requests_repository.g.dart';

@riverpod
TransportRequestsRepository transportRequestsRepository(Ref ref) {
  return TransportRequestsRepository(Supabase.instance.client);
}

@riverpod
Stream<List<Map<String, dynamic>>> parentTransportRequests(Ref ref) {
  return ref.watch(transportRequestsRepositoryProvider).streamMyRequests();
}

class TransportRequestsRepository {
  final SupabaseClient _supabase;

  TransportRequestsRepository(this._supabase);

  Future<void> createTransportRequest({
    required String childName,
    required int childAge,
    required String schoolName,
    required String bookingType,
    required String homeLocation,
    required double homeLat,
    required double homeLng,
    required String schoolLocation,
    required double schoolLat,
    required double schoolLng,
    String? childId,
    String? childGender,
    String? childGrade,
    String? notes,
  }) async {
    final userId = _supabase.auth.currentUser!.id;

    await _supabase.from('transport_requests').insert({
      'parent_id': userId,
      'child_id': childId,
      'child_name': childName,
      'child_age': childAge,
      'child_gender': childGender,
      'child_grade': childGrade,
      'school_name': schoolName,
      'booking_type': bookingType,
      'hometxt_location': homeLocation,
      'schooltxt_location': schoolLocation,
      'homegeo_location': 'SRID=4326;POINT($homeLng $homeLat)',
      'schoolgeo_location': 'SRID=4326;POINT($schoolLng $schoolLat)',
      'notes': notes,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Stream<List<Map<String, dynamic>>> streamMyRequests() {
    final userId = _supabase.auth.currentUser!.id;
    return _supabase
        .from('transport_requests')
        .stream(primaryKey: ['id'])
        .eq('parent_id', userId)
        .order('created_at', ascending: false);
  }

  Future<void> deleteRequest(String requestId) async {
    await _supabase.from('transport_requests').delete().eq('id', requestId);
  }
}
