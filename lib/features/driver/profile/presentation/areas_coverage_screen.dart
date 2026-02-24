import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/city_model.dart';
import '../domain/models/area_model.dart';
import '../application/driver_coverage_controller.dart';
import '../data/driver_coverage_repository.dart';

// Helper model for UI state
class CityWithAreas {
  final CityModel city;
  final List<AreaModel> areas;
  final bool allSelected;
  final Set<String> selectedAreaIds;

  CityWithAreas({
    required this.city,
    required this.areas,
    this.allSelected = false,
    required this.selectedAreaIds,
  });
}

class AreasCoverageScreen extends ConsumerStatefulWidget {
  const AreasCoverageScreen({super.key});

  @override
  ConsumerState<AreasCoverageScreen> createState() =>
      _AreasCoverageScreenState();
}

class _AreasCoverageScreenState extends ConsumerState<AreasCoverageScreen> {
  Set<String> _selectedAreaIds = {};
  String? _expandedCityId;
  final TextEditingController _searchController = TextEditingController();
  bool _isLoaded = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _initializeSelection(Set<String> currentIds) {
    if (!_isLoaded) {
      _selectedAreaIds = Set.from(currentIds);
      _isLoaded = true;
    }
  }

  void _toggleArea(String areaId) {
    setState(() {
      if (_selectedAreaIds.contains(areaId)) {
        _selectedAreaIds.remove(areaId);
      } else {
        _selectedAreaIds.add(areaId);
      }
    });
  }

  void _toggleAllCityAreas(List<AreaModel> cityAreas, bool isSelected) {
    setState(() {
      if (isSelected) {
        // Deselect all
        for (var area in cityAreas) {
          _selectedAreaIds.remove(area.id);
        }
      } else {
        // Select all
        for (var area in cityAreas) {
          _selectedAreaIds.add(area.id);
        }
      }
    });
  }

  Future<void> _handleSave() async {
    final controller = ref.read(driverCoverageControllerProvider.notifier);
    await controller.saveAreas(_selectedAreaIds);

    if (mounted) {
      final state = ref.read(driverCoverageControllerProvider);
      if (!state.hasError) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Areas coverage saved successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final citiesAsync = ref.watch(coverageCitiesProvider);
    final areasAsync = ref.watch(coverageAllAreasProvider);
    final currentCoverageAsync = ref.watch(driverCoverageAreaIdsProvider);
    final saveState = ref.watch(driverCoverageControllerProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50], // Match design
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Areas Coverage',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${_selectedAreaIds.length} area${_selectedAreaIds.length != 1 ? 's' : ''} selected',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search cities or areas...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ),
      ),
      body: currentCoverageAsync.when(
        data: (currentIds) {
          _initializeSelection(currentIds);

          return citiesAsync.when(
            data: (cities) {
              return areasAsync.when(
                data: (areas) {
                  final filteredCities = _processData(
                    cities,
                    areas,
                    _searchController.text,
                  );

                  if (filteredCities.isEmpty) {
                    return _buildEmptyState();
                  }

                  return Column(
                    children: [
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            _buildSummaryCard(),
                            const SizedBox(height: 16),
                            ...filteredCities.map(
                              (cityData) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildCityCard(cityData),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildSaveButton(saveState),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text('Error areas: $e')),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Error cities: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error coverage: $e')),
      ),
    );
  }

  List<CityWithAreas> _processData(
    List<CityModel> cities,
    List<AreaModel> allAreas,
    String query,
  ) {
    query = query.toLowerCase().trim();
    List<CityWithAreas> result = [];

    for (var city in cities) {
      final cityAreas = allAreas.where((a) => a.cityId == city.id).toList();
      if (cityAreas.isEmpty) continue;

      final matchingAreas = cityAreas
          .where(
            (a) =>
                a.name.toLowerCase().contains(query) ||
                city.name.toLowerCase().contains(query),
          )
          .toList();

      if (matchingAreas.isNotEmpty) {
        final selectedInCity = matchingAreas
            .where((a) => _selectedAreaIds.contains(a.id))
            .map((a) => a.id)
            .toSet();

        result.add(
          CityWithAreas(
            city: city,
            areas: matchingAreas,
            selectedAreaIds: selectedInCity,
            allSelected:
                matchingAreas.isNotEmpty &&
                selectedInCity.length == matchingAreas.length,
          ),
        );
      }
    }
    return result;
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFCCFBF1),
        border: Border.all(color: const Color(0xFF99F6E4)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFF14B8A6),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_on, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Service Areas',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                SizedBox(height: 4),
                Text(
                  'Choose the neighborhoods and areas where you can provide transportation services.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF374151)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCityCard(CityWithAreas cityData) {
    final isExpanded = _expandedCityId == cityData.city.id;
    final selectedCount = cityData.selectedAreaIds.length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expandedCityId = isExpanded ? null : cityData.city.id;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_right,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cityData.city.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${cityData.areas.length} area${cityData.areas.length != 1 ? 's' : ''} available',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (selectedCount > 0)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF14B8A6),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$selectedCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSelectAllCheckbox(cityData),
                  const SizedBox(height: 8),
                  ...cityData.areas.map((area) => _buildAreaCheckbox(area)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSelectAllCheckbox(CityWithAreas cityData) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFCCFBF1),
        border: Border.all(color: const Color(0xFF14B8A6), width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: cityData.allSelected,
              onChanged: (value) =>
                  _toggleAllCityAreas(cityData.areas, cityData.allSelected),
              activeColor: const Color(0xFF14B8A6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'All Areas in ${cityData.city.name}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  'Select all ${cityData.areas.length} areas',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAreaCheckbox(AreaModel area) {
    final isSelected = _selectedAreaIds.contains(area.id);
    return InkWell(
      onTap: () => _toggleArea(area.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: isSelected,
                onChanged: (value) => _toggleArea(area.id),
                activeColor: const Color(0xFF14B8A6),
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.location_on, size: 18, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(
              child: Text(area.name, style: const TextStyle(fontSize: 15)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_on, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No areas found matching "${_searchController.text}"',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(AsyncValue<void> saveState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: saveState.isLoading ? null : _handleSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF14B8A6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: saveState.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Save Areas Coverage',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

