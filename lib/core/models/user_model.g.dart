// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  id: json['id'] as String,
  email: json['email'] as String,
  fullName: json['full_name'] as String,
  phone: json['phone'] as String,
  role: $enumDecodeNullable(_$UserRoleEnumMap, json['role']) ?? UserRole.parent,
  photoUrl: json['photo_url'] as String?,
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'full_name': instance.fullName,
      'phone': instance.phone,
      'role': _$UserRoleEnumMap[instance.role]!,
      'photo_url': instance.photoUrl,
    };

const _$UserRoleEnumMap = {
  UserRole.parent: 'parent',
  UserRole.driver: 'driver',
  UserRole.admin: 'admin',
};
