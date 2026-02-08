// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gotosco_v3/core/constants/enums.dart';

// هذه الأسطر ضرورية جداً لعمل Freezed
part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
sealed class UserModel with _$UserModel {
  // 1. تعريف الحقول داخل الـ factory وليس كمتغيرات عادية
  // 2. استخدام = _UserModel لربطها بالكود المولد
  const UserModel._();

  const factory UserModel({
    required String id,
    required String email,
    // @JsonKey helps match incoming snake_case fields from Supabase
    @JsonKey(name: 'full_name') required String fullName,
    String? phone,
    // The DB stores 'role' as a jsonb/array (e.g. ["driver", "parent"])
    // We map it to a List<String> here.
    @JsonKey(name: 'role') @Default([]) List<String> roles,
    @JsonKey(name: 'photo_url') String? photoUrl,
    // Add these lines:
    @JsonKey(name: 'location_text') String? locationText,
    @JsonKey(name: 'location_lat') double? locationLat,
    @JsonKey(name: 'location_lng') double? locationLng,
  }) = _UserModel;

  // This line is needed to generate the JSON conversion method
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// Backward compatibility: returns the first role as UserRole enum,
  /// or defaults to UserRole.parent if list is empty or invalid.
  UserRole get role {
    if (roles.isEmpty) return UserRole.parent;
    try {
      // Find the enum that matches the first string in the list
      return UserRole.values.firstWhere((e) => e.name == roles.first);
    } catch (_) {
      return UserRole.parent;
    }
  }
}
