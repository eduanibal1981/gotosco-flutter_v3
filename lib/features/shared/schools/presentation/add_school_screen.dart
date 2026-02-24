import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:gotosco_v3/features/shared/schools/data/schools_repository.dart';
import 'package:gotosco_v3/features/driver/profile/domain/models/city_model.dart';
import 'package:gotosco_v3/features/shared/location/presentation/location_picker_screen.dart';

class AddSchoolScreen extends ConsumerStatefulWidget {
  final String? initialName;
  final String? initialCityId; // NEW

  const AddSchoolScreen({super.key, this.initialName, this.initialCityId});

  @override
  ConsumerState<AddSchoolScreen> createState() => _AddSchoolScreenState();
}

class _AddSchoolScreenState extends ConsumerState<AddSchoolScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  final _addressController = TextEditingController();

  CityModel? _selectedCity;
  List<CityModel> _cities = [];
  LatLng? _selectedLocation;
  bool _isLoading = false;
  bool _isLoadingCities = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _loadCities();
  }

  Future<void> _loadCities() async {
    try {
      final cities = await ref.read(schoolsRepositoryProvider).getCities();
      if (mounted) {
        setState(() {
          _cities = cities;
          _isLoadingCities = false; // Loaded

          // Pre-select city if ID provided
          if (widget.initialCityId != null) {
            try {
              _selectedCity = cities.firstWhere(
                (c) => c.id == widget.initialCityId,
              );
              // Assuming ID matches exactly
            } catch (_) {}
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingCities = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading cities: $e')));
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (context) =>
            LocationPickerScreen(initialLocation: _selectedLocation),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedLocation = result;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCity == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a city')));
      return;
    }
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location on map')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final school = await ref
          .read(schoolsRepositoryProvider)
          .upsertSchool(
            name: _nameController.text.trim(),
            address: _addressController.text.trim().isEmpty
                ? null
                : _addressController.text.trim(),
            cityId: _selectedCity!.id,
            latitude: _selectedLocation!.latitude,
            longitude: _selectedLocation!.longitude,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('School added successfully'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop(school);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving school: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New School')),
      body: _isLoadingCities
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'School Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<CityModel>(
                      value: _selectedCity,
                      decoration: const InputDecoration(
                        labelText: 'City',
                        border: OutlineInputBorder(),
                      ),
                      items: _cities.map((city) {
                        return DropdownMenuItem(
                          value: city,
                          child: Text(city.name),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedCity = val),
                    ),
                    const SizedBox(height: 16),

                    InkWell(
                      onTap: _pickLocation,
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade100,
                        ),
                        child: Center(
                          child: _selectedLocation == null
                              ? const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.map,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                    Text('Tap to pick location'),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 40,
                                    ),
                                    Text(
                                      'Lat: ${_selectedLocation!.latitude.toStringAsFixed(4)}, Lng: ${_selectedLocation!.longitude.toStringAsFixed(4)}',
                                    ),
                                    const Text(
                                      'Tap to change',
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Address (Optional)',
                        border: OutlineInputBorder(),
                        hintText: 'e.g. Street name, Building',
                      ),
                    ),

                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Save School'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

