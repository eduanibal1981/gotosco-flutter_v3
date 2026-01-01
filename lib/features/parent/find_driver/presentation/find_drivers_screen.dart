// lib/features/parent/find_driver/presentation/find_drivers_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/drivers_repository.dart';
import 'widgets/driver_ad_card.dart';
import 'widgets/filter_sheet.dart';

class FindDriversScreen extends ConsumerStatefulWidget {
  const FindDriversScreen({super.key});

  @override
  ConsumerState<FindDriversScreen> createState() => _FindDriversScreenState();
}

class _FindDriversScreenState extends ConsumerState<FindDriversScreen> {
  // 1. REMOVE 'final' so we can reassign it
  Map<String, dynamic> _filters = {
    'gender': 'All',
    'maxPrice': 100.0,
    'vehicleType': 'All',
    'cityId': null,
    'areaId': null,
    'schoolId': null,
  };

  void _openFilters() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterSheet(currentFilters: _filters),
    );

    if (result != null) {
      setState(() {
        // 2. CREATE A NEW MAP INSTANCE
        // This forces Riverpod to see a "change" and re-fetch data.
        _filters = Map.from(_filters)..addAll(result);

        // Alternative syntax:
        // _filters = {..._filters, ...result};
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Now this will trigger because _filters is a new object
    final driversAsync = ref.watch(driverAdsProvider(_filters));

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          // --- Search & Filter Header ---
          SliverAppBar(
            floating: true,
            pinned: true,
            backgroundColor: Colors.grey.shade50,
            elevation: 0,
            toolbarHeight: 80,
            title: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: "Search area, school...",
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      onChanged: (val) {
                        // For text search, you would update state here similarly
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _openFilters,
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.indigo,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.indigo.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.tune, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // --- Drivers List ---
          driversAsync.when(
            data: (drivers) {
              if (drivers.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text("No drivers found matching your filters."),
                      ],
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => DriverAdCard(driver: drivers[index]),
                    childCount: drivers.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) =>
                SliverFillRemaining(child: Center(child: Text("Error: $err"))),
          ),
        ],
      ),
    );
  }
}
