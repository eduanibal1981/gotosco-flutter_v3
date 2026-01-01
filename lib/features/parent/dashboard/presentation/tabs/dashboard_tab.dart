// lib/features/parent/dashboard/presentation/tabs/dashboard_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

// Import your widgets
import '../widgets/dashboard_header.dart';
import '../widgets/live_status_card.dart';
import '../widgets/actionable_empty_state_card.dart';
import '../widgets/transport_request_card.dart'; // NEW
import '../widgets/children_section.dart'; // NEW
import '../widgets/featured_drivers.dart'; // Existing
import '../widgets/today_trip_list.dart'; // Existing

// --- MOCK PROVIDERS (Replace with real DB logic) ---
final hasChildrenProvider = StateProvider<bool>(
  (ref) => true,
); // Toggle to test
final hasBookingsProvider = StateProvider<bool>(
  (ref) => false,
); // Toggle to test
final hasActiveTripProvider = StateProvider<bool>(
  (ref) => false,
); // Toggle to test

class DashboardTab extends ConsumerWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasChildren = ref.watch(hasChildrenProvider);
    final hasBookings = ref.watch(hasBookingsProvider);
    final hasActiveTrip = ref.watch(hasActiveTripProvider);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // 1. HEADER (With Call, Notif, Favorite)
        const DashboardHeader(),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // 2. MAIN STATUS CARD (Dynamic)
                // Priority: Active Trip > Accepted Bookings > Empty/Start
                if (hasActiveTrip)
                  const LiveStatusCard()
                else if (hasBookings)
                  _buildAcceptedBookingsSummary()
                else
                  const ActionableEmptyStateCard(), // "Let's Start"

                const SizedBox(height: 24),

                // 3. CHILDREN CARD (List or "Add Message")
                const ChildrenSection(),

                const SizedBox(height: 24),

                // 4. REQUEST TRANSPORT CARD (New Feature)
                const TransportRequestCard(),

                const SizedBox(height: 24),

                // 5. SUGGESTED ADS (Conditional)
                // "Appear only if no booking in the list"
                if (!hasBookings) ...[
                  Row(
                    children: [
                      const Icon(Icons.near_me, size: 18, color: Colors.indigo),
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
                  const FeaturedDrivers(), // Shows best 5 ads
                  const SizedBox(height: 24),
                ],

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
        const TodayTripList(), // Reusing your list widget
      ],
    );
  }
}
