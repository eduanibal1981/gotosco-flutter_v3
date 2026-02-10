import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gotosco_v3/features/parent/find_driver/presentation/filter_drivers_screen.dart';
import 'package:gotosco_v3/features/parent/find_driver/presentation/favorites_screen.dart';
import 'widgets/driver_ad_card.dart';
import '../application/find_driver_providers.dart';

class FindDriversScreen extends ConsumerStatefulWidget {
  const FindDriversScreen({super.key});

  @override
  ConsumerState<FindDriversScreen> createState() => _FindDriversScreenState();
}

class _FindDriversScreenState extends ConsumerState<FindDriversScreen> {
  Position? _currentPosition;
  bool _locationDenied = false;
  bool _locationServiceDisabled = false;
  Timer? _searchDebounce;
  final TextEditingController _searchController = TextEditingController();
  bool _showClearButton = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref
          .read(
            driverAdsProvider(
              lat: _currentPosition?.latitude,
              lng: _currentPosition?.longitude,
            ).notifier,
          )
          .loadNextPage();
    }
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        setState(() {
          _locationServiceDisabled = true;
        });
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          setState(() {
            _locationDenied = true;
          });
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        setState(() {
          _locationDenied = true;
        });
      }
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    if (mounted) {
      setState(() {
        _currentPosition = position;
        _locationDenied = false;
        _locationServiceDisabled = false;
      });
    }
  }

  void _openLocationSettings() {
    Geolocator.openLocationSettings();
  }

  void _openAppSettings() {
    Geolocator.openAppSettings();
  }

  void _openFilters() async {
    final currentFilters = ref.read(driversFilterControllerProvider);
    // Use the new full screen filter or large modal
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            FilterDriversScreen(initialFilters: currentFilters),
      ),
    );

    if (result != null) {
      ref.read(driversFilterControllerProvider.notifier).updateFilters(result);
    }
  }

  void _clearFilters() {
    ref.read(driversFilterControllerProvider.notifier).clearFilters();
  }

  void _clearSearch() {
    _searchController.clear();
    _onSearchChanged('');
    setState(() {
      _showClearButton = false;
    });
  }

  void _onSearchChanged(String value) {
    if (_showClearButton != value.isNotEmpty) {
      setState(() {
        _showClearButton = value.isNotEmpty;
      });
    }

    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(driversFilterControllerProvider.notifier).updateFilters({
        'searchQuery': value.trim(),
      });
      ref.invalidate(
        driverAdsProvider(
          lat: _currentPosition?.latitude,
          lng: _currentPosition?.longitude,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final filterController = ref.watch(
      driversFilterControllerProvider.notifier,
    );

    // We pass lat/lng as named arguments. Filters are watched internally by the provider.
    final driversAsync = ref.watch(
      driverAdsProvider(
        lat: _currentPosition?.latitude,
        lng: _currentPosition?.longitude,
      ),
    );
    final filterSummary = filterController.filterSummary;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        controller: _scrollController,
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
                  child: Semantics(
                    label: "Search drivers",
                    textField: true,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextField(
                        controller: _searchController,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: "Search by driver name, area, school...",
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.grey,
                          ),
                          suffixIcon: _showClearButton
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    size: 20,
                                    color: Colors.grey,
                                  ),
                                  onPressed: _clearSearch,
                                  tooltip: 'Clear search',
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                        ),
                        onChanged: _onSearchChanged,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Filter Button (Highlight if filters are active)
                Semantics(
                  button: true,
                  label: "Filter drivers",
                  hint: filterSummary != null
                      ? "Filters active: $filterSummary"
                      : null,
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
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _openFilters,
                            borderRadius: BorderRadius.circular(12),
                            child: const Icon(Icons.tune, color: Colors.white),
                          ),
                        ),
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

                const SizedBox(width: 12),

                // Favorites Button
                Semantics(
                  button: true,
                  label: "Show favorite drivers",
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.pink.shade100),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pink.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FavoritesScreen(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: const Icon(Icons.favorite, color: Colors.pink),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (_locationServiceDisabled || _locationDenied)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: _buildLocationBanner(),
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
            skipLoadingOnReload: true,
            data: (drivers) {
              if (drivers.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.indigo.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.search_off_rounded,
                              size: 48,
                              color: Colors.indigo.shade300,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            "No Drivers Found",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "We couldn't find any drivers matching your current filters. Try adjusting your search criteria.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _clearFilters,
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text('Clear Filters'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.indigo,
                              elevation: 0,
                              side: BorderSide(color: Colors.indigo.shade100),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              final bool isPaginating = driversAsync.isLoading;
              return SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      // Show loading spinner at the bottom
                      if (index == drivers.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return DriverAdCard(driver: drivers[index]);
                    },
                    // Add 1 for the spinner if paginating
                    childCount: drivers.length + (isPaginating ? 1 : 0),
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

  Widget _buildLocationBanner() {
    final title = _locationServiceDisabled
        ? 'Turn on Location Services'
        : 'Enable Location Permission';
    final body = _locationServiceDisabled
        ? 'Location is off. Turn it on to find nearby drivers.'
        : 'Allow location to improve driver search results.';
    final actionLabel = _locationServiceDisabled
        ? 'Open Settings'
        : 'Grant Access';
    final onTap = _locationServiceDisabled
        ? _openLocationSettings
        : _openAppSettings;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.location_off, color: Colors.orange.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.orange.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: TextStyle(color: Colors.orange.shade700, fontSize: 12),
                ),
              ],
            ),
          ),
          TextButton(onPressed: onTap, child: Text(actionLabel)),
        ],
      ),
    );
  }
}
