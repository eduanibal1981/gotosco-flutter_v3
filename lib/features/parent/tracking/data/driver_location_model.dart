import 'package:latlong2/latlong.dart';

/// Model representing the driver's current location.
class DriverLocation {
  final String driverId;
  final double latitude;
  final double longitude;
  final DateTime updatedAt;

  DriverLocation({
    required this.driverId,
    required this.latitude,
    required this.longitude,
    required this.updatedAt,
  });

  /// Convenience getter for flutter_map LatLng.
  LatLng get position => LatLng(latitude, longitude);

  factory DriverLocation.fromMap(Map<String, dynamic> map) {
    return DriverLocation(
      driverId: map['driver_id'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'driver_id': driverId,
      'latitude': latitude,
      'longitude': longitude,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() =>
      'DriverLocation(driverId: $driverId, lat: $latitude, lng: $longitude)';
}
