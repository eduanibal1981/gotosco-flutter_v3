// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'driver_trip_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DriverTrip {

@JsonKey(name: 'id') String get id;@JsonKey(name: 'driver_id') String get driverId;@JsonKey(name: 'trip_date') String get tripDate;// Date as string YYYY-MM-DD
@JsonKey(name: 'trip_type') String get tripType;@JsonKey(name: 'status') String? get status;@JsonKey(name: 'planned_start_time') DateTime? get plannedStartTime;@JsonKey(name: 'actual_start_time') DateTime? get actualStartTime;@JsonKey(name: 'actual_end_time') DateTime? get actualEndTime;@JsonKey(name: 'total_distance_km') double? get totalDistanceKm;@JsonKey(name: 'route_stops') List<RouteStop> get routeStops;
/// Create a copy of DriverTrip
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriverTripCopyWith<DriverTrip> get copyWith => _$DriverTripCopyWithImpl<DriverTrip>(this as DriverTrip, _$identity);

  /// Serializes this DriverTrip to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriverTrip&&(identical(other.id, id) || other.id == id)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.tripDate, tripDate) || other.tripDate == tripDate)&&(identical(other.tripType, tripType) || other.tripType == tripType)&&(identical(other.status, status) || other.status == status)&&(identical(other.plannedStartTime, plannedStartTime) || other.plannedStartTime == plannedStartTime)&&(identical(other.actualStartTime, actualStartTime) || other.actualStartTime == actualStartTime)&&(identical(other.actualEndTime, actualEndTime) || other.actualEndTime == actualEndTime)&&(identical(other.totalDistanceKm, totalDistanceKm) || other.totalDistanceKm == totalDistanceKm)&&const DeepCollectionEquality().equals(other.routeStops, routeStops));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,driverId,tripDate,tripType,status,plannedStartTime,actualStartTime,actualEndTime,totalDistanceKm,const DeepCollectionEquality().hash(routeStops));

@override
String toString() {
  return 'DriverTrip(id: $id, driverId: $driverId, tripDate: $tripDate, tripType: $tripType, status: $status, plannedStartTime: $plannedStartTime, actualStartTime: $actualStartTime, actualEndTime: $actualEndTime, totalDistanceKm: $totalDistanceKm, routeStops: $routeStops)';
}


}

/// @nodoc
abstract mixin class $DriverTripCopyWith<$Res>  {
  factory $DriverTripCopyWith(DriverTrip value, $Res Function(DriverTrip) _then) = _$DriverTripCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id') String id,@JsonKey(name: 'driver_id') String driverId,@JsonKey(name: 'trip_date') String tripDate,@JsonKey(name: 'trip_type') String tripType,@JsonKey(name: 'status') String? status,@JsonKey(name: 'planned_start_time') DateTime? plannedStartTime,@JsonKey(name: 'actual_start_time') DateTime? actualStartTime,@JsonKey(name: 'actual_end_time') DateTime? actualEndTime,@JsonKey(name: 'total_distance_km') double? totalDistanceKm,@JsonKey(name: 'route_stops') List<RouteStop> routeStops
});




}
/// @nodoc
class _$DriverTripCopyWithImpl<$Res>
    implements $DriverTripCopyWith<$Res> {
  _$DriverTripCopyWithImpl(this._self, this._then);

  final DriverTrip _self;
  final $Res Function(DriverTrip) _then;

/// Create a copy of DriverTrip
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? driverId = null,Object? tripDate = null,Object? tripType = null,Object? status = freezed,Object? plannedStartTime = freezed,Object? actualStartTime = freezed,Object? actualEndTime = freezed,Object? totalDistanceKm = freezed,Object? routeStops = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,driverId: null == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String,tripDate: null == tripDate ? _self.tripDate : tripDate // ignore: cast_nullable_to_non_nullable
as String,tripType: null == tripType ? _self.tripType : tripType // ignore: cast_nullable_to_non_nullable
as String,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,plannedStartTime: freezed == plannedStartTime ? _self.plannedStartTime : plannedStartTime // ignore: cast_nullable_to_non_nullable
as DateTime?,actualStartTime: freezed == actualStartTime ? _self.actualStartTime : actualStartTime // ignore: cast_nullable_to_non_nullable
as DateTime?,actualEndTime: freezed == actualEndTime ? _self.actualEndTime : actualEndTime // ignore: cast_nullable_to_non_nullable
as DateTime?,totalDistanceKm: freezed == totalDistanceKm ? _self.totalDistanceKm : totalDistanceKm // ignore: cast_nullable_to_non_nullable
as double?,routeStops: null == routeStops ? _self.routeStops : routeStops // ignore: cast_nullable_to_non_nullable
as List<RouteStop>,
  ));
}

}


/// Adds pattern-matching-related methods to [DriverTrip].
extension DriverTripPatterns on DriverTrip {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DriverTrip value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DriverTrip() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DriverTrip value)  $default,){
final _that = this;
switch (_that) {
case _DriverTrip():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DriverTrip value)?  $default,){
final _that = this;
switch (_that) {
case _DriverTrip() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  String id, @JsonKey(name: 'driver_id')  String driverId, @JsonKey(name: 'trip_date')  String tripDate, @JsonKey(name: 'trip_type')  String tripType, @JsonKey(name: 'status')  String? status, @JsonKey(name: 'planned_start_time')  DateTime? plannedStartTime, @JsonKey(name: 'actual_start_time')  DateTime? actualStartTime, @JsonKey(name: 'actual_end_time')  DateTime? actualEndTime, @JsonKey(name: 'total_distance_km')  double? totalDistanceKm, @JsonKey(name: 'route_stops')  List<RouteStop> routeStops)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DriverTrip() when $default != null:
return $default(_that.id,_that.driverId,_that.tripDate,_that.tripType,_that.status,_that.plannedStartTime,_that.actualStartTime,_that.actualEndTime,_that.totalDistanceKm,_that.routeStops);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  String id, @JsonKey(name: 'driver_id')  String driverId, @JsonKey(name: 'trip_date')  String tripDate, @JsonKey(name: 'trip_type')  String tripType, @JsonKey(name: 'status')  String? status, @JsonKey(name: 'planned_start_time')  DateTime? plannedStartTime, @JsonKey(name: 'actual_start_time')  DateTime? actualStartTime, @JsonKey(name: 'actual_end_time')  DateTime? actualEndTime, @JsonKey(name: 'total_distance_km')  double? totalDistanceKm, @JsonKey(name: 'route_stops')  List<RouteStop> routeStops)  $default,) {final _that = this;
switch (_that) {
case _DriverTrip():
return $default(_that.id,_that.driverId,_that.tripDate,_that.tripType,_that.status,_that.plannedStartTime,_that.actualStartTime,_that.actualEndTime,_that.totalDistanceKm,_that.routeStops);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id')  String id, @JsonKey(name: 'driver_id')  String driverId, @JsonKey(name: 'trip_date')  String tripDate, @JsonKey(name: 'trip_type')  String tripType, @JsonKey(name: 'status')  String? status, @JsonKey(name: 'planned_start_time')  DateTime? plannedStartTime, @JsonKey(name: 'actual_start_time')  DateTime? actualStartTime, @JsonKey(name: 'actual_end_time')  DateTime? actualEndTime, @JsonKey(name: 'total_distance_km')  double? totalDistanceKm, @JsonKey(name: 'route_stops')  List<RouteStop> routeStops)?  $default,) {final _that = this;
switch (_that) {
case _DriverTrip() when $default != null:
return $default(_that.id,_that.driverId,_that.tripDate,_that.tripType,_that.status,_that.plannedStartTime,_that.actualStartTime,_that.actualEndTime,_that.totalDistanceKm,_that.routeStops);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DriverTrip extends DriverTrip {
  const _DriverTrip({@JsonKey(name: 'id') required this.id, @JsonKey(name: 'driver_id') required this.driverId, @JsonKey(name: 'trip_date') required this.tripDate, @JsonKey(name: 'trip_type') required this.tripType, @JsonKey(name: 'status') this.status, @JsonKey(name: 'planned_start_time') this.plannedStartTime, @JsonKey(name: 'actual_start_time') this.actualStartTime, @JsonKey(name: 'actual_end_time') this.actualEndTime, @JsonKey(name: 'total_distance_km') this.totalDistanceKm, @JsonKey(name: 'route_stops') final  List<RouteStop> routeStops = const []}): _routeStops = routeStops,super._();
  factory _DriverTrip.fromJson(Map<String, dynamic> json) => _$DriverTripFromJson(json);

@override@JsonKey(name: 'id') final  String id;
@override@JsonKey(name: 'driver_id') final  String driverId;
@override@JsonKey(name: 'trip_date') final  String tripDate;
// Date as string YYYY-MM-DD
@override@JsonKey(name: 'trip_type') final  String tripType;
@override@JsonKey(name: 'status') final  String? status;
@override@JsonKey(name: 'planned_start_time') final  DateTime? plannedStartTime;
@override@JsonKey(name: 'actual_start_time') final  DateTime? actualStartTime;
@override@JsonKey(name: 'actual_end_time') final  DateTime? actualEndTime;
@override@JsonKey(name: 'total_distance_km') final  double? totalDistanceKm;
 final  List<RouteStop> _routeStops;
@override@JsonKey(name: 'route_stops') List<RouteStop> get routeStops {
  if (_routeStops is EqualUnmodifiableListView) return _routeStops;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_routeStops);
}


/// Create a copy of DriverTrip
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DriverTripCopyWith<_DriverTrip> get copyWith => __$DriverTripCopyWithImpl<_DriverTrip>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DriverTripToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DriverTrip&&(identical(other.id, id) || other.id == id)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.tripDate, tripDate) || other.tripDate == tripDate)&&(identical(other.tripType, tripType) || other.tripType == tripType)&&(identical(other.status, status) || other.status == status)&&(identical(other.plannedStartTime, plannedStartTime) || other.plannedStartTime == plannedStartTime)&&(identical(other.actualStartTime, actualStartTime) || other.actualStartTime == actualStartTime)&&(identical(other.actualEndTime, actualEndTime) || other.actualEndTime == actualEndTime)&&(identical(other.totalDistanceKm, totalDistanceKm) || other.totalDistanceKm == totalDistanceKm)&&const DeepCollectionEquality().equals(other._routeStops, _routeStops));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,driverId,tripDate,tripType,status,plannedStartTime,actualStartTime,actualEndTime,totalDistanceKm,const DeepCollectionEquality().hash(_routeStops));

@override
String toString() {
  return 'DriverTrip(id: $id, driverId: $driverId, tripDate: $tripDate, tripType: $tripType, status: $status, plannedStartTime: $plannedStartTime, actualStartTime: $actualStartTime, actualEndTime: $actualEndTime, totalDistanceKm: $totalDistanceKm, routeStops: $routeStops)';
}


}

/// @nodoc
abstract mixin class _$DriverTripCopyWith<$Res> implements $DriverTripCopyWith<$Res> {
  factory _$DriverTripCopyWith(_DriverTrip value, $Res Function(_DriverTrip) _then) = __$DriverTripCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id') String id,@JsonKey(name: 'driver_id') String driverId,@JsonKey(name: 'trip_date') String tripDate,@JsonKey(name: 'trip_type') String tripType,@JsonKey(name: 'status') String? status,@JsonKey(name: 'planned_start_time') DateTime? plannedStartTime,@JsonKey(name: 'actual_start_time') DateTime? actualStartTime,@JsonKey(name: 'actual_end_time') DateTime? actualEndTime,@JsonKey(name: 'total_distance_km') double? totalDistanceKm,@JsonKey(name: 'route_stops') List<RouteStop> routeStops
});




}
/// @nodoc
class __$DriverTripCopyWithImpl<$Res>
    implements _$DriverTripCopyWith<$Res> {
  __$DriverTripCopyWithImpl(this._self, this._then);

  final _DriverTrip _self;
  final $Res Function(_DriverTrip) _then;

/// Create a copy of DriverTrip
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? driverId = null,Object? tripDate = null,Object? tripType = null,Object? status = freezed,Object? plannedStartTime = freezed,Object? actualStartTime = freezed,Object? actualEndTime = freezed,Object? totalDistanceKm = freezed,Object? routeStops = null,}) {
  return _then(_DriverTrip(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,driverId: null == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String,tripDate: null == tripDate ? _self.tripDate : tripDate // ignore: cast_nullable_to_non_nullable
as String,tripType: null == tripType ? _self.tripType : tripType // ignore: cast_nullable_to_non_nullable
as String,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,plannedStartTime: freezed == plannedStartTime ? _self.plannedStartTime : plannedStartTime // ignore: cast_nullable_to_non_nullable
as DateTime?,actualStartTime: freezed == actualStartTime ? _self.actualStartTime : actualStartTime // ignore: cast_nullable_to_non_nullable
as DateTime?,actualEndTime: freezed == actualEndTime ? _self.actualEndTime : actualEndTime // ignore: cast_nullable_to_non_nullable
as DateTime?,totalDistanceKm: freezed == totalDistanceKm ? _self.totalDistanceKm : totalDistanceKm // ignore: cast_nullable_to_non_nullable
as double?,routeStops: null == routeStops ? _self._routeStops : routeStops // ignore: cast_nullable_to_non_nullable
as List<RouteStop>,
  ));
}


}


/// @nodoc
mixin _$RouteStop {

@JsonKey(name: 'id') String get id;@JsonKey(name: 'stop_type') String? get stopType;@JsonKey(name: 'latitude') double? get latitude;@JsonKey(name: 'longitude') double? get longitude;@JsonKey(name: 'sequence_order') int? get sequenceOrder;@JsonKey(name: 'actual_arrival_time') DateTime? get actualArrivalTime;@JsonKey(name: 'status') String? get status;@JsonKey(name: 'child_name') String? get childName;@JsonKey(name: 'student_id') String? get studentId;@JsonKey(name: 'booking_id') String? get bookingId;@JsonKey(name: 'home_location') String? get homeLocation;@JsonKey(name: 'school_location') String? get schoolLocation;
/// Create a copy of RouteStop
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RouteStopCopyWith<RouteStop> get copyWith => _$RouteStopCopyWithImpl<RouteStop>(this as RouteStop, _$identity);

  /// Serializes this RouteStop to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RouteStop&&(identical(other.id, id) || other.id == id)&&(identical(other.stopType, stopType) || other.stopType == stopType)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.sequenceOrder, sequenceOrder) || other.sequenceOrder == sequenceOrder)&&(identical(other.actualArrivalTime, actualArrivalTime) || other.actualArrivalTime == actualArrivalTime)&&(identical(other.status, status) || other.status == status)&&(identical(other.childName, childName) || other.childName == childName)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.bookingId, bookingId) || other.bookingId == bookingId)&&(identical(other.homeLocation, homeLocation) || other.homeLocation == homeLocation)&&(identical(other.schoolLocation, schoolLocation) || other.schoolLocation == schoolLocation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,stopType,latitude,longitude,sequenceOrder,actualArrivalTime,status,childName,studentId,bookingId,homeLocation,schoolLocation);

@override
String toString() {
  return 'RouteStop(id: $id, stopType: $stopType, latitude: $latitude, longitude: $longitude, sequenceOrder: $sequenceOrder, actualArrivalTime: $actualArrivalTime, status: $status, childName: $childName, studentId: $studentId, bookingId: $bookingId, homeLocation: $homeLocation, schoolLocation: $schoolLocation)';
}


}

/// @nodoc
abstract mixin class $RouteStopCopyWith<$Res>  {
  factory $RouteStopCopyWith(RouteStop value, $Res Function(RouteStop) _then) = _$RouteStopCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id') String id,@JsonKey(name: 'stop_type') String? stopType,@JsonKey(name: 'latitude') double? latitude,@JsonKey(name: 'longitude') double? longitude,@JsonKey(name: 'sequence_order') int? sequenceOrder,@JsonKey(name: 'actual_arrival_time') DateTime? actualArrivalTime,@JsonKey(name: 'status') String? status,@JsonKey(name: 'child_name') String? childName,@JsonKey(name: 'student_id') String? studentId,@JsonKey(name: 'booking_id') String? bookingId,@JsonKey(name: 'home_location') String? homeLocation,@JsonKey(name: 'school_location') String? schoolLocation
});




}
/// @nodoc
class _$RouteStopCopyWithImpl<$Res>
    implements $RouteStopCopyWith<$Res> {
  _$RouteStopCopyWithImpl(this._self, this._then);

  final RouteStop _self;
  final $Res Function(RouteStop) _then;

/// Create a copy of RouteStop
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? stopType = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? sequenceOrder = freezed,Object? actualArrivalTime = freezed,Object? status = freezed,Object? childName = freezed,Object? studentId = freezed,Object? bookingId = freezed,Object? homeLocation = freezed,Object? schoolLocation = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,stopType: freezed == stopType ? _self.stopType : stopType // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,sequenceOrder: freezed == sequenceOrder ? _self.sequenceOrder : sequenceOrder // ignore: cast_nullable_to_non_nullable
as int?,actualArrivalTime: freezed == actualArrivalTime ? _self.actualArrivalTime : actualArrivalTime // ignore: cast_nullable_to_non_nullable
as DateTime?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,childName: freezed == childName ? _self.childName : childName // ignore: cast_nullable_to_non_nullable
as String?,studentId: freezed == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String?,bookingId: freezed == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String?,homeLocation: freezed == homeLocation ? _self.homeLocation : homeLocation // ignore: cast_nullable_to_non_nullable
as String?,schoolLocation: freezed == schoolLocation ? _self.schoolLocation : schoolLocation // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RouteStop].
extension RouteStopPatterns on RouteStop {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RouteStop value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RouteStop() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RouteStop value)  $default,){
final _that = this;
switch (_that) {
case _RouteStop():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RouteStop value)?  $default,){
final _that = this;
switch (_that) {
case _RouteStop() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  String id, @JsonKey(name: 'stop_type')  String? stopType, @JsonKey(name: 'latitude')  double? latitude, @JsonKey(name: 'longitude')  double? longitude, @JsonKey(name: 'sequence_order')  int? sequenceOrder, @JsonKey(name: 'actual_arrival_time')  DateTime? actualArrivalTime, @JsonKey(name: 'status')  String? status, @JsonKey(name: 'child_name')  String? childName, @JsonKey(name: 'student_id')  String? studentId, @JsonKey(name: 'booking_id')  String? bookingId, @JsonKey(name: 'home_location')  String? homeLocation, @JsonKey(name: 'school_location')  String? schoolLocation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RouteStop() when $default != null:
return $default(_that.id,_that.stopType,_that.latitude,_that.longitude,_that.sequenceOrder,_that.actualArrivalTime,_that.status,_that.childName,_that.studentId,_that.bookingId,_that.homeLocation,_that.schoolLocation);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  String id, @JsonKey(name: 'stop_type')  String? stopType, @JsonKey(name: 'latitude')  double? latitude, @JsonKey(name: 'longitude')  double? longitude, @JsonKey(name: 'sequence_order')  int? sequenceOrder, @JsonKey(name: 'actual_arrival_time')  DateTime? actualArrivalTime, @JsonKey(name: 'status')  String? status, @JsonKey(name: 'child_name')  String? childName, @JsonKey(name: 'student_id')  String? studentId, @JsonKey(name: 'booking_id')  String? bookingId, @JsonKey(name: 'home_location')  String? homeLocation, @JsonKey(name: 'school_location')  String? schoolLocation)  $default,) {final _that = this;
switch (_that) {
case _RouteStop():
return $default(_that.id,_that.stopType,_that.latitude,_that.longitude,_that.sequenceOrder,_that.actualArrivalTime,_that.status,_that.childName,_that.studentId,_that.bookingId,_that.homeLocation,_that.schoolLocation);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id')  String id, @JsonKey(name: 'stop_type')  String? stopType, @JsonKey(name: 'latitude')  double? latitude, @JsonKey(name: 'longitude')  double? longitude, @JsonKey(name: 'sequence_order')  int? sequenceOrder, @JsonKey(name: 'actual_arrival_time')  DateTime? actualArrivalTime, @JsonKey(name: 'status')  String? status, @JsonKey(name: 'child_name')  String? childName, @JsonKey(name: 'student_id')  String? studentId, @JsonKey(name: 'booking_id')  String? bookingId, @JsonKey(name: 'home_location')  String? homeLocation, @JsonKey(name: 'school_location')  String? schoolLocation)?  $default,) {final _that = this;
switch (_that) {
case _RouteStop() when $default != null:
return $default(_that.id,_that.stopType,_that.latitude,_that.longitude,_that.sequenceOrder,_that.actualArrivalTime,_that.status,_that.childName,_that.studentId,_that.bookingId,_that.homeLocation,_that.schoolLocation);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RouteStop extends RouteStop {
  const _RouteStop({@JsonKey(name: 'id') required this.id, @JsonKey(name: 'stop_type') this.stopType, @JsonKey(name: 'latitude') this.latitude, @JsonKey(name: 'longitude') this.longitude, @JsonKey(name: 'sequence_order') this.sequenceOrder, @JsonKey(name: 'actual_arrival_time') this.actualArrivalTime, @JsonKey(name: 'status') this.status, @JsonKey(name: 'child_name') this.childName, @JsonKey(name: 'student_id') this.studentId, @JsonKey(name: 'booking_id') this.bookingId, @JsonKey(name: 'home_location') this.homeLocation, @JsonKey(name: 'school_location') this.schoolLocation}): super._();
  factory _RouteStop.fromJson(Map<String, dynamic> json) => _$RouteStopFromJson(json);

@override@JsonKey(name: 'id') final  String id;
@override@JsonKey(name: 'stop_type') final  String? stopType;
@override@JsonKey(name: 'latitude') final  double? latitude;
@override@JsonKey(name: 'longitude') final  double? longitude;
@override@JsonKey(name: 'sequence_order') final  int? sequenceOrder;
@override@JsonKey(name: 'actual_arrival_time') final  DateTime? actualArrivalTime;
@override@JsonKey(name: 'status') final  String? status;
@override@JsonKey(name: 'child_name') final  String? childName;
@override@JsonKey(name: 'student_id') final  String? studentId;
@override@JsonKey(name: 'booking_id') final  String? bookingId;
@override@JsonKey(name: 'home_location') final  String? homeLocation;
@override@JsonKey(name: 'school_location') final  String? schoolLocation;

/// Create a copy of RouteStop
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RouteStopCopyWith<_RouteStop> get copyWith => __$RouteStopCopyWithImpl<_RouteStop>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RouteStopToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RouteStop&&(identical(other.id, id) || other.id == id)&&(identical(other.stopType, stopType) || other.stopType == stopType)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.sequenceOrder, sequenceOrder) || other.sequenceOrder == sequenceOrder)&&(identical(other.actualArrivalTime, actualArrivalTime) || other.actualArrivalTime == actualArrivalTime)&&(identical(other.status, status) || other.status == status)&&(identical(other.childName, childName) || other.childName == childName)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.bookingId, bookingId) || other.bookingId == bookingId)&&(identical(other.homeLocation, homeLocation) || other.homeLocation == homeLocation)&&(identical(other.schoolLocation, schoolLocation) || other.schoolLocation == schoolLocation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,stopType,latitude,longitude,sequenceOrder,actualArrivalTime,status,childName,studentId,bookingId,homeLocation,schoolLocation);

@override
String toString() {
  return 'RouteStop(id: $id, stopType: $stopType, latitude: $latitude, longitude: $longitude, sequenceOrder: $sequenceOrder, actualArrivalTime: $actualArrivalTime, status: $status, childName: $childName, studentId: $studentId, bookingId: $bookingId, homeLocation: $homeLocation, schoolLocation: $schoolLocation)';
}


}

/// @nodoc
abstract mixin class _$RouteStopCopyWith<$Res> implements $RouteStopCopyWith<$Res> {
  factory _$RouteStopCopyWith(_RouteStop value, $Res Function(_RouteStop) _then) = __$RouteStopCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id') String id,@JsonKey(name: 'stop_type') String? stopType,@JsonKey(name: 'latitude') double? latitude,@JsonKey(name: 'longitude') double? longitude,@JsonKey(name: 'sequence_order') int? sequenceOrder,@JsonKey(name: 'actual_arrival_time') DateTime? actualArrivalTime,@JsonKey(name: 'status') String? status,@JsonKey(name: 'child_name') String? childName,@JsonKey(name: 'student_id') String? studentId,@JsonKey(name: 'booking_id') String? bookingId,@JsonKey(name: 'home_location') String? homeLocation,@JsonKey(name: 'school_location') String? schoolLocation
});




}
/// @nodoc
class __$RouteStopCopyWithImpl<$Res>
    implements _$RouteStopCopyWith<$Res> {
  __$RouteStopCopyWithImpl(this._self, this._then);

  final _RouteStop _self;
  final $Res Function(_RouteStop) _then;

/// Create a copy of RouteStop
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? stopType = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? sequenceOrder = freezed,Object? actualArrivalTime = freezed,Object? status = freezed,Object? childName = freezed,Object? studentId = freezed,Object? bookingId = freezed,Object? homeLocation = freezed,Object? schoolLocation = freezed,}) {
  return _then(_RouteStop(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,stopType: freezed == stopType ? _self.stopType : stopType // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,sequenceOrder: freezed == sequenceOrder ? _self.sequenceOrder : sequenceOrder // ignore: cast_nullable_to_non_nullable
as int?,actualArrivalTime: freezed == actualArrivalTime ? _self.actualArrivalTime : actualArrivalTime // ignore: cast_nullable_to_non_nullable
as DateTime?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,childName: freezed == childName ? _self.childName : childName // ignore: cast_nullable_to_non_nullable
as String?,studentId: freezed == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String?,bookingId: freezed == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String?,homeLocation: freezed == homeLocation ? _self.homeLocation : homeLocation // ignore: cast_nullable_to_non_nullable
as String?,schoolLocation: freezed == schoolLocation ? _self.schoolLocation : schoolLocation // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
