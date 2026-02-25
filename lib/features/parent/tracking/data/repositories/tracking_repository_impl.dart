import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/contracts/tracking_contract.dart';
import '../../domain/models/tracking_view_model.dart';
import '../../domain/models/booking_location_model.dart';
import '../../domain/models/parent_next_stop_info.dart';

part 'tracking_repository_impl.g.dart';

@riverpod
TrackingContract trackingRepository(Ref ref) {
  return TrackingRepositoryImpl(Supabase.instance.client);
}

class TrackingRepositoryImpl implements TrackingContract {
  final SupabaseClient _supabase;

  TrackingRepositoryImpl(this._supabase);

  @override
  Stream<TrackingViewModel?> getDriverLocationStream(String driverId) {
    late StreamController<TrackingViewModel?> controller;
    RealtimeChannel? channel;

    controller = StreamController<TrackingViewModel?>.broadcast(
      onListen: () async {
        // 1. Initial Fetch to get the latest static location
        try {
          final data = await _supabase
              .from('tracking_view')
              .select()
              .eq('driver_id', driverId)
              .maybeSingle();

          if (data != null && !controller.isClosed) {
            controller.add(TrackingViewModel.fromJson(data));
          }
        } catch (e) {
          print('Error fetching initial tracking view: $e');
        }

        // 2. Setup Broadcast Channel for high-frequency updates
        channel = _supabase.channel('driver_tracking_$driverId');

        channel
            ?.onBroadcast(
              event: 'location_update',
              callback: (payload) {
                if (controller.isClosed || payload.isEmpty) return;

                try {
                  // Map the broadcast payload back into a format TrackingViewModel expects
                  final data = {
                    'driver_id': payload['driver_id'],
                    'latitude': payload['latitude'],
                    'longitude': payload['longitude'],
                    'heading': payload['heading'],
                    'speed': payload['speed'],
                    'updated_at': payload['updated_at'],
                    'trip_type': payload['trip_type'],
                    'trips_started': payload['trips_started'] ?? true,
                  };
                  controller.add(TrackingViewModel.fromJson(data));
                } catch (e) {
                  print("Error parsing location_update broadcast: $e");
                }
              },
            )
            .subscribe();
      },
      onCancel: () {
        channel?.unsubscribe();
        controller.close();
      },
    );

    return controller.stream;
  }

  @override
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

  @override
  Stream<Map<String, dynamic>?> streamLatestRideEvent(String bookingId) {
    return _supabase
        .from('ride_events')
        .stream(primaryKey: ['id'])
        .eq('booking_id', bookingId)
        .order('created_at', ascending: false)
        .limit(1)
        .map((events) => events.isEmpty ? null : events.first);
  }

  @override
  Future<ParentNextStopInfo?> getParentNextStopInfo(String bookingId) async {
    try {
      final response = await _supabase
          .from('parent_tracking_snapshot')
          .select()
          .eq('booking_id', bookingId)
          .maybeSingle();

      if (response != null) {
        return ParentNextStopInfo.fromMap(response);
      }
      return null;
    } catch (e, stack) {
      print('Error in getParentNextStopInfo: $e\n$stack');
      return null;
    }
  }
}
