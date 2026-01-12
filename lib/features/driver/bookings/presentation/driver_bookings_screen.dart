// lib/features/driver/bookings/presentation/driver_bookings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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

class _DriverBookingsScreenState extends ConsumerState<DriverBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
      body: bookingsAsync.when(
        data: (bookings) {
          final pending = bookings.where((b) => b.status == 'pending').toList();
          final active = bookings.where((b) => b.status == 'accepted').toList();
          final history = bookings
              .where((b) => b.status == 'rejected' || b.status == 'completed')
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
        error: (e, s) => Center(child: Text('Error: $e')),
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
