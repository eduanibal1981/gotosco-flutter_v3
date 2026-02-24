// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'driver_schedule_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DriverScheduleModel {

@JsonKey(name: 'id') String get id;// id might be omitted in creates? No, usually id exists on fetch.
// If creates, it might be null? The original model required id.
// I'll make it default to empty string if missing?
// Original had required id.
// On create, we don't need id? `createSchedule` takes model.
// If create, id might be empty string.
@JsonKey(name: 'driver_id') String get driverId;@JsonKey(name: 'day_of_week') String get dayOfWeek;@JsonKey(name: 'shift_type') String get shiftType;@JsonKey(name: 'available_from') String get availableFrom;@JsonKey(name: 'available_until') String get availableUntil;@JsonKey(name: 'max_capacity') int get maxCapacity;@JsonKey(name: 'is_schedactive') bool get isActive;
/// Create a copy of DriverScheduleModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriverScheduleModelCopyWith<DriverScheduleModel> get copyWith => _$DriverScheduleModelCopyWithImpl<DriverScheduleModel>(this as DriverScheduleModel, _$identity);

  /// Serializes this DriverScheduleModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriverScheduleModel&&(identical(other.id, id) || other.id == id)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.dayOfWeek, dayOfWeek) || other.dayOfWeek == dayOfWeek)&&(identical(other.shiftType, shiftType) || other.shiftType == shiftType)&&(identical(other.availableFrom, availableFrom) || other.availableFrom == availableFrom)&&(identical(other.availableUntil, availableUntil) || other.availableUntil == availableUntil)&&(identical(other.maxCapacity, maxCapacity) || other.maxCapacity == maxCapacity)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,driverId,dayOfWeek,shiftType,availableFrom,availableUntil,maxCapacity,isActive);

@override
String toString() {
  return 'DriverScheduleModel(id: $id, driverId: $driverId, dayOfWeek: $dayOfWeek, shiftType: $shiftType, availableFrom: $availableFrom, availableUntil: $availableUntil, maxCapacity: $maxCapacity, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class $DriverScheduleModelCopyWith<$Res>  {
  factory $DriverScheduleModelCopyWith(DriverScheduleModel value, $Res Function(DriverScheduleModel) _then) = _$DriverScheduleModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id') String id,@JsonKey(name: 'driver_id') String driverId,@JsonKey(name: 'day_of_week') String dayOfWeek,@JsonKey(name: 'shift_type') String shiftType,@JsonKey(name: 'available_from') String availableFrom,@JsonKey(name: 'available_until') String availableUntil,@JsonKey(name: 'max_capacity') int maxCapacity,@JsonKey(name: 'is_schedactive') bool isActive
});




}
/// @nodoc
class _$DriverScheduleModelCopyWithImpl<$Res>
    implements $DriverScheduleModelCopyWith<$Res> {
  _$DriverScheduleModelCopyWithImpl(this._self, this._then);

  final DriverScheduleModel _self;
  final $Res Function(DriverScheduleModel) _then;

/// Create a copy of DriverScheduleModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? driverId = null,Object? dayOfWeek = null,Object? shiftType = null,Object? availableFrom = null,Object? availableUntil = null,Object? maxCapacity = null,Object? isActive = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,driverId: null == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String,dayOfWeek: null == dayOfWeek ? _self.dayOfWeek : dayOfWeek // ignore: cast_nullable_to_non_nullable
as String,shiftType: null == shiftType ? _self.shiftType : shiftType // ignore: cast_nullable_to_non_nullable
as String,availableFrom: null == availableFrom ? _self.availableFrom : availableFrom // ignore: cast_nullable_to_non_nullable
as String,availableUntil: null == availableUntil ? _self.availableUntil : availableUntil // ignore: cast_nullable_to_non_nullable
as String,maxCapacity: null == maxCapacity ? _self.maxCapacity : maxCapacity // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [DriverScheduleModel].
extension DriverScheduleModelPatterns on DriverScheduleModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DriverScheduleModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DriverScheduleModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DriverScheduleModel value)  $default,){
final _that = this;
switch (_that) {
case _DriverScheduleModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DriverScheduleModel value)?  $default,){
final _that = this;
switch (_that) {
case _DriverScheduleModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  String id, @JsonKey(name: 'driver_id')  String driverId, @JsonKey(name: 'day_of_week')  String dayOfWeek, @JsonKey(name: 'shift_type')  String shiftType, @JsonKey(name: 'available_from')  String availableFrom, @JsonKey(name: 'available_until')  String availableUntil, @JsonKey(name: 'max_capacity')  int maxCapacity, @JsonKey(name: 'is_schedactive')  bool isActive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DriverScheduleModel() when $default != null:
return $default(_that.id,_that.driverId,_that.dayOfWeek,_that.shiftType,_that.availableFrom,_that.availableUntil,_that.maxCapacity,_that.isActive);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  String id, @JsonKey(name: 'driver_id')  String driverId, @JsonKey(name: 'day_of_week')  String dayOfWeek, @JsonKey(name: 'shift_type')  String shiftType, @JsonKey(name: 'available_from')  String availableFrom, @JsonKey(name: 'available_until')  String availableUntil, @JsonKey(name: 'max_capacity')  int maxCapacity, @JsonKey(name: 'is_schedactive')  bool isActive)  $default,) {final _that = this;
switch (_that) {
case _DriverScheduleModel():
return $default(_that.id,_that.driverId,_that.dayOfWeek,_that.shiftType,_that.availableFrom,_that.availableUntil,_that.maxCapacity,_that.isActive);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id')  String id, @JsonKey(name: 'driver_id')  String driverId, @JsonKey(name: 'day_of_week')  String dayOfWeek, @JsonKey(name: 'shift_type')  String shiftType, @JsonKey(name: 'available_from')  String availableFrom, @JsonKey(name: 'available_until')  String availableUntil, @JsonKey(name: 'max_capacity')  int maxCapacity, @JsonKey(name: 'is_schedactive')  bool isActive)?  $default,) {final _that = this;
switch (_that) {
case _DriverScheduleModel() when $default != null:
return $default(_that.id,_that.driverId,_that.dayOfWeek,_that.shiftType,_that.availableFrom,_that.availableUntil,_that.maxCapacity,_that.isActive);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DriverScheduleModel extends DriverScheduleModel {
  const _DriverScheduleModel({@JsonKey(name: 'id') this.id = '', @JsonKey(name: 'driver_id') required this.driverId, @JsonKey(name: 'day_of_week') required this.dayOfWeek, @JsonKey(name: 'shift_type') required this.shiftType, @JsonKey(name: 'available_from') required this.availableFrom, @JsonKey(name: 'available_until') required this.availableUntil, @JsonKey(name: 'max_capacity') this.maxCapacity = 8, @JsonKey(name: 'is_schedactive') this.isActive = true}): super._();
  factory _DriverScheduleModel.fromJson(Map<String, dynamic> json) => _$DriverScheduleModelFromJson(json);

@override@JsonKey(name: 'id') final  String id;
// id might be omitted in creates? No, usually id exists on fetch.
// If creates, it might be null? The original model required id.
// I'll make it default to empty string if missing?
// Original had required id.
// On create, we don't need id? `createSchedule` takes model.
// If create, id might be empty string.
@override@JsonKey(name: 'driver_id') final  String driverId;
@override@JsonKey(name: 'day_of_week') final  String dayOfWeek;
@override@JsonKey(name: 'shift_type') final  String shiftType;
@override@JsonKey(name: 'available_from') final  String availableFrom;
@override@JsonKey(name: 'available_until') final  String availableUntil;
@override@JsonKey(name: 'max_capacity') final  int maxCapacity;
@override@JsonKey(name: 'is_schedactive') final  bool isActive;

/// Create a copy of DriverScheduleModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DriverScheduleModelCopyWith<_DriverScheduleModel> get copyWith => __$DriverScheduleModelCopyWithImpl<_DriverScheduleModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DriverScheduleModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DriverScheduleModel&&(identical(other.id, id) || other.id == id)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.dayOfWeek, dayOfWeek) || other.dayOfWeek == dayOfWeek)&&(identical(other.shiftType, shiftType) || other.shiftType == shiftType)&&(identical(other.availableFrom, availableFrom) || other.availableFrom == availableFrom)&&(identical(other.availableUntil, availableUntil) || other.availableUntil == availableUntil)&&(identical(other.maxCapacity, maxCapacity) || other.maxCapacity == maxCapacity)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,driverId,dayOfWeek,shiftType,availableFrom,availableUntil,maxCapacity,isActive);

@override
String toString() {
  return 'DriverScheduleModel(id: $id, driverId: $driverId, dayOfWeek: $dayOfWeek, shiftType: $shiftType, availableFrom: $availableFrom, availableUntil: $availableUntil, maxCapacity: $maxCapacity, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class _$DriverScheduleModelCopyWith<$Res> implements $DriverScheduleModelCopyWith<$Res> {
  factory _$DriverScheduleModelCopyWith(_DriverScheduleModel value, $Res Function(_DriverScheduleModel) _then) = __$DriverScheduleModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id') String id,@JsonKey(name: 'driver_id') String driverId,@JsonKey(name: 'day_of_week') String dayOfWeek,@JsonKey(name: 'shift_type') String shiftType,@JsonKey(name: 'available_from') String availableFrom,@JsonKey(name: 'available_until') String availableUntil,@JsonKey(name: 'max_capacity') int maxCapacity,@JsonKey(name: 'is_schedactive') bool isActive
});




}
/// @nodoc
class __$DriverScheduleModelCopyWithImpl<$Res>
    implements _$DriverScheduleModelCopyWith<$Res> {
  __$DriverScheduleModelCopyWithImpl(this._self, this._then);

  final _DriverScheduleModel _self;
  final $Res Function(_DriverScheduleModel) _then;

/// Create a copy of DriverScheduleModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? driverId = null,Object? dayOfWeek = null,Object? shiftType = null,Object? availableFrom = null,Object? availableUntil = null,Object? maxCapacity = null,Object? isActive = null,}) {
  return _then(_DriverScheduleModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,driverId: null == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String,dayOfWeek: null == dayOfWeek ? _self.dayOfWeek : dayOfWeek // ignore: cast_nullable_to_non_nullable
as String,shiftType: null == shiftType ? _self.shiftType : shiftType // ignore: cast_nullable_to_non_nullable
as String,availableFrom: null == availableFrom ? _self.availableFrom : availableFrom // ignore: cast_nullable_to_non_nullable
as String,availableUntil: null == availableUntil ? _self.availableUntil : availableUntil // ignore: cast_nullable_to_non_nullable
as String,maxCapacity: null == maxCapacity ? _self.maxCapacity : maxCapacity // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
