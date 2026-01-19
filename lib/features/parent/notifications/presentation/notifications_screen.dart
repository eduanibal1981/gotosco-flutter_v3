import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/notifications_repository.dart';
import 'notifications_controller.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _showWelcome = false;

  @override
  void initState() {
    super.initState();
    _loadWelcome();
  }

  Future<void> _loadWelcome() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('parent_notifications_welcome_seen') ?? false;
    if (!seen && mounted) {
      setState(() => _showWelcome = true);
      await prefs.setBool('parent_notifications_welcome_seen', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(parentNotificationsStreamProvider);
    final initialAsync = ref.watch(parentNotificationsOnceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        actions: [
          TextButton(
            onPressed: () =>
                ref.read(notificationsControllerProvider.notifier).markAllAsRead(),
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (items) => _buildList(items, ref),
        loading: () => initialAsync.when(
          data: (items) => _buildList(items, ref),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => _buildErrorState(err.toString(), ref),
        ),
        error: (err, _) => _buildErrorState(err.toString(), ref),
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> items, WidgetRef ref) {
    if (items.isEmpty) {
      return _buildEmptyState();
    }
    final totalItems = items.length + (_showWelcome ? 1 : 0);
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: totalItems,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (_showWelcome && index == 0) {
          return _buildWelcomeCard();
        }
        final itemIndex = _showWelcome ? index - 1 : index;
        return _buildNotificationCard(context, ref, items[itemIndex]);
      },
    );
  }

  Widget _buildErrorState(String message, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Error: $message'),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => ref.invalidate(parentNotificationsOnceProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> item,
  ) {
    final eventType = item['event_type'] as String? ?? '';
    final childName = item['child_name'] as String? ?? 'Child';
    final driverName = item['driver_name'] as String? ?? 'Driver';
    final createdAt = item['created_at'] != null
        ? DateTime.tryParse(item['created_at'])
        : null;
    final isUnread = item['read_at'] == null;

    final title = _buildTitle(eventType, childName);
    final subtitle = _buildSubtitle(eventType, driverName);
    final icon = _eventIcon(eventType);

    return InkWell(
      onTap: () {
        if (item['id'] != null) {
          ref
              .read(notificationsControllerProvider.notifier)
              .markAsRead(item['id'] as String);
        }
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isUnread ? Colors.indigo.shade200 : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.indigo.shade50,
              child: Icon(icon, color: Colors.indigo),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  if (createdAt != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      _formatDate(createdAt),
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                    ),
                  ],
                ],
              ),
            ),
            if (isUnread)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'NEW',
                  style: TextStyle(
                    color: Colors.indigo,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade600, Colors.indigo.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.waving_hand, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Welcome! Your ride updates will appear here.',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _showWelcome = false),
            icon: const Icon(Icons.close, color: Colors.white),
            tooltip: 'Dismiss',
          ),
        ],
      ),
    );
  }

  String _buildTitle(String eventType, String childName) {
    switch (eventType) {
      case 'approaching':
        return 'Driver is approaching $childName';
      case 'picked_up':
        return '$childName was picked up';
      case 'dropped_off':
        return '$childName was dropped off';
      default:
        return 'Ride update for $childName';
    }
  }

  String _buildSubtitle(String eventType, String driverName) {
    switch (eventType) {
      case 'approaching':
        return '$driverName is near the pickup point';
      case 'picked_up':
        return '$driverName confirmed pickup';
      case 'dropped_off':
        return '$driverName confirmed drop-off';
      default:
        return 'Driver update';
    }
  }

  IconData _eventIcon(String eventType) {
    switch (eventType) {
      case 'approaching':
        return Icons.directions_bus_outlined;
      case 'picked_up':
        return Icons.check_circle_outline;
      case 'dropped_off':
        return Icons.flag_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
