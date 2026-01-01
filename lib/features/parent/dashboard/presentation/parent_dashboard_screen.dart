// lib/features/parent/dashboard/presentation/parent_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tabs/dashboard_tab.dart';

class ParentDashboardScreen extends ConsumerStatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  ConsumerState<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends ConsumerState<ParentDashboardScreen> {
  int _selectedIndex = 1; // Default to 'Home' (Index 1)

  // Pages corresponding to your requested Navbar items
  final List<Widget> _pages = const [
    Center(child: Text("Find Drivers Page")), // Index 0
    DashboardTab(),                           // Index 1 (Home)
    Center(child: Text("Children List Page")),// Index 2
    Center(child: Text("Profile Page")),      // Index 3
    Center(child: Text("My Bookings Page")),  // Index 4
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
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