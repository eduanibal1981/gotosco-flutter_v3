import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gotosco_v3/features/auth/data/auth_repository.dart';
import 'child_model.dart';

final childrenRepositoryProvider = Provider<ChildrenRepository>((ref) {
  return ChildrenRepository(Supabase.instance.client);
});

final myChildrenProvider = FutureProvider<List<ChildModel>>((ref) async {
  // Use a unique key to force refresh when needed
  final user = ref.watch(authRepositoryProvider).currentUser;
  if (user == null) return [];
  return ref.watch(childrenRepositoryProvider).getChildren(user.id);
});

class ChildrenRepository {
  final SupabaseClient _supabase;

  ChildrenRepository(this._supabase);

  Future<List<ChildModel>> getChildren(String parentId) async {
    try {
      final response = await _supabase
          .from('children')
          .select()
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

  // --- NEW: ADD CHILD FUNCTION ---
  Future<void> addChild({
    required String name,
    required String school,
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
      'school': school,
      'grade': grade,
      'gender': gender, // 'male' or 'female'
      'date_of_birth': dob.toIso8601String(),
      'medical_conditions': medicalConditions,
      'notes': notes,
      'created_at': DateTime.now().toIso8601String(),
    });
  }
  // --- NEW: UPDATE CHILD ---
  Future<void> updateChild({
    required String childId,
    required String name,
    required String school,
    required String grade,
    required String gender,
    required DateTime dob,
    String? medicalConditions,
    String? notes,
  }) async {
    await _supabase.from('children').update({
      'name': name,
      'school': school,
      'grade': grade,
      'gender': gender,
      'date_of_birth': dob.toIso8601String(),
      'medical_conditions': medicalConditions,
      'notes': notes,
    }).eq('id', childId);
  }

  // --- NEW: DELETE CHILD ---
  Future<void> deleteChild(String childId) async {
    await _supabase.from('children').delete().eq('id', childId);
  }
}
