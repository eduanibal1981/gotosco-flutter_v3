import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'driver_location_model.dart';

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
  Stream<DriverLocation> getDriverLocationStream(String driverId) {
    // Use Supabase stream for real-time updates
    return _supabase
        .from('driver_locations')
        .stream(primaryKey: ['driver_id'])
        .eq('driver_id', driverId)
        .map((data) {
          if (data.isEmpty) {
            throw Exception('No location data found for driver: $driverId');
          }
          return DriverLocation.fromMap(data.first);
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

  /// Updates driver location - used for simulation/testing.
  /// In production, this would be called from the Driver app.
  Future<void> updateDriverLocation({
    required String driverId,
    required double latitude,
    required double longitude,
  }) async {
    await _supabase.from('driver_locations').upsert({
      'driver_id': driverId,
      'latitude': latitude,
      'longitude': longitude,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  /// Simulates driver movement for testing.
  /// Moves the driver along a path from start to end coordinates.
  Future<void> simulateDriverMovement({
    required String driverId,
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    int steps = 20,
    Duration interval = const Duration(seconds: 2),
  }) async {
    final latStep = (endLat - startLat) / steps;
    final lngStep = (endLng - startLng) / steps;

    for (int i = 0; i <= steps; i++) {
      final currentLat = startLat + (latStep * i);
      final currentLng = startLng + (lngStep * i);

      await updateDriverLocation(
        driverId: driverId,
        latitude: currentLat,
        longitude: currentLng,
      );

      if (i < steps) {
        await Future.delayed(interval);
      }
    }
  }
}
