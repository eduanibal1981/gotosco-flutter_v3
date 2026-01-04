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
                          height:
                              190, // Slightly taller to accommodate padding/shadows if needed
                          child: PageView.builder(
                            padEnds: false,
                            controller: PageController(viewportFraction: 0.92),
                            itemCount: acceptedBookings.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: DriverStatusMonitor(
                                  booking: acceptedBookings[index],
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

                // 5. SUGGESTED ADS (Only if no bookings)
                bookingsAsync.when(
                  data: (bookings) {
                    if (bookings.isEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.near_me,
                                size: 18,
                                color: Colors.indigo,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "Drivers Near You",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const FeaturedDrivers(),
                          const SizedBox(height: 24),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
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
