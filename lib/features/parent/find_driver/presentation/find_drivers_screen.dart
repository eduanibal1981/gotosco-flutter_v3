// lib/features/parent/find_driver/presentation/find_drivers_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/drivers_repository.dart';
import 'widgets/driver_ad_card.dart';
import 'widgets/filter_sheet.dart';
import 'drivers_controller.dart';

class FindDriversScreen extends ConsumerStatefulWidget {
  const FindDriversScreen({super.key});

  @override
  ConsumerState<FindDriversScreen> createState() => _FindDriversScreenState();
}

class _FindDriversScreenState extends ConsumerState<FindDriversScreen> {
  void _openFilters() async {
    final currentFilters = ref.read(driversFilterControllerProvider);
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterSheet(currentFilters: currentFilters),
    );

    if (result != null) {
      ref.read(driversFilterControllerProvider.notifier).updateFilters(result);
    }
  }

  void _clearFilters() {
    ref.read(driversFilterControllerProvider.notifier).clearFilters();
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(driversFilterControllerProvider);
    final filterController = ref.watch(
      driversFilterControllerProvider.notifier,
    );
    final driversAsync = ref.watch(driverAdsProvider(filters));
    final filterSummary = filterController.filterSummary;

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
                        // Implement text search logic if needed
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Filter Button (Highlight if filters are active)
                GestureDetector(
                  onTap: _openFilters,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
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
                      // Red Dot Badge if filtered
                      if (filterSummary != null)
                        Positioned(
                          top: -2,
                          right: -2,
                          child: Container(
                            height: 14,
                            width: 14,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- 4. NEW: Filter Summary Bar ---
          if (filterSummary != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.indigo.shade100),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.filter_list,
                        size: 18,
                        color: Colors.indigo,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Filtered by: $filterSummary",
                          style: TextStyle(
                            color: Colors.indigo.shade900,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      InkWell(
                        onTap: _clearFilters,
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.close,
                            size: 20,
                            color: Colors.indigo,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
