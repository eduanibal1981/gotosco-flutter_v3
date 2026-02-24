// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trip_category_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TripCategoryModel {

 String get id; String get label; String get icon; String? get description;
/// Create a copy of TripCategoryModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TripCategoryModelCopyWith<TripCategoryModel> get copyWith => _$TripCategoryModelCopyWithImpl<TripCategoryModel>(this as TripCategoryModel, _$identity);

  /// Serializes this TripCategoryModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TripCategoryModel&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,icon,description);

@override
String toString() {
  return 'TripCategoryModel(id: $id, label: $label, icon: $icon, description: $description)';
}


}

/// @nodoc
abstract mixin class $TripCategoryModelCopyWith<$Res>  {
  factory $TripCategoryModelCopyWith(TripCategoryModel value, $Res Function(TripCategoryModel) _then) = _$TripCategoryModelCopyWithImpl;
@useResult
$Res call({
 String id, String label, String icon, String? description
});




}
/// @nodoc
class _$TripCategoryModelCopyWithImpl<$Res>
    implements $TripCategoryModelCopyWith<$Res> {
  _$TripCategoryModelCopyWithImpl(this._self, this._then);

  final TripCategoryModel _self;
  final $Res Function(TripCategoryModel) _then;

/// Create a copy of TripCategoryModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,Object? icon = null,Object? description = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TripCategoryModel].
extension TripCategoryModelPatterns on TripCategoryModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TripCategoryModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TripCategoryModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TripCategoryModel value)  $default,){
final _that = this;
switch (_that) {
case _TripCategoryModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TripCategoryModel value)?  $default,){
final _that = this;
switch (_that) {
case _TripCategoryModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String label,  String icon,  String? description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TripCategoryModel() when $default != null:
return $default(_that.id,_that.label,_that.icon,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String label,  String icon,  String? description)  $default,) {final _that = this;
switch (_that) {
case _TripCategoryModel():
return $default(_that.id,_that.label,_that.icon,_that.description);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String label,  String icon,  String? description)?  $default,) {final _that = this;
switch (_that) {
case _TripCategoryModel() when $default != null:
return $default(_that.id,_that.label,_that.icon,_that.description);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TripCategoryModel extends TripCategoryModel {
  const _TripCategoryModel({required this.id, required this.label, required this.icon, this.description}): super._();
  factory _TripCategoryModel.fromJson(Map<String, dynamic> json) => _$TripCategoryModelFromJson(json);

@override final  String id;
@override final  String label;
@override final  String icon;
@override final  String? description;

/// Create a copy of TripCategoryModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TripCategoryModelCopyWith<_TripCategoryModel> get copyWith => __$TripCategoryModelCopyWithImpl<_TripCategoryModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TripCategoryModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TripCategoryModel&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,icon,description);

@override
String toString() {
  return 'TripCategoryModel(id: $id, label: $label, icon: $icon, description: $description)';
}


}

/// @nodoc
abstract mixin class _$TripCategoryModelCopyWith<$Res> implements $TripCategoryModelCopyWith<$Res> {
  factory _$TripCategoryModelCopyWith(_TripCategoryModel value, $Res Function(_TripCategoryModel) _then) = __$TripCategoryModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String label, String icon, String? description
});




}
/// @nodoc
class __$TripCategoryModelCopyWithImpl<$Res>
    implements _$TripCategoryModelCopyWith<$Res> {
  __$TripCategoryModelCopyWithImpl(this._self, this._then);

  final _TripCategoryModel _self;
  final $Res Function(_TripCategoryModel) _then;

/// Create a copy of TripCategoryModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? icon = null,Object? description = freezed,}) {
  return _then(_TripCategoryModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
