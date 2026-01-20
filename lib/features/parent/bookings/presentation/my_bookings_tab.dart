// lib/features/parent/bookings/presentation/my_bookings_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../data/bookings_repository.dart';
import '../../dashboard/presentation/dashboard_controller.dart';

class MyBookingsTab extends ConsumerStatefulWidget {
  const MyBookingsTab({super.key});

  @override
  ConsumerState<MyBookingsTab> createState() => _MyBookingsTabState();
}

class _MyBookingsTabState extends ConsumerState<MyBookingsTab> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
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
          title: 'Active',
          subtitle: 'Show',
          value: active.toString(),
          color: Colors.green,
          isSelected: _selectedFilter == 'active',
          onTap: () => setState(() => _selectedFilter = 'active'),
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          icon: Icons.hourglass_empty,
          title: 'Pending',
          subtitle: 'Show',
          value: pending.toString(),
          color: Colors.orange,
          isSelected: _selectedFilter == 'pending',
          onTap: () => setState(() => _selectedFilter = 'pending'),
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          icon: Icons.history,
          title: 'All',
          subtitle: 'Show',
          value: bookings.length.toString(),
          color: Colors.white,
          isSelected: _selectedFilter == 'all',
          onTap: () => setState(() => _selectedFilter = 'all'),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white.withOpacity(0.25)
                : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: Colors.white60, width: 1.5)
                : null,
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
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 11,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 11,
                ),
              ),
            ],
          ),
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
    if (accepted.isNotEmpty &&
        (_selectedFilter == 'all' || _selectedFilter == 'active')) {
      items.add(
        _buildSectionHeader('Active Bookings', Colors.green, accepted.length),
      );
      for (var booking in accepted) {
        items.add(
          _buildBookingCard(
            context,
            ref,
            booking,
            showTrack: true,
            showCancel: true,
          ),
        );
      }
      items.add(const SizedBox(height: 16));
    }

    // Pending bookings
    if (pending.isNotEmpty &&
        (_selectedFilter == 'all' || _selectedFilter == 'pending')) {
      items.add(
        _buildSectionHeader('Pending Approval', Colors.orange, pending.length),
      );
      for (var booking in pending) {
        items.add(_buildBookingCard(context, ref, booking, showCancel: true));
      }
      items.add(const SizedBox(height: 16));
    }

    // Completed bookings
    if (completed.isNotEmpty && _selectedFilter == 'all') {
      items.add(
        _buildSectionHeader('Completed', Colors.grey, completed.length),
      );
      for (var booking in completed) {
        items.add(_buildBookingCard(context, ref, booking));
      }
      items.add(const SizedBox(height: 16));
    }

    // Rejected/Cancelled
    if (rejected.isNotEmpty && _selectedFilter == 'all') {
      items.add(_buildSectionHeader('Cancelled', Colors.red, rejected.length));
      for (var booking in rejected) {
        items.add(
          _buildBookingCard(
            context,
            ref,
            booking,
            showDelete: true,
            showRebook: true,
          ),
        );
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
    bool showDelete = false,
    bool showRebook = false,
  }) {
    final status = booking['status'] as String?;
    final driverName = booking['driver_name'] as String? ?? 'Driver';
    final driverPhoto = booking['driver_photo'] as String?;
    final bookingType = booking['booking_type'] as String? ?? '';
    final homeLocation = booking['home_location'] as String? ?? '';
    final schoolLocation = booking['school_location'] as String? ?? '';
    final subscriptionStatus = booking['subscription_status'] as String?;
    final pauseEndDate = booking['pause_end_date'] as String?;
    final scheduledStopDate = booking['contract_end_date'] as String?;
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

            // Children Names
            if (booking['child_names'] != null &&
                (booking['child_names'] as List).isNotEmpty)
              _buildInfoRow(
                Icons.child_care,
                (booking['child_names'] as List).join(', '),
              ),

            // Date
            if (createdAt != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Booked on ${_formatDate(createdAt)}',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ),

            if (subscriptionStatus == 'paused')
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  pauseEndDate != null
                      ? 'Paused until ${_formatDate(DateTime.parse(pauseEndDate))}'
                      : 'Paused',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            if (scheduledStopDate != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Scheduled stop on ${_formatDate(DateTime.parse(scheduledStopDate))}',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

            // Actions
            if (showTrack || showCancel || showDelete || showRebook) ...[
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
                        label: Text(
                          status == 'accepted' ? 'Manage' : 'Cancel',
                          style: const TextStyle(color: Colors.red),
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

                  if (showDelete || showRebook) ...[
                    if (showDelete)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _deleteBooking(context, ref, booking['id']),
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: Colors.grey,
                          ),
                          label: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.grey),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.grey),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),

                    if (showDelete && showRebook) const SizedBox(width: 12),

                    if (showRebook)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _rebookDriver(context, ref, booking),
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Rebook'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo.shade50,
                            foregroundColor: Colors.indigo,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                  ],
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

  Future<void> _deleteBooking(
    BuildContext context,
    WidgetRef ref,
    String bookingId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Booking History?'),
        content: const Text(
          'This will permanently remove this booking from your list.\n\nNote: If there are payments linked to this booking, deletion might fail.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(bookingsRepositoryProvider).deleteBooking(bookingId);
        ref.invalidate(myBookingsProvider); // Force refresh
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Booking deleted')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to delete: ${e.toString().split("\n").first}',
              ),
            ),
          );
        }
      }
    }
  }

  void _rebookDriver(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> booking,
  ) {
    final driverId = booking['driver_id'];
    final driverName = booking['driver_name'] ?? 'Driver';

    if (driverId != null) {
      context.push(
        '/booking',
        extra: {
          'driverId': driverId,
          'driverName': driverName,
          // Pass the existing booking to pre-fill the form
          'initialData': booking,
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot rebook: Driver details missing')),
      );
    }
  }

  void _showCancelDialog(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> booking,
  ) {
    final status = booking['status'] as String?;
    if (status == 'accepted') {
      _showManageBookingDialog(context, ref, booking);
      return;
    }

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
              // Close dialog immediately
              Navigator.of(ctx, rootNavigator: true).pop();

              try {
                await ref
                    .read(bookingsRepositoryProvider)
                    .cancelBooking(
                      booking['id'],
                      cancellationType: 'parent_cancel_grace',
                      cancellationReason: 'parent_cancel_grace',
                      cancelRequestedAt: DateTime.now(),
                    );

                // Force refresh the list
                ref.invalidate(myBookingsProvider);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Booking cancelled successfully'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to cancel booking: $e')),
                  );
                }
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

  void _showManageBookingDialog(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> booking,
  ) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            24 + MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Manage Booking',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose the option that fits your situation.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 16),
              if ((booking['subscription_status'] as String?) == 'paused')
                _buildManageAction(
                  title: 'Resume Service',
                  subtitle: 'Continue pickups immediately',
                  icon: Icons.play_circle_filled,
                  iconColor: Colors.green,
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _resumeBooking(context, ref, booking);
                  },
                ),
              if (booking['contract_end_date'] != null)
                _buildManageAction(
                  title: 'Cancel Scheduled Stop',
                  subtitle: 'Keep service active',
                  icon: Icons.undo,
                  iconColor: Colors.green,
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _clearScheduledStop(context, ref, booking);
                  },
                ),
              _buildManageAction(
                title: 'Schedule Stop',
                subtitle: 'Set an end date for service',
                icon: Icons.event_busy,
                onTap: () async {
                  Navigator.pop(ctx);
                  final date = await _pickDate(context);
                  if (date == null) return;
                  await _applyScheduleStop(context, ref, booking, date);
                },
              ),
              _buildManageAction(
                title: 'Pause Service',
                subtitle: 'Temporarily pause pickups',
                icon: Icons.pause_circle_filled,
                onTap: () async {
                  Navigator.pop(ctx);
                  final date = await _pickDate(context);
                  if (date == null) return;
                  await _applyPause(context, ref, booking, date);
                },
              ),
              _buildManageAction(
                title: 'Stop Immediately',
                subtitle: 'Ends now; fees may apply',
                icon: Icons.cancel_schedule_send,
                onTap: () async {
                  Navigator.pop(ctx);
                  await _confirmImmediateStop(context, ref, booking);
                },
              ),
              _buildManageAction(
                title: 'Safety Issue',
                subtitle: 'Report a safety concern and stop',
                icon: Icons.report_gmailerrorred,
                onTap: () async {
                  Navigator.pop(ctx);
                  await _confirmSafetyStop(context, ref, booking);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManageAction({
    required String title,
    required String subtitle,
    required IconData icon,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Colors.indigo.shade50,
        child: Icon(icon, color: iconColor ?? Colors.indigo),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Future<DateTime?> _pickDate(BuildContext context) {
    final now = DateTime.now();
    return showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );
  }

  Future<void> _applyScheduleStop(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> booking,
    DateTime date,
  ) async {
    try {
      await ref
          .read(bookingsRepositoryProvider)
          .cancelBooking(
            booking['id'],
            status: 'accepted',
            cancellationType: 'scheduled_stop',
            cancellationReason: 'parent_scheduled_stop',
            contractEndDate: date,
            cancelRequestedAt: DateTime.now(),
          );
      ref.invalidate(myBookingsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Stop date scheduled')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to schedule stop: $e')));
      }
    }
  }

  Future<void> _applyPause(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> booking,
    DateTime untilDate,
  ) async {
    try {
      await ref
          .read(bookingsRepositoryProvider)
          .cancelBooking(
            booking['id'],
            status: 'accepted',
            cancellationType: 'pause',
            cancellationReason: 'parent_pause',
            pauseStartDate: DateTime.now(),
            pauseEndDate: untilDate,
            cancelRequestedAt: DateTime.now(),
            subscriptionStatus: 'paused',
          );
      ref.invalidate(myBookingsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Booking paused')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to pause booking: $e')));
      }
    }
  }

  Future<void> _confirmImmediateStop(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> booking,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Stop Immediately?'),
        content: const Text(
          'This will end the service now. Late cancellation fees may apply.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep Service'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Stop Now'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    try {
      await ref
          .read(bookingsRepositoryProvider)
          .cancelBooking(
            booking['id'],
            cancellationType: 'immediate_stop_fee',
            cancellationReason: 'parent_immediate_stop_fee',
            cancelRequestedAt: DateTime.now(),
          );
      ref.invalidate(myBookingsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Booking stopped')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to stop booking: $e')));
      }
    }
  }

  Future<void> _confirmSafetyStop(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> booking,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Report Safety Issue?'),
        content: const Text(
          'This will immediately stop service and alert support.',
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
            child: const Text('Stop & Report'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    try {
      await ref
          .read(bookingsRepositoryProvider)
          .cancelBooking(
            booking['id'],
            cancellationType: 'safety_stop',
            cancellationReason: 'safety_stop_pending_review',
            cancelRequestedAt: DateTime.now(),
          );
      ref.invalidate(myBookingsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Safety stop requested')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to stop booking: $e')));
      }
    }
  }

  Future<void> _resumeBooking(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> booking,
  ) async {
    try {
      await ref
          .read(bookingsRepositoryProvider)
          .updateBookingFields(booking['id'], {
            'subscription_status': 'active',
            'pause_start_date': null,
            'pause_end_date': null,
            'cancellation_type': null,
            'cancellation_reason': null,
          });
      ref.invalidate(myBookingsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Service resumed')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to resume: $e')));
      }
    }
  }

  Future<void> _clearScheduledStop(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> booking,
  ) async {
    try {
      await ref
          .read(bookingsRepositoryProvider)
          .updateBookingFields(booking['id'], {
            'contract_end_date': null,
            'cancellation_type': null,
            'cancellation_reason': null,
            'cancel_requested_at': null,
          });
      ref.invalidate(myBookingsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Scheduled stop removed')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
      }
    }
  }
}
