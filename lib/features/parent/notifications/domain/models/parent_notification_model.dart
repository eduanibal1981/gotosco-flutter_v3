// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'parent_notification_model.freezed.dart';
part 'parent_notification_model.g.dart';

@freezed
abstract class ParentNotification with _$ParentNotification {
  const ParentNotification._();

  const factory ParentNotification({
    @JsonKey(name: 'id') required String id,
    @JsonKey(name: 'title') String? title,
    @JsonKey(name: 'body') String? body,
    @JsonKey(name: 'event_type') String? eventType,
    @JsonKey(name: 'child_id') String? childId,
    @JsonKey(name: 'driver_id') String? driverId,
    @JsonKey(name: 'trip_id') String? tripId,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'read_at') DateTime? readAt,
    @JsonKey(name: 'child_name') @Default('Child') String childName,
    @JsonKey(name: 'driver_name') @Default('Driver') String driverName,
    @JsonKey(name: 'driver_photo') String? driverPhoto,
    @JsonKey(name: 'latitude') double? latitude,
    @JsonKey(name: 'longitude') double? longitude,
  }) = _ParentNotification;

  factory ParentNotification.fromJson(Map<String, dynamic> json) =>
      _$ParentNotificationFromJson(json);

  Map<String, dynamic> toLegacyMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'event_type': eventType,
      'child_id': childId,
      'driver_id': driverId,
      'trip_id': tripId,
      'created_at': createdAt?.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
      'child_name': childName,
      'driver_name': driverName,
      'driver_photo': driverPhoto,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
