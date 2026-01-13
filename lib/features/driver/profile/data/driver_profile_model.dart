// lib/features/driver/profile/data/driver_profile_model.dart

enum VerificationStatus { verified, pending, unverified }

class DriverProfileModel {
  final String id;
  final String userId;
  final String name;
  final String? photoUrl;
  final String phone;
  final String email;

  // Driver-specific info
  final int experienceYears;
  final String? licenseNumber;
  final DateTime? licenseExpiry;
  final String? licenseImageUrl;

  // Vehicle details
  final String vehicleType;
  final String? vehicleNumber;
  final int vehicleCapacity;
  final String? mulkiaImageUrl;

  // Pricing
  final double priceMonthlyTwoWay;
  final double priceMonthlyOneWay;
  final double priceDaily;

  // Other
  final String bio;
  final double rating;
  final int totalReviews;
  final bool isVerified;
  final bool licenseVerified;
  final bool insuranceVerified;
  final bool backgroundCheckVerified;
  final List<String> serviceAreas;
  final List<String> schools;

  // Location
  final String? locationText;
  final double? locationLat;
  final double? locationLng;
  final String? startLocationText;
  final double? startLocationLat;
  final double? startLocationLng;

  DriverProfileModel({
    required this.id,
    required this.userId,
    required this.name,
    this.photoUrl,
    required this.phone,
    required this.email,
    this.experienceYears = 0,
    this.licenseNumber,
    this.licenseExpiry,
    this.licenseImageUrl,
    required this.vehicleType,
    this.vehicleNumber,
    this.vehicleCapacity = 0,
    this.mulkiaImageUrl,
    this.priceMonthlyTwoWay = 0,
    this.priceMonthlyOneWay = 0,
    this.priceDaily = 0,
    this.bio = '',
    this.rating = 0,
    this.totalReviews = 0,
    this.isVerified = false,
    this.licenseVerified = false,
    this.insuranceVerified = false,
    this.backgroundCheckVerified = false,
    this.serviceAreas = const [],
    this.schools = const [],
    this.locationText,
    this.locationLat,
    this.locationLng,
    this.startLocationText,
    this.startLocationLat,
    this.startLocationLng,
  });

  factory DriverProfileModel.fromMap(Map<String, dynamic> map) {
    // Handle nested user data from join
    final userData = map['users'] as Map<String, dynamic>?;

    return DriverProfileModel(
      // Note: drivers table uses user_id as primary key, there's no separate 'id' column
      id: map['user_id'] ?? '',
      userId: map['user_id'] ?? '',
      name: userData?['full_name'] ?? map['name'] ?? 'Driver',
      photoUrl: userData?['photo_url'] ?? map['photo_url'],
      phone: userData?['phone'] ?? map['phone'] ?? '',
      email: userData?['email'] ?? map['email'] ?? '',
      experienceYears: map['experience_years'] ?? 0,
      licenseNumber: map['license_number'],
      licenseExpiry: map['license_expiry'] != null
          ? DateTime.tryParse(map['license_expiry'].toString())
          : null,
      licenseImageUrl: map['license_image_url'],
      vehicleType: map['vehicle_type'] ?? 'Bus',
      vehicleNumber: map['vehicle_number'],
      vehicleCapacity: map['vehicle_capacity'] ?? 0,
      mulkiaImageUrl: map['mulkia_image_url'],
      priceMonthlyTwoWay: (map['price_monthly_two_way'] ?? 0).toDouble(),
      priceMonthlyOneWay: (map['price_monthly_one_way'] ?? 0).toDouble(),
      priceDaily: (map['price_daily'] ?? 0).toDouble(),
      bio: map['bio'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      // Note: total_reviews column doesn't exist in schema, default to 0
      totalReviews: map['total_reviews'] ?? 0,
      isVerified: map['is_verified'] ?? false,
      licenseVerified: map['license_verified'] ?? false,
      insuranceVerified: map['insurance_verified'] ?? false,
      backgroundCheckVerified: map['background_check_verified'] ?? false,
      // Note: service_areas and schools columns don't exist in schema
      serviceAreas: const [],
      schools: const [],
      // Location fields
      locationText: map['location_text'],
      locationLat: (map['location_lat'] as num?)?.toDouble(),
      locationLng: (map['location_lng'] as num?)?.toDouble(),
      startLocationText: map['start_location_text'],
      startLocationLat: (map['start_location_lat'] as num?)?.toDouble(),
      startLocationLng: (map['start_location_lng'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'experience_years': experienceYears,
      'license_number': licenseNumber,
      'license_expiry': licenseExpiry?.toIso8601String().split('T').first,
      'license_image_url': licenseImageUrl,
      'vehicle_type': vehicleType,
      'vehicle_number': vehicleNumber,
      'vehicle_capacity': vehicleCapacity,
      'mulkia_image_url': mulkiaImageUrl,
      'price_monthly_two_way': priceMonthlyTwoWay,
      'price_monthly_one_way': priceMonthlyOneWay,
      'price_daily': priceDaily,
      'bio': bio,
    };
  }

  DriverProfileModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? photoUrl,
    String? phone,
    String? email,
    int? experienceYears,
    String? licenseNumber,
    DateTime? licenseExpiry,
    String? licenseImageUrl,
    String? vehicleType,
    String? vehicleNumber,
    int? vehicleCapacity,
    String? mulkiaImageUrl,
    double? priceMonthlyTwoWay,
    double? priceMonthlyOneWay,
    double? priceDaily,
    String? bio,
    double? rating,
    int? totalReviews,
    bool? isVerified,
    bool? licenseVerified,
    bool? insuranceVerified,
    bool? backgroundCheckVerified,
    List<String>? serviceAreas,
    List<String>? schools,
    String? locationText,
    double? locationLat,
    double? locationLng,
    String? startLocationText,
    double? startLocationLat,
    double? startLocationLng,
  }) {
    return DriverProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      experienceYears: experienceYears ?? this.experienceYears,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      licenseExpiry: licenseExpiry ?? this.licenseExpiry,
      licenseImageUrl: licenseImageUrl ?? this.licenseImageUrl,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      vehicleCapacity: vehicleCapacity ?? this.vehicleCapacity,
      mulkiaImageUrl: mulkiaImageUrl ?? this.mulkiaImageUrl,
      priceMonthlyTwoWay: priceMonthlyTwoWay ?? this.priceMonthlyTwoWay,
      priceMonthlyOneWay: priceMonthlyOneWay ?? this.priceMonthlyOneWay,
      priceDaily: priceDaily ?? this.priceDaily,
      bio: bio ?? this.bio,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      isVerified: isVerified ?? this.isVerified,
      licenseVerified: licenseVerified ?? this.licenseVerified,
      insuranceVerified: insuranceVerified ?? this.insuranceVerified,
      backgroundCheckVerified:
          backgroundCheckVerified ?? this.backgroundCheckVerified,
      serviceAreas: serviceAreas ?? this.serviceAreas,
      schools: schools ?? this.schools,
      locationText: locationText ?? this.locationText,
      locationLat: locationLat ?? this.locationLat,
      locationLng: locationLng ?? this.locationLng,
      startLocationText: startLocationText ?? this.startLocationText,
      startLocationLat: startLocationLat ?? this.startLocationLat,
      startLocationLng: startLocationLng ?? this.startLocationLng,
    );
  }

  /// Get verification status based on document uploads and admin verification
  VerificationStatus get verificationStatus {
    // If admin has verified the driver
    if (isVerified) {
      return VerificationStatus.verified;
    }

    // If both documents are uploaded but not yet verified
    final hasLicenseImage =
        licenseImageUrl != null && licenseImageUrl!.isNotEmpty;
    final hasMulkiaImage = mulkiaImageUrl != null && mulkiaImageUrl!.isNotEmpty;

    if (hasLicenseImage && hasMulkiaImage) {
      return VerificationStatus.pending;
    }

    // Otherwise, driver hasn't uploaded required documents
    return VerificationStatus.unverified;
  }
}
