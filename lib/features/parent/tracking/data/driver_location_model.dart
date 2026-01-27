import 'package:latlong2/latlong.dart';

/// Model representing the driver's current location from driver_locations table.
class DriverLocation {
  final String driverId;
  final double latitude;
  final double longitude;
  final double heading; // 0-360 degrees for icon rotation
  final double speed; // km/h for ETA calculation
  final String? tripType; // 'pickup' | 'dropoff' | 'idle'
  final bool isOnline;
  final int? etaMinutes;
  final String? nextStopId;
  final DateTime updatedAt;

  DriverLocation({
    required this.driverId,
    required this.latitude,
    required this.longitude,
    this.heading = 0.0,
    this.speed = 0.0,
    this.tripType,
    this.isOnline = false,
    this.etaMinutes,
    this.nextStopId,
    required this.updatedAt,
  });

  /// Convenience getter for flutter_map LatLng.
  LatLng get position => LatLng(latitude, longitude);

  /// Whether driver is currently on a trip (pickup or dropoff).
  bool get isOnTrip => tripType == 'pickup' || tripType == 'dropoff';

  /// Returns the heading in radians for Transform.rotate.
  double get headingRadians => heading * (3.14159265359 / 180);

  factory DriverLocation.fromMap(Map<String, dynamic> map) {
    return DriverLocation(
      driverId: map['driver_id'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      heading: (map['heading'] as num?)?.toDouble() ?? 0.0,
      speed: (map['speed'] as num?)?.toDouble() ?? 0.0,
      tripType: map['trip_type'] as String?,
      isOnline: map['is_online'] as bool? ?? false,
      etaMinutes: map['eta_minutes'] as int?,
      nextStopId: map['next_stop_id'] as String?,
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'driver_id': driverId,
      'latitude': latitude,
      'longitude': longitude,
      'heading': heading,
      'speed': speed,
      'trip_type': tripType,
      'is_online': isOnline,
      'eta_minutes': etaMinutes,
      'next_stop_id': nextStopId,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() =>
      'DriverLocation(driverId: $driverId, lat: $latitude, lng: $longitude, heading: $heading, tripType: $tripType)';

  DriverLocation copyWith({
    String? driverId,
    double? latitude,
    double? longitude,
    double? heading,
    double? speed,
    String? tripType,
    bool? isOnline,
    int? etaMinutes,
    String? nextStopId,
    DateTime? updatedAt,
  }) {
    return DriverLocation(
      driverId: driverId ?? this.driverId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      heading: heading ?? this.heading,
      speed: speed ?? this.speed,
      tripType: tripType ?? this.tripType,
      isOnline: isOnline ?? this.isOnline,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      nextStopId: nextStopId ?? this.nextStopId,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
