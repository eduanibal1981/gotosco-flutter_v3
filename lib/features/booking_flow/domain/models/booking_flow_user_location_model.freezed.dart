// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking_flow_user_location_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BookingFlowUserLocationModel {

 String? get locationText; double? get locationLat; double? get locationLng;
/// Create a copy of BookingFlowUserLocationModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookingFlowUserLocationModelCopyWith<BookingFlowUserLocationModel> get copyWith => _$BookingFlowUserLocationModelCopyWithImpl<BookingFlowUserLocationModel>(this as BookingFlowUserLocationModel, _$identity);

  /// Serializes this BookingFlowUserLocationModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookingFlowUserLocationModel&&(identical(other.locationText, locationText) || other.locationText == locationText)&&(identical(other.locationLat, locationLat) || other.locationLat == locationLat)&&(identical(other.locationLng, locationLng) || other.locationLng == locationLng));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,locationText,locationLat,locationLng);

@override
String toString() {
  return 'BookingFlowUserLocationModel(locationText: $locationText, locationLat: $locationLat, locationLng: $locationLng)';
}


}

/// @nodoc
abstract mixin class $BookingFlowUserLocationModelCopyWith<$Res>  {
  factory $BookingFlowUserLocationModelCopyWith(BookingFlowUserLocationModel value, $Res Function(BookingFlowUserLocationModel) _then) = _$BookingFlowUserLocationModelCopyWithImpl;
@useResult
$Res call({
 String? locationText, double? locationLat, double? locationLng
});




}
/// @nodoc
class _$BookingFlowUserLocationModelCopyWithImpl<$Res>
    implements $BookingFlowUserLocationModelCopyWith<$Res> {
  _$BookingFlowUserLocationModelCopyWithImpl(this._self, this._then);

  final BookingFlowUserLocationModel _self;
  final $Res Function(BookingFlowUserLocationModel) _then;

/// Create a copy of BookingFlowUserLocationModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? locationText = freezed,Object? locationLat = freezed,Object? locationLng = freezed,}) {
  return _then(_self.copyWith(
locationText: freezed == locationText ? _self.locationText : locationText // ignore: cast_nullable_to_non_nullable
as String?,locationLat: freezed == locationLat ? _self.locationLat : locationLat // ignore: cast_nullable_to_non_nullable
as double?,locationLng: freezed == locationLng ? _self.locationLng : locationLng // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [BookingFlowUserLocationModel].
extension BookingFlowUserLocationModelPatterns on BookingFlowUserLocationModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BookingFlowUserLocationModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BookingFlowUserLocationModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BookingFlowUserLocationModel value)  $default,){
final _that = this;
switch (_that) {
case _BookingFlowUserLocationModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BookingFlowUserLocationModel value)?  $default,){
final _that = this;
switch (_that) {
case _BookingFlowUserLocationModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? locationText,  double? locationLat,  double? locationLng)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BookingFlowUserLocationModel() when $default != null:
return $default(_that.locationText,_that.locationLat,_that.locationLng);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? locationText,  double? locationLat,  double? locationLng)  $default,) {final _that = this;
switch (_that) {
case _BookingFlowUserLocationModel():
return $default(_that.locationText,_that.locationLat,_that.locationLng);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? locationText,  double? locationLat,  double? locationLng)?  $default,) {final _that = this;
switch (_that) {
case _BookingFlowUserLocationModel() when $default != null:
return $default(_that.locationText,_that.locationLat,_that.locationLng);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BookingFlowUserLocationModel implements BookingFlowUserLocationModel {
  const _BookingFlowUserLocationModel({this.locationText, this.locationLat, this.locationLng});
  factory _BookingFlowUserLocationModel.fromJson(Map<String, dynamic> json) => _$BookingFlowUserLocationModelFromJson(json);

@override final  String? locationText;
@override final  double? locationLat;
@override final  double? locationLng;

/// Create a copy of BookingFlowUserLocationModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookingFlowUserLocationModelCopyWith<_BookingFlowUserLocationModel> get copyWith => __$BookingFlowUserLocationModelCopyWithImpl<_BookingFlowUserLocationModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookingFlowUserLocationModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BookingFlowUserLocationModel&&(identical(other.locationText, locationText) || other.locationText == locationText)&&(identical(other.locationLat, locationLat) || other.locationLat == locationLat)&&(identical(other.locationLng, locationLng) || other.locationLng == locationLng));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,locationText,locationLat,locationLng);

@override
String toString() {
  return 'BookingFlowUserLocationModel(locationText: $locationText, locationLat: $locationLat, locationLng: $locationLng)';
}


}

/// @nodoc
abstract mixin class _$BookingFlowUserLocationModelCopyWith<$Res> implements $BookingFlowUserLocationModelCopyWith<$Res> {
  factory _$BookingFlowUserLocationModelCopyWith(_BookingFlowUserLocationModel value, $Res Function(_BookingFlowUserLocationModel) _then) = __$BookingFlowUserLocationModelCopyWithImpl;
@override @useResult
$Res call({
 String? locationText, double? locationLat, double? locationLng
});




}
/// @nodoc
class __$BookingFlowUserLocationModelCopyWithImpl<$Res>
    implements _$BookingFlowUserLocationModelCopyWith<$Res> {
  __$BookingFlowUserLocationModelCopyWithImpl(this._self, this._then);

  final _BookingFlowUserLocationModel _self;
  final $Res Function(_BookingFlowUserLocationModel) _then;

/// Create a copy of BookingFlowUserLocationModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? locationText = freezed,Object? locationLat = freezed,Object? locationLng = freezed,}) {
  return _then(_BookingFlowUserLocationModel(
locationText: freezed == locationText ? _self.locationText : locationText // ignore: cast_nullable_to_non_nullable
as String?,locationLat: freezed == locationLat ? _self.locationLat : locationLat // ignore: cast_nullable_to_non_nullable
as double?,locationLng: freezed == locationLng ? _self.locationLng : locationLng // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
