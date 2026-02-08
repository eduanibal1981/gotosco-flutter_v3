// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'driver_location_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DriverLocation {

@JsonKey(name: 'driver_id') String get driverId; double get latitude; double get longitude; double get heading; double get speed;@JsonKey(name: 'trip_type') String? get tripType;@JsonKey(name: 'trips_started') bool get tripsStarted;@JsonKey(name: 'eta_minutes') int? get etaMinutes;@JsonKey(name: 'next_stop_id') String? get nextStopId;@JsonKey(name: 'updated_at') DateTime get updatedAt;@JsonKey(name: 'is_app_online') bool get isAppOnline;@JsonKey(name: 'is_profile_online') bool get isOnlineVisible;
/// Create a copy of DriverLocation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriverLocationCopyWith<DriverLocation> get copyWith => _$DriverLocationCopyWithImpl<DriverLocation>(this as DriverLocation, _$identity);

  /// Serializes this DriverLocation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriverLocation&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.heading, heading) || other.heading == heading)&&(identical(other.speed, speed) || other.speed == speed)&&(identical(other.tripType, tripType) || other.tripType == tripType)&&(identical(other.tripsStarted, tripsStarted) || other.tripsStarted == tripsStarted)&&(identical(other.etaMinutes, etaMinutes) || other.etaMinutes == etaMinutes)&&(identical(other.nextStopId, nextStopId) || other.nextStopId == nextStopId)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isAppOnline, isAppOnline) || other.isAppOnline == isAppOnline)&&(identical(other.isOnlineVisible, isOnlineVisible) || other.isOnlineVisible == isOnlineVisible));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,driverId,latitude,longitude,heading,speed,tripType,tripsStarted,etaMinutes,nextStopId,updatedAt,isAppOnline,isOnlineVisible);

@override
String toString() {
  return 'DriverLocation(driverId: $driverId, latitude: $latitude, longitude: $longitude, heading: $heading, speed: $speed, tripType: $tripType, tripsStarted: $tripsStarted, etaMinutes: $etaMinutes, nextStopId: $nextStopId, updatedAt: $updatedAt, isAppOnline: $isAppOnline, isOnlineVisible: $isOnlineVisible)';
}


}

/// @nodoc
abstract mixin class $DriverLocationCopyWith<$Res>  {
  factory $DriverLocationCopyWith(DriverLocation value, $Res Function(DriverLocation) _then) = _$DriverLocationCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'driver_id') String driverId, double latitude, double longitude, double heading, double speed,@JsonKey(name: 'trip_type') String? tripType,@JsonKey(name: 'trips_started') bool tripsStarted,@JsonKey(name: 'eta_minutes') int? etaMinutes,@JsonKey(name: 'next_stop_id') String? nextStopId,@JsonKey(name: 'updated_at') DateTime updatedAt,@JsonKey(name: 'is_app_online') bool isAppOnline,@JsonKey(name: 'is_profile_online') bool isOnlineVisible
});




}
/// @nodoc
class _$DriverLocationCopyWithImpl<$Res>
    implements $DriverLocationCopyWith<$Res> {
  _$DriverLocationCopyWithImpl(this._self, this._then);

  final DriverLocation _self;
  final $Res Function(DriverLocation) _then;

/// Create a copy of DriverLocation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? driverId = null,Object? latitude = null,Object? longitude = null,Object? heading = null,Object? speed = null,Object? tripType = freezed,Object? tripsStarted = null,Object? etaMinutes = freezed,Object? nextStopId = freezed,Object? updatedAt = null,Object? isAppOnline = null,Object? isOnlineVisible = null,}) {
  return _then(_self.copyWith(
driverId: null == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,heading: null == heading ? _self.heading : heading // ignore: cast_nullable_to_non_nullable
as double,speed: null == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as double,tripType: freezed == tripType ? _self.tripType : tripType // ignore: cast_nullable_to_non_nullable
as String?,tripsStarted: null == tripsStarted ? _self.tripsStarted : tripsStarted // ignore: cast_nullable_to_non_nullable
as bool,etaMinutes: freezed == etaMinutes ? _self.etaMinutes : etaMinutes // ignore: cast_nullable_to_non_nullable
as int?,nextStopId: freezed == nextStopId ? _self.nextStopId : nextStopId // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isAppOnline: null == isAppOnline ? _self.isAppOnline : isAppOnline // ignore: cast_nullable_to_non_nullable
as bool,isOnlineVisible: null == isOnlineVisible ? _self.isOnlineVisible : isOnlineVisible // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [DriverLocation].
extension DriverLocationPatterns on DriverLocation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DriverLocation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DriverLocation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DriverLocation value)  $default,){
final _that = this;
switch (_that) {
case _DriverLocation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DriverLocation value)?  $default,){
final _that = this;
switch (_that) {
case _DriverLocation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'driver_id')  String driverId,  double latitude,  double longitude,  double heading,  double speed, @JsonKey(name: 'trip_type')  String? tripType, @JsonKey(name: 'trips_started')  bool tripsStarted, @JsonKey(name: 'eta_minutes')  int? etaMinutes, @JsonKey(name: 'next_stop_id')  String? nextStopId, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'is_app_online')  bool isAppOnline, @JsonKey(name: 'is_profile_online')  bool isOnlineVisible)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DriverLocation() when $default != null:
return $default(_that.driverId,_that.latitude,_that.longitude,_that.heading,_that.speed,_that.tripType,_that.tripsStarted,_that.etaMinutes,_that.nextStopId,_that.updatedAt,_that.isAppOnline,_that.isOnlineVisible);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'driver_id')  String driverId,  double latitude,  double longitude,  double heading,  double speed, @JsonKey(name: 'trip_type')  String? tripType, @JsonKey(name: 'trips_started')  bool tripsStarted, @JsonKey(name: 'eta_minutes')  int? etaMinutes, @JsonKey(name: 'next_stop_id')  String? nextStopId, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'is_app_online')  bool isAppOnline, @JsonKey(name: 'is_profile_online')  bool isOnlineVisible)  $default,) {final _that = this;
switch (_that) {
case _DriverLocation():
return $default(_that.driverId,_that.latitude,_that.longitude,_that.heading,_that.speed,_that.tripType,_that.tripsStarted,_that.etaMinutes,_that.nextStopId,_that.updatedAt,_that.isAppOnline,_that.isOnlineVisible);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'driver_id')  String driverId,  double latitude,  double longitude,  double heading,  double speed, @JsonKey(name: 'trip_type')  String? tripType, @JsonKey(name: 'trips_started')  bool tripsStarted, @JsonKey(name: 'eta_minutes')  int? etaMinutes, @JsonKey(name: 'next_stop_id')  String? nextStopId, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'is_app_online')  bool isAppOnline, @JsonKey(name: 'is_profile_online')  bool isOnlineVisible)?  $default,) {final _that = this;
switch (_that) {
case _DriverLocation() when $default != null:
return $default(_that.driverId,_that.latitude,_that.longitude,_that.heading,_that.speed,_that.tripType,_that.tripsStarted,_that.etaMinutes,_that.nextStopId,_that.updatedAt,_that.isAppOnline,_that.isOnlineVisible);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DriverLocation extends DriverLocation {
  const _DriverLocation({@JsonKey(name: 'driver_id') required this.driverId, required this.latitude, required this.longitude, this.heading = 0.0, this.speed = 0.0, @JsonKey(name: 'trip_type') this.tripType, @JsonKey(name: 'trips_started') this.tripsStarted = false, @JsonKey(name: 'eta_minutes') this.etaMinutes, @JsonKey(name: 'next_stop_id') this.nextStopId, @JsonKey(name: 'updated_at') required this.updatedAt, @JsonKey(name: 'is_app_online') this.isAppOnline = false, @JsonKey(name: 'is_profile_online') this.isOnlineVisible = true}): super._();
  factory _DriverLocation.fromJson(Map<String, dynamic> json) => _$DriverLocationFromJson(json);

@override@JsonKey(name: 'driver_id') final  String driverId;
@override final  double latitude;
@override final  double longitude;
@override@JsonKey() final  double heading;
@override@JsonKey() final  double speed;
@override@JsonKey(name: 'trip_type') final  String? tripType;
@override@JsonKey(name: 'trips_started') final  bool tripsStarted;
@override@JsonKey(name: 'eta_minutes') final  int? etaMinutes;
@override@JsonKey(name: 'next_stop_id') final  String? nextStopId;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;
@override@JsonKey(name: 'is_app_online') final  bool isAppOnline;
@override@JsonKey(name: 'is_profile_online') final  bool isOnlineVisible;

/// Create a copy of DriverLocation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DriverLocationCopyWith<_DriverLocation> get copyWith => __$DriverLocationCopyWithImpl<_DriverLocation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DriverLocationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DriverLocation&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.heading, heading) || other.heading == heading)&&(identical(other.speed, speed) || other.speed == speed)&&(identical(other.tripType, tripType) || other.tripType == tripType)&&(identical(other.tripsStarted, tripsStarted) || other.tripsStarted == tripsStarted)&&(identical(other.etaMinutes, etaMinutes) || other.etaMinutes == etaMinutes)&&(identical(other.nextStopId, nextStopId) || other.nextStopId == nextStopId)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isAppOnline, isAppOnline) || other.isAppOnline == isAppOnline)&&(identical(other.isOnlineVisible, isOnlineVisible) || other.isOnlineVisible == isOnlineVisible));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,driverId,latitude,longitude,heading,speed,tripType,tripsStarted,etaMinutes,nextStopId,updatedAt,isAppOnline,isOnlineVisible);

@override
String toString() {
  return 'DriverLocation(driverId: $driverId, latitude: $latitude, longitude: $longitude, heading: $heading, speed: $speed, tripType: $tripType, tripsStarted: $tripsStarted, etaMinutes: $etaMinutes, nextStopId: $nextStopId, updatedAt: $updatedAt, isAppOnline: $isAppOnline, isOnlineVisible: $isOnlineVisible)';
}


}

/// @nodoc
abstract mixin class _$DriverLocationCopyWith<$Res> implements $DriverLocationCopyWith<$Res> {
  factory _$DriverLocationCopyWith(_DriverLocation value, $Res Function(_DriverLocation) _then) = __$DriverLocationCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'driver_id') String driverId, double latitude, double longitude, double heading, double speed,@JsonKey(name: 'trip_type') String? tripType,@JsonKey(name: 'trips_started') bool tripsStarted,@JsonKey(name: 'eta_minutes') int? etaMinutes,@JsonKey(name: 'next_stop_id') String? nextStopId,@JsonKey(name: 'updated_at') DateTime updatedAt,@JsonKey(name: 'is_app_online') bool isAppOnline,@JsonKey(name: 'is_profile_online') bool isOnlineVisible
});




}
/// @nodoc
class __$DriverLocationCopyWithImpl<$Res>
    implements _$DriverLocationCopyWith<$Res> {
  __$DriverLocationCopyWithImpl(this._self, this._then);

  final _DriverLocation _self;
  final $Res Function(_DriverLocation) _then;

/// Create a copy of DriverLocation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? driverId = null,Object? latitude = null,Object? longitude = null,Object? heading = null,Object? speed = null,Object? tripType = freezed,Object? tripsStarted = null,Object? etaMinutes = freezed,Object? nextStopId = freezed,Object? updatedAt = null,Object? isAppOnline = null,Object? isOnlineVisible = null,}) {
  return _then(_DriverLocation(
driverId: null == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,heading: null == heading ? _self.heading : heading // ignore: cast_nullable_to_non_nullable
as double,speed: null == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as double,tripType: freezed == tripType ? _self.tripType : tripType // ignore: cast_nullable_to_non_nullable
as String?,tripsStarted: null == tripsStarted ? _self.tripsStarted : tripsStarted // ignore: cast_nullable_to_non_nullable
as bool,etaMinutes: freezed == etaMinutes ? _self.etaMinutes : etaMinutes // ignore: cast_nullable_to_non_nullable
as int?,nextStopId: freezed == nextStopId ? _self.nextStopId : nextStopId // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isAppOnline: null == isAppOnline ? _self.isAppOnline : isAppOnline // ignore: cast_nullable_to_non_nullable
as bool,isOnlineVisible: null == isOnlineVisible ? _self.isOnlineVisible : isOnlineVisible // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
