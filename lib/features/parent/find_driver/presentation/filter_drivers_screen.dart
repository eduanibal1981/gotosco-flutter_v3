import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/find_driver_providers.dart';

class FilterDriversScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> initialFilters;

  const FilterDriversScreen({super.key, required this.initialFilters});

  @override
  ConsumerState<FilterDriversScreen> createState() =>
      _FilterDriversScreenState();
}

class _FilterDriversScreenState extends ConsumerState<FilterDriversScreen> {
  late String _selectedGender;
  late String _selectedVehicle;
  late double _maxPrice;
  late bool _onlineOnly;
  late bool _verifiedOnly;
  late double _minRating;
  late double _maxDistance;
  String? _selectedCityId;
  String? _selectedAreaId;
  String? _selectedSchoolId;

  @override
  void initState() {
    super.initState();
    _selectedGender = widget.initialFilters['gender'] ?? 'All';
    _selectedVehicle = widget.initialFilters['vehicleType'] ?? 'All';
    _maxPrice =
        (widget.initialFilters['maxPrice'] as num?)?.toDouble() ?? 3000.0;
    _onlineOnly = widget.initialFilters['onlineOnly'] ?? false;
    _verifiedOnly = widget.initialFilters['verifiedOnly'] ?? false;
    _minRating =
        (widget.initialFilters['minRating'] as num?)?.toDouble() ?? 0.0;
    _maxDistance =
        (widget.initialFilters['maxDistance'] as num?)?.toDouble() ?? 50.0;
    _selectedCityId = widget.initialFilters['cityId'];
    _selectedAreaId = widget.initialFilters['areaId'];
    _selectedSchoolId = widget.initialFilters['schoolId'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Filter Drivers'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          TextButton(onPressed: _resetFilters, child: const Text('Reset')),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gender
            _buildSectionTitle('Gender'),
            const SizedBox(height: 8),
            _buildChoiceChips(
              ['All', 'male', 'female'],
              _selectedGender,
              (val) => setState(() => _selectedGender = val),
            ),

            const SizedBox(height: 24),

            // Vehicle Type
            _buildSectionTitle('Vehicle Type'),
            const SizedBox(height: 8),
            _buildChoiceChips(
              ['All', 'Sedan', 'SUV', 'Van', 'Bus'],
              _selectedVehicle,
              (val) => setState(() => _selectedVehicle = val),
            ),

            const SizedBox(height: 24),

            // Price Range
            _buildSectionTitle('Max Monthly Price (Two-way)'),
            ref
                .watch(priceRangeProvider)
                .when(
                  data: (range) {
                    // Ensure current value is within valid range
                    // If range.min == range.max, expand slightly to avoid slider error
                    final min = range.min;
                    final max = range.max > range.min
                        ? range.max
                        : range.min + 100;

                    // Allow _maxPrice to exceed max if it was set higher previously?
                    // No, clamp it for UI consistency.
                    // But don't modify state directly in build.
                    // Just clamp for display and slider.
                    final displayValue = _maxPrice.clamp(min, max);

                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('SAR ${min.round()}'),
                            Text(
                              'SAR ${displayValue.round()}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: displayValue,
                          min: min,
                          max: max,

                          activeColor: Colors.indigo,
                          label: displayValue.round().toString(),
                          onChanged: (val) => setState(() => _maxPrice = val),
                        ),
                      ],
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: LinearProgressIndicator(),
                  ),
                  error: (err, _) => const Text('Error loading price range'),
                ),

            const SizedBox(height: 24),
            // Price Range
            _buildSectionTitle('Max Distance (Km)'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('1 km'),
                Text(
                  '${_maxDistance.round()} km',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
              ],
            ),
            Slider(
              value: _maxDistance,
              min: 1,
              max: 100,
              divisions: 99,
              activeColor: Colors.indigo,
              label: _maxDistance.round().toString(),
              onChanged: (val) => setState(() => _maxDistance = val),
            ),

            const SizedBox(height: 24),

            // Areas Searchable Selector
            _buildSectionTitle(
              'Area',
              subtitle: 'Areas drivers cover for student pickup',
            ),
            const SizedBox(height: 8),
            _buildSearchableSelector(
              title: 'Area',
              label: _getAreaLabel(_selectedAreaId),
              selectedCityId: _selectedCityId,
              selectedId: _selectedAreaId,
              itemsProvider: areasProvider,
              onSelected: (cityId, itemId) {
                setState(() {
                  _selectedCityId = cityId;
                  _selectedAreaId = itemId;
                });
              },
            ),

            const SizedBox(height: 24),

            // Schools Searchable Selector
            _buildSectionTitle(
              'School',
              subtitle: 'Schools drivers transport to',
            ),
            const SizedBox(height: 8),
            _buildSearchableSelector(
              title: 'School',
              label: _getSchoolLabel(_selectedSchoolId),
              selectedCityId: _selectedCityId,
              selectedId: _selectedSchoolId,
              itemsProvider: schoolsProvider,
              onSelected: (cityId, itemId) {
                setState(() {
                  _selectedCityId = cityId;
                  _selectedSchoolId = itemId;
                });
              },
            ),

            const SizedBox(height: 24),

            // Switches
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Online Drivers Only'),
              value: _onlineOnly,
              activeColor: Colors.indigo,
              onChanged: (val) => setState(() => _onlineOnly = val),
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Verified Drivers Only'),
              value: _verifiedOnly,
              activeColor: Colors.indigo,
              onChanged: (val) => setState(() => _verifiedOnly = val),
            ),

            const SizedBox(height: 16),
            _buildSectionTitle('Minimum Rating'),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${_minRating.toStringAsFixed(1)}+',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: Slider(
                    value: _minRating,
                    min: 0,
                    max: 5,
                    divisions: 5, // 0, 1, 2, 3, 4, 5
                    activeColor: Colors.orange,
                    onChanged: (val) => setState(() => _minRating = val),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context, {
                'gender': _selectedGender,
                'vehicleType': _selectedVehicle,
                'maxPrice': _maxPrice,
                'onlineOnly': _onlineOnly,
                'verifiedOnly': _verifiedOnly,
                'minRating': _minRating > 0 ? _minRating : null,
                'maxDistance': _maxDistance < 100 ? _maxDistance : null,
                'areaId': _selectedAreaId,
                'schoolId': _selectedSchoolId,
                'cityId': _selectedCityId, // Return cityId
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Apply Filters',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedGender = 'All';
      _selectedVehicle = 'All';
      _maxPrice = 5000.0;
      _onlineOnly = false;
      _verifiedOnly = false;
      _minRating = 0.0;
      _maxDistance = 50.0;
      _selectedAreaId = null;
      _selectedSchoolId = null;
      _selectedCityId = null; // Reset cityId
    });
  }

  String _getAreaLabel(String? areaId) {
    if (areaId == null) return 'All Areas';
    final areas = ref.read(areasProvider(cityId: _selectedCityId)).value;
    return areas?.firstWhere(
          (element) => element['id'] == areaId,
          orElse: () => {'name': 'All Areas'},
        )['name'] ??
        'All Areas';
  }

  String _getSchoolLabel(String? schoolId) {
    if (schoolId == null) return 'All Schools';
    final schools = ref.read(schoolsProvider(cityId: _selectedCityId)).value;
    return schools?.firstWhere(
          (element) => element['id'] == schoolId,
          orElse: () => {'name': 'All Schools'},
        )['name'] ??
        'All Schools';
  }

  Widget _buildSectionTitle(String title, {String? subtitle}) {
    if (subtitle != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      );
    }
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildChoiceChips(
    List<String> options,
    String selectedValue,
    Function(String) onSelected,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((label) {
        final isSelected = selectedValue == label;
        return ChoiceChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) onSelected(label);
          },
          selectedColor: Colors.indigo.shade100,
          labelStyle: TextStyle(
            color: isSelected ? Colors.indigo.shade900 : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          backgroundColor: Colors.white,
          side: isSelected
              ? BorderSide.none
              : BorderSide(color: Colors.grey.shade300),
        );
      }).toList(),
    );
  }

  Widget _buildSearchableSelector({
    required String title,
    required String? label,
    required String? selectedCityId,
    required String? selectedId,
    // Use dynamic to avoid import issues with AutoDisposeFutureProviderFamily
    required dynamic itemsProvider,
    required Function(String? cityId, String? itemId) onSelected,
  }) {
    return InkWell(
      onTap: () async {
        final result = await showModalBottomSheet<Map<String, String?>>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) => _CityDependentSelectionSheet(
            title: title,
            initialCityId: selectedCityId,
            initialItemId: selectedId,
            itemsProvider: itemsProvider,
          ),
        );

        if (result != null) {
          onSelected(result['cityId'], result['itemId']);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label ?? 'Select $title',
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _CityDependentSelectionSheet extends ConsumerStatefulWidget {
  final String title;
  final String? initialCityId;
  final String? initialItemId;
  // Use dynamic here as well matching the helper
  final dynamic itemsProvider;

  const _CityDependentSelectionSheet({
    required this.title,
    required this.initialCityId,
    required this.initialItemId,
    required this.itemsProvider,
  });

  @override
  ConsumerState<_CityDependentSelectionSheet> createState() =>
      _CityDependentSelectionSheetState();
}

class _CityDependentSelectionSheetState
    extends ConsumerState<_CityDependentSelectionSheet> {
  late TextEditingController _searchController;
  String? _selectedCityId;
  String? _selectedItemId;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _selectedCityId = widget.initialCityId;
    _selectedItemId = widget.initialItemId;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final citiesAsync = ref.watch(citiesProvider);
    final AsyncValue<List<Map<String, dynamic>>> itemsAsync = ref.watch(
      widget.itemsProvider(cityId: _selectedCityId),
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, controller) {
        return Column(
          children: [
            // Handle bar
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // City Dropdown
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: citiesAsync.when(
                data: (cities) => DropdownButtonFormField<String>(
                  value: _selectedCityId,
                  decoration: InputDecoration(
                    labelText: 'Select City First',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Cities'),
                    ),
                    ...cities.map(
                      (c) => DropdownMenuItem(
                        value: c['id'] as String,
                        child: Text(c['name'] as String),
                      ),
                    ),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _selectedCityId = val;
                      _selectedItemId = null; // Reset item when city changes
                    });
                  },
                ),
                loading: () => const LinearProgressIndicator(),
                error: (err, _) => const SizedBox(),
              ),
            ),

            if (_selectedCityId == null)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Please select a city to see available options",
                  style: TextStyle(color: Colors.grey),
                ),
              ),

            if (_selectedCityId != null) ...[
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search ${widget.title}...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
              const SizedBox(height: 8),

              // List
              Expanded(
                child: itemsAsync.when(
                  data: (items) {
                    final filtered = items.where((item) {
                      final name = item['name'] as String;
                      return name.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      );
                    }).toList();

                    if (filtered.isEmpty) {
                      return const Center(child: Text("No results found"));
                    }

                    return ListView.separated(
                      controller: controller,
                      itemCount: filtered.length + 1,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          // "All" option for this city? Or just clear selection?
                          return ListTile(
                            title: const Text('Any (Clear Selection)'),
                            onTap: () {
                              Navigator.pop(context, {
                                'cityId': _selectedCityId,
                                'itemId': null, // Clear filter
                              });
                            },
                          );
                        }
                        final item = filtered[index - 1];
                        final isSelected = item['id'] == _selectedItemId;
                        return ListTile(
                          title: Text(item['name'] as String),
                          trailing: isSelected
                              ? const Icon(Icons.check, color: Colors.indigo)
                              : null,
                          onTap: () {
                            Navigator.pop(context, {
                              'cityId': _selectedCityId,
                              'itemId': item['id'] as String,
                            });
                          },
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: Text('Error: $err')),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
