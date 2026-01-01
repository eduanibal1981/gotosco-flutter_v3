// lib/features/parent/find_driver/presentation/widgets/filter_sheet.dart
import 'package:flutter/material.dart';

class FilterSheet extends StatefulWidget {
  final Map<String, dynamic> currentFilters;

  const FilterSheet({super.key, required this.currentFilters});

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late String _selectedGender;
  late double _maxPrice;
  late String _vehicleType;

  @override
  void initState() {
    super.initState();
    _selectedGender = widget.currentFilters['gender'] ?? 'All';
    _maxPrice = (widget.currentFilters['maxPrice'] ?? 200.0).toDouble();
    _vehicleType = widget.currentFilters['vehicleType'] ?? 'All';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 24),
          const Text("Filter Drivers", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),

          // --- GENDER ---
          const Text("Driver Gender", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildFilterChip("All", "All", _selectedGender, (val) => setState(() => _selectedGender = val)),
              const SizedBox(width: 12),
              _buildFilterChip("Male", "male", _selectedGender, (val) => setState(() => _selectedGender = val)),
              const SizedBox(width: 12),
              _buildFilterChip("Female", "female", _selectedGender, (val) => setState(() => _selectedGender = val)),
            ],
          ),
          const SizedBox(height: 24),

          // --- PRICE ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Max Monthly Price", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("${_maxPrice.toInt()} OMR", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
            ],
          ),
          Slider(
            value: _maxPrice,
            min: 50,
            max: 500,
            divisions: 9,
            activeColor: Colors.indigo,
            onChanged: (val) => setState(() => _maxPrice = val),
          ),
          const SizedBox(height: 30),

          // --- APPLY BUTTON ---
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  'gender': _selectedGender,
                  'maxPrice': _maxPrice,
                  'vehicleType': _vehicleType,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Apply Filters", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, String groupValue, Function(String) onSelect) {
    final isSelected = groupValue.toLowerCase() == value.toLowerCase();
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        if (selected) onSelect(value);
      },
      selectedColor: Colors.indigo.shade100,
      labelStyle: TextStyle(
        color: isSelected ? Colors.indigo.shade900 : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}