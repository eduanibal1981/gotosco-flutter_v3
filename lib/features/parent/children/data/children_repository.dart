import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gotosco_v3/features/auth/data/repositories/auth_repository_impl.dart';
import 'child_model.dart';
import 'attendance_model.dart';
part 'children_repository.g.dart';

@riverpod
ChildrenRepository childrenRepository(Ref ref) {
  return ChildrenRepository(Supabase.instance.client);
}

@riverpod
Future<List<ChildModel>> myChildren(Ref ref) async {
  // Use a unique key to force refresh when needed
  final user = ref.watch(authRepositoryProvider).currentUser;
  if (user == null) return [];
  return ref.watch(childrenRepositoryProvider).getChildren(user.id);
}

class ChildrenRepository {
  final SupabaseClient _supabase;

  ChildrenRepository(this._supabase);

  Future<List<ChildModel>> getChildren(String parentId) async {
    try {
      final response = await _supabase
          .from('children')
          .select(
            '*, schools(name, cities(name))',
          ) // Join to get school and city name
          .eq('parent_id', parentId)
          .order('name', ascending: true);

      return (response as List)
          .map((data) => ChildModel.fromMap(data))
          .toList();
    } catch (e) {
      print('Error fetching children: $e');
      return [];
    }
  }

  // --- ADD CHILD FUNCTION ---
  Future<void> addChild({
    required String name,
    required String
    school, // Kept for backward compat or manual entry if needed
    String? schoolId, // NEW
    required String grade,
    required String gender,
    required DateTime dob,
    String? medicalConditions,
    String? notes,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    await _supabase.from('children').insert({
      'parent_id': user.id,
      'name': name,
      'school_name': school, // Still saving name as fallback
      'school_id': schoolId,
      'grade': grade,
      'gender': gender, // 'male' or 'female'
      'date_of_birth': dob.toIso8601String(),
      'medical_conditions': medicalConditions,
      'notes': notes,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // --- UPDATE CHILD ---
  Future<void> updateChild({
    required String childId,
    required String name,
    required String school,
    String? schoolId,
    required String grade,
    required String gender,
    required DateTime dob,
    String? medicalConditions,
    String? notes,
  }) async {
    await _supabase
        .from('children')
        .update({
          'name': name,
          'school_name': school,
          if (schoolId != null) 'school_id': schoolId,
          'grade': grade,
          'gender': gender,
          'date_of_birth': dob.toIso8601String(),
          'medical_conditions': medicalConditions,
          'notes': notes,
        })
        .eq('id', childId);
  }

  // --- DELETE CHILD ---
  Future<void> deleteChild(String childId) async {
    await _supabase.from('children').delete().eq('id', childId);
  }

  // --- ATTENDANCE HISTORY ---
  Future<List<AttendanceRecord>> getAttendanceHistory(String childId) async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

      final response = await _supabase
          .from('ride_events')
          .select()
          .eq('child_id', childId)
          .gte('created_at', thirtyDaysAgo.toIso8601String())
          .order('created_at', ascending: false);

      return (response as List)
          .map((data) => AttendanceRecord.fromMap(data))
          .toList();
    } catch (e) {
      print('Error fetching attendance: $e');
      return [];
    }
  }

  // --- REPORT ABSENCE ---
  Future<void> reportAbsence({
    required String childId,
    required DateTime date,
    String? reason,
  }) async {
    // Format date as YYYY-MM-DD to store purely the date part
    final dateStr = date.toIso8601String().split('T').first;

    await _supabase.from('child_absences').upsert({
      'child_id': childId,
      'date': dateStr,
      'reason': reason,
      'created_at': DateTime.now().toIso8601String(),
    }, onConflict: 'child_id, date'); // Ensure uniqueness per child per day
  }
}
