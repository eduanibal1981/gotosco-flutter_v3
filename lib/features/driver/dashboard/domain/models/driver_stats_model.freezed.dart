// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'driver_stats_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DriverStats {

@JsonKey(name: 'driver_id') String get driverId;@JsonKey(name: 'active_students') int get activeStudents;@JsonKey(name: 'pending_requests') int get pendingRequests;@JsonKey(name: 'active_bookings') int get activeBookings;@JsonKey(name: 'monthly_earnings') double get monthlyEarnings;
/// Create a copy of DriverStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriverStatsCopyWith<DriverStats> get copyWith => _$DriverStatsCopyWithImpl<DriverStats>(this as DriverStats, _$identity);

  /// Serializes this DriverStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriverStats&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.activeStudents, activeStudents) || other.activeStudents == activeStudents)&&(identical(other.pendingRequests, pendingRequests) || other.pendingRequests == pendingRequests)&&(identical(other.activeBookings, activeBookings) || other.activeBookings == activeBookings)&&(identical(other.monthlyEarnings, monthlyEarnings) || other.monthlyEarnings == monthlyEarnings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,driverId,activeStudents,pendingRequests,activeBookings,monthlyEarnings);

@override
String toString() {
  return 'DriverStats(driverId: $driverId, activeStudents: $activeStudents, pendingRequests: $pendingRequests, activeBookings: $activeBookings, monthlyEarnings: $monthlyEarnings)';
}


}

/// @nodoc
abstract mixin class $DriverStatsCopyWith<$Res>  {
  factory $DriverStatsCopyWith(DriverStats value, $Res Function(DriverStats) _then) = _$DriverStatsCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'driver_id') String driverId,@JsonKey(name: 'active_students') int activeStudents,@JsonKey(name: 'pending_requests') int pendingRequests,@JsonKey(name: 'active_bookings') int activeBookings,@JsonKey(name: 'monthly_earnings') double monthlyEarnings
});




}
/// @nodoc
class _$DriverStatsCopyWithImpl<$Res>
    implements $DriverStatsCopyWith<$Res> {
  _$DriverStatsCopyWithImpl(this._self, this._then);

  final DriverStats _self;
  final $Res Function(DriverStats) _then;

/// Create a copy of DriverStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? driverId = null,Object? activeStudents = null,Object? pendingRequests = null,Object? activeBookings = null,Object? monthlyEarnings = null,}) {
  return _then(_self.copyWith(
driverId: null == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String,activeStudents: null == activeStudents ? _self.activeStudents : activeStudents // ignore: cast_nullable_to_non_nullable
as int,pendingRequests: null == pendingRequests ? _self.pendingRequests : pendingRequests // ignore: cast_nullable_to_non_nullable
as int,activeBookings: null == activeBookings ? _self.activeBookings : activeBookings // ignore: cast_nullable_to_non_nullable
as int,monthlyEarnings: null == monthlyEarnings ? _self.monthlyEarnings : monthlyEarnings // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [DriverStats].
extension DriverStatsPatterns on DriverStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DriverStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DriverStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DriverStats value)  $default,){
final _that = this;
switch (_that) {
case _DriverStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DriverStats value)?  $default,){
final _that = this;
switch (_that) {
case _DriverStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'driver_id')  String driverId, @JsonKey(name: 'active_students')  int activeStudents, @JsonKey(name: 'pending_requests')  int pendingRequests, @JsonKey(name: 'active_bookings')  int activeBookings, @JsonKey(name: 'monthly_earnings')  double monthlyEarnings)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DriverStats() when $default != null:
return $default(_that.driverId,_that.activeStudents,_that.pendingRequests,_that.activeBookings,_that.monthlyEarnings);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'driver_id')  String driverId, @JsonKey(name: 'active_students')  int activeStudents, @JsonKey(name: 'pending_requests')  int pendingRequests, @JsonKey(name: 'active_bookings')  int activeBookings, @JsonKey(name: 'monthly_earnings')  double monthlyEarnings)  $default,) {final _that = this;
switch (_that) {
case _DriverStats():
return $default(_that.driverId,_that.activeStudents,_that.pendingRequests,_that.activeBookings,_that.monthlyEarnings);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'driver_id')  String driverId, @JsonKey(name: 'active_students')  int activeStudents, @JsonKey(name: 'pending_requests')  int pendingRequests, @JsonKey(name: 'active_bookings')  int activeBookings, @JsonKey(name: 'monthly_earnings')  double monthlyEarnings)?  $default,) {final _that = this;
switch (_that) {
case _DriverStats() when $default != null:
return $default(_that.driverId,_that.activeStudents,_that.pendingRequests,_that.activeBookings,_that.monthlyEarnings);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DriverStats extends DriverStats {
  const _DriverStats({@JsonKey(name: 'driver_id') required this.driverId, @JsonKey(name: 'active_students') this.activeStudents = 0, @JsonKey(name: 'pending_requests') this.pendingRequests = 0, @JsonKey(name: 'active_bookings') this.activeBookings = 0, @JsonKey(name: 'monthly_earnings') this.monthlyEarnings = 0}): super._();
  factory _DriverStats.fromJson(Map<String, dynamic> json) => _$DriverStatsFromJson(json);

@override@JsonKey(name: 'driver_id') final  String driverId;
@override@JsonKey(name: 'active_students') final  int activeStudents;
@override@JsonKey(name: 'pending_requests') final  int pendingRequests;
@override@JsonKey(name: 'active_bookings') final  int activeBookings;
@override@JsonKey(name: 'monthly_earnings') final  double monthlyEarnings;

/// Create a copy of DriverStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DriverStatsCopyWith<_DriverStats> get copyWith => __$DriverStatsCopyWithImpl<_DriverStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DriverStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DriverStats&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.activeStudents, activeStudents) || other.activeStudents == activeStudents)&&(identical(other.pendingRequests, pendingRequests) || other.pendingRequests == pendingRequests)&&(identical(other.activeBookings, activeBookings) || other.activeBookings == activeBookings)&&(identical(other.monthlyEarnings, monthlyEarnings) || other.monthlyEarnings == monthlyEarnings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,driverId,activeStudents,pendingRequests,activeBookings,monthlyEarnings);

@override
String toString() {
  return 'DriverStats(driverId: $driverId, activeStudents: $activeStudents, pendingRequests: $pendingRequests, activeBookings: $activeBookings, monthlyEarnings: $monthlyEarnings)';
}


}

/// @nodoc
abstract mixin class _$DriverStatsCopyWith<$Res> implements $DriverStatsCopyWith<$Res> {
  factory _$DriverStatsCopyWith(_DriverStats value, $Res Function(_DriverStats) _then) = __$DriverStatsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'driver_id') String driverId,@JsonKey(name: 'active_students') int activeStudents,@JsonKey(name: 'pending_requests') int pendingRequests,@JsonKey(name: 'active_bookings') int activeBookings,@JsonKey(name: 'monthly_earnings') double monthlyEarnings
});




}
/// @nodoc
class __$DriverStatsCopyWithImpl<$Res>
    implements _$DriverStatsCopyWith<$Res> {
  __$DriverStatsCopyWithImpl(this._self, this._then);

  final _DriverStats _self;
  final $Res Function(_DriverStats) _then;

/// Create a copy of DriverStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? driverId = null,Object? activeStudents = null,Object? pendingRequests = null,Object? activeBookings = null,Object? monthlyEarnings = null,}) {
  return _then(_DriverStats(
driverId: null == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String,activeStudents: null == activeStudents ? _self.activeStudents : activeStudents // ignore: cast_nullable_to_non_nullable
as int,pendingRequests: null == pendingRequests ? _self.pendingRequests : pendingRequests // ignore: cast_nullable_to_non_nullable
as int,activeBookings: null == activeBookings ? _self.activeBookings : activeBookings // ignore: cast_nullable_to_non_nullable
as int,monthlyEarnings: null == monthlyEarnings ? _self.monthlyEarnings : monthlyEarnings // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
