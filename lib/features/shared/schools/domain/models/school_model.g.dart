// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'school_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SchoolModel _$SchoolModelFromJson(Map<String, dynamic> json) => _SchoolModel(
  id: json['id'] as String,
  name: json['name'] as String,
  address: json['address'] as String?,
  cityId: json['city_id'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  createdBy: json['createdby'] as String?,
);

Map<String, dynamic> _$SchoolModelToJson(_SchoolModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'city_id': instance.cityId,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'createdby': instance.createdBy,
    };
