// lib/features/driver/dashboard/presentation/driver_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../data/driver_dashboard_repository.dart';
import '../../earnings/presentation/earnings_tab.dart';
import '../../profile/presentation/driver_profile_tab.dart';
import 'tabs/driver_home_tab.dart';
import 'tabs/trips_tab.dart';

// Provider for managing selected tab index
final driverDashboardIndexProvider =
    StateNotifierProvider<DashboardIndexNotifier, int>((ref) {
      return DashboardIndexNotifier();
    });

class DashboardIndexNotifier extends StateNotifier<int> {
  DashboardIndexNotifier() : super(0); // Default to Home tab

  void setIndex(int index) => state = index;
}

class DriverDashboardScreen extends ConsumerStatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  ConsumerState<DriverDashboardScreen> createState() =>
      _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends ConsumerState<DriverDashboardScreen> {
  int? _previousIndex;

  // Pages corresponding to Navbar items (4 tabs as per user request)
  final List<Widget> _pages = const [
    DriverHomeTab(), // Index 0: Home
    TripsTab(), // Index 1: Trips
    EarningsTab(), // Index 2: Earnings
    DriverProfileTab(), // Index 3: Profile
  ];

  /// Invalidate providers when switching tabs to ensure fresh data
  void _onTabChanged(int newIndex) {
    if (_previousIndex != null && _previousIndex != newIndex) {
      // Invalidate providers based on which tab we're navigating TO
      switch (newIndex) {
        case 0: // Home Tab
          ref.invalidate(driverDashboardStateProvider);
          ref.invalidate(driverStatsProvider);
          ref.invalidate(todaysTripsProvider);
          ref.invalidate(nextScheduledTripProvider);
          ref.invalidate(activeTripProvider);
          break;
        case 1: // Trips Tab
          ref.invalidate(todaysTripsProvider);
          ref.invalidate(driverStatsProvider);
          ref.invalidate(driverBookingRequestsProvider);
          ref.invalidate(driverStudentsProvider);
          break;
        case 2: // Earnings Tab
          ref.invalidate(driverStatsProvider);
          break;
        case 3: // Profile Tab
          ref.invalidate(driverProfileProvider);
          break;
      }
    }
    _previousIndex = newIndex;
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(driverDashboardIndexProvider);

    // Listen for tab changes and invalidate providers
    ref.listen<int>(driverDashboardIndexProvider, (previous, next) {
      _onTabChanged(next);
    });

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: IndexedStack(index: selectedIndex, children: _pages),
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
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(
              Icons.account_balance_wallet,
              color: Colors.teal,
            ),
            label: 'Earnings',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: Colors.teal),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
