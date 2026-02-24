// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TripCategoryModel _$TripCategoryModelFromJson(Map<String, dynamic> json) =>
    _TripCategoryModel(
      id: json['id'] as String,
      label: json['label'] as String,
      icon: json['icon'] as String,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$TripCategoryModelToJson(_TripCategoryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'icon': instance.icon,
      'description': instance.description,
    };
