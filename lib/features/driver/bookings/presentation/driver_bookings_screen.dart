// lib/features/driver/bookings/presentation/driver_bookings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gotosco_v3/features/driver/bookings/data/booking_model.dart';
import 'package:gotosco_v3/features/driver/bookings/data/driver_bookings_repository.dart';
import 'package:gotosco_v3/features/driver/bookings/presentation/widgets/booking_card.dart';
import 'package:gotosco_v3/features/driver/bookings/presentation/widgets/booking_detail_sheet.dart';

class DriverBookingsScreen extends ConsumerStatefulWidget {
  final int initialTabIndex;

  const DriverBookingsScreen({super.key, this.initialTabIndex = 0});

  @override
  ConsumerState<DriverBookingsScreen> createState() =>
      _DriverBookingsScreenState();
}

class _DriverBookingsScreenState extends ConsumerState<DriverBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 2),
    );
  }

  @override
  void didUpdateWidget(DriverBookingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTabIndex != oldWidget.initialTabIndex) {
      _tabController.animateTo(widget.initialTabIndex.clamp(0, 2));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(driverBookingsProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Manage Bookings'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Requests'),
            Tab(text: 'Active'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: RefreshIndicator(
        color: Colors.teal,
        onRefresh: () async {
          ref.invalidate(driverBookingsProvider);
          await ref.read(driverBookingsProvider.future);
        },
        child: bookingsAsync.when(
          data: (bookings) {
            final pending =
                bookings.where((b) => b.status == 'pending').toList();
            final active =
                bookings.where((b) => b.status == 'accepted').toList();
            final history = bookings
                .where(
                  (b) =>
                      b.status == 'rejected' ||
                      b.status == 'completed' ||
                      b.status == 'cancelled',
                )
                .toList(); // Adjust status based on real data

            return TabBarView(
              controller: _tabController,
              children: [
                _buildBookingList(context, ref, pending, isPending: true),
                _buildBookingList(context, ref, active),
                _buildBookingList(context, ref, history, canDelete: true),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => _buildErrorState(context, ref, e.toString()),
        ),
      ),
    );
  }

  Widget _buildBookingList(
    BuildContext context,
    WidgetRef ref,
    List<BookingModel> bookings, {
    bool isPending = false,
    bool canDelete = false,
  }) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No bookings found',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return BookingCard(
          booking: booking,
          isPending: isPending,
          canDelete:
              canDelete ||
              booking
                  .isExpired, // Allow delete if explicitly allowed OR expired
          onTap: () => _showBookingDetails(context, ref, booking),
        );
      },
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    WidgetRef ref,
    String message,
  ) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Padding(
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
      ],
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
