import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/location_repository.dart';

class FilterSheet extends ConsumerStatefulWidget {
  final Map<String, dynamic> currentFilters;

  const FilterSheet({super.key, required this.currentFilters});

  @override
  ConsumerState<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<FilterSheet> {
  // Existing filters
  late String _selectedGender;
  late double _maxPrice;
  late String _vehicleType;

  // New Location filters
  String? _selectedCityId;
  String? _selectedAreaId;
  String? _selectedSchoolId;

  @override
  void initState() {
    super.initState();
    _selectedGender = widget.currentFilters['gender'] ?? 'All';
    _maxPrice = (widget.currentFilters['maxPrice'] ?? 200.0).toDouble();
    _vehicleType = widget.currentFilters['vehicleType'] ?? 'All';

    // Restore location state if previously selected
    _selectedCityId = widget.currentFilters['cityId'];
    _selectedAreaId = widget.currentFilters['areaId'];
    _selectedSchoolId = widget.currentFilters['schoolId'];
  }

  @override
  Widget build(BuildContext context) {
    // Watch providers
    final citiesAsync = ref.watch(citiesProvider);
    final areasAsync = _selectedCityId == null
        ? const AsyncValue.data(<Map<String, dynamic>>[])
        : ref.watch(areasProvider(_selectedCityId!));
    final schoolsAsync = _selectedAreaId == null
        ? const AsyncValue.data(<Map<String, dynamic>>[])
        : ref.watch(schoolsProvider(_selectedAreaId!));

    return Container(
      height: MediaQuery.of(context).size.height * 0.85, // Taller sheet
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Filter Drivers",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: ListView(
              children: [
                // 1. LOCATION SECTION
                const Text(
                  "Location & School",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),

                // City Dropdown
                _buildDropdown(
                  label: "City",
                  value: _selectedCityId,
                  items: citiesAsync.value ?? <Map<String, dynamic>>[],
                  onChanged: (val) {
                    setState(() {
                      _selectedCityId = val;
                      _selectedAreaId = null; // Reset dependent fields
                      _selectedSchoolId = null;
                    });
                  },
                ),
                const SizedBox(height: 12),

                // Area Dropdown (Enabled only if City selected)
                _buildDropdown(
                  label: "Area",
                  value: _selectedAreaId,
                  items: areasAsync.value ?? <Map<String, dynamic>>[],
                  enabled: _selectedCityId != null,
                  onChanged: (val) {
                    setState(() {
                      _selectedAreaId = val;
                      _selectedSchoolId = null;
                    });
                  },
                ),
                const SizedBox(height: 12),

                // School Dropdown (Enabled only if Area selected)
                _buildDropdown(
                  label: "School (Optional)",
                  value: _selectedSchoolId,
                  items: schoolsAsync.value ?? <Map<String, dynamic>>[],
                  enabled: _selectedAreaId != null,
                  onChanged: (val) => setState(() => _selectedSchoolId = val),
                ),

                const Divider(height: 40),

                // 2. GENDER SECTION
                const Text(
                  "Driver Gender",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildChip("All", "All"),
                    const SizedBox(width: 12),
                    _buildChip("Male", "male"),
                    const SizedBox(width: 12),
                    _buildChip("Female", "female"),
                  ],
                ),
                const SizedBox(height: 24),

                // 3. PRICE SECTION
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Max Monthly Price",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${_maxPrice.toInt()} OMR",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _maxPrice,
                  min: 10,
                  max: 250,
                  divisions: 15,
                  activeColor: Colors.indigo,
                  onChanged: (val) => setState(() => _maxPrice = val),
                ),
              ],
            ),
          ),

          // APPLY BUTTON
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  'gender': _selectedGender,
                  'maxPrice': _maxPrice,
                  'vehicleType': _vehicleType,
                  'cityId': _selectedCityId, // Pass new filters
                  'areaId': _selectedAreaId,
                  'schoolId': _selectedSchoolId,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Apply Filters",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<Map<String, dynamic>> items,
    required Function(String?) onChanged,
    bool enabled = true,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey.shade100,
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item['id'] as String,
          child: Text(item['name'] as String),
        );
      }).toList(),
      onChanged: enabled ? onChanged : null,
      hint: Text(enabled ? "Select $label" : "Select City first"),
    );
  }

  Widget _buildChip(String label, String value) {
    final isSelected = _selectedGender.toLowerCase() == value.toLowerCase();
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _selectedGender = value);
      },
      selectedColor: Colors.indigo.shade100,
      labelStyle: TextStyle(
        color: isSelected ? Colors.indigo.shade900 : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
