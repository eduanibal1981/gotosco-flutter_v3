import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../find_driver/presentation/find_drivers_screen.dart'; // Ensure import
import '../../children/presentation/children_tab.dart'; // NEW
import '../../bookings/presentation/my_bookings_tab.dart'; // NEW
import '../../profile/presentation/profile_tab.dart'; // NEW
import 'tabs/dashboard_tab.dart';
import 'dashboard_controller.dart'; // Import the new controller
import '../../../../core/widgets/double_back_to_exit_wrapper.dart';

class ParentDashboardScreen extends ConsumerWidget {
  const ParentDashboardScreen({super.key});

  // Pages corresponding to Navbar items
  final List<Widget> _pages = const [
    ChildrenTab(), // Index 0: Children
    FindDriversScreen(), // Index 1: Find Driver
    DashboardTab(), // Index 2: Home
    MyBookingsTab(), // Index 3: Bookings
    ProfileTab(), // Index 4: Profile
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Watch the provider
    final selectedIndex = ref.watch(parentDashboardIndexProvider);

    return DoubleBackToExitWrapper(
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: IndexedStack(index: selectedIndex, children: _pages),
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          // 2. Update provider on click
          onDestinationSelected: (i) =>
              ref.read(parentDashboardIndexProvider.notifier).setIndex(i),
          backgroundColor: Colors.white,
          elevation: 8,
          shadowColor: Colors.black12,
          indicatorColor: Colors.indigo.shade50,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.child_care_outlined),
              selectedIcon: Icon(Icons.child_care, color: Colors.indigo),
              label: 'Children',
            ),
            NavigationDestination(
              icon: Icon(Icons.search_outlined),
              selectedIcon: Icon(Icons.search, color: Colors.indigo),
              label: 'Find',
            ),
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home, color: Colors.indigo),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month, color: Colors.indigo),
              label: 'Booking',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person, color: Colors.indigo),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
