// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'school_location_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SchoolLocationModel _$SchoolLocationModelFromJson(Map<String, dynamic> json) =>
    _SchoolLocationModel(
      schoolId: json['schoolId'] as String,
      schoolName: json['schoolName'] as String,
      schoolAddress: json['schoolAddress'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      studentIds:
          (json['studentIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      sequenceOrder: (json['sequenceOrder'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SchoolLocationModelToJson(
  _SchoolLocationModel instance,
) => <String, dynamic>{
  'schoolId': instance.schoolId,
  'schoolName': instance.schoolName,
  'schoolAddress': instance.schoolAddress,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'studentIds': instance.studentIds,
  'sequenceOrder': instance.sequenceOrder,
};
