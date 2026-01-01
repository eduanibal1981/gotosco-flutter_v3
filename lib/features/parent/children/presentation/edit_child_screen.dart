import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:gotosco_v3/features/parent/children/data/child_model.dart';
import 'package:gotosco_v3/features/parent/children/data/children_repository.dart';

class EditChildScreen extends ConsumerStatefulWidget {
  final ChildModel child; // Receive the child data to edit

  const EditChildScreen({super.key, required this.child});

  @override
  ConsumerState<EditChildScreen> createState() => _EditChildScreenState();
}

class _EditChildScreenState extends ConsumerState<EditChildScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _schoolController;
  late TextEditingController _gradeController;
  late TextEditingController _medicalController;
  late TextEditingController _notesController;

  late String _selectedGender;
  DateTime? _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill data
    _nameController = TextEditingController(text: widget.child.name);
    _schoolController = TextEditingController(text: widget.child.schoolName);
    _gradeController = TextEditingController(text: widget.child.grade);
    // Note: You might need to add medical/notes to your ChildModel if you want to edit them
    _medicalController = TextEditingController();
    _notesController = TextEditingController();
    _selectedGender = widget.child.gender ?? 'male';
    // _selectedDate = widget.child.dob; // If you have dob in ChildModel
    _selectedDate = DateTime.now().subtract(
      const Duration(days: 365 * 6),
    ); // Placeholder
  }

  @override
  void dispose() {
    _nameController.dispose();
    _schoolController.dispose();
    _gradeController.dispose();
    _medicalController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _update() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await ref
          .read(childrenRepositoryProvider)
          .updateChild(
            childId: widget.child.id,
            name: _nameController.text.trim(),
            school: _schoolController.text.trim(),
            grade: _gradeController.text.trim(),
            gender: _selectedGender,
            dob: _selectedDate!,
            medicalConditions: _medicalController.text.trim(),
            notes: _notesController.text.trim(),
          );

      if (!mounted) return;
      ref.invalidate(myChildrenProvider); // Refresh the list
      context.pop(); // Go back
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
            children: [
              _buildTextField(
                controller: _nameController,
                label: "Full Name",
                icon: Icons.person,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _schoolController,
                label: "School",
                icon: Icons.school,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _gradeController,
                label: "Grade",
                icon: Icons.class_,
              ),
              const SizedBox(height: 24),

              // ... (Include Gender and Date pickers similar to Add Screen) ...
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
      validator: (v) => v!.isEmpty ? "$label is required" : null,
    );
  }
}
