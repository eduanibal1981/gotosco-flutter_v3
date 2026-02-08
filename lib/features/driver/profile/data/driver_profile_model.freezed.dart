// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'driver_profile_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DriverProfileModel {

 String get id; String get userId; String get name; String? get photoUrl; String get phone; String get email;@JsonKey(name: 'experience_years') int get experienceYears;@JsonKey(name: 'license_number') String? get licenseNumber;@JsonKey(name: 'license_expiry') DateTime? get licenseExpiry;@JsonKey(name: 'license_image_url') String? get licenseImageUrl;@JsonKey(name: 'vehicle_type') String get vehicleType;@JsonKey(name: 'vehicle_number') String? get vehicleNumber;@JsonKey(name: 'vehicle_capacity') int get vehicleCapacity;@JsonKey(name: 'mulkia_image_url') String? get mulkiaImageUrl;@JsonKey(name: 'vehicle_image_urls') List<String> get vehicleImageUrls;@JsonKey(name: 'price_monthly_two_way') double get priceMonthlyTwoWay;@JsonKey(name: 'price_monthly_one_way') double get priceMonthlyOneWay;@JsonKey(name: 'price_daily') double get priceDaily; String get bio; double get rating;@JsonKey(name: 'total_reviews') int get totalReviews;@JsonKey(name: 'is_verified') bool get isVerified;@JsonKey(name: 'license_verified') bool get licenseVerified;@JsonKey(name: 'insurance_verified') bool get insuranceVerified;@JsonKey(name: 'background_check_verified') bool get backgroundCheckVerified;@JsonKey(name: 'service_areas') List<String> get serviceAreas; List<String> get schools;@JsonKey(name: 'location_text') String? get locationText;@JsonKey(name: 'location_lat') double? get locationLat;@JsonKey(name: 'location_lng') double? get locationLng;@JsonKey(name: 'start_location_text') String? get startLocationText;@JsonKey(name: 'start_location_lat') double? get startLocationLat;@JsonKey(name: 'start_location_lng') double? get startLocationLng;
/// Create a copy of DriverProfileModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriverProfileModelCopyWith<DriverProfileModel> get copyWith => _$DriverProfileModelCopyWithImpl<DriverProfileModel>(this as DriverProfileModel, _$identity);

  /// Serializes this DriverProfileModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriverProfileModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.experienceYears, experienceYears) || other.experienceYears == experienceYears)&&(identical(other.licenseNumber, licenseNumber) || other.licenseNumber == licenseNumber)&&(identical(other.licenseExpiry, licenseExpiry) || other.licenseExpiry == licenseExpiry)&&(identical(other.licenseImageUrl, licenseImageUrl) || other.licenseImageUrl == licenseImageUrl)&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&(identical(other.vehicleNumber, vehicleNumber) || other.vehicleNumber == vehicleNumber)&&(identical(other.vehicleCapacity, vehicleCapacity) || other.vehicleCapacity == vehicleCapacity)&&(identical(other.mulkiaImageUrl, mulkiaImageUrl) || other.mulkiaImageUrl == mulkiaImageUrl)&&const DeepCollectionEquality().equals(other.vehicleImageUrls, vehicleImageUrls)&&(identical(other.priceMonthlyTwoWay, priceMonthlyTwoWay) || other.priceMonthlyTwoWay == priceMonthlyTwoWay)&&(identical(other.priceMonthlyOneWay, priceMonthlyOneWay) || other.priceMonthlyOneWay == priceMonthlyOneWay)&&(identical(other.priceDaily, priceDaily) || other.priceDaily == priceDaily)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.totalReviews, totalReviews) || other.totalReviews == totalReviews)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.licenseVerified, licenseVerified) || other.licenseVerified == licenseVerified)&&(identical(other.insuranceVerified, insuranceVerified) || other.insuranceVerified == insuranceVerified)&&(identical(other.backgroundCheckVerified, backgroundCheckVerified) || other.backgroundCheckVerified == backgroundCheckVerified)&&const DeepCollectionEquality().equals(other.serviceAreas, serviceAreas)&&const DeepCollectionEquality().equals(other.schools, schools)&&(identical(other.locationText, locationText) || other.locationText == locationText)&&(identical(other.locationLat, locationLat) || other.locationLat == locationLat)&&(identical(other.locationLng, locationLng) || other.locationLng == locationLng)&&(identical(other.startLocationText, startLocationText) || other.startLocationText == startLocationText)&&(identical(other.startLocationLat, startLocationLat) || other.startLocationLat == startLocationLat)&&(identical(other.startLocationLng, startLocationLng) || other.startLocationLng == startLocationLng));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,userId,name,photoUrl,phone,email,experienceYears,licenseNumber,licenseExpiry,licenseImageUrl,vehicleType,vehicleNumber,vehicleCapacity,mulkiaImageUrl,const DeepCollectionEquality().hash(vehicleImageUrls),priceMonthlyTwoWay,priceMonthlyOneWay,priceDaily,bio,rating,totalReviews,isVerified,licenseVerified,insuranceVerified,backgroundCheckVerified,const DeepCollectionEquality().hash(serviceAreas),const DeepCollectionEquality().hash(schools),locationText,locationLat,locationLng,startLocationText,startLocationLat,startLocationLng]);

@override
String toString() {
  return 'DriverProfileModel(id: $id, userId: $userId, name: $name, photoUrl: $photoUrl, phone: $phone, email: $email, experienceYears: $experienceYears, licenseNumber: $licenseNumber, licenseExpiry: $licenseExpiry, licenseImageUrl: $licenseImageUrl, vehicleType: $vehicleType, vehicleNumber: $vehicleNumber, vehicleCapacity: $vehicleCapacity, mulkiaImageUrl: $mulkiaImageUrl, vehicleImageUrls: $vehicleImageUrls, priceMonthlyTwoWay: $priceMonthlyTwoWay, priceMonthlyOneWay: $priceMonthlyOneWay, priceDaily: $priceDaily, bio: $bio, rating: $rating, totalReviews: $totalReviews, isVerified: $isVerified, licenseVerified: $licenseVerified, insuranceVerified: $insuranceVerified, backgroundCheckVerified: $backgroundCheckVerified, serviceAreas: $serviceAreas, schools: $schools, locationText: $locationText, locationLat: $locationLat, locationLng: $locationLng, startLocationText: $startLocationText, startLocationLat: $startLocationLat, startLocationLng: $startLocationLng)';
}


}

/// @nodoc
abstract mixin class $DriverProfileModelCopyWith<$Res>  {
  factory $DriverProfileModelCopyWith(DriverProfileModel value, $Res Function(DriverProfileModel) _then) = _$DriverProfileModelCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String name, String? photoUrl, String phone, String email,@JsonKey(name: 'experience_years') int experienceYears,@JsonKey(name: 'license_number') String? licenseNumber,@JsonKey(name: 'license_expiry') DateTime? licenseExpiry,@JsonKey(name: 'license_image_url') String? licenseImageUrl,@JsonKey(name: 'vehicle_type') String vehicleType,@JsonKey(name: 'vehicle_number') String? vehicleNumber,@JsonKey(name: 'vehicle_capacity') int vehicleCapacity,@JsonKey(name: 'mulkia_image_url') String? mulkiaImageUrl,@JsonKey(name: 'vehicle_image_urls') List<String> vehicleImageUrls,@JsonKey(name: 'price_monthly_two_way') double priceMonthlyTwoWay,@JsonKey(name: 'price_monthly_one_way') double priceMonthlyOneWay,@JsonKey(name: 'price_daily') double priceDaily, String bio, double rating,@JsonKey(name: 'total_reviews') int totalReviews,@JsonKey(name: 'is_verified') bool isVerified,@JsonKey(name: 'license_verified') bool licenseVerified,@JsonKey(name: 'insurance_verified') bool insuranceVerified,@JsonKey(name: 'background_check_verified') bool backgroundCheckVerified,@JsonKey(name: 'service_areas') List<String> serviceAreas, List<String> schools,@JsonKey(name: 'location_text') String? locationText,@JsonKey(name: 'location_lat') double? locationLat,@JsonKey(name: 'location_lng') double? locationLng,@JsonKey(name: 'start_location_text') String? startLocationText,@JsonKey(name: 'start_location_lat') double? startLocationLat,@JsonKey(name: 'start_location_lng') double? startLocationLng
});




}
/// @nodoc
class _$DriverProfileModelCopyWithImpl<$Res>
    implements $DriverProfileModelCopyWith<$Res> {
  _$DriverProfileModelCopyWithImpl(this._self, this._then);

  final DriverProfileModel _self;
  final $Res Function(DriverProfileModel) _then;

/// Create a copy of DriverProfileModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? photoUrl = freezed,Object? phone = null,Object? email = null,Object? experienceYears = null,Object? licenseNumber = freezed,Object? licenseExpiry = freezed,Object? licenseImageUrl = freezed,Object? vehicleType = null,Object? vehicleNumber = freezed,Object? vehicleCapacity = null,Object? mulkiaImageUrl = freezed,Object? vehicleImageUrls = null,Object? priceMonthlyTwoWay = null,Object? priceMonthlyOneWay = null,Object? priceDaily = null,Object? bio = null,Object? rating = null,Object? totalReviews = null,Object? isVerified = null,Object? licenseVerified = null,Object? insuranceVerified = null,Object? backgroundCheckVerified = null,Object? serviceAreas = null,Object? schools = null,Object? locationText = freezed,Object? locationLat = freezed,Object? locationLng = freezed,Object? startLocationText = freezed,Object? startLocationLat = freezed,Object? startLocationLng = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,experienceYears: null == experienceYears ? _self.experienceYears : experienceYears // ignore: cast_nullable_to_non_nullable
as int,licenseNumber: freezed == licenseNumber ? _self.licenseNumber : licenseNumber // ignore: cast_nullable_to_non_nullable
as String?,licenseExpiry: freezed == licenseExpiry ? _self.licenseExpiry : licenseExpiry // ignore: cast_nullable_to_non_nullable
as DateTime?,licenseImageUrl: freezed == licenseImageUrl ? _self.licenseImageUrl : licenseImageUrl // ignore: cast_nullable_to_non_nullable
as String?,vehicleType: null == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as String,vehicleNumber: freezed == vehicleNumber ? _self.vehicleNumber : vehicleNumber // ignore: cast_nullable_to_non_nullable
as String?,vehicleCapacity: null == vehicleCapacity ? _self.vehicleCapacity : vehicleCapacity // ignore: cast_nullable_to_non_nullable
as int,mulkiaImageUrl: freezed == mulkiaImageUrl ? _self.mulkiaImageUrl : mulkiaImageUrl // ignore: cast_nullable_to_non_nullable
as String?,vehicleImageUrls: null == vehicleImageUrls ? _self.vehicleImageUrls : vehicleImageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,priceMonthlyTwoWay: null == priceMonthlyTwoWay ? _self.priceMonthlyTwoWay : priceMonthlyTwoWay // ignore: cast_nullable_to_non_nullable
as double,priceMonthlyOneWay: null == priceMonthlyOneWay ? _self.priceMonthlyOneWay : priceMonthlyOneWay // ignore: cast_nullable_to_non_nullable
as double,priceDaily: null == priceDaily ? _self.priceDaily : priceDaily // ignore: cast_nullable_to_non_nullable
as double,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,totalReviews: null == totalReviews ? _self.totalReviews : totalReviews // ignore: cast_nullable_to_non_nullable
as int,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,licenseVerified: null == licenseVerified ? _self.licenseVerified : licenseVerified // ignore: cast_nullable_to_non_nullable
as bool,insuranceVerified: null == insuranceVerified ? _self.insuranceVerified : insuranceVerified // ignore: cast_nullable_to_non_nullable
as bool,backgroundCheckVerified: null == backgroundCheckVerified ? _self.backgroundCheckVerified : backgroundCheckVerified // ignore: cast_nullable_to_non_nullable
as bool,serviceAreas: null == serviceAreas ? _self.serviceAreas : serviceAreas // ignore: cast_nullable_to_non_nullable
as List<String>,schools: null == schools ? _self.schools : schools // ignore: cast_nullable_to_non_nullable
as List<String>,locationText: freezed == locationText ? _self.locationText : locationText // ignore: cast_nullable_to_non_nullable
as String?,locationLat: freezed == locationLat ? _self.locationLat : locationLat // ignore: cast_nullable_to_non_nullable
as double?,locationLng: freezed == locationLng ? _self.locationLng : locationLng // ignore: cast_nullable_to_non_nullable
as double?,startLocationText: freezed == startLocationText ? _self.startLocationText : startLocationText // ignore: cast_nullable_to_non_nullable
as String?,startLocationLat: freezed == startLocationLat ? _self.startLocationLat : startLocationLat // ignore: cast_nullable_to_non_nullable
as double?,startLocationLng: freezed == startLocationLng ? _self.startLocationLng : startLocationLng // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [DriverProfileModel].
extension DriverProfileModelPatterns on DriverProfileModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DriverProfileModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DriverProfileModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DriverProfileModel value)  $default,){
final _that = this;
switch (_that) {
case _DriverProfileModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DriverProfileModel value)?  $default,){
final _that = this;
switch (_that) {
case _DriverProfileModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String name,  String? photoUrl,  String phone,  String email, @JsonKey(name: 'experience_years')  int experienceYears, @JsonKey(name: 'license_number')  String? licenseNumber, @JsonKey(name: 'license_expiry')  DateTime? licenseExpiry, @JsonKey(name: 'license_image_url')  String? licenseImageUrl, @JsonKey(name: 'vehicle_type')  String vehicleType, @JsonKey(name: 'vehicle_number')  String? vehicleNumber, @JsonKey(name: 'vehicle_capacity')  int vehicleCapacity, @JsonKey(name: 'mulkia_image_url')  String? mulkiaImageUrl, @JsonKey(name: 'vehicle_image_urls')  List<String> vehicleImageUrls, @JsonKey(name: 'price_monthly_two_way')  double priceMonthlyTwoWay, @JsonKey(name: 'price_monthly_one_way')  double priceMonthlyOneWay, @JsonKey(name: 'price_daily')  double priceDaily,  String bio,  double rating, @JsonKey(name: 'total_reviews')  int totalReviews, @JsonKey(name: 'is_verified')  bool isVerified, @JsonKey(name: 'license_verified')  bool licenseVerified, @JsonKey(name: 'insurance_verified')  bool insuranceVerified, @JsonKey(name: 'background_check_verified')  bool backgroundCheckVerified, @JsonKey(name: 'service_areas')  List<String> serviceAreas,  List<String> schools, @JsonKey(name: 'location_text')  String? locationText, @JsonKey(name: 'location_lat')  double? locationLat, @JsonKey(name: 'location_lng')  double? locationLng, @JsonKey(name: 'start_location_text')  String? startLocationText, @JsonKey(name: 'start_location_lat')  double? startLocationLat, @JsonKey(name: 'start_location_lng')  double? startLocationLng)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DriverProfileModel() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.photoUrl,_that.phone,_that.email,_that.experienceYears,_that.licenseNumber,_that.licenseExpiry,_that.licenseImageUrl,_that.vehicleType,_that.vehicleNumber,_that.vehicleCapacity,_that.mulkiaImageUrl,_that.vehicleImageUrls,_that.priceMonthlyTwoWay,_that.priceMonthlyOneWay,_that.priceDaily,_that.bio,_that.rating,_that.totalReviews,_that.isVerified,_that.licenseVerified,_that.insuranceVerified,_that.backgroundCheckVerified,_that.serviceAreas,_that.schools,_that.locationText,_that.locationLat,_that.locationLng,_that.startLocationText,_that.startLocationLat,_that.startLocationLng);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String name,  String? photoUrl,  String phone,  String email, @JsonKey(name: 'experience_years')  int experienceYears, @JsonKey(name: 'license_number')  String? licenseNumber, @JsonKey(name: 'license_expiry')  DateTime? licenseExpiry, @JsonKey(name: 'license_image_url')  String? licenseImageUrl, @JsonKey(name: 'vehicle_type')  String vehicleType, @JsonKey(name: 'vehicle_number')  String? vehicleNumber, @JsonKey(name: 'vehicle_capacity')  int vehicleCapacity, @JsonKey(name: 'mulkia_image_url')  String? mulkiaImageUrl, @JsonKey(name: 'vehicle_image_urls')  List<String> vehicleImageUrls, @JsonKey(name: 'price_monthly_two_way')  double priceMonthlyTwoWay, @JsonKey(name: 'price_monthly_one_way')  double priceMonthlyOneWay, @JsonKey(name: 'price_daily')  double priceDaily,  String bio,  double rating, @JsonKey(name: 'total_reviews')  int totalReviews, @JsonKey(name: 'is_verified')  bool isVerified, @JsonKey(name: 'license_verified')  bool licenseVerified, @JsonKey(name: 'insurance_verified')  bool insuranceVerified, @JsonKey(name: 'background_check_verified')  bool backgroundCheckVerified, @JsonKey(name: 'service_areas')  List<String> serviceAreas,  List<String> schools, @JsonKey(name: 'location_text')  String? locationText, @JsonKey(name: 'location_lat')  double? locationLat, @JsonKey(name: 'location_lng')  double? locationLng, @JsonKey(name: 'start_location_text')  String? startLocationText, @JsonKey(name: 'start_location_lat')  double? startLocationLat, @JsonKey(name: 'start_location_lng')  double? startLocationLng)  $default,) {final _that = this;
switch (_that) {
case _DriverProfileModel():
return $default(_that.id,_that.userId,_that.name,_that.photoUrl,_that.phone,_that.email,_that.experienceYears,_that.licenseNumber,_that.licenseExpiry,_that.licenseImageUrl,_that.vehicleType,_that.vehicleNumber,_that.vehicleCapacity,_that.mulkiaImageUrl,_that.vehicleImageUrls,_that.priceMonthlyTwoWay,_that.priceMonthlyOneWay,_that.priceDaily,_that.bio,_that.rating,_that.totalReviews,_that.isVerified,_that.licenseVerified,_that.insuranceVerified,_that.backgroundCheckVerified,_that.serviceAreas,_that.schools,_that.locationText,_that.locationLat,_that.locationLng,_that.startLocationText,_that.startLocationLat,_that.startLocationLng);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String name,  String? photoUrl,  String phone,  String email, @JsonKey(name: 'experience_years')  int experienceYears, @JsonKey(name: 'license_number')  String? licenseNumber, @JsonKey(name: 'license_expiry')  DateTime? licenseExpiry, @JsonKey(name: 'license_image_url')  String? licenseImageUrl, @JsonKey(name: 'vehicle_type')  String vehicleType, @JsonKey(name: 'vehicle_number')  String? vehicleNumber, @JsonKey(name: 'vehicle_capacity')  int vehicleCapacity, @JsonKey(name: 'mulkia_image_url')  String? mulkiaImageUrl, @JsonKey(name: 'vehicle_image_urls')  List<String> vehicleImageUrls, @JsonKey(name: 'price_monthly_two_way')  double priceMonthlyTwoWay, @JsonKey(name: 'price_monthly_one_way')  double priceMonthlyOneWay, @JsonKey(name: 'price_daily')  double priceDaily,  String bio,  double rating, @JsonKey(name: 'total_reviews')  int totalReviews, @JsonKey(name: 'is_verified')  bool isVerified, @JsonKey(name: 'license_verified')  bool licenseVerified, @JsonKey(name: 'insurance_verified')  bool insuranceVerified, @JsonKey(name: 'background_check_verified')  bool backgroundCheckVerified, @JsonKey(name: 'service_areas')  List<String> serviceAreas,  List<String> schools, @JsonKey(name: 'location_text')  String? locationText, @JsonKey(name: 'location_lat')  double? locationLat, @JsonKey(name: 'location_lng')  double? locationLng, @JsonKey(name: 'start_location_text')  String? startLocationText, @JsonKey(name: 'start_location_lat')  double? startLocationLat, @JsonKey(name: 'start_location_lng')  double? startLocationLng)?  $default,) {final _that = this;
switch (_that) {
case _DriverProfileModel() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.photoUrl,_that.phone,_that.email,_that.experienceYears,_that.licenseNumber,_that.licenseExpiry,_that.licenseImageUrl,_that.vehicleType,_that.vehicleNumber,_that.vehicleCapacity,_that.mulkiaImageUrl,_that.vehicleImageUrls,_that.priceMonthlyTwoWay,_that.priceMonthlyOneWay,_that.priceDaily,_that.bio,_that.rating,_that.totalReviews,_that.isVerified,_that.licenseVerified,_that.insuranceVerified,_that.backgroundCheckVerified,_that.serviceAreas,_that.schools,_that.locationText,_that.locationLat,_that.locationLng,_that.startLocationText,_that.startLocationLat,_that.startLocationLng);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DriverProfileModel extends DriverProfileModel {
  const _DriverProfileModel({required this.id, required this.userId, required this.name, this.photoUrl, required this.phone, required this.email, @JsonKey(name: 'experience_years') this.experienceYears = 0, @JsonKey(name: 'license_number') this.licenseNumber, @JsonKey(name: 'license_expiry') this.licenseExpiry, @JsonKey(name: 'license_image_url') this.licenseImageUrl, @JsonKey(name: 'vehicle_type') required this.vehicleType, @JsonKey(name: 'vehicle_number') this.vehicleNumber, @JsonKey(name: 'vehicle_capacity') this.vehicleCapacity = 0, @JsonKey(name: 'mulkia_image_url') this.mulkiaImageUrl, @JsonKey(name: 'vehicle_image_urls') final  List<String> vehicleImageUrls = const [], @JsonKey(name: 'price_monthly_two_way') this.priceMonthlyTwoWay = 0, @JsonKey(name: 'price_monthly_one_way') this.priceMonthlyOneWay = 0, @JsonKey(name: 'price_daily') this.priceDaily = 0, this.bio = '', this.rating = 0, @JsonKey(name: 'total_reviews') this.totalReviews = 0, @JsonKey(name: 'is_verified') this.isVerified = false, @JsonKey(name: 'license_verified') this.licenseVerified = false, @JsonKey(name: 'insurance_verified') this.insuranceVerified = false, @JsonKey(name: 'background_check_verified') this.backgroundCheckVerified = false, @JsonKey(name: 'service_areas') final  List<String> serviceAreas = const [], final  List<String> schools = const [], @JsonKey(name: 'location_text') this.locationText, @JsonKey(name: 'location_lat') this.locationLat, @JsonKey(name: 'location_lng') this.locationLng, @JsonKey(name: 'start_location_text') this.startLocationText, @JsonKey(name: 'start_location_lat') this.startLocationLat, @JsonKey(name: 'start_location_lng') this.startLocationLng}): _vehicleImageUrls = vehicleImageUrls,_serviceAreas = serviceAreas,_schools = schools,super._();
  factory _DriverProfileModel.fromJson(Map<String, dynamic> json) => _$DriverProfileModelFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String name;
@override final  String? photoUrl;
@override final  String phone;
@override final  String email;
@override@JsonKey(name: 'experience_years') final  int experienceYears;
@override@JsonKey(name: 'license_number') final  String? licenseNumber;
@override@JsonKey(name: 'license_expiry') final  DateTime? licenseExpiry;
@override@JsonKey(name: 'license_image_url') final  String? licenseImageUrl;
@override@JsonKey(name: 'vehicle_type') final  String vehicleType;
@override@JsonKey(name: 'vehicle_number') final  String? vehicleNumber;
@override@JsonKey(name: 'vehicle_capacity') final  int vehicleCapacity;
@override@JsonKey(name: 'mulkia_image_url') final  String? mulkiaImageUrl;
 final  List<String> _vehicleImageUrls;
@override@JsonKey(name: 'vehicle_image_urls') List<String> get vehicleImageUrls {
  if (_vehicleImageUrls is EqualUnmodifiableListView) return _vehicleImageUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_vehicleImageUrls);
}

@override@JsonKey(name: 'price_monthly_two_way') final  double priceMonthlyTwoWay;
@override@JsonKey(name: 'price_monthly_one_way') final  double priceMonthlyOneWay;
@override@JsonKey(name: 'price_daily') final  double priceDaily;
@override@JsonKey() final  String bio;
@override@JsonKey() final  double rating;
@override@JsonKey(name: 'total_reviews') final  int totalReviews;
@override@JsonKey(name: 'is_verified') final  bool isVerified;
@override@JsonKey(name: 'license_verified') final  bool licenseVerified;
@override@JsonKey(name: 'insurance_verified') final  bool insuranceVerified;
@override@JsonKey(name: 'background_check_verified') final  bool backgroundCheckVerified;
 final  List<String> _serviceAreas;
@override@JsonKey(name: 'service_areas') List<String> get serviceAreas {
  if (_serviceAreas is EqualUnmodifiableListView) return _serviceAreas;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_serviceAreas);
}

 final  List<String> _schools;
@override@JsonKey() List<String> get schools {
  if (_schools is EqualUnmodifiableListView) return _schools;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_schools);
}

@override@JsonKey(name: 'location_text') final  String? locationText;
@override@JsonKey(name: 'location_lat') final  double? locationLat;
@override@JsonKey(name: 'location_lng') final  double? locationLng;
@override@JsonKey(name: 'start_location_text') final  String? startLocationText;
@override@JsonKey(name: 'start_location_lat') final  double? startLocationLat;
@override@JsonKey(name: 'start_location_lng') final  double? startLocationLng;

/// Create a copy of DriverProfileModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DriverProfileModelCopyWith<_DriverProfileModel> get copyWith => __$DriverProfileModelCopyWithImpl<_DriverProfileModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DriverProfileModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DriverProfileModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.experienceYears, experienceYears) || other.experienceYears == experienceYears)&&(identical(other.licenseNumber, licenseNumber) || other.licenseNumber == licenseNumber)&&(identical(other.licenseExpiry, licenseExpiry) || other.licenseExpiry == licenseExpiry)&&(identical(other.licenseImageUrl, licenseImageUrl) || other.licenseImageUrl == licenseImageUrl)&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&(identical(other.vehicleNumber, vehicleNumber) || other.vehicleNumber == vehicleNumber)&&(identical(other.vehicleCapacity, vehicleCapacity) || other.vehicleCapacity == vehicleCapacity)&&(identical(other.mulkiaImageUrl, mulkiaImageUrl) || other.mulkiaImageUrl == mulkiaImageUrl)&&const DeepCollectionEquality().equals(other._vehicleImageUrls, _vehicleImageUrls)&&(identical(other.priceMonthlyTwoWay, priceMonthlyTwoWay) || other.priceMonthlyTwoWay == priceMonthlyTwoWay)&&(identical(other.priceMonthlyOneWay, priceMonthlyOneWay) || other.priceMonthlyOneWay == priceMonthlyOneWay)&&(identical(other.priceDaily, priceDaily) || other.priceDaily == priceDaily)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.totalReviews, totalReviews) || other.totalReviews == totalReviews)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.licenseVerified, licenseVerified) || other.licenseVerified == licenseVerified)&&(identical(other.insuranceVerified, insuranceVerified) || other.insuranceVerified == insuranceVerified)&&(identical(other.backgroundCheckVerified, backgroundCheckVerified) || other.backgroundCheckVerified == backgroundCheckVerified)&&const DeepCollectionEquality().equals(other._serviceAreas, _serviceAreas)&&const DeepCollectionEquality().equals(other._schools, _schools)&&(identical(other.locationText, locationText) || other.locationText == locationText)&&(identical(other.locationLat, locationLat) || other.locationLat == locationLat)&&(identical(other.locationLng, locationLng) || other.locationLng == locationLng)&&(identical(other.startLocationText, startLocationText) || other.startLocationText == startLocationText)&&(identical(other.startLocationLat, startLocationLat) || other.startLocationLat == startLocationLat)&&(identical(other.startLocationLng, startLocationLng) || other.startLocationLng == startLocationLng));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,userId,name,photoUrl,phone,email,experienceYears,licenseNumber,licenseExpiry,licenseImageUrl,vehicleType,vehicleNumber,vehicleCapacity,mulkiaImageUrl,const DeepCollectionEquality().hash(_vehicleImageUrls),priceMonthlyTwoWay,priceMonthlyOneWay,priceDaily,bio,rating,totalReviews,isVerified,licenseVerified,insuranceVerified,backgroundCheckVerified,const DeepCollectionEquality().hash(_serviceAreas),const DeepCollectionEquality().hash(_schools),locationText,locationLat,locationLng,startLocationText,startLocationLat,startLocationLng]);

@override
String toString() {
  return 'DriverProfileModel(id: $id, userId: $userId, name: $name, photoUrl: $photoUrl, phone: $phone, email: $email, experienceYears: $experienceYears, licenseNumber: $licenseNumber, licenseExpiry: $licenseExpiry, licenseImageUrl: $licenseImageUrl, vehicleType: $vehicleType, vehicleNumber: $vehicleNumber, vehicleCapacity: $vehicleCapacity, mulkiaImageUrl: $mulkiaImageUrl, vehicleImageUrls: $vehicleImageUrls, priceMonthlyTwoWay: $priceMonthlyTwoWay, priceMonthlyOneWay: $priceMonthlyOneWay, priceDaily: $priceDaily, bio: $bio, rating: $rating, totalReviews: $totalReviews, isVerified: $isVerified, licenseVerified: $licenseVerified, insuranceVerified: $insuranceVerified, backgroundCheckVerified: $backgroundCheckVerified, serviceAreas: $serviceAreas, schools: $schools, locationText: $locationText, locationLat: $locationLat, locationLng: $locationLng, startLocationText: $startLocationText, startLocationLat: $startLocationLat, startLocationLng: $startLocationLng)';
}


}

/// @nodoc
abstract mixin class _$DriverProfileModelCopyWith<$Res> implements $DriverProfileModelCopyWith<$Res> {
  factory _$DriverProfileModelCopyWith(_DriverProfileModel value, $Res Function(_DriverProfileModel) _then) = __$DriverProfileModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String name, String? photoUrl, String phone, String email,@JsonKey(name: 'experience_years') int experienceYears,@JsonKey(name: 'license_number') String? licenseNumber,@JsonKey(name: 'license_expiry') DateTime? licenseExpiry,@JsonKey(name: 'license_image_url') String? licenseImageUrl,@JsonKey(name: 'vehicle_type') String vehicleType,@JsonKey(name: 'vehicle_number') String? vehicleNumber,@JsonKey(name: 'vehicle_capacity') int vehicleCapacity,@JsonKey(name: 'mulkia_image_url') String? mulkiaImageUrl,@JsonKey(name: 'vehicle_image_urls') List<String> vehicleImageUrls,@JsonKey(name: 'price_monthly_two_way') double priceMonthlyTwoWay,@JsonKey(name: 'price_monthly_one_way') double priceMonthlyOneWay,@JsonKey(name: 'price_daily') double priceDaily, String bio, double rating,@JsonKey(name: 'total_reviews') int totalReviews,@JsonKey(name: 'is_verified') bool isVerified,@JsonKey(name: 'license_verified') bool licenseVerified,@JsonKey(name: 'insurance_verified') bool insuranceVerified,@JsonKey(name: 'background_check_verified') bool backgroundCheckVerified,@JsonKey(name: 'service_areas') List<String> serviceAreas, List<String> schools,@JsonKey(name: 'location_text') String? locationText,@JsonKey(name: 'location_lat') double? locationLat,@JsonKey(name: 'location_lng') double? locationLng,@JsonKey(name: 'start_location_text') String? startLocationText,@JsonKey(name: 'start_location_lat') double? startLocationLat,@JsonKey(name: 'start_location_lng') double? startLocationLng
});




}
/// @nodoc
class __$DriverProfileModelCopyWithImpl<$Res>
    implements _$DriverProfileModelCopyWith<$Res> {
  __$DriverProfileModelCopyWithImpl(this._self, this._then);

  final _DriverProfileModel _self;
  final $Res Function(_DriverProfileModel) _then;

/// Create a copy of DriverProfileModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? photoUrl = freezed,Object? phone = null,Object? email = null,Object? experienceYears = null,Object? licenseNumber = freezed,Object? licenseExpiry = freezed,Object? licenseImageUrl = freezed,Object? vehicleType = null,Object? vehicleNumber = freezed,Object? vehicleCapacity = null,Object? mulkiaImageUrl = freezed,Object? vehicleImageUrls = null,Object? priceMonthlyTwoWay = null,Object? priceMonthlyOneWay = null,Object? priceDaily = null,Object? bio = null,Object? rating = null,Object? totalReviews = null,Object? isVerified = null,Object? licenseVerified = null,Object? insuranceVerified = null,Object? backgroundCheckVerified = null,Object? serviceAreas = null,Object? schools = null,Object? locationText = freezed,Object? locationLat = freezed,Object? locationLng = freezed,Object? startLocationText = freezed,Object? startLocationLat = freezed,Object? startLocationLng = freezed,}) {
  return _then(_DriverProfileModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,experienceYears: null == experienceYears ? _self.experienceYears : experienceYears // ignore: cast_nullable_to_non_nullable
as int,licenseNumber: freezed == licenseNumber ? _self.licenseNumber : licenseNumber // ignore: cast_nullable_to_non_nullable
as String?,licenseExpiry: freezed == licenseExpiry ? _self.licenseExpiry : licenseExpiry // ignore: cast_nullable_to_non_nullable
as DateTime?,licenseImageUrl: freezed == licenseImageUrl ? _self.licenseImageUrl : licenseImageUrl // ignore: cast_nullable_to_non_nullable
as String?,vehicleType: null == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as String,vehicleNumber: freezed == vehicleNumber ? _self.vehicleNumber : vehicleNumber // ignore: cast_nullable_to_non_nullable
as String?,vehicleCapacity: null == vehicleCapacity ? _self.vehicleCapacity : vehicleCapacity // ignore: cast_nullable_to_non_nullable
as int,mulkiaImageUrl: freezed == mulkiaImageUrl ? _self.mulkiaImageUrl : mulkiaImageUrl // ignore: cast_nullable_to_non_nullable
as String?,vehicleImageUrls: null == vehicleImageUrls ? _self._vehicleImageUrls : vehicleImageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,priceMonthlyTwoWay: null == priceMonthlyTwoWay ? _self.priceMonthlyTwoWay : priceMonthlyTwoWay // ignore: cast_nullable_to_non_nullable
as double,priceMonthlyOneWay: null == priceMonthlyOneWay ? _self.priceMonthlyOneWay : priceMonthlyOneWay // ignore: cast_nullable_to_non_nullable
as double,priceDaily: null == priceDaily ? _self.priceDaily : priceDaily // ignore: cast_nullable_to_non_nullable
as double,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,totalReviews: null == totalReviews ? _self.totalReviews : totalReviews // ignore: cast_nullable_to_non_nullable
as int,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,licenseVerified: null == licenseVerified ? _self.licenseVerified : licenseVerified // ignore: cast_nullable_to_non_nullable
as bool,insuranceVerified: null == insuranceVerified ? _self.insuranceVerified : insuranceVerified // ignore: cast_nullable_to_non_nullable
as bool,backgroundCheckVerified: null == backgroundCheckVerified ? _self.backgroundCheckVerified : backgroundCheckVerified // ignore: cast_nullable_to_non_nullable
as bool,serviceAreas: null == serviceAreas ? _self._serviceAreas : serviceAreas // ignore: cast_nullable_to_non_nullable
as List<String>,schools: null == schools ? _self._schools : schools // ignore: cast_nullable_to_non_nullable
as List<String>,locationText: freezed == locationText ? _self.locationText : locationText // ignore: cast_nullable_to_non_nullable
as String?,locationLat: freezed == locationLat ? _self.locationLat : locationLat // ignore: cast_nullable_to_non_nullable
as double?,locationLng: freezed == locationLng ? _self.locationLng : locationLng // ignore: cast_nullable_to_non_nullable
as double?,startLocationText: freezed == startLocationText ? _self.startLocationText : startLocationText // ignore: cast_nullable_to_non_nullable
as String?,startLocationLat: freezed == startLocationLat ? _self.startLocationLat : startLocationLat // ignore: cast_nullable_to_non_nullable
as double?,startLocationLng: freezed == startLocationLng ? _self.startLocationLng : startLocationLng // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
