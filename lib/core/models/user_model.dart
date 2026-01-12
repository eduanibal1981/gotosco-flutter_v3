import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gotosco_v3/core/constants/enums.dart';

// هذه الأسطر ضرورية جداً لعمل Freezed
part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
sealed class UserModel with _$UserModel {
  // 1. تعريف الحقول داخل الـ factory وليس كمتغيرات عادية
  // 2. استخدام = _UserModel لربطها بالكود المولد
  const factory UserModel({
    required String id,
    required String email,
    // @JsonKey يساعد في مطابقة أسماء الحقول القادمة من Supabase (snake_case)
    @JsonKey(name: 'full_name') required String fullName,
    required String phone,
    @Default(UserRole.parent) UserRole role,
    @JsonKey(name: 'photo_url') String? photoUrl,
  }) = _UserModel;

  // هذا السطر ضروري لتوليد دالة تحويل JSON
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
