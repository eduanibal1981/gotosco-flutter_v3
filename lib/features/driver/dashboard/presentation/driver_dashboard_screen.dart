// lib/features/driver/dashboard/presentation/driver_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../data/driver_dashboard_repository.dart';
import '../../earnings/presentation/earnings_tab.dart';
import '../../profile/presentation/driver_profile_tab.dart';
import '../../availability/presentation/driver_availability_controller.dart';
import 'package:gotosco_v3/features/driver/bookings/presentation/driver_bookings_screen.dart';
import 'package:gotosco_v3/features/driver/transport_requests/data/transport_requests_repository.dart';
import 'tabs/driver_home_tab.dart';
import 'tabs/trips_tab.dart';
import '../../../../core/widgets/double_back_to_exit_wrapper.dart';

// Provider for managing selected tab index
final driverDashboardIndexProvider =
    StateNotifierProvider<DashboardIndexNotifier, int>((ref) {
      return DashboardIndexNotifier();
    });

// Provider for managing booking screen tab index
final driverBookingTabIndexNotifierProvider =
    StateNotifierProvider<BookingTabIndexNotifier, int>((ref) {
      return BookingTabIndexNotifier();
    });

class DashboardIndexNotifier extends StateNotifier<int> {
  DashboardIndexNotifier()
    : super(2); // Default to Home tab (Index 2 in the new order)

  void setIndex(int index) => state = index;
}

class BookingTabIndexNotifier extends StateNotifier<int> {
  BookingTabIndexNotifier() : super(0); // Default to Requests tab

  void setIndex(int index) => state = index.clamp(0, 3);
}

class DriverDashboardScreen extends ConsumerStatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  ConsumerState<DriverDashboardScreen> createState() =>
      _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends ConsumerState<DriverDashboardScreen> {
  int? _previousIndex;

  // Pages are built dynamically to pass booking tab index
  List<Widget> _buildPages(int bookingTabIndex) {
    return [
      const EarningsTab(), // Index 0: Earnings
      const DriverBookingsScreen(), // Index 1: Booking
      const DriverHomeTab(), // Index 2: Home
      const TripsTab(), // Index 3: Trips
      const DriverProfileTab(), // Index 4: Profile
    ];
  }

  @override
  void initState() {
    super.initState();
    // Check if driver should auto-go-online based on schedule
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(driverAvailabilityControllerProvider.notifier).checkAutoOnline();
    });
  }

  /// Invalidate providers when switching tabs to ensure fresh data
  void _onTabChanged(int newIndex) {
    if (_previousIndex != null && _previousIndex != newIndex) {
      // Invalidate providers based on which tab we're navigating TO
      switch (newIndex) {
        case 0: // Earnings Tab
          ref.invalidate(driverStatsProvider);
          break;
        case 1: // Booking Tab
          ref.invalidate(driverBookingRequestsProvider);
          ref.invalidate(transportRequestsProvider);
          break;
        case 2: // Home Tab
          ref.invalidate(driverDashboardStateProvider);
          ref.invalidate(driverStatsProvider);
          ref.invalidate(todaysTripsProvider);
          ref.invalidate(nextScheduledTripProvider);
          ref.invalidate(activeTripProvider);
          break;
        case 3: // Trips Tab
          ref.invalidate(todaysTripsProvider);
          ref.invalidate(driverStatsProvider);
          ref.invalidate(driverBookingRequestsProvider);
          ref.invalidate(driverStudentsProvider);
          break;
        case 4: // Profile Tab
          ref.invalidate(driverProfileProvider);
          break;
      }
    }
    _previousIndex = newIndex;
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(driverDashboardIndexProvider);
    final bookingTabIndex = ref.watch(driverBookingTabIndexNotifierProvider);

    // Listen for tab changes and invalidate providers
    ref.listen<int>(driverDashboardIndexProvider, (previous, next) {
      _onTabChanged(next);
    });

    return DoubleBackToExitWrapper(
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: IndexedStack(
          index: selectedIndex,
          children: _buildPages(bookingTabIndex),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (i) =>
              ref.read(driverDashboardIndexProvider.notifier).setIndex(i),
          backgroundColor: Colors.white,
          elevation: 8,
          shadowColor: Colors.black12,
          indicatorColor: Colors.teal.shade50,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: Icon(
                Icons.account_balance_wallet,
                color: Colors.teal,
              ),
              label: 'Earnings',
            ),
            NavigationDestination(
              icon: Icon(Icons.book_online_outlined),
              selectedIcon: Icon(Icons.book_online, color: Colors.teal),
              label: 'Booking',
            ),
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home, color: Colors.teal),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.directions_bus_outlined),
              selectedIcon: Icon(Icons.directions_bus, color: Colors.teal),
              label: 'Trips',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person, color: Colors.teal),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
