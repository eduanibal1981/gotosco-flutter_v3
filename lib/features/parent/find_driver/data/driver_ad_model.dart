// lib/features/parent/find_driver/data/driver_ad_model.dart
class DriverAdModel {
  final String driverId;
  final String name;
  final String? photoUrl;
  final String gender;
  final String vehicleType;
  final double rating;
  final int totalReviews;
  final double priceMonthlyTwoWay;
  final double priceMonthlyOneWay;
  final bool isVerified;
  final String bio;
  final String phone; // New field
  DriverAdModel({
    required this.driverId,
    required this.name,
    this.photoUrl,
    required this.gender,
    required this.vehicleType,
    required this.rating,
    required this.totalReviews,
    required this.priceMonthlyTwoWay,
    required this.priceMonthlyOneWay,
    required this.isVerified,
    required this.bio,
    required this.phone,
  });

  // The View returns 'driver_id', 'name', etc. directly.
  // No need for nested 'users' map logic anymore.
  factory DriverAdModel.fromMap(Map<String, dynamic> map) {
    return DriverAdModel(
      driverId: map['driver_id'] ?? '',
      name: map['name'] ?? 'Driver',
      photoUrl: map['photo_url'],
      gender: map['gender'] ?? 'male',
      vehicleType: map['vehicle_type'] ?? 'Bus',
      rating: (map['rating'] ?? 0.0).toDouble(),
      totalReviews: map['total_reviews'] ?? 0,
      priceMonthlyTwoWay: (map['price_monthly_two_way'] ?? 0).toDouble(),
      priceMonthlyOneWay: (map['price_monthly_one_way'] ?? 0).toDouble(),
      isVerified: true, // The view filters only verified ones
      bio: map['bio'] ?? '',
      phone: map['phone'] ?? '',
    );
  }
}
