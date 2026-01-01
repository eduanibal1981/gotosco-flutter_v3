import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../find_driver/presentation/find_drivers_screen.dart'; // Ensure import
import 'tabs/dashboard_tab.dart';
import 'dashboard_controller.dart'; // Import the new controller

class ParentDashboardScreen extends ConsumerWidget {
  const ParentDashboardScreen({super.key});

  // Pages corresponding to Navbar items
  final List<Widget> _pages = const [
    FindDriversScreen(),        // Index 0: The Driver Ads Screen
    DashboardTab(),             // Index 1: Home
    Center(child: Text("Children List Page")),
    Center(child: Text("Profile Page")),
    Center(child: Text("My Bookings Page")),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Watch the provider
    final selectedIndex = ref.watch(parentDashboardIndexProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: IndexedStack(
        index: selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        // 2. Update provider on click
        onDestinationSelected: (i) => ref.read(parentDashboardIndexProvider.notifier).state = i,
        backgroundColor: Colors.white,
        elevation: 8,
        shadowColor: Colors.black12,
        indicatorColor: Colors.indigo.shade50,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
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
            icon: Icon(Icons.child_care_outlined),
            selectedIcon: Icon(Icons.child_care, color: Colors.indigo),
            label: 'Children',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: Colors.indigo),
            label: 'Profile',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month, color: Colors.indigo),
            label: 'Booking',
          ),
        ],
      ),
    );
  }
}