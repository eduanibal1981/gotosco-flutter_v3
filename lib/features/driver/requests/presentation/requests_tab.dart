// lib/features/driver/requests/presentation/requests_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../dashboard/data/driver_dashboard_repository.dart';
import '../../transport_requests/data/models/driver_request_model.dart';

class RequestsTab extends ConsumerWidget {
  const RequestsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(driverBookingRequestsProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal.shade700, Colors.teal.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Booking Requests',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Accept or reject parent requests',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: requestsAsync.when(
              data: (requests) {
                final pending = requests
                    .where((r) => r.status == 'pending')
                    .toList();
                final others = requests
                    .where((r) => r.status != 'pending')
                    .toList();

                if (requests.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(),
                  );
                }

                return SliverList(
                  delegate: SliverChildListDelegate([
                    if (pending.isNotEmpty) ...[
                      _buildSectionHeader(
                        'Pending Requests',
                        Colors.orange,
                        pending.length,
                      ),
                      ...pending.map(
                        (r) =>
                            _buildRequestCard(context, ref, r, isPending: true),
                      ),
                      const SizedBox(height: 20),
                    ],
                    if (others.isNotEmpty) ...[
                      _buildSectionHeader(
                        'History',
                        Colors.grey,
                        others.length,
                      ),
                      ...others.map((r) => _buildRequestCard(context, ref, r)),
                    ],
                  ]),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => SliverFillRemaining(
                child: Center(child: Text('Error: $err')),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.inbox, size: 50, color: Colors.teal.shade300),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Requests Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'When parents send booking requests,\nthey will appear here',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(
    BuildContext context,
    WidgetRef ref,
    DriverRequest request, {
    bool isPending = false,
  }) {
    final parentName = request.parentName ?? 'Parent';
    final parentPhoto = request.parentPhoto;
    final parentPhone = request.parentPhone;
    final bookingType = request.bookingType ?? '';
    final homeLocation = request.homeLocation ?? '';
    final schoolLocation = request.schoolLocation ?? '';
    final children = request.studentsInfo;
    final status = request.status;
    final createdAt = request.createdAt;

    Color statusColor;
    switch (status) {
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'accepted':
        statusColor = Colors.green;
        break;
      case 'rejected':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isPending ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: isPending
            ? BorderSide(color: Colors.orange.shade200, width: 1)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Parent info
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.teal.shade100,
                  backgroundImage: parentPhoto != null
                      ? NetworkImage(parentPhoto)
                      : null,
                  child: parentPhoto == null
                      ? Text(
                          parentName[0].toUpperCase(),
                          style: TextStyle(
                            color: Colors.teal.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
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
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '$bookingType • ${children.length} child${children.length != 1 ? 'ren' : ''}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status?.toUpperCase() ?? '',
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Children
            if (children.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Wrap(
                  spacing: 8,
                  children: children
                      .map(
                        (c) => Chip(
                          label: Text(
                            children[0]['name'] ??
                                '', // children/studentsInfo is List<Map>
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: Colors.teal.shade50,
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                      )
                      .toList(),
                ),
              ),

            // Locations
            if (homeLocation.isNotEmpty)
              _buildInfoRow(Icons.home, 'Home', homeLocation),
            if (schoolLocation.isNotEmpty)
              _buildInfoRow(Icons.school, 'School', schoolLocation),

            // Date
            if (createdAt != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Requested on ${_formatDate(createdAt)}',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ),

            // Actions
            if (isPending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _handleAccept(context, ref, request.id),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Accept'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _handleReject(context, ref, request.id),
                      icon: const Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.red,
                      ),
                      label: const Text(
                        'Reject',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade500),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
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

  void _handleAccept(
    BuildContext context,
    WidgetRef ref,
    String bookingId,
  ) async {
    await ref.read(driverDashboardRepositoryProvider).acceptBooking(bookingId);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking accepted!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _handleReject(
    BuildContext context,
    WidgetRef ref,
    String bookingId,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reject Request?'),
        content: const Text(
          'Are you sure you want to reject this booking request?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref
          .read(driverDashboardRepositoryProvider)
          .rejectBooking(bookingId);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Request rejected')));
      }
    }
  }
}
