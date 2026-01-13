import 'dart:async';
import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'driver_location_model.dart';

part 'tracking_repository.g.dart';

@riverpod
TrackingRepository trackingRepository(Ref ref) {
  return TrackingRepository(Supabase.instance.client);
}

/// Represents the home and school locations from a booking.
class BookingLocations {
  final LatLng? home;
  final LatLng? school;
  final String? driverId;
  final String? driverName;

  BookingLocations({this.home, this.school, this.driverId, this.driverName});

  bool get hasLocations => home != null || school != null;
}

class TrackingRepository {
  final SupabaseClient _supabase;

  TrackingRepository(this._supabase);

  /// Returns a stream of real-time driver location updates.
  /// Uses Supabase Realtime to listen for changes to the driver_locations table.
  /// Only returns data when driver is online.
  Stream<DriverLocation> getDriverLocationStream(String driverId) {
    return _supabase
        .from('driver_locations')
        .stream(primaryKey: ['driver_id'])
        .eq('driver_id', driverId)
        .map((data) {
          if (data.isEmpty) {
            throw Exception('No location data found for driver: $driverId');
          }
          final location = DriverLocation.fromMap(data.first);
          // Allow offline status to pass through so UI can update immediately
          // without entering error state.
          return location;
        });
  }

  /// Fetches the latest driver location (one-time read).
  Future<DriverLocation?> getDriverLocation(String driverId) async {
    final response = await _supabase
        .from('driver_locations')
        .select()
        .eq('driver_id', driverId)
        .maybeSingle();

    if (response == null) return null;
    return DriverLocation.fromMap(response);
  }

  /// Fetches home and school locations from a booking.
  Future<BookingLocations> getBookingLocations(String bookingId) async {
    final response = await _supabase
        .from('bookings')
        .select('''
          home_lat, home_lng, school_lat, school_lng, driver_id,
          drivers!bookings_driver_id_fkey(
            users!drivers_user_id_fkey(full_name)
          )
        ''')
        .eq('id', bookingId)
        .maybeSingle();

    if (response == null) {
      return BookingLocations();
    }

    final homeLat = response['home_lat'] as num?;
    final homeLng = response['home_lng'] as num?;
    final schoolLat = response['school_lat'] as num?;
    final schoolLng = response['school_lng'] as num?;

    // Navigate through the nested structure: drivers -> users -> full_name
    final driverName = response['drivers']?['users']?['full_name'] as String?;

    return BookingLocations(
      home: (homeLat != null && homeLng != null)
          ? LatLng(homeLat.toDouble(), homeLng.toDouble())
          : null,
      school: (schoolLat != null && schoolLng != null)
          ? LatLng(schoolLat.toDouble(), schoolLng.toDouble())
          : null,
      driverId: response['driver_id'] as String?,
      driverName: driverName,
    );
  }

  /// Calculates estimated time of arrival in minutes.
  /// Uses Haversine distance and current speed.
  double? calculateEtaMinutes(DriverLocation driver, LatLng destination) {
    if (driver.speed <= 0) return null;

    const distance = Distance();
    final distanceKm = distance.as(
      LengthUnit.Kilometer,
      driver.position,
      destination,
    );

    // ETA = distance / speed (in hours), convert to minutes
    final etaHours = distanceKm / driver.speed;
    return etaHours * 60;
  }
}
