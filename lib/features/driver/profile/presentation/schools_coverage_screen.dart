import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import '../data/city_model.dart';
import '../data/school_model.dart';
import '../data/driver_coverage_repository.dart';

class CityWithSchools {
  final CityModel city;
  final List<SchoolModel> schools;
  final bool allSelected;
  final Set<String> selectedSchoolIds;

  CityWithSchools({
    required this.city,
    required this.schools,
    this.allSelected = false,
    required this.selectedSchoolIds,
  });
}

class SchoolsCoverageScreen extends riverpod.ConsumerStatefulWidget {
  const SchoolsCoverageScreen({super.key});

  @override
  ConsumerState<SchoolsCoverageScreen> createState() =>
      _SchoolsCoverageScreenState();
}

class _SchoolsCoverageScreenState extends ConsumerState<SchoolsCoverageScreen> {
  Set<String> _selectedSchoolIds = {};
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
      _selectedSchoolIds = Set.from(currentIds);
      _isLoaded = true;
    }
  }

  void _toggleSchool(String schoolId) {
    setState(() {
      if (_selectedSchoolIds.contains(schoolId)) {
        _selectedSchoolIds.remove(schoolId);
      } else {
        _selectedSchoolIds.add(schoolId);
      }
    });
  }

  void _toggleAllCitySchools(List<SchoolModel> citySchools, bool isSelected) {
    setState(() {
      if (isSelected) {
        for (var s in citySchools) _selectedSchoolIds.remove(s.id);
      } else {
        for (var s in citySchools) _selectedSchoolIds.add(s.id);
      }
    });
  }

  Future<void> _handleSave() async {
    final controller = ref.read(driverCoverageControllerProvider.notifier);
    await controller.saveSchools(_selectedSchoolIds);

    if (mounted) {
      final state = ref.read(driverCoverageControllerProvider);
      if (!state.hasError) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Schools coverage saved successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final citiesAsync = ref.watch(coverageCitiesProvider);
    final schoolsAsync = ref.watch(coverageAllSchoolsProvider);
    final currentCoverageAsync = ref.watch(driverCoverageSchoolIdsProvider);
    final saveState = ref.watch(driverCoverageControllerProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Schools Coverage',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${_selectedSchoolIds.length} school${_selectedSchoolIds.length != 1 ? 's' : ''} selected',
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
                hintText: 'Search schools, locations, or cities...',
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
              return schoolsAsync.when(
                data: (schools) {
                  final filteredCities = _processData(
                    cities,
                    schools,
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
                error: (e, s) => Center(child: Text('Error schools: $e')),
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

  List<CityWithSchools> _processData(
    List<CityModel> cities,
    List<SchoolModel> allSchools,
    String query,
  ) {
    query = query.toLowerCase().trim();
    List<CityWithSchools> result = [];

    for (var city in cities) {
      final citySchools = allSchools.where((s) => s.cityId == city.id).toList();
      if (citySchools.isEmpty) continue;

      final matchingSchools = citySchools.where((s) {
        final matchesName = s.name.toLowerCase().contains(query);
        final matchesCity = city.name.toLowerCase().contains(query);
        final matchesAddress =
            s.address?.toLowerCase().contains(query) ?? false;
        return matchesName || matchesCity || matchesAddress;
      }).toList();

      if (matchingSchools.isNotEmpty) {
        final selectedInCity = matchingSchools
            .where((s) => _selectedSchoolIds.contains(s.id))
            .map((s) => s.id)
            .toSet();

        result.add(
          CityWithSchools(
            city: city,
            schools: matchingSchools,
            selectedSchoolIds: selectedInCity,
            allSelected:
                matchingSchools.isNotEmpty &&
                selectedInCity.length == matchingSchools.length,
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
            child: const Icon(Icons.school, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select School Coverage',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                SizedBox(height: 4),
                Text(
                  'Choose the schools where you can pick up and drop off students.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF374151)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCityCard(CityWithSchools cityData) {
    final isExpanded = _expandedCityId == cityData.city.id;
    final selectedCount = cityData.selectedSchoolIds.length;

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
                          '${cityData.schools.length} school${cityData.schools.length != 1 ? 's' : ''} available',
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
                  ...cityData.schools.map(
                    (school) => _buildSchoolCheckbox(school),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSelectAllCheckbox(CityWithSchools cityData) {
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
                  _toggleAllCitySchools(cityData.schools, cityData.allSelected),
              activeColor: const Color(0xFF14B8A6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'All Schools in ${cityData.city.name}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  'Select all ${cityData.schools.length} schools',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchoolCheckbox(SchoolModel school) {
    final isSelected = _selectedSchoolIds.contains(school.id);
    return InkWell(
      onTap: () => _toggleSchool(school.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: isSelected,
                onChanged: (value) => _toggleSchool(school.id),
                activeColor: const Color(0xFF14B8A6),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.school, size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          school.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (school.address != null) ...[
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(left: 26),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              school.address!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
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
          Icon(Icons.school, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No schools found matching "${_searchController.text}"',
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
                    'Save Schools Coverage',
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
