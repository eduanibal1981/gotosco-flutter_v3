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
  final String? driverPhone;

  BookingLocations({
    this.home,
    this.school,
    this.driverId,
    this.driverName,
    this.driverPhone,
  });

  bool get hasLocations => home != null || school != null;
}

class TrackingRepository {
  final SupabaseClient _supabase;

  TrackingRepository(this._supabase);

  /// Returns a stream of real-time driver location updates.
  /// Uses Supabase Realtime to listen for changes to the driver_locations table.
  /// Only returns data when driver is online.
  Stream<DriverLocation> getDriverLocationStream(String driverId) {
    // Manually merge streams since we don't have RxDart
    late StreamController<DriverLocation> controller;
    StreamSubscription? locationSub;
    StreamSubscription? driverSub;

    DriverLocation? lastLocation;
    bool isOnline = false;

    void emit() {
      if (lastLocation != null && !controller.isClosed) {
        controller.add(lastLocation!.copyWith(isOnline: isOnline));
      }
    }

    controller = StreamController<DriverLocation>(
      onListen: () {
        // 1. Listen to Data (High Frequency)
        locationSub = _supabase
            .from('driver_locations')
            .stream(primaryKey: ['driver_id'])
            .eq('driver_id', driverId)
            .listen((data) {
              if (data.isNotEmpty) {
                lastLocation = DriverLocation.fromMap(data.first);
                emit();
              } else {
                // If no location record exists, create a default "offline" one
                // This prevents the stream from hanging in "loading" state
                lastLocation = DriverLocation(
                  driverId: driverId,
                  latitude: 0,
                  longitude: 0,
                  heading: 0,
                  speed: 0,
                  updatedAt: DateTime.now(),
                  isOnline: isOnline,
                );
                emit();
              }
            }, onError: controller.addError);

        // 2. Listen to Status (Low Frequency)
        // 2. Listen to Status (Low Frequency)
        driverSub = _supabase
            .from('users')
            .stream(primaryKey: ['id'])
            .eq('id', driverId)
            .listen(
              (data) {
                if (data.isNotEmpty) {
                  // Use is_app_online AND is_online_visible from users table
                  final isAppOnline =
                      data.first['is_app_online'] as bool? ?? false;
                  final isVisible =
                      data.first['is_online_visible'] as bool? ?? true;

                  // Logic:
                  // If NOT visible -> Always Offline
                  // If visible -> Online if app is online
                  isOnline = isVisible && isAppOnline;

                  if (lastLocation != null) emit();
                }
              },
              onError: (e) {
                // Log but don't crash main stream
                print('Error streaming driver status: $e');
              },
            );
      },
      onCancel: () {
        locationSub?.cancel();
        driverSub?.cancel();
      },
    );

    return controller.stream;
  }

  /// Fetches the latest driver location (one-time read).
  Future<DriverLocation?> getDriverLocation(String driverId) async {
    final results = await Future.wait([
      _supabase
          .from('driver_locations')
          .select()
          .eq('driver_id', driverId)
          .maybeSingle(),
      _supabase
          .from('users')
          .select('is_app_online, is_online_visible')
          .eq('id', driverId)
          .maybeSingle(),
    ]);

    final locData = results[0];
    final userData = results[1];

    if (locData == null) return null;

    final isAppOnline = userData?['is_app_online'] as bool? ?? false;
    final isVisible = userData?['is_online_visible'] as bool? ?? true;
    final isOnline = isVisible && isAppOnline;

    return DriverLocation.fromMap(locData).copyWith(isOnline: isOnline);
  }

  /// Fetches home and school locations from a booking.
  Future<BookingLocations> getBookingLocations(String bookingId) async {
    final response = await _supabase
        .from('bookings')
        .select('''
          home_lat, home_lng, school_lat, school_lng, driver_id,
          drivers!bookings_driver_id_fkey(
            users!drivers_user_id_fkey(full_name, phone)
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
    final driverData = response['drivers']?['users'];
    final driverName = driverData?['full_name'] as String?;
    final driverPhone = driverData?['phone'] as String?;

    return BookingLocations(
      home: (homeLat != null && homeLng != null)
          ? LatLng(homeLat.toDouble(), homeLng.toDouble())
          : null,
      school: (schoolLat != null && schoolLng != null)
          ? LatLng(schoolLat.toDouble(), schoolLng.toDouble())
          : null,
      driverId: response['driver_id'] as String?,
      driverName: driverName,
      driverPhone: driverPhone,
    );
  }

  Stream<Map<String, dynamic>?> streamLatestRideEvent(String bookingId) {
    return _supabase
        .from('ride_events')
        .stream(primaryKey: ['id'])
        .eq('booking_id', bookingId)
        .order('created_at', ascending: false)
        .map((events) {
          if (events.isEmpty) return null;
          return Map<String, dynamic>.from(events.first);
        });
  }

  Future<ParentNextStopInfo?> getParentNextStopInfo(String bookingId) async {
    try {
      final response = await _supabase.rpc(
        'get_parent_next_stop_info',
        params: {'booking_id_input': bookingId},
      );

      if (response is List && response.isNotEmpty) {
        return ParentNextStopInfo.fromMap(
          Map<String, dynamic>.from(response.first),
        );
      }
      return null;
    } catch (_) {
      // RPC missing or blocked; treat as no info to avoid console noise.
      return null;
    }
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

class ParentNextStopInfo {
  final bool nextStopIsParent;
  final String? nextStopLabel;
  final int? stopsUntilParent;
  final int? etaMinutes;

  ParentNextStopInfo({
    required this.nextStopIsParent,
    this.nextStopLabel,
    this.stopsUntilParent,
    this.etaMinutes,
  });

  factory ParentNextStopInfo.fromMap(Map<String, dynamic> map) {
    return ParentNextStopInfo(
      nextStopIsParent: map['next_stop_is_parent'] as bool? ?? false,
      nextStopLabel: map['next_stop_label'] as String?,
      stopsUntilParent: map['stops_until_parent'] as int?,
      etaMinutes: map['eta_minutes'] as int?,
    );
  }
}
