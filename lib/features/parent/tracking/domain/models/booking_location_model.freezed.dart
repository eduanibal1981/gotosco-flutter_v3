// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking_location_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BookingLocation {

// booking_id is primary key of view
@JsonKey(name: 'booking_id') String get bookingId;@JsonKey(name: 'home_lat') double? get homeLat;@JsonKey(name: 'home_lng') double? get homeLng;@JsonKey(name: 'school_lat') double? get schoolLat;@JsonKey(name: 'school_lng') double? get schoolLng;@JsonKey(name: 'driver_id') String? get driverId;@JsonKey(name: 'driver_name') String? get driverName;@JsonKey(name: 'driver_phone') String? get driverPhone;
/// Create a copy of BookingLocation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookingLocationCopyWith<BookingLocation> get copyWith => _$BookingLocationCopyWithImpl<BookingLocation>(this as BookingLocation, _$identity);

  /// Serializes this BookingLocation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookingLocation&&(identical(other.bookingId, bookingId) || other.bookingId == bookingId)&&(identical(other.homeLat, homeLat) || other.homeLat == homeLat)&&(identical(other.homeLng, homeLng) || other.homeLng == homeLng)&&(identical(other.schoolLat, schoolLat) || other.schoolLat == schoolLat)&&(identical(other.schoolLng, schoolLng) || other.schoolLng == schoolLng)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.driverName, driverName) || other.driverName == driverName)&&(identical(other.driverPhone, driverPhone) || other.driverPhone == driverPhone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bookingId,homeLat,homeLng,schoolLat,schoolLng,driverId,driverName,driverPhone);

@override
String toString() {
  return 'BookingLocation(bookingId: $bookingId, homeLat: $homeLat, homeLng: $homeLng, schoolLat: $schoolLat, schoolLng: $schoolLng, driverId: $driverId, driverName: $driverName, driverPhone: $driverPhone)';
}


}

/// @nodoc
abstract mixin class $BookingLocationCopyWith<$Res>  {
  factory $BookingLocationCopyWith(BookingLocation value, $Res Function(BookingLocation) _then) = _$BookingLocationCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'booking_id') String bookingId,@JsonKey(name: 'home_lat') double? homeLat,@JsonKey(name: 'home_lng') double? homeLng,@JsonKey(name: 'school_lat') double? schoolLat,@JsonKey(name: 'school_lng') double? schoolLng,@JsonKey(name: 'driver_id') String? driverId,@JsonKey(name: 'driver_name') String? driverName,@JsonKey(name: 'driver_phone') String? driverPhone
});




}
/// @nodoc
class _$BookingLocationCopyWithImpl<$Res>
    implements $BookingLocationCopyWith<$Res> {
  _$BookingLocationCopyWithImpl(this._self, this._then);

  final BookingLocation _self;
  final $Res Function(BookingLocation) _then;

/// Create a copy of BookingLocation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bookingId = null,Object? homeLat = freezed,Object? homeLng = freezed,Object? schoolLat = freezed,Object? schoolLng = freezed,Object? driverId = freezed,Object? driverName = freezed,Object? driverPhone = freezed,}) {
  return _then(_self.copyWith(
bookingId: null == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String,homeLat: freezed == homeLat ? _self.homeLat : homeLat // ignore: cast_nullable_to_non_nullable
as double?,homeLng: freezed == homeLng ? _self.homeLng : homeLng // ignore: cast_nullable_to_non_nullable
as double?,schoolLat: freezed == schoolLat ? _self.schoolLat : schoolLat // ignore: cast_nullable_to_non_nullable
as double?,schoolLng: freezed == schoolLng ? _self.schoolLng : schoolLng // ignore: cast_nullable_to_non_nullable
as double?,driverId: freezed == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String?,driverName: freezed == driverName ? _self.driverName : driverName // ignore: cast_nullable_to_non_nullable
as String?,driverPhone: freezed == driverPhone ? _self.driverPhone : driverPhone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BookingLocation].
extension BookingLocationPatterns on BookingLocation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BookingLocation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BookingLocation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BookingLocation value)  $default,){
final _that = this;
switch (_that) {
case _BookingLocation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BookingLocation value)?  $default,){
final _that = this;
switch (_that) {
case _BookingLocation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'booking_id')  String bookingId, @JsonKey(name: 'home_lat')  double? homeLat, @JsonKey(name: 'home_lng')  double? homeLng, @JsonKey(name: 'school_lat')  double? schoolLat, @JsonKey(name: 'school_lng')  double? schoolLng, @JsonKey(name: 'driver_id')  String? driverId, @JsonKey(name: 'driver_name')  String? driverName, @JsonKey(name: 'driver_phone')  String? driverPhone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BookingLocation() when $default != null:
return $default(_that.bookingId,_that.homeLat,_that.homeLng,_that.schoolLat,_that.schoolLng,_that.driverId,_that.driverName,_that.driverPhone);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'booking_id')  String bookingId, @JsonKey(name: 'home_lat')  double? homeLat, @JsonKey(name: 'home_lng')  double? homeLng, @JsonKey(name: 'school_lat')  double? schoolLat, @JsonKey(name: 'school_lng')  double? schoolLng, @JsonKey(name: 'driver_id')  String? driverId, @JsonKey(name: 'driver_name')  String? driverName, @JsonKey(name: 'driver_phone')  String? driverPhone)  $default,) {final _that = this;
switch (_that) {
case _BookingLocation():
return $default(_that.bookingId,_that.homeLat,_that.homeLng,_that.schoolLat,_that.schoolLng,_that.driverId,_that.driverName,_that.driverPhone);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'booking_id')  String bookingId, @JsonKey(name: 'home_lat')  double? homeLat, @JsonKey(name: 'home_lng')  double? homeLng, @JsonKey(name: 'school_lat')  double? schoolLat, @JsonKey(name: 'school_lng')  double? schoolLng, @JsonKey(name: 'driver_id')  String? driverId, @JsonKey(name: 'driver_name')  String? driverName, @JsonKey(name: 'driver_phone')  String? driverPhone)?  $default,) {final _that = this;
switch (_that) {
case _BookingLocation() when $default != null:
return $default(_that.bookingId,_that.homeLat,_that.homeLng,_that.schoolLat,_that.schoolLng,_that.driverId,_that.driverName,_that.driverPhone);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BookingLocation extends BookingLocation {
  const _BookingLocation({@JsonKey(name: 'booking_id') required this.bookingId, @JsonKey(name: 'home_lat') this.homeLat, @JsonKey(name: 'home_lng') this.homeLng, @JsonKey(name: 'school_lat') this.schoolLat, @JsonKey(name: 'school_lng') this.schoolLng, @JsonKey(name: 'driver_id') this.driverId, @JsonKey(name: 'driver_name') this.driverName, @JsonKey(name: 'driver_phone') this.driverPhone}): super._();
  factory _BookingLocation.fromJson(Map<String, dynamic> json) => _$BookingLocationFromJson(json);

// booking_id is primary key of view
@override@JsonKey(name: 'booking_id') final  String bookingId;
@override@JsonKey(name: 'home_lat') final  double? homeLat;
@override@JsonKey(name: 'home_lng') final  double? homeLng;
@override@JsonKey(name: 'school_lat') final  double? schoolLat;
@override@JsonKey(name: 'school_lng') final  double? schoolLng;
@override@JsonKey(name: 'driver_id') final  String? driverId;
@override@JsonKey(name: 'driver_name') final  String? driverName;
@override@JsonKey(name: 'driver_phone') final  String? driverPhone;

/// Create a copy of BookingLocation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookingLocationCopyWith<_BookingLocation> get copyWith => __$BookingLocationCopyWithImpl<_BookingLocation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookingLocationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BookingLocation&&(identical(other.bookingId, bookingId) || other.bookingId == bookingId)&&(identical(other.homeLat, homeLat) || other.homeLat == homeLat)&&(identical(other.homeLng, homeLng) || other.homeLng == homeLng)&&(identical(other.schoolLat, schoolLat) || other.schoolLat == schoolLat)&&(identical(other.schoolLng, schoolLng) || other.schoolLng == schoolLng)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.driverName, driverName) || other.driverName == driverName)&&(identical(other.driverPhone, driverPhone) || other.driverPhone == driverPhone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bookingId,homeLat,homeLng,schoolLat,schoolLng,driverId,driverName,driverPhone);

@override
String toString() {
  return 'BookingLocation(bookingId: $bookingId, homeLat: $homeLat, homeLng: $homeLng, schoolLat: $schoolLat, schoolLng: $schoolLng, driverId: $driverId, driverName: $driverName, driverPhone: $driverPhone)';
}


}

/// @nodoc
abstract mixin class _$BookingLocationCopyWith<$Res> implements $BookingLocationCopyWith<$Res> {
  factory _$BookingLocationCopyWith(_BookingLocation value, $Res Function(_BookingLocation) _then) = __$BookingLocationCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'booking_id') String bookingId,@JsonKey(name: 'home_lat') double? homeLat,@JsonKey(name: 'home_lng') double? homeLng,@JsonKey(name: 'school_lat') double? schoolLat,@JsonKey(name: 'school_lng') double? schoolLng,@JsonKey(name: 'driver_id') String? driverId,@JsonKey(name: 'driver_name') String? driverName,@JsonKey(name: 'driver_phone') String? driverPhone
});




}
/// @nodoc
class __$BookingLocationCopyWithImpl<$Res>
    implements _$BookingLocationCopyWith<$Res> {
  __$BookingLocationCopyWithImpl(this._self, this._then);

  final _BookingLocation _self;
  final $Res Function(_BookingLocation) _then;

/// Create a copy of BookingLocation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bookingId = null,Object? homeLat = freezed,Object? homeLng = freezed,Object? schoolLat = freezed,Object? schoolLng = freezed,Object? driverId = freezed,Object? driverName = freezed,Object? driverPhone = freezed,}) {
  return _then(_BookingLocation(
bookingId: null == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String,homeLat: freezed == homeLat ? _self.homeLat : homeLat // ignore: cast_nullable_to_non_nullable
as double?,homeLng: freezed == homeLng ? _self.homeLng : homeLng // ignore: cast_nullable_to_non_nullable
as double?,schoolLat: freezed == schoolLat ? _self.schoolLat : schoolLat // ignore: cast_nullable_to_non_nullable
as double?,schoolLng: freezed == schoolLng ? _self.schoolLng : schoolLng // ignore: cast_nullable_to_non_nullable
as double?,driverId: freezed == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String?,driverName: freezed == driverName ? _self.driverName : driverName // ignore: cast_nullable_to_non_nullable
as String?,driverPhone: freezed == driverPhone ? _self.driverPhone : driverPhone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
