// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  id: json['id'] as String,
  email: json['email'] as String,
  fullName: json['full_name'] as String,
  phone: json['phone'] as String?,
  roles:
      (json['role'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  photoUrl: json['photo_url'] as String?,
  locationText: json['location_text'] as String?,
  locationLat: (json['location_lat'] as num?)?.toDouble(),
  locationLng: (json['location_lng'] as num?)?.toDouble(),
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'full_name': instance.fullName,
      'phone': instance.phone,
      'role': instance.roles,
      'photo_url': instance.photoUrl,
      'location_text': instance.locationText,
      'location_lat': instance.locationLat,
      'location_lng': instance.locationLng,
    };
