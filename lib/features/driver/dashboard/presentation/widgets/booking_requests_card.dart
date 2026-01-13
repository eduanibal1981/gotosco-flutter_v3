// lib/features/driver/dashboard/presentation/widgets/booking_requests_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/driver_dashboard_repository.dart';
import '../driver_dashboard_screen.dart';

class BookingRequestsCard extends ConsumerWidget {
  const BookingRequestsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(driverBookingRequestsProvider);

    return requestsAsync.when(
      data: (requests) {
        final pending = requests
            .where((r) => r['status'] == 'pending')
            .toList();

        // Only show if there are pending requests
        if (pending.isEmpty) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: () {
            // Set the booking tab to "Requests" (index 0) before navigating
            ref
                .read(driverBookingTabIndexNotifierProvider.notifier)
                .setIndex(0);
            // Navigate to Booking tab (index 1) in the dashboard
            ref.read(driverDashboardIndexProvider.notifier).setIndex(1);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: Colors.orange.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.notifications_active,
                      color: Colors.orange.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Booking Requests',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    // Badge for count
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${pending.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        // Set the booking tab to "Requests" (index 0) before navigating
                        ref
                            .read(
                              driverBookingTabIndexNotifierProvider.notifier,
                            )
                            .setIndex(0);
                        // Switch to Booking tab
                        ref
                            .read(driverDashboardIndexProvider.notifier)
                            .setIndex(1);
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: Colors.teal,
                      ),
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...pending
                    .take(2)
                    .map((req) => _buildRequestRow(context, ref, req)),
                if (pending.length > 2)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Center(
                      child: Text(
                        'And ${pending.length - 2} more...',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
      loading: () =>
          const SizedBox.shrink(), // Don't show anything while loading on home
      error: (e, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildRequestRow(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> request,
  ) {
    final parentId = request['parent_id'] as String? ?? '';
    final parentName = request['parent_name'] as String? ?? 'Parent';
    final children = request['children'] as List? ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.orange.shade100,
            radius: 16,
            child: Icon(Icons.person, size: 16, color: Colors.orange.shade700),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  parentName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${children.length} Children • ${request['hometxt_location'] ?? "Address"}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Chat button
          IconButton(
            onPressed: () => context.push(
              '/chat',
              extra: {'userId': parentId, 'userName': parentName},
            ),
            icon: Icon(
              Icons.chat_bubble_outline,
              color: Colors.blue.shade400,
              size: 20,
            ),
            tooltip: 'Chat with parent',
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
