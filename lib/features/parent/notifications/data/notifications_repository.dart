import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'notifications_repository.g.dart';

@riverpod
NotificationsRepository notificationsRepository(Ref ref) {
  return NotificationsRepository(Supabase.instance.client);
}

@riverpod
Stream<List<Map<String, dynamic>>> parentNotificationsStream(Ref ref) {
  return ref.watch(notificationsRepositoryProvider).streamNotifications();
}

@riverpod
Future<List<Map<String, dynamic>>> parentNotificationsOnce(Ref ref) {
  return ref.watch(notificationsRepositoryProvider).fetchNotifications();
}

@riverpod
Stream<int> parentUnreadNotificationsCount(Ref ref) {
  return ref
      .watch(notificationsRepositoryProvider)
      .streamNotifications()
      .map((items) => items.where((e) => e['read_at'] == null).length);
}

class NotificationsRepository {
  final SupabaseClient _supabase;

  NotificationsRepository(this._supabase);

  Stream<List<Map<String, dynamic>>> streamNotifications() {
    final userId = _supabase.auth.currentUser!.id;

    return _supabase
        .from('ride_events')
        .stream(primaryKey: ['id'])
        .eq('parent_id', userId)
        .order('created_at', ascending: false)
        .asyncMap((events) async {
          if (events.isEmpty) return <Map<String, dynamic>>[];

          final childIds = events
              .map((e) => e['child_id'] as String?)
              .where((id) => id != null)
              .cast<String>()
              .toSet()
              .toList();
          final driverIds = events
              .map((e) => e['driver_id'] as String?)
              .where((id) => id != null)
              .cast<String>()
              .toSet()
              .toList();

          final results = await Future.wait([
            if (childIds.isNotEmpty)
              _supabase
                  .from('children')
                  .select('id, name')
                  .inFilter('id', childIds)
            else
              Future.value(<Map<String, dynamic>>[]),
            if (driverIds.isNotEmpty)
              _supabase
                  .from('users')
                  .select('id, full_name')
                  .inFilter('id', driverIds)
            else
              Future.value(<Map<String, dynamic>>[]),
          ]);

          final childrenData = results[0] as List<dynamic>;
          final driversData = results[1] as List<dynamic>;

          final childMap = {
            for (final c in childrenData)
              c['id']: c['name'] as String? ?? 'Child',
          };
          final driverMap = {
            for (final d in driversData)
              d['id']: d['full_name'] as String? ?? 'Driver',
          };

          final enriched = events.map((e) {
            final newMap = Map<String, dynamic>.from(e);
            final childId = e['child_id'] as String?;
            final driverId = e['driver_id'] as String?;
            newMap['child_name'] = childMap[childId] ?? 'Child';
            newMap['driver_name'] = driverMap[driverId] ?? 'Driver';
            return newMap;
          }).toList();

          enriched.sort((a, b) {
            final aTime = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(0);
            final bTime = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(0);
            return bTime.compareTo(aTime);
          });

          return enriched;
        });
  }

  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    final userId = _supabase.auth.currentUser!.id;
    final events = await _supabase
        .from('ride_events')
        .select()
        .eq('parent_id', userId)
        .order('created_at', ascending: false);

    if (events is! List || events.isEmpty) return <Map<String, dynamic>>[];

    final childIds = events
        .map((e) => e['child_id'] as String?)
        .where((id) => id != null)
        .cast<String>()
        .toSet()
        .toList();
    final driverIds = events
        .map((e) => e['driver_id'] as String?)
        .where((id) => id != null)
        .cast<String>()
        .toSet()
        .toList();

    final results = await Future.wait([
      if (childIds.isNotEmpty)
        _supabase.from('children').select('id, name').inFilter('id', childIds)
      else
        Future.value(<Map<String, dynamic>>[]),
      if (driverIds.isNotEmpty)
        _supabase.from('users').select('id, full_name').inFilter('id', driverIds)
      else
        Future.value(<Map<String, dynamic>>[]),
    ]);

    final childrenData = results[0] as List<dynamic>;
    final driversData = results[1] as List<dynamic>;

    final childMap = {
      for (final c in childrenData) c['id']: c['name'] as String? ?? 'Child',
    };
    final driverMap = {
      for (final d in driversData) d['id']: d['full_name'] as String? ?? 'Driver',
    };

    return (events as List).map((e) {
      final newMap = Map<String, dynamic>.from(e);
      final childId = e['child_id'] as String?;
      final driverId = e['driver_id'] as String?;
      newMap['child_name'] = childMap[childId] ?? 'Child';
      newMap['driver_name'] = driverMap[driverId] ?? 'Driver';
      return newMap;
    }).toList();
  }

  Future<void> markAsRead(String eventId) async {
    await _supabase
        .from('ride_events')
        .update({'read_at': DateTime.now().toIso8601String()})
        .eq('id', eventId);
  }

  Future<void> markAllAsRead() async {
    final userId = _supabase.auth.currentUser!.id;
    await _supabase
        .from('ride_events')
        .update({'read_at': DateTime.now().toIso8601String()})
        .eq('parent_id', userId)
        .isFilter('read_at', null);
  }
}
