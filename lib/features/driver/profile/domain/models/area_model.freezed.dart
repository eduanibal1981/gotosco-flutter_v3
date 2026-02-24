// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'area_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AreaModel {

 String get id; String get cityId; String get name;
/// Create a copy of AreaModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AreaModelCopyWith<AreaModel> get copyWith => _$AreaModelCopyWithImpl<AreaModel>(this as AreaModel, _$identity);

  /// Serializes this AreaModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AreaModel&&(identical(other.id, id) || other.id == id)&&(identical(other.cityId, cityId) || other.cityId == cityId)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,cityId,name);

@override
String toString() {
  return 'AreaModel(id: $id, cityId: $cityId, name: $name)';
}


}

/// @nodoc
abstract mixin class $AreaModelCopyWith<$Res>  {
  factory $AreaModelCopyWith(AreaModel value, $Res Function(AreaModel) _then) = _$AreaModelCopyWithImpl;
@useResult
$Res call({
 String id, String cityId, String name
});




}
/// @nodoc
class _$AreaModelCopyWithImpl<$Res>
    implements $AreaModelCopyWith<$Res> {
  _$AreaModelCopyWithImpl(this._self, this._then);

  final AreaModel _self;
  final $Res Function(AreaModel) _then;

/// Create a copy of AreaModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? cityId = null,Object? name = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,cityId: null == cityId ? _self.cityId : cityId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AreaModel].
extension AreaModelPatterns on AreaModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AreaModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AreaModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AreaModel value)  $default,){
final _that = this;
switch (_that) {
case _AreaModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AreaModel value)?  $default,){
final _that = this;
switch (_that) {
case _AreaModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String cityId,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AreaModel() when $default != null:
return $default(_that.id,_that.cityId,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String cityId,  String name)  $default,) {final _that = this;
switch (_that) {
case _AreaModel():
return $default(_that.id,_that.cityId,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String cityId,  String name)?  $default,) {final _that = this;
switch (_that) {
case _AreaModel() when $default != null:
return $default(_that.id,_that.cityId,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AreaModel implements AreaModel {
  const _AreaModel({required this.id, required this.cityId, required this.name});
  factory _AreaModel.fromJson(Map<String, dynamic> json) => _$AreaModelFromJson(json);

@override final  String id;
@override final  String cityId;
@override final  String name;

/// Create a copy of AreaModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AreaModelCopyWith<_AreaModel> get copyWith => __$AreaModelCopyWithImpl<_AreaModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AreaModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AreaModel&&(identical(other.id, id) || other.id == id)&&(identical(other.cityId, cityId) || other.cityId == cityId)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,cityId,name);

@override
String toString() {
  return 'AreaModel(id: $id, cityId: $cityId, name: $name)';
}


}

/// @nodoc
abstract mixin class _$AreaModelCopyWith<$Res> implements $AreaModelCopyWith<$Res> {
  factory _$AreaModelCopyWith(_AreaModel value, $Res Function(_AreaModel) _then) = __$AreaModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String cityId, String name
});




}
/// @nodoc
class __$AreaModelCopyWithImpl<$Res>
    implements _$AreaModelCopyWith<$Res> {
  __$AreaModelCopyWithImpl(this._self, this._then);

  final _AreaModel _self;
  final $Res Function(_AreaModel) _then;

/// Create a copy of AreaModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? cityId = null,Object? name = null,}) {
  return _then(_AreaModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,cityId: null == cityId ? _self.cityId : cityId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
