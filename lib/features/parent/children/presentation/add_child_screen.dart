import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'children_controller.dart';

class AddChildScreen extends ConsumerStatefulWidget {
  const AddChildScreen({super.key});

  @override
  ConsumerState<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends ConsumerState<AddChildScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _schoolController = TextEditingController();
  final _gradeController = TextEditingController();
  final _medicalController = TextEditingController();
  final _notesController = TextEditingController();

  // State
  String _selectedGender = 'male'; // Default
  DateTime? _selectedDate;

  @override
  void dispose() {
    _nameController.dispose();
    _schoolController.dispose();
    _gradeController.dispose();
    _medicalController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Date of Birth')),
      );
      return;
    }

    try {
      final success = await ref
          .read(childrenControllerProvider.notifier)
          .addChild(
            name: _nameController.text.trim(),
            school: _schoolController.text.trim(),
            grade: _gradeController.text.trim(),
            gender: _selectedGender,
            dob: _selectedDate!,
            medicalConditions: _medicalController.text.trim(),
            notes: _notesController.text.trim(),
          );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Child profile added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      } else {
        final error = ref.read(childrenControllerProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add child: ${error ?? "Unknown error"}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controllerState = ref.watch(childrenControllerProvider);
    final isLoading = controllerState.isLoading;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Add Child Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. PHOTO UPLOAD (Placeholder) ---
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade200,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.indigo,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- 2. BASIC INFO ---
              _buildSectionTitle("Basic Information"),
              _buildTextField(
                controller: _nameController,
                label: "Full Name",
                icon: Icons.person_outline,
                validator: (v) => v!.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),

              // Gender Selector
              const Text(
                "Gender",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildGenderCard('male', Icons.male, Colors.blue),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildGenderCard(
                      'female',
                      Icons.female,
                      Colors.pink,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Date of Birth Picker
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().subtract(
                      const Duration(days: 365 * 6),
                    ), // Default to 6 years old
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.grey),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate == null
                            ? "Date of Birth"
                            : DateFormat('MMMM d, yyyy').format(_selectedDate!),
                        style: TextStyle(
                          color: _selectedDate == null
                              ? Colors.grey.shade600
                              : Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // --- 3. SCHOOL INFO ---
              _buildSectionTitle("School Details"),
              _buildTextField(
                controller: _schoolController,
                label: "School Name",
                icon: Icons.school_outlined,
                validator: (v) => v!.isEmpty ? 'School is required' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _gradeController,
                label: "Grade / Class",
                icon: Icons.class_outlined,
                validator: (v) => v!.isEmpty ? 'Grade is required' : null,
              ),

              const SizedBox(height: 24),

              // --- 4. MEDICAL & NOTES ---
              _buildSectionTitle("Additional Information"),
              _buildTextField(
                controller: _medicalController,
                label: "Medical Conditions (Allergies, etc.)",
                icon: Icons.medical_services_outlined,
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _notesController,
                label: "Specific Notes for Driver",
                icon: Icons.note_alt_outlined,
                maxLines: 3,
              ),

              const SizedBox(height: 40),

              // --- 5. SUBMIT BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Save Child Profile",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- HELPERS ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.indigo,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.indigo, width: 2),
        ),
      ),
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
}
