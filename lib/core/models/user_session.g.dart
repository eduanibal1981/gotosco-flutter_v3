// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserSession _$UserSessionFromJson(Map<String, dynamic> json) => _UserSession(
  userId: json['userId'] as String,
  fullName: json['fullName'] as String,
  email: json['email'] as String?,
  phone: json['phone'] as String?,
  photoUrl: json['photoUrl'] as String?,
  roles: (json['roles'] as List<dynamic>).map((e) => e as String).toList(),
  activeRole: json['activeRole'] as String,
  authProvider: json['authProvider'] as String? ?? 'phone',
);

Map<String, dynamic> _$UserSessionToJson(_UserSession instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'fullName': instance.fullName,
      'email': instance.email,
      'phone': instance.phone,
      'photoUrl': instance.photoUrl,
      'roles': instance.roles,
      'activeRole': instance.activeRole,
      'authProvider': instance.authProvider,
    };
