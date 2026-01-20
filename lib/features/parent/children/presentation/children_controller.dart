import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/children_repository.dart';
import '../data/attendance_model.dart';

part 'children_controller.g.dart';

/// Provider to fetch attendance history for a specific child
@riverpod
Future<List<AttendanceRecord>> attendanceHistory(Ref ref, String childId) {
  return ref.watch(childrenRepositoryProvider).getAttendanceHistory(childId);
}

/// Controller that encapsulates all children management business logic.
/// Handles validation, CRUD operations, and state management.
@riverpod
class ChildrenController extends _$ChildrenController {
  @override
  FutureOr<void> build() {}

  /// Validates input and adds a new child profile.
  /// Returns true on success, throws on error.
  Future<bool> addChild({
    required String name,
    required String school,
    String? schoolId, // NEW
    required String grade,
    required String gender,
    required DateTime dob,
    String? medicalConditions,
    String? notes,
  }) async {
    // Validation
    if (name.trim().isEmpty) {
      throw Exception('Name is required');
    }
    if (school.trim().isEmpty && schoolId == null) {
      throw Exception('School is required');
    }
    if (grade.trim().isEmpty) {
      throw Exception('Grade is required');
    }

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await ref
          .read(childrenRepositoryProvider)
          .addChild(
            name: name.trim(),
            school: school.trim(),
            schoolId: schoolId,
            grade: grade.trim(),
            gender: gender,
            dob: dob,
            medicalConditions: medicalConditions?.trim(),
            notes: notes?.trim(),
          );

      // Refresh the children list
      ref.invalidate(myChildrenProvider);
    });

    return !state.hasError;
  }

  /// Updates an existing child profile.
  Future<bool> updateChild({
    required String childId,
    required String name,
    required String school,
    required String grade,
    required String gender,
    required DateTime dob,
    String? medicalConditions,
    String? notes,
  }) async {
    // Validation
    if (name.trim().isEmpty) {
      throw Exception('Name is required');
    }
    if (school.trim().isEmpty) {
      throw Exception('School is required');
    }

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await ref
          .read(childrenRepositoryProvider)
          .updateChild(
            childId: childId,
            name: name.trim(),
            school: school.trim(),
            grade: grade.trim(),
            gender: gender,
            dob: dob,
            medicalConditions: medicalConditions?.trim(),
            notes: notes?.trim(),
          );

      // Refresh the children list
      ref.invalidate(myChildrenProvider);
    });

    return !state.hasError;
  }

  /// Deletes a child profile.
  Future<bool> deleteChild(String childId) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await ref.read(childrenRepositoryProvider).deleteChild(childId);

      // Refresh the children list
      ref.invalidate(myChildrenProvider);
    });

    return !state.hasError;
  }
}
