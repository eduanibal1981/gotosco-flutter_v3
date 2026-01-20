import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gotosco_v3/features/parent/children/data/child_model.dart';
import 'package:gotosco_v3/features/parent/children/data/children_repository.dart';
import 'package:gotosco_v3/features/shared/schools/data/school_model.dart';
import 'package:gotosco_v3/features/shared/schools/presentation/school_selection_field.dart';
import 'package:gotosco_v3/features/driver/profile/data/city_model.dart';
import 'package:gotosco_v3/features/shared/schools/data/schools_repository.dart';

class EditChildScreen extends ConsumerStatefulWidget {
  final ChildModel child; // Receive the child data to edit

  const EditChildScreen({super.key, required this.child});

  @override
  ConsumerState<EditChildScreen> createState() => _EditChildScreenState();
}

class _EditChildScreenState extends ConsumerState<EditChildScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _gradeController;
  late TextEditingController _medicalController;
  late TextEditingController _notesController;

  late String _selectedGender;
  DateTime? _selectedDate;
  bool _isLoading = false;

  // School & City State
  SchoolModel? _selectedSchool;
  CityModel? _selectedCity;
  List<CityModel> _cities = [];
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.child.name);
    _gradeController = TextEditingController(text: widget.child.grade);
    _medicalController = TextEditingController(
      text: widget.child.medicalConditions,
    );
    _notesController = TextEditingController(text: widget.child.notes);
    _selectedGender = widget.child.gender ?? 'male';
    _selectedDate =
        widget.child.dob ??
        DateTime.now().subtract(const Duration(days: 365 * 6));

    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      // 1. Fetch Cities
      final cities = await ref.read(schoolsRepositoryProvider).getCities();

      // 2. Fetch existing school details if ID exists
      SchoolModel? existingSchool;
      if (widget.child.schoolId != null) {
        existingSchool = await ref
            .read(schoolsRepositoryProvider)
            .getSchoolById(widget.child.schoolId!);
      }

      if (mounted) {
        setState(() {
          _cities = cities;
          _selectedSchool = existingSchool; // Set initial school model

          // Pre-select city based on school
          if (existingSchool != null) {
            try {
              _selectedCity = cities.firstWhere(
                (c) => c.id == existingSchool!.cityId,
              );
            } catch (_) {}
          }

          _isLoadingData = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingData = false);
      print('Error loading initial data: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _gradeController.dispose();
    _medicalController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _update() async {
    if (!_formKey.currentState!.validate()) return;

    // Validation: ensure school is selected or at least name preserved
    // Logic: If _selectedSchool is null, it means we didn't fetch it successfully AND user didn't pick one.
    // If widget.child.schoolName exists, we could fallback, but better to force selection if we want IDs.
    if (_selectedSchool == null && widget.child.schoolName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a school')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref
          .read(childrenRepositoryProvider)
          .updateChild(
            childId: widget.child.id,
            name: _nameController.text.trim(),
            school:
                _selectedSchool?.name ??
                widget
                    .child
                    .schoolName, // Fallback to old name if not changed/fetched
            schoolId: _selectedSchool?.id, // Can be null if using legacy name
            grade: _gradeController.text.trim(),
            gender: _selectedGender,
            dob: _selectedDate!,
            medicalConditions: _medicalController.text.trim(),
            notes: _notesController.text.trim(),
          );

      if (!mounted) return;
      ref.invalidate(myChildrenProvider);
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Child profile updated!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ... delete method remains same ...

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete Child Profile?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => c.pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => c.pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await ref.read(childrenRepositoryProvider).deleteChild(widget.child.id);
      if (!mounted) return;
      ref.invalidate(myChildrenProvider);
      context.pop();
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        actions: [
          IconButton(
            onPressed: _delete,
            icon: const Icon(Icons.delete_outline, color: Colors.red),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: _nameController,
                label: "Full Name",
                icon: Icons.person,
              ),
              const SizedBox(height: 16),

              // --- School Section ---
              const Text(
                "School Details",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(height: 8),

              _buildCityDropdown(),
              const SizedBox(height: 16),

              SchoolSelectionField(
                initialValue: _selectedSchool?.name ?? widget.child.schoolName,
                cityId: _selectedCity?.id,
                onSchoolSelected: (school) {
                  setState(() => _selectedSchool = school);
                },
              ),

              const SizedBox(height: 16),
              _buildTextField(
                controller: _gradeController,
                label: "Grade",
                icon: Icons.class_,
              ),
              const SizedBox(height: 24),

              // ... (Include Gender and Date pickers similar to Add Screen) ...
              // For brevity assuming helper methods or re-implementing them minimally
              _buildGenderRes(),
              const SizedBox(height: 16),
              _buildDateRes(),

              const SizedBox(height: 16),
              _buildTextField(
                controller: _medicalController,
                label: "Medical Conditions",
                icon: Icons.medical_services,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _notesController,
                label: "Notes",
                icon: Icons.note,
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _update,
                  child: const Text("Update Profile"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCityDropdown() {
    return DropdownButtonFormField<CityModel>(
      value: _selectedCity,
      decoration: InputDecoration(
        labelText: 'Select City',
        prefixIcon: const Icon(Icons.location_city, color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      items: _cities.map((city) {
        return DropdownMenuItem(value: city, child: Text(city.name));
      }).toList(),
      onChanged: (val) {
        setState(() {
          _selectedCity = val;
          // Note: we don't clear selected school name immediately to avoid jarring UX,
          // but the ID logic handles filters.
          _selectedSchool = null;
        });
      },
      validator: (val) => val == null ? 'Please select a city' : null,
    );
  }

  Widget _buildGenderRes() {
    return Row(
      children: [
        Expanded(child: _buildGenderCard('male', Icons.male, Colors.blue)),
        const SizedBox(width: 12),
        Expanded(child: _buildGenderCard('female', Icons.female, Colors.pink)),
      ],
    );
  }

  Widget _buildGenderCard(String value, IconData icon, Color color) {
    final isSelected = _selectedGender == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey, size: 28),
            const SizedBox(height: 4),
            Text(
              value[0].toUpperCase() + value.substring(1),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? color : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRes() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (picked != null) setState(() => _selectedDate = picked);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today),
            const SizedBox(width: 10),
            Text(
              _selectedDate != null
                  ? _selectedDate.toString().split(' ')[0]
                  : "DOB",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (v) =>
          v!.isEmpty && label != "Medical Conditions" && label != "Notes"
          ? "$label is required"
          : null,
    );
  }
}
