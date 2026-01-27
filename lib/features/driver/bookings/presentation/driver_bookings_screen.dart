// lib/features/driver/bookings/presentation/driver_bookings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gotosco_v3/features/driver/bookings/data/booking_model.dart';
import 'package:gotosco_v3/features/driver/bookings/data/driver_bookings_repository.dart';
import 'package:gotosco_v3/features/driver/bookings/presentation/widgets/booking_card.dart';
import 'package:gotosco_v3/features/driver/bookings/presentation/widgets/booking_detail_sheet.dart';

class DriverBookingsScreen extends ConsumerStatefulWidget {
  const DriverBookingsScreen({super.key});

  @override
  ConsumerState<DriverBookingsScreen> createState() =>
      _DriverBookingsScreenState();
}

class _DriverBookingsScreenState extends ConsumerState<DriverBookingsScreen> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(driverBookingsProvider);

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
                  colors: [Colors.teal.shade600, Colors.teal.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Manage Bookings',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Track and manage your transport requests',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  // Quick Stats / Filters
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
                child: _buildErrorState(context, ref, err.toString()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(List<BookingModel> bookings) {
    // Determine counts based on status
    final active = bookings
        .where(
          (b) =>
              (b.status == 'confirmed' || b.status == 'accepted') &&
              (b.subscriptionStatus == 'active' ||
                  b.subscriptionStatus == null),
        )
        .length;
    final requests = bookings
        .where((b) => b.status == 'pending' || b.status == 'posted')
        .length;

    return Row(
      children: [
        _buildStatCard(
          icon: Icons.check_circle,
          title: 'Active',
          subtitle: 'Show',
          value: active.toString(),
          color: Colors.white, // Inverted for teal background? No, keep style
          isSelected: _selectedFilter == 'active',
          onTap: () => setState(() => _selectedFilter = 'active'),
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          icon: Icons.hourglass_empty,
          title: 'Requests',
          subtitle: 'Show',
          value: requests.toString(),
          color: Colors.orange.shade200,
          isSelected: _selectedFilter == 'requests',
          onTap: () => setState(() => _selectedFilter = 'requests'),
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          icon: Icons.history, // or list
          title: 'All',
          subtitle: 'Show',
          value: bookings.length.toString(),
          color: Colors.white70,
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
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
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
                color: Colors.teal.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inbox_outlined,
                size: 60,
                color: Colors.teal.shade300,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Bookings Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You have no booking requests or history at the moment.',
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
                ref.invalidate(driverBookingsProvider);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
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

  Widget _buildErrorState(BuildContext context, WidgetRef ref, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 56, color: Colors.red.shade300),
            const SizedBox(height: 12),
            const Text(
              'Unable to load bookings',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => ref.refresh(driverBookingsProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
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
    List<BookingModel> bookings,
  ) {
    // Group by status
    final requests = bookings
        .where((b) => b.status == 'pending' || b.status == 'posted')
        .toList();
    final active = bookings
        .where(
          (b) =>
              (b.status == 'confirmed' || b.status == 'accepted') &&
              (b.subscriptionStatus == 'active' ||
                  b.subscriptionStatus == null),
        )
        .toList();
    // History includes rejected, completed, cancelled, or expired subscriptions
    final history = bookings.where((b) {
      return b.status == 'cancelled' ||
          b.status == 'rejected' ||
          b.status == 'completed' ||
          b.subscriptionStatus == 'expired' ||
          b.subscriptionStatus == 'cancelled';
    }).toList();

    final List<Widget> items = [];

    // Requests Section
    if (requests.isNotEmpty &&
        (_selectedFilter == 'all' || _selectedFilter == 'requests')) {
      items.add(
        _buildSectionHeader('New Requests', Colors.orange, requests.length),
      );
      for (var booking in requests) {
        items.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: BookingCard(
              booking: booking,
              isPending: true,
              onTap: () => _showBookingDetails(context, ref, booking),
            ),
          ),
        );
      }
      items.add(const SizedBox(height: 12));
    }

    // Active Section
    if (active.isNotEmpty &&
        (_selectedFilter == 'all' || _selectedFilter == 'active')) {
      items.add(
        _buildSectionHeader('Active Bookings', Colors.green, active.length),
      );
      for (var booking in active) {
        items.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: BookingCard(
              booking: booking,
              onTap: () => _showBookingDetails(context, ref, booking),
            ),
          ),
        );
      }
      items.add(const SizedBox(height: 12));
    }

    // History Section
    // Show history only when 'all' is selected, as per typical UX, or could be a separate filter if needed.
    // In MyBookingsTab, it shows completed/rejected when 'all' is selected.
    if (history.isNotEmpty && _selectedFilter == 'all') {
      items.add(_buildSectionHeader('History', Colors.grey, history.length));
      for (var booking in history) {
        items.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: BookingCard(
              booking: booking,
              canDelete: true, // Allow deleting history items
              onTap: () => _showBookingDetails(context, ref, booking),
            ),
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
      padding: const EdgeInsets.only(bottom: 12, left: 4),
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
              color: color.withOpacity(0.8), // Slightly darker for readability
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
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBookingDetails(
    BuildContext context,
    WidgetRef ref,
    BookingModel booking,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BookingDetailSheet(booking: booking),
    );
  }
}
