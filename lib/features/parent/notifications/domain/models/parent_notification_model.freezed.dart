// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'parent_notification_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ParentNotification {

@JsonKey(name: 'id') String get id;@JsonKey(name: 'title') String? get title;@JsonKey(name: 'body') String? get body;@JsonKey(name: 'event_type') String? get eventType;@JsonKey(name: 'driver_id') String? get driverId;@JsonKey(name: 'trip_id') String? get tripId;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'read_at') DateTime? get readAt;@JsonKey(name: 'child_name') String get childName;@JsonKey(name: 'driver_name') String get driverName;@JsonKey(name: 'driver_photo') String? get driverPhoto;@JsonKey(name: 'latitude') double? get latitude;@JsonKey(name: 'longitude') double? get longitude;
/// Create a copy of ParentNotification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParentNotificationCopyWith<ParentNotification> get copyWith => _$ParentNotificationCopyWithImpl<ParentNotification>(this as ParentNotification, _$identity);

  /// Serializes this ParentNotification to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParentNotification&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.eventType, eventType) || other.eventType == eventType)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.tripId, tripId) || other.tripId == tripId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.readAt, readAt) || other.readAt == readAt)&&(identical(other.childName, childName) || other.childName == childName)&&(identical(other.driverName, driverName) || other.driverName == driverName)&&(identical(other.driverPhoto, driverPhoto) || other.driverPhoto == driverPhoto)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,body,eventType,driverId,tripId,createdAt,readAt,childName,driverName,driverPhoto,latitude,longitude);

@override
String toString() {
  return 'ParentNotification(id: $id, title: $title, body: $body, eventType: $eventType, driverId: $driverId, tripId: $tripId, createdAt: $createdAt, readAt: $readAt, childName: $childName, driverName: $driverName, driverPhoto: $driverPhoto, latitude: $latitude, longitude: $longitude)';
}


}

/// @nodoc
abstract mixin class $ParentNotificationCopyWith<$Res>  {
  factory $ParentNotificationCopyWith(ParentNotification value, $Res Function(ParentNotification) _then) = _$ParentNotificationCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id') String id,@JsonKey(name: 'title') String? title,@JsonKey(name: 'body') String? body,@JsonKey(name: 'event_type') String? eventType,@JsonKey(name: 'driver_id') String? driverId,@JsonKey(name: 'trip_id') String? tripId,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'read_at') DateTime? readAt,@JsonKey(name: 'child_name') String childName,@JsonKey(name: 'driver_name') String driverName,@JsonKey(name: 'driver_photo') String? driverPhoto,@JsonKey(name: 'latitude') double? latitude,@JsonKey(name: 'longitude') double? longitude
});




}
/// @nodoc
class _$ParentNotificationCopyWithImpl<$Res>
    implements $ParentNotificationCopyWith<$Res> {
  _$ParentNotificationCopyWithImpl(this._self, this._then);

  final ParentNotification _self;
  final $Res Function(ParentNotification) _then;

/// Create a copy of ParentNotification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = freezed,Object? body = freezed,Object? eventType = freezed,Object? driverId = freezed,Object? tripId = freezed,Object? createdAt = freezed,Object? readAt = freezed,Object? childName = null,Object? driverName = null,Object? driverPhoto = freezed,Object? latitude = freezed,Object? longitude = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,eventType: freezed == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as String?,driverId: freezed == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String?,tripId: freezed == tripId ? _self.tripId : tripId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,readAt: freezed == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as DateTime?,childName: null == childName ? _self.childName : childName // ignore: cast_nullable_to_non_nullable
as String,driverName: null == driverName ? _self.driverName : driverName // ignore: cast_nullable_to_non_nullable
as String,driverPhoto: freezed == driverPhoto ? _self.driverPhoto : driverPhoto // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [ParentNotification].
extension ParentNotificationPatterns on ParentNotification {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ParentNotification value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ParentNotification() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ParentNotification value)  $default,){
final _that = this;
switch (_that) {
case _ParentNotification():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ParentNotification value)?  $default,){
final _that = this;
switch (_that) {
case _ParentNotification() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  String id, @JsonKey(name: 'title')  String? title, @JsonKey(name: 'body')  String? body, @JsonKey(name: 'event_type')  String? eventType, @JsonKey(name: 'driver_id')  String? driverId, @JsonKey(name: 'trip_id')  String? tripId, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'read_at')  DateTime? readAt, @JsonKey(name: 'child_name')  String childName, @JsonKey(name: 'driver_name')  String driverName, @JsonKey(name: 'driver_photo')  String? driverPhoto, @JsonKey(name: 'latitude')  double? latitude, @JsonKey(name: 'longitude')  double? longitude)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ParentNotification() when $default != null:
return $default(_that.id,_that.title,_that.body,_that.eventType,_that.driverId,_that.tripId,_that.createdAt,_that.readAt,_that.childName,_that.driverName,_that.driverPhoto,_that.latitude,_that.longitude);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  String id, @JsonKey(name: 'title')  String? title, @JsonKey(name: 'body')  String? body, @JsonKey(name: 'event_type')  String? eventType, @JsonKey(name: 'driver_id')  String? driverId, @JsonKey(name: 'trip_id')  String? tripId, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'read_at')  DateTime? readAt, @JsonKey(name: 'child_name')  String childName, @JsonKey(name: 'driver_name')  String driverName, @JsonKey(name: 'driver_photo')  String? driverPhoto, @JsonKey(name: 'latitude')  double? latitude, @JsonKey(name: 'longitude')  double? longitude)  $default,) {final _that = this;
switch (_that) {
case _ParentNotification():
return $default(_that.id,_that.title,_that.body,_that.eventType,_that.driverId,_that.tripId,_that.createdAt,_that.readAt,_that.childName,_that.driverName,_that.driverPhoto,_that.latitude,_that.longitude);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id')  String id, @JsonKey(name: 'title')  String? title, @JsonKey(name: 'body')  String? body, @JsonKey(name: 'event_type')  String? eventType, @JsonKey(name: 'driver_id')  String? driverId, @JsonKey(name: 'trip_id')  String? tripId, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'read_at')  DateTime? readAt, @JsonKey(name: 'child_name')  String childName, @JsonKey(name: 'driver_name')  String driverName, @JsonKey(name: 'driver_photo')  String? driverPhoto, @JsonKey(name: 'latitude')  double? latitude, @JsonKey(name: 'longitude')  double? longitude)?  $default,) {final _that = this;
switch (_that) {
case _ParentNotification() when $default != null:
return $default(_that.id,_that.title,_that.body,_that.eventType,_that.driverId,_that.tripId,_that.createdAt,_that.readAt,_that.childName,_that.driverName,_that.driverPhoto,_that.latitude,_that.longitude);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ParentNotification extends ParentNotification {
  const _ParentNotification({@JsonKey(name: 'id') required this.id, @JsonKey(name: 'title') this.title, @JsonKey(name: 'body') this.body, @JsonKey(name: 'event_type') this.eventType, @JsonKey(name: 'driver_id') this.driverId, @JsonKey(name: 'trip_id') this.tripId, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'read_at') this.readAt, @JsonKey(name: 'child_name') this.childName = 'Child', @JsonKey(name: 'driver_name') this.driverName = 'Driver', @JsonKey(name: 'driver_photo') this.driverPhoto, @JsonKey(name: 'latitude') this.latitude, @JsonKey(name: 'longitude') this.longitude}): super._();
  factory _ParentNotification.fromJson(Map<String, dynamic> json) => _$ParentNotificationFromJson(json);

@override@JsonKey(name: 'id') final  String id;
@override@JsonKey(name: 'title') final  String? title;
@override@JsonKey(name: 'body') final  String? body;
@override@JsonKey(name: 'event_type') final  String? eventType;
@override@JsonKey(name: 'driver_id') final  String? driverId;
@override@JsonKey(name: 'trip_id') final  String? tripId;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'read_at') final  DateTime? readAt;
@override@JsonKey(name: 'child_name') final  String childName;
@override@JsonKey(name: 'driver_name') final  String driverName;
@override@JsonKey(name: 'driver_photo') final  String? driverPhoto;
@override@JsonKey(name: 'latitude') final  double? latitude;
@override@JsonKey(name: 'longitude') final  double? longitude;

/// Create a copy of ParentNotification
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ParentNotificationCopyWith<_ParentNotification> get copyWith => __$ParentNotificationCopyWithImpl<_ParentNotification>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ParentNotificationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ParentNotification&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.eventType, eventType) || other.eventType == eventType)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.tripId, tripId) || other.tripId == tripId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.readAt, readAt) || other.readAt == readAt)&&(identical(other.childName, childName) || other.childName == childName)&&(identical(other.driverName, driverName) || other.driverName == driverName)&&(identical(other.driverPhoto, driverPhoto) || other.driverPhoto == driverPhoto)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,body,eventType,driverId,tripId,createdAt,readAt,childName,driverName,driverPhoto,latitude,longitude);

@override
String toString() {
  return 'ParentNotification(id: $id, title: $title, body: $body, eventType: $eventType, driverId: $driverId, tripId: $tripId, createdAt: $createdAt, readAt: $readAt, childName: $childName, driverName: $driverName, driverPhoto: $driverPhoto, latitude: $latitude, longitude: $longitude)';
}


}

/// @nodoc
abstract mixin class _$ParentNotificationCopyWith<$Res> implements $ParentNotificationCopyWith<$Res> {
  factory _$ParentNotificationCopyWith(_ParentNotification value, $Res Function(_ParentNotification) _then) = __$ParentNotificationCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id') String id,@JsonKey(name: 'title') String? title,@JsonKey(name: 'body') String? body,@JsonKey(name: 'event_type') String? eventType,@JsonKey(name: 'driver_id') String? driverId,@JsonKey(name: 'trip_id') String? tripId,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'read_at') DateTime? readAt,@JsonKey(name: 'child_name') String childName,@JsonKey(name: 'driver_name') String driverName,@JsonKey(name: 'driver_photo') String? driverPhoto,@JsonKey(name: 'latitude') double? latitude,@JsonKey(name: 'longitude') double? longitude
});




}
/// @nodoc
class __$ParentNotificationCopyWithImpl<$Res>
    implements _$ParentNotificationCopyWith<$Res> {
  __$ParentNotificationCopyWithImpl(this._self, this._then);

  final _ParentNotification _self;
  final $Res Function(_ParentNotification) _then;

/// Create a copy of ParentNotification
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = freezed,Object? body = freezed,Object? eventType = freezed,Object? driverId = freezed,Object? tripId = freezed,Object? createdAt = freezed,Object? readAt = freezed,Object? childName = null,Object? driverName = null,Object? driverPhoto = freezed,Object? latitude = freezed,Object? longitude = freezed,}) {
  return _then(_ParentNotification(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,eventType: freezed == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as String?,driverId: freezed == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String?,tripId: freezed == tripId ? _self.tripId : tripId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,readAt: freezed == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as DateTime?,childName: null == childName ? _self.childName : childName // ignore: cast_nullable_to_non_nullable
as String,driverName: null == driverName ? _self.driverName : driverName // ignore: cast_nullable_to_non_nullable
as String,driverPhoto: freezed == driverPhoto ? _self.driverPhoto : driverPhoto // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
