import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('SAR 0'),
                Text(
                  'SAR ${_maxPrice.round()}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
              ],
            ),
            Slider(
              value: _maxPrice,
              min: 0,
              max: 5000,
              divisions: 50,
              activeColor: Colors.indigo,
              label: _maxPrice.round().toString(),
              onChanged: (val) => setState(() => _maxPrice = val),
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
                // areaId and schoolId are preserved by caller if needed, or added here if we had pickers
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
    });
  }

  Widget _buildSectionTitle(String title) {
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
}
