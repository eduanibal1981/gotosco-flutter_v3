import 'dart:async';
import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'driver_location_model.dart';
import 'models/booking_location_model.dart';

part 'tracking_repository.g.dart';

@riverpod
TrackingRepository trackingRepository(Ref ref) {
  return TrackingRepository(Supabase.instance.client);
}

class TrackingRepository {
  final SupabaseClient _supabase;

  TrackingRepository(this._supabase);

  /// Returns a stream of real-time driver location updates.
  /// Uses Supabase Realtime to listen for changes to the driver_locations table.
  /// Only returns data when driver is online.
  /// Returns a stream of real-time driver location updates.
  /// Uses Supabase Realtime for trigger, then fetches full data from View.
  Stream<DriverLocation?> getDriverLocationStream(String driverId) {
    late StreamController<DriverLocation?> controller;
    StreamSubscription? sub;

    controller = StreamController<DriverLocation?>(
      onListen: () {
        // Initial Fetch
        getDriverLocation(driverId).then((loc) {
          //if (loc != null && !controller.isClosed) controller.add(loc);
          if (!controller.isClosed) controller.add(loc);
        });

        // Listen to changes on base table 'driver_locations'
        sub = _supabase
            .from('driver_locations')
            .stream(primaryKey: ['driver_id'])
            .eq('driver_id', driverId)
            .listen((_) async {
              // Re-fetch from view to get joined status
              final loc = await getDriverLocation(driverId);
              if (!controller.isClosed) {
                controller.add(loc);
              }
            });
      },
      onCancel: () {
        sub?.cancel();
      },
    );

    return controller.stream;
  }

  /// Fetches the latest driver location from View.
  Future<DriverLocation?> getDriverLocation(String driverId) async {
    final data = await _supabase
        .from('tracking_view')
        .select()
        .eq('driver_id', driverId)
        .maybeSingle();

    if (data == null) return null;
    return DriverLocation.fromJson(data);
  }

  /// Fetches home and school locations from a booking.
  Future<BookingLocation?> getBookingLocations(String bookingId) async {
    final data = await _supabase
        .from('booking_locations_view')
        .select()
        .eq('booking_id', bookingId)
        .maybeSingle();

    if (data == null) {
      return null;
    }

    return BookingLocation.fromJson(data);
  }

  Stream<Map<String, dynamic>?> streamLatestRideEvent(String bookingId) {
    final now = DateTime.now();

    // 1. Get Midnight in LOCAL time (e.g., 00:00 Muscat)
    final localMidnight = DateTime(now.year, now.month, now.day);

    // 2. Convert to UTC (e.g., 20:00 Yesterday UTC)
    // This adds the 'Z' at the end: "2026-02-07T20:00:00.000Z"
    final utcMidnightStr = localMidnight.toUtc().toIso8601String();

    return _supabase
        .from('ride_events')
        .stream(primaryKey: ['id'])
        .eq('booking_id', bookingId)
        .order('created_at', ascending: false)
        .limit(1)
        .map((events) {
          if (events.isEmpty) return null;
          final event = events.first;

          // Filter in Dart since .gte() is not supported on stream()
          final eventTime = DateTime.tryParse(event['created_at'].toString());
          final cutoffTime = DateTime.parse(utcMidnightStr);

          if (eventTime != null && eventTime.isBefore(cutoffTime)) {
            return null;
          }

          return Map<String, dynamic>.from(event);
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
  final String? tripType; // 'Go to School(s)' | 'Return from School(s)'
  final String? stopType; // 'pickup' | 'dropoff'

  ParentNextStopInfo({
    required this.nextStopIsParent,
    this.nextStopLabel,
    this.stopsUntilParent,
    this.etaMinutes,
    this.tripType,
    this.stopType,
  });

  /// Returns true for morning Go trips, false for afternoon Return trips
  bool get isGoTrip => tripType?.contains('Go') ?? false;

  /// Returns true for afternoon Return trips
  bool get isReturnTrip => tripType?.contains('Return') ?? false;

  /// Returns a user-friendly destination description
  String get destinationLabel {
    if (isGoTrip) return 'school';
    if (isReturnTrip) return 'home';
    return 'destination';
  }

  factory ParentNextStopInfo.fromMap(Map<String, dynamic> map) {
    return ParentNextStopInfo(
      nextStopIsParent: map['next_stop_is_parent'] as bool? ?? false,
      nextStopLabel: map['next_stop_label'] as String?,
      stopsUntilParent: map['stops_until_parent'] as int?,
      etaMinutes: map['eta_minutes'] as int?,
      tripType: map['trip_type'] as String?,
      stopType: map['stop_type'] as String?,
    );
  }
}
