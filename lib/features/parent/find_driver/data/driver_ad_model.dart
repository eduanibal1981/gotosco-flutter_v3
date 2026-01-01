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
  });

  factory DriverAdModel.fromMap(Map<String, dynamic> map) {
    // Handle simplified flat structure (from RPC) or nested structure (from client-side join)
    final user =
        map['users'] ??
        map; // If 'users' key exists (join), use it, else use root

    return DriverAdModel(
      driverId: map['user_id'] ?? map['driver_id'] ?? '',
      name: user['full_name'] ?? 'Driver',
      photoUrl: user['photo_url'],
      gender: user['gender'] ?? 'male', // Default to male if missing
      vehicleType: map['vehicle_type'] ?? 'Bus',
      rating: (map['rating'] ?? 0.0).toDouble(),
      totalReviews:
          map['total_reviews'] ?? 0, // Ensure your DB view calculates this
      priceMonthlyTwoWay: (map['price_monthly_two_way'] ?? 0).toDouble(),
      priceMonthlyOneWay: (map['price_monthly_one_way'] ?? 0).toDouble(),
      isVerified: map['verified'] ?? false,
      bio: map['bio'] ?? '',
    );
  }
}
