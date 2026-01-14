import 'package:freezed_annotation/freezed_annotation.dart';

part 'driver_ad_model.freezed.dart';
part 'driver_ad_model.g.dart';

@freezed
abstract class DriverAdModel with _$DriverAdModel {
  const DriverAdModel._();

  const factory DriverAdModel({
    @JsonKey(name: 'driver_id') required String driverId,
    @Default('Driver') String name,
    @JsonKey(name: 'photo_url') String? photoUrl,
    @Default('male') String gender,
    @JsonKey(name: 'vehicle_type') @Default('') String vehicleType,
    @Default(0.0) double rating,
    @JsonKey(name: 'total_reviews') @Default(0) int totalReviews,
    @JsonKey(name: 'price_monthly_two_way')
    @Default(0.0)
    double priceMonthlyTwoWay,
    @JsonKey(name: 'is_verified') @Default(false) bool isVerified,
    @Default('') String bio,
    @Default('') String phone,
    @JsonKey(name: 'is_online') @Default(false) bool isOnline,
    @JsonKey(name: 'distance_km') double? distanceKm,
    @Default([]) List<String> coveredSchools,
    @Default([]) List<String> coveredAreas,
    @JsonKey(name: 'vehicle_capacity') @Default(0) int vehicleCapacity,
    @Default({}) Map<String, double> otherPrices,
    @Default([]) List<String> adPhotos,
  }) = _DriverAdModel;

  factory DriverAdModel.fromMap(Map<String, dynamic> map) {
    // Parse covered_schools (handle JSONB list of objects)
    List<String> schoolNames = [];
    if (map['covered_schools'] != null) {
      final List<dynamic> list = map['covered_schools'];
      schoolNames = list
          .map((e) {
            if (e is String) return e;
            if (e is Map) return e['name']?.toString() ?? '';
            return e.toString();
          })
          .where((s) => s.isNotEmpty)
          .toList();
    }

    // Parse service_areas
    List<String> areaNames = [];
    final areasJson = map['service_areas'] ?? map['covered_areas'];
    if (areasJson != null) {
      final List<dynamic> list = areasJson;
      areaNames = list
          .map((e) {
            if (e is String) return e;
            if (e is Map) return e['name']?.toString() ?? '';
            return e.toString();
          })
          .where((s) => s.isNotEmpty)
          .toList();
    }

    // Parse other prices (dynamic keys)
    final otherPrices = <String, double>{};
    for (var key in map.keys) {
      if (key.startsWith('price_') && key != 'price_monthly_two_way') {
        final val = map[key];
        if (val is num) {
          otherPrices[key] = val.toDouble();
        } else if (val is String) {
          final parsed = double.tryParse(val);
          if (parsed != null) {
            otherPrices[key] = parsed;
          }
        }
      }
    }

    // Parse adPhotos (TEXT[] from SQL)
    List<String> photos = [];
    if (map['advs_photos'] != null) {
      final val = map['advs_photos'];
      if (val is List) {
        photos = val
            .map((e) => e.toString())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    }

    return DriverAdModel(
      driverId: map['driver_id'] ?? '',
      name: map['name'] ?? 'Driver',
      photoUrl: map['photo_url'],
      gender: map['gender'] ?? 'male',
      vehicleType: map['vehicle_type'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      totalReviews: map['total_reviews'] ?? 0,
      priceMonthlyTwoWay: (map['price_monthly_two_way'] ?? 0).toDouble(),
      isVerified: map['is_verified'] ?? false,
      bio: map['bio'] ?? '',
      phone: map['phone'] ?? '',
      isOnline: map['is_online'] ?? false,
      distanceKm: map['distance_km'] != null
          ? (map['distance_km'] as num).toDouble()
          : null,
      vehicleCapacity: map['vehicle_capacity'] ?? 0,
      coveredSchools: schoolNames,
      coveredAreas: areaNames,
      otherPrices: otherPrices,
      adPhotos: photos,
    );
  }

  // Alias for fromJson to satisfy convention if needed, though fromMap is what was called
  factory DriverAdModel.fromJson(Map<String, dynamic> json) =>
      DriverAdModel.fromMap(json);
}
