// lib/features/parent/bookings/presentation/my_bookings_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../data/bookings_repository.dart';
import '../../dashboard/presentation/dashboard_controller.dart';

class MyBookingsTab extends ConsumerWidget {
  const MyBookingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(myBookingsProvider);

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
                  colors: [Colors.indigo.shade600, Colors.indigo.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'My Bookings',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Manage your transport subscriptions',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  // Quick Stats
                  bookingsAsync.when(
                    data: (bookings) => _buildQuickStats(bookings),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: bookingsAsync.when(
              data: (bookings) {
                if (bookings.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(context, ref),
                  );
                }
                return _buildBookingsList(context, ref, bookings);
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, stack) => SliverFillRemaining(
                child: Center(child: Text('Error: $err')),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(List<Map<String, dynamic>> bookings) {
    final active = bookings.where((b) => b['status'] == 'accepted').length;
    final pending = bookings.where((b) => b['status'] == 'pending').length;

    return Row(
      children: [
        _buildStatCard(
          icon: Icons.check_circle,
          label: 'Active',
          value: active.toString(),
          color: Colors.green,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          icon: Icons.hourglass_empty,
          label: 'Pending',
          value: pending.toString(),
          color: Colors.orange,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          icon: Icons.history,
          label: 'Total',
          value: bookings.length.toString(),
          color: Colors.white,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_month,
                size: 60,
                color: Colors.indigo.shade300,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Bookings Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Find a driver to start booking\nschool transport for your children',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to Find Drivers tab (index 1)
                ref.read(parentDashboardIndexProvider.notifier).setIndex(1);
              },
              icon: const Icon(Icons.search),
              label: const Text('Find a Driver'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverList _buildBookingsList(
    BuildContext context,
    WidgetRef ref,
    List<Map<String, dynamic>> bookings,
  ) {
    // Group by status
    final accepted = bookings.where((b) => b['status'] == 'accepted').toList();
    final pending = bookings.where((b) => b['status'] == 'pending').toList();
    final completed = bookings
        .where((b) => b['status'] == 'completed')
        .toList();
    final rejected = bookings
        .where((b) => b['status'] == 'rejected' || b['status'] == 'cancelled')
        .toList();

    final List<Widget> items = [];

    // Active bookings
    if (accepted.isNotEmpty) {
      items.add(
        _buildSectionHeader('Active Bookings', Colors.green, accepted.length),
      );
      for (var booking in accepted) {
        items.add(_buildBookingCard(context, ref, booking, showTrack: true));
      }
      items.add(const SizedBox(height: 16));
    }

    // Pending bookings
    if (pending.isNotEmpty) {
      items.add(
        _buildSectionHeader('Pending Approval', Colors.orange, pending.length),
      );
      for (var booking in pending) {
        items.add(_buildBookingCard(context, ref, booking, showCancel: true));
      }
      items.add(const SizedBox(height: 16));
    }

    // Completed bookings
    if (completed.isNotEmpty) {
      items.add(
        _buildSectionHeader('Completed', Colors.grey, completed.length),
      );
      for (var booking in completed) {
        items.add(_buildBookingCard(context, ref, booking));
      }
      items.add(const SizedBox(height: 16));
    }

    // Rejected/Cancelled
    if (rejected.isNotEmpty) {
      items.add(_buildSectionHeader('Cancelled', Colors.red, rejected.length));
      for (var booking in rejected) {
        items.add(_buildBookingCard(context, ref, booking));
      }
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => items[index],
        childCount: items.length,
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

  Widget _buildBookingCard(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> booking, {
    bool showTrack = false,
    bool showCancel = false,
  }) {
    final status = booking['status'] as String?;
    final driverName = booking['driver_name'] as String? ?? 'Driver';
    final driverPhoto = booking['driver_photo'] as String?;
    final bookingType = booking['booking_type'] as String? ?? '';
    final homeLocation = booking['home_location'] as String? ?? '';
    final schoolLocation = booking['school_location'] as String? ?? '';
    final createdAt = booking['created_at'] != null
        ? DateTime.tryParse(booking['created_at'])
        : null;

    Color statusColor;
    IconData statusIcon;
    switch (status) {
      case 'accepted':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
        break;
      case 'completed':
        statusColor = Colors.grey;
        statusIcon = Icons.task_alt;
        break;
      default:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: status == 'accepted' ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: status == 'accepted'
            ? BorderSide(color: Colors.green.shade200, width: 1)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.indigo.shade100,
                  backgroundImage: driverPhoto != null
                      ? NetworkImage(driverPhoto)
                      : null,
                  child: driverPhoto == null
                      ? Icon(Icons.person, color: Colors.indigo.shade700)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driverName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        bookingType,
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        status?.toUpperCase() ?? '',
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Locations
            if (homeLocation.isNotEmpty)
              _buildInfoRow(Icons.home, homeLocation),
            if (schoolLocation.isNotEmpty)
              _buildInfoRow(Icons.school, schoolLocation),

            // Date
            if (createdAt != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Booked on ${_formatDate(createdAt)}',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ),

            // Actions
            if (showTrack || showCancel) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  if (showTrack)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _navigateToTracking(context, booking),
                        icon: const Icon(Icons.location_on, size: 18),
                        label: const Text('Track Driver'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  if (showTrack && showCancel) const SizedBox(width: 12),
                  if (showCancel)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _showCancelDialog(context, ref, booking),
                        icon: const Icon(
                          Icons.close,
                          size: 18,
                          color: Colors.red,
                        ),
                        label: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.red),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
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

  Widget _buildInfoRow(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
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

  void _navigateToTracking(BuildContext context, Map<String, dynamic> booking) {
    final homeLat = booking['home_lat'] as double?;
    final homeLng = booking['home_lng'] as double?;
    final schoolLat = booking['school_lat'] as double?;
    final schoolLng = booking['school_lng'] as double?;

    context.push(
      '/tracking',
      extra: {
        'bookingId': booking['id'],
        'driverId': booking['driver_id'],
        'driverName': booking['driver_name'] ?? 'Driver',
        'driverPhotoUrl': booking['driver_photo'],
        'homeLocation': (homeLat != null && homeLng != null)
            ? LatLng(homeLat, homeLng)
            : null,
        'schoolLocation': (schoolLat != null && schoolLng != null)
            ? LatLng(schoolLat, schoolLng)
            : null,
      },
    );
  }

  void _showCancelDialog(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> booking,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Booking?'),
        content: const Text(
          'Are you sure you want to cancel this booking request?\n\nThe driver will be notified.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('No, Keep It'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(bookingsRepositoryProvider)
                  .cancelBooking(booking['id']);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Booking cancelled')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}
