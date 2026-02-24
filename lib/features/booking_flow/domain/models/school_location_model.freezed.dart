// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'school_location_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SchoolLocationModel {

 String get schoolId; String get schoolName; String? get schoolAddress; double? get latitude; double? get longitude; List<String> get studentIds; int? get sequenceOrder;
/// Create a copy of SchoolLocationModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SchoolLocationModelCopyWith<SchoolLocationModel> get copyWith => _$SchoolLocationModelCopyWithImpl<SchoolLocationModel>(this as SchoolLocationModel, _$identity);

  /// Serializes this SchoolLocationModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SchoolLocationModel&&(identical(other.schoolId, schoolId) || other.schoolId == schoolId)&&(identical(other.schoolName, schoolName) || other.schoolName == schoolName)&&(identical(other.schoolAddress, schoolAddress) || other.schoolAddress == schoolAddress)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&const DeepCollectionEquality().equals(other.studentIds, studentIds)&&(identical(other.sequenceOrder, sequenceOrder) || other.sequenceOrder == sequenceOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schoolId,schoolName,schoolAddress,latitude,longitude,const DeepCollectionEquality().hash(studentIds),sequenceOrder);

@override
String toString() {
  return 'SchoolLocationModel(schoolId: $schoolId, schoolName: $schoolName, schoolAddress: $schoolAddress, latitude: $latitude, longitude: $longitude, studentIds: $studentIds, sequenceOrder: $sequenceOrder)';
}


}

/// @nodoc
abstract mixin class $SchoolLocationModelCopyWith<$Res>  {
  factory $SchoolLocationModelCopyWith(SchoolLocationModel value, $Res Function(SchoolLocationModel) _then) = _$SchoolLocationModelCopyWithImpl;
@useResult
$Res call({
 String schoolId, String schoolName, String? schoolAddress, double? latitude, double? longitude, List<String> studentIds, int? sequenceOrder
});




}
/// @nodoc
class _$SchoolLocationModelCopyWithImpl<$Res>
    implements $SchoolLocationModelCopyWith<$Res> {
  _$SchoolLocationModelCopyWithImpl(this._self, this._then);

  final SchoolLocationModel _self;
  final $Res Function(SchoolLocationModel) _then;

/// Create a copy of SchoolLocationModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schoolId = null,Object? schoolName = null,Object? schoolAddress = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? studentIds = null,Object? sequenceOrder = freezed,}) {
  return _then(_self.copyWith(
schoolId: null == schoolId ? _self.schoolId : schoolId // ignore: cast_nullable_to_non_nullable
as String,schoolName: null == schoolName ? _self.schoolName : schoolName // ignore: cast_nullable_to_non_nullable
as String,schoolAddress: freezed == schoolAddress ? _self.schoolAddress : schoolAddress // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,studentIds: null == studentIds ? _self.studentIds : studentIds // ignore: cast_nullable_to_non_nullable
as List<String>,sequenceOrder: freezed == sequenceOrder ? _self.sequenceOrder : sequenceOrder // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [SchoolLocationModel].
extension SchoolLocationModelPatterns on SchoolLocationModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SchoolLocationModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SchoolLocationModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SchoolLocationModel value)  $default,){
final _that = this;
switch (_that) {
case _SchoolLocationModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SchoolLocationModel value)?  $default,){
final _that = this;
switch (_that) {
case _SchoolLocationModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String schoolId,  String schoolName,  String? schoolAddress,  double? latitude,  double? longitude,  List<String> studentIds,  int? sequenceOrder)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SchoolLocationModel() when $default != null:
return $default(_that.schoolId,_that.schoolName,_that.schoolAddress,_that.latitude,_that.longitude,_that.studentIds,_that.sequenceOrder);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String schoolId,  String schoolName,  String? schoolAddress,  double? latitude,  double? longitude,  List<String> studentIds,  int? sequenceOrder)  $default,) {final _that = this;
switch (_that) {
case _SchoolLocationModel():
return $default(_that.schoolId,_that.schoolName,_that.schoolAddress,_that.latitude,_that.longitude,_that.studentIds,_that.sequenceOrder);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String schoolId,  String schoolName,  String? schoolAddress,  double? latitude,  double? longitude,  List<String> studentIds,  int? sequenceOrder)?  $default,) {final _that = this;
switch (_that) {
case _SchoolLocationModel() when $default != null:
return $default(_that.schoolId,_that.schoolName,_that.schoolAddress,_that.latitude,_that.longitude,_that.studentIds,_that.sequenceOrder);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SchoolLocationModel implements SchoolLocationModel {
  const _SchoolLocationModel({required this.schoolId, required this.schoolName, this.schoolAddress, this.latitude, this.longitude, final  List<String> studentIds = const [], this.sequenceOrder}): _studentIds = studentIds;
  factory _SchoolLocationModel.fromJson(Map<String, dynamic> json) => _$SchoolLocationModelFromJson(json);

@override final  String schoolId;
@override final  String schoolName;
@override final  String? schoolAddress;
@override final  double? latitude;
@override final  double? longitude;
 final  List<String> _studentIds;
@override@JsonKey() List<String> get studentIds {
  if (_studentIds is EqualUnmodifiableListView) return _studentIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_studentIds);
}

@override final  int? sequenceOrder;

/// Create a copy of SchoolLocationModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SchoolLocationModelCopyWith<_SchoolLocationModel> get copyWith => __$SchoolLocationModelCopyWithImpl<_SchoolLocationModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SchoolLocationModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SchoolLocationModel&&(identical(other.schoolId, schoolId) || other.schoolId == schoolId)&&(identical(other.schoolName, schoolName) || other.schoolName == schoolName)&&(identical(other.schoolAddress, schoolAddress) || other.schoolAddress == schoolAddress)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&const DeepCollectionEquality().equals(other._studentIds, _studentIds)&&(identical(other.sequenceOrder, sequenceOrder) || other.sequenceOrder == sequenceOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schoolId,schoolName,schoolAddress,latitude,longitude,const DeepCollectionEquality().hash(_studentIds),sequenceOrder);

@override
String toString() {
  return 'SchoolLocationModel(schoolId: $schoolId, schoolName: $schoolName, schoolAddress: $schoolAddress, latitude: $latitude, longitude: $longitude, studentIds: $studentIds, sequenceOrder: $sequenceOrder)';
}


}

/// @nodoc
abstract mixin class _$SchoolLocationModelCopyWith<$Res> implements $SchoolLocationModelCopyWith<$Res> {
  factory _$SchoolLocationModelCopyWith(_SchoolLocationModel value, $Res Function(_SchoolLocationModel) _then) = __$SchoolLocationModelCopyWithImpl;
@override @useResult
$Res call({
 String schoolId, String schoolName, String? schoolAddress, double? latitude, double? longitude, List<String> studentIds, int? sequenceOrder
});




}
/// @nodoc
class __$SchoolLocationModelCopyWithImpl<$Res>
    implements _$SchoolLocationModelCopyWith<$Res> {
  __$SchoolLocationModelCopyWithImpl(this._self, this._then);

  final _SchoolLocationModel _self;
  final $Res Function(_SchoolLocationModel) _then;

/// Create a copy of SchoolLocationModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schoolId = null,Object? schoolName = null,Object? schoolAddress = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? studentIds = null,Object? sequenceOrder = freezed,}) {
  return _then(_SchoolLocationModel(
schoolId: null == schoolId ? _self.schoolId : schoolId // ignore: cast_nullable_to_non_nullable
as String,schoolName: null == schoolName ? _self.schoolName : schoolName // ignore: cast_nullable_to_non_nullable
as String,schoolAddress: freezed == schoolAddress ? _self.schoolAddress : schoolAddress // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,studentIds: null == studentIds ? _self._studentIds : studentIds // ignore: cast_nullable_to_non_nullable
as List<String>,sequenceOrder: freezed == sequenceOrder ? _self.sequenceOrder : sequenceOrder // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
