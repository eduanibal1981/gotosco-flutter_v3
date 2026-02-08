// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parent_notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ParentNotification _$ParentNotificationFromJson(Map<String, dynamic> json) =>
    _ParentNotification(
      id: json['id'] as String,
      title: json['title'] as String?,
      body: json['body'] as String?,
      eventType: json['event_type'] as String?,
      childId: json['child_id'] as String?,
      driverId: json['driver_id'] as String?,
      tripId: json['trip_id'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      readAt: json['read_at'] == null
          ? null
          : DateTime.parse(json['read_at'] as String),
      childName: json['child_name'] as String? ?? 'Child',
      driverName: json['driver_name'] as String? ?? 'Driver',
      driverPhoto: json['driver_photo'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ParentNotificationToJson(_ParentNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'body': instance.body,
      'event_type': instance.eventType,
      'child_id': instance.childId,
      'driver_id': instance.driverId,
      'trip_id': instance.tripId,
      'created_at': instance.createdAt?.toIso8601String(),
      'read_at': instance.readAt?.toIso8601String(),
      'child_name': instance.childName,
      'driver_name': instance.driverName,
      'driver_photo': instance.driverPhoto,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
