// lib/features/parent/dashboard/presentation/tabs/dashboard_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import your widgets
import '../widgets/dashboard_header.dart';
import '../widgets/actionable_empty_state_card.dart';
import '../widgets/driver_status_monitor.dart'; // NEW
import '../widgets/transport_request_card.dart';
import '../widgets/children_section.dart';
import '../widgets/featured_drivers.dart';
import '../widgets/today_trip_list.dart';

import '../../../bookings/data/bookings_repository.dart'; // Import repo

class DashboardTab extends ConsumerWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch real bookings stream
    final bookingsAsync = ref.watch(myBookingsProvider);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // 1. HEADER
        const DashboardHeader(),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // 2. MAIN STATUS CARD (Dynamic)
                bookingsAsync.when(
                  data: (bookings) {
                    // Check for ALL accepted bookings
                    final acceptedBookings = bookings
                        .where((b) => b['status'] == 'accepted')
                        .toList();

                    // Logic:
                    // 1. If accepted bookings exist (> 0) -> Show List of DriverStatusMonitors
                    // 2. Else -> Show ActionableEmptyStateCard

                    if (acceptedBookings.isNotEmpty) {
                      if (acceptedBookings.length == 1) {
                        return DriverStatusMonitor(
                          booking: acceptedBookings.first,
                        );
                      } else {
                        // Multiple active bookings -> Horizontal List
                        return SizedBox(
                          height: 220, // Increased to accommodate shadows
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            physics: const BouncingScrollPhysics(),
                            itemCount: acceptedBookings.length,
                            itemBuilder: (context, index) {
                              return SizedBox(
                                width: MediaQuery.of(context).size.width * 0.9,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 16.0),
                                  child: DriverStatusMonitor(
                                    booking: acceptedBookings[index],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }
                    } else if (bookings.isNotEmpty) {
                      // Has pending/cancelled but no approved contract
                      return _buildAcceptedBookingsSummary();
                    } else {
                      // No bookings at all
                      return const ActionableEmptyStateCard();
                    }
                  },
                  loading: () => const SizedBox(
                    height: 180,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, stack) => Text('Error: $err'),
                ),

                const SizedBox(height: 24),

                // 3. CHILDREN CARD
                const ChildrenSection(),

                const SizedBox(height: 24),

                // 4. REQUEST TRANSPORT CARD
                const TransportRequestCard(),

                const SizedBox(height: 24),

                // 5. SUGGESTED ADS
                // 5. SUGGESTED ADS
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.near_me, size: 18, color: Colors.indigo),
                        SizedBox(width: 8),
                        Text(
                          "Drivers Near You",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    FeaturedDrivers(),
                    SizedBox(height: 24),
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAcceptedBookingsSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Upcoming Trips",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const TodayTripList(),
      ],
    );
  }
}
