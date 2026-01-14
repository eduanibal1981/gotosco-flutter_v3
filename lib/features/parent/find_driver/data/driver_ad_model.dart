class DriverAdModel {
  final String driverId;
  final String name;
  final String? photoUrl;
  final String gender;
  final String vehicleType;
  final double rating;
  final int totalReviews;
  final double priceMonthlyTwoWay;
  final bool isVerified;
  final String bio;
  final String phone;
  final bool isOnline;

  // New Fields
  final double? distanceKm;
  final List<String> coveredSchools; // Simple list of names for UI
  final List<String> coveredAreas; // Simple list of names for UI
  final int vehicleCapacity;
  final Map<String, double> otherPrices;
  final List<String> adPhotos;

  DriverAdModel({
    required this.driverId,
    required this.name,
    this.photoUrl,
    required this.gender,
    required this.vehicleType,
    required this.rating,
    required this.totalReviews,
    required this.priceMonthlyTwoWay,
    required this.isVerified,
    required this.bio,
    required this.phone,
    required this.isOnline,
    this.distanceKm,
    this.coveredSchools = const [],
    this.coveredAreas = const [],
    this.vehicleCapacity = 0,
    this.otherPrices = const {},
    this.adPhotos = const [],
  });

  factory DriverAdModel.fromMap(Map<String, dynamic> map) {
    // Parse the JSON list of schools safely
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

    // Parse the JSON list of areas safely
    List<String> areaNames = [];
    // SQL function now returns 'service_areas', but check 'covered_areas' for backward compatibility
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

      // New Fields Mapping
      distanceKm: map['distance_km'] != null
          ? (map['distance_km'] as num).toDouble()
          : null,
      vehicleCapacity: map['vehicle_capacity'] ?? 0,
      coveredSchools: schoolNames,
      coveredAreas: areaNames,
      otherPrices: _parseOtherPrices(map),
      adPhotos: _parseInfos(map['advs_photos']),
    );
  }

  static List<String> _parseInfos(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
    }
    return [];
  }

  static Map<String, double> _parseOtherPrices(Map<String, dynamic> map) {
    final prices = <String, double>{};
    for (var key in map.keys) {
      if (key.startsWith('price_') && key != 'price_monthly_two_way') {
        final val = map[key];
        if (val is num) {
          prices[key] = val.toDouble();
        } else if (val is String) {
          final parsed = double.tryParse(val);
          if (parsed != null) {
            prices[key] = parsed;
          }
        }
      }
    }
    return prices;
  }
}
