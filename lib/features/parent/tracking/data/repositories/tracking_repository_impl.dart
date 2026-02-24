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
    return _supabase
        .from('tracking_view')
        .stream(primaryKey: ['driver_id'])
        .eq('driver_id', driverId)
        .map((events) {
          if (events.isEmpty) return null;
          return TrackingViewModel.fromJson(events.first);
        });
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
    final now = DateTime.now();

    // 1. Get Midnight in LOCAL time (e.g., 00:00 Muscat)
    final localMidnight = DateTime(now.year, now.month, now.day);

    // 2. Convert to UTC (e.g., 20:00 Yesterday UTC)
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

          // If the event happened before today's start, execute logic?
          // The query already orders by created_at desc limit 1.
          // Wait, if the latest event is old (yesterday), we return null.
          if (eventTime != null && eventTime.isBefore(cutoffTime)) {
            return null;
          }

          return Map<String, dynamic>.from(event);
        });
  }

  @override
  Future<ParentNextStopInfo?> getParentNextStopInfo(String bookingId) async {
    try {
      final response = await _supabase.rpc(
        'get_parent_tracking_ui_state',
        params: {'booking_id_input': bookingId},
      );

      if (response is List && response.isNotEmpty) {
        return ParentNextStopInfo.fromMap(
          Map<String, dynamic>.from(response.first),
        );
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
