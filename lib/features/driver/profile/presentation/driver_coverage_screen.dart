import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/area_model.dart';
import '../data/city_model.dart';
import '../data/driver_coverage_repository.dart';
import '../data/school_model.dart';

class DriverCoverageScreen extends ConsumerStatefulWidget {
  const DriverCoverageScreen({super.key});

  @override
  ConsumerState<DriverCoverageScreen> createState() =>
      _DriverCoverageScreenState();
}

class _DriverCoverageScreenState extends ConsumerState<DriverCoverageScreen> {
  String? _selectedCityId;
  final _areaSearchController = TextEditingController();
  final _schoolSearchController = TextEditingController();
  final _selectedAreaIds = <String>{};
  final _selectedSchoolIds = <String>{};
  bool _initialSelectionLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadInitialSelection();
  }

  Future<void> _loadInitialSelection() async {
    final areaIds = await ref.read(driverCoverageAreaIdsProvider.future);
    final schoolIds = await ref.read(driverCoverageSchoolIdsProvider.future);
    if (!mounted) return;
    setState(() {
      _selectedAreaIds.addAll(areaIds);
      _selectedSchoolIds.addAll(schoolIds);
      _initialSelectionLoaded = true;
    });
  }

  @override
  void dispose() {
    _areaSearchController.dispose();
    _schoolSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final citiesAsync = ref.watch(coverageCitiesProvider);
    final saveState = ref.watch(driverCoverageControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coverage'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      backgroundColor: Colors.grey.shade50,
      body: citiesAsync.when(
        data: (cities) {
          if (_selectedCityId == null && cities.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _selectedCityId == null) {
                setState(() => _selectedCityId = cities.first.id);
              }
            });
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: _buildCityPicker(cities),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _selectedCityId == null
                    ? const Center(child: Text('Select a city to continue'))
                    : _buildCoverageLists(context),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: saveState.isLoading ? null : _handleSaveCoverage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: saveState.isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Save Coverage',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Failed to load cities: $err')),
      ),
    );
  }

  Widget _buildCityPicker(List<CityModel> cities) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'City',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedCityId,
          items: cities
              .map(
                (city) => DropdownMenuItem(
                  value: city.id,
                  child: Text(city.name),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              _selectedCityId = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildCoverageLists(BuildContext context) {
    final cityId = _selectedCityId!;
    final areasAsync = ref.watch(coverageAreasProvider(cityId: cityId));
    final schoolsAsync = ref.watch(coverageSchoolsProvider(cityId: cityId));

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        _buildSectionHeader(
          title: 'Covered Areas',
          subtitle: 'Choose neighborhoods you can reach easily.',
          trailing: _buildSelectionCount(_selectedAreaIds.length),
        ),
        const SizedBox(height: 8),
        _buildSearchField(
          controller: _areaSearchController,
          hintText: 'Search areas',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        areasAsync.when(
          data: (areas) => _buildAreasList(areas),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Text('Failed to load areas: $err'),
        ),
        const SizedBox(height: 20),
        _buildSectionHeader(
          title: 'Covered Schools',
          subtitle: 'Select schools you can serve in this city.',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSelectionCount(_selectedSchoolIds.length),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => _openAddSchoolDialog(context, cityId),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add School'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _buildSearchField(
          controller: _schoolSearchController,
          hintText: 'Search schools',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        schoolsAsync.when(
          data: (schools) => _buildSchoolsList(schools),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Text('Failed to load schools: $err'),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildAreasList(List<AreaModel> areas) {
    final query = _areaSearchController.text.trim().toLowerCase();
    final filtered = query.isEmpty
        ? areas
        : areas
            .where((area) => area.name.toLowerCase().contains(query))
            .toList();

    if (filtered.isEmpty) {
      return _buildEmptyHint('No areas found for this city.');
    }

    return Column(
      children: filtered.map((area) {
        final selected = _selectedAreaIds.contains(area.id);
        return CheckboxListTile(
          value: selected,
          onChanged: (value) {
            setState(() {
              if (value == true) {
                _selectedAreaIds.add(area.id);
              } else {
                _selectedAreaIds.remove(area.id);
              }
            });
          },
          title: Text(area.name),
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: Colors.teal,
          contentPadding: EdgeInsets.zero,
        );
      }).toList(),
    );
  }

  Widget _buildSchoolsList(List<SchoolModel> schools) {
    final query = _schoolSearchController.text.trim().toLowerCase();
    final filtered = query.isEmpty
        ? schools
        : schools
            .where((school) => school.name.toLowerCase().contains(query))
            .toList();

    if (filtered.isEmpty) {
      return _buildEmptyHint('No schools found for this city.');
    }

    return Column(
      children: filtered.map((school) {
        final selected = _selectedSchoolIds.contains(school.id);
        return CheckboxListTile(
          value: selected,
          onChanged: (value) {
            setState(() {
              if (value == true) {
                _selectedSchoolIds.add(school.id);
              } else {
                _selectedSchoolIds.remove(school.id);
              }
            });
          },
          title: Text(school.name),
          subtitle: school.address != null && school.address!.isNotEmpty
              ? Text(school.address!)
              : null,
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: Colors.teal,
          contentPadding: EdgeInsets.zero,
        );
      }).toList(),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildSelectionCount(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count selected',
        style: TextStyle(
          color: Colors.teal.shade700,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSearchField({
    required TextEditingController controller,
    required String hintText,
    required ValueChanged<String> onChanged,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildEmptyHint(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: TextStyle(color: Colors.grey.shade600),
      ),
    );
  }

  Future<void> _handleSaveCoverage() async {
    if (!_initialSelectionLoaded) return;

    final controller = ref.read(driverCoverageControllerProvider.notifier);
    await controller.saveCoverage(
      areaIds: _selectedAreaIds,
      schoolIds: _selectedSchoolIds,
    );

    if (!mounted) return;

    final state = ref.read(driverCoverageControllerProvider);
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving coverage: ${state.error}'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Coverage updated'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _openAddSchoolDialog(BuildContext context, String cityId) async {
    final nameController = TextEditingController();
    final addressController = TextEditingController();

    final created = await showDialog<SchoolModel>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add School'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'School name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                final school =
                    await ref.read(driverCoverageRepositoryProvider).addSchool(
                          cityId: cityId,
                          name: name,
                          address: addressController.text.trim().isEmpty
                              ? null
                              : addressController.text.trim(),
                        );
                if (context.mounted) {
                  Navigator.pop(context, school);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    nameController.dispose();
    addressController.dispose();

    if (created == null) return;
    if (!mounted) return;
    ref.invalidate(coverageSchoolsProvider(cityId: cityId));
    setState(() {
      _selectedSchoolIds.add(created.id);
    });
  }
}
