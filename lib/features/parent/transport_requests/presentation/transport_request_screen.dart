import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gotosco_v3/features/parent/children/data/child_model.dart';
import 'package:gotosco_v3/features/parent/children/data/children_repository.dart';
import 'package:gotosco_v3/features/parent/bookings/presentation/widgets/location_input_field.dart';
import 'transport_request_controller.dart';
import '../data/transport_requests_repository.dart';

class TransportRequestScreen extends ConsumerStatefulWidget {
  const TransportRequestScreen({super.key});

  @override
  ConsumerState<TransportRequestScreen> createState() =>
      _TransportRequestScreenState();
}

class _TransportRequestScreenState
    extends ConsumerState<TransportRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  final _childNameController = TextEditingController();
  final _childAgeController = TextEditingController();
  final _schoolNameController = TextEditingController();
  final _homeLocationController = TextEditingController();
  final _schoolLocationController = TextEditingController();
  final _notesController = TextEditingController();

  ChildModel? _selectedChild;
  double? _homeLat;
  double? _homeLng;
  double? _schoolLat;
  double? _schoolLng;
  String _bookingType = 'Two Way';

  @override
  void dispose() {
    _childNameController.dispose();
    _childAgeController.dispose();
    _schoolNameController.dispose();
    _homeLocationController.dispose();
    _schoolLocationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  int? _calculateAge(DateTime? dob) {
    if (dob == null) return null;
    final today = DateTime.now();
    var age = today.year - dob.year;
    final hasHadBirthday =
        (today.month > dob.month) ||
        (today.month == dob.month && today.day >= dob.day);
    if (!hasHadBirthday) age -= 1;
    return age < 0 ? 0 : age;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final selected = _selectedChild;
    final childName = selected?.name ?? _childNameController.text.trim();
    final derivedAge = _calculateAge(selected?.dob);
    final childAge = derivedAge ?? int.tryParse(_childAgeController.text.trim());

    if (childAge == null || childAge <= 0) {
      _showMessage('Please enter a valid child age');
      return;
    }

    final homeLocation = _homeLocationController.text.trim();
    final schoolLocation = _schoolLocationController.text.trim();
    final schoolName = _schoolNameController.text.trim().isNotEmpty
        ? _schoolNameController.text.trim()
        : (selected?.schoolName ?? '');

    if (_homeLat == null || _homeLng == null) {
      _showMessage('Please pin the home location on the map');
      return;
    }
    if (_schoolLat == null || _schoolLng == null) {
      _showMessage('Please pin the school location on the map');
      return;
    }
    if (schoolName.isEmpty) {
      _showMessage('Please enter the school name');
      return;
    }

    try {
      final success = await ref
          .read(transportRequestControllerProvider.notifier)
          .submitRequest(
            childName: childName,
            childAge: childAge,
            schoolName: schoolName,
            bookingType: _bookingType,
            homeLocation: homeLocation,
            homeLat: _homeLat!,
            homeLng: _homeLng!,
            schoolLocation: schoolLocation,
            schoolLat: _schoolLat!,
            schoolLng: _schoolLng!,
            childId: selected?.id,
            childGender: selected?.gender,
            childGrade: selected?.grade,
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          );

      if (success && mounted) {
        ref.invalidate(parentTransportRequestsProvider);
        _showMessage('Request posted successfully');
        context.pop();
      }
    } catch (e) {
      _showMessage(e.toString());
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final childrenAsync = ref.watch(myChildrenProvider);
    final submitState = ref.watch(transportRequestControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transport Request'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Post your child\'s transport request and let drivers contact you.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            childrenAsync.when(
              data: (children) => _buildChildSection(children),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text('Error loading children: $err'),
            ),
            const SizedBox(height: 16),
            _buildBookingTypeField(),
            const SizedBox(height: 16),
            LocationInputField(
              label: 'Home Location',
              controller: _homeLocationController,
              onLocationSelected: (lat, lng) {
                _homeLat = lat;
                _homeLng = lng;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _schoolNameController,
              decoration: const InputDecoration(
                labelText: 'School Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final v = value?.trim() ?? '';
                final fromChild = _selectedChild?.schoolName ?? '';
                if (v.isEmpty && fromChild.isEmpty) {
                  return 'Please enter the school name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            LocationInputField(
              label: 'School Location',
              controller: _schoolLocationController,
              onLocationSelected: (lat, lng) {
                _schoolLat = lat;
                _schoolLng = lng;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                helperText: 'Tip: You can include the price you seek here.',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: submitState.isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
                child: submitState.isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Post Request'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildSection(List<ChildModel> children) {
    final selected = _selectedChild;
    final derivedAge = _calculateAge(selected?.dob);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Child Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (children.isEmpty)
              TextButton(
                onPressed: () => context.push('/add-student'),
                child: const Text('Add Child'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (children.isNotEmpty)
          DropdownButtonFormField<ChildModel>(
            value: selected,
            decoration: const InputDecoration(
              labelText: 'Select Child (optional)',
              border: OutlineInputBorder(),
            ),
            items: children
                .map(
                  (c) => DropdownMenuItem(
                    value: c,
                    child: Text(c.name),
                  ),
                )
                .toList(),
            onChanged: (child) {
              setState(() {
                _selectedChild = child;
                if (child != null) {
                  _childNameController.text = child.name;
                  final age = _calculateAge(child.dob);
                  if (age != null) {
                    _childAgeController.text = age.toString();
                  }
                  if (_schoolNameController.text.trim().isEmpty &&
                      child.schoolName.isNotEmpty) {
                    _schoolNameController.text = child.schoolName;
                  }
                } else {
                  _childNameController.clear();
                  _childAgeController.clear();
                }
              });
            },
          ),
        const SizedBox(height: 12),
        if (selected == null) ...[
          TextFormField(
            controller: _childNameController,
            decoration: const InputDecoration(
              labelText: 'Child Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if ((_selectedChild == null) && (value?.trim().isEmpty ?? true)) {
                return 'Please enter the child name';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _childAgeController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Child Age',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (_selectedChild != null) return null;
              final age = int.tryParse(value ?? '');
              if (age == null || age <= 0) {
                return 'Please enter a valid age';
              }
              return null;
            },
          ),
        ] else if (derivedAge != null) ...[
          TextFormField(
            controller: _childAgeController,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Child Age',
              border: OutlineInputBorder(),
            ),
          ),
        ] else ...[
          TextFormField(
            controller: _childAgeController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Child Age',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              final age = int.tryParse(value ?? '');
              if (age == null || age <= 0) {
                return 'Please enter a valid age';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  Widget _buildBookingTypeField() {
    const bookingTypes = [
      'Two Way',
      'One Way to School',
      'One Way Back Home',
      'Other',
    ];

    return DropdownButtonFormField<String>(
      value: _bookingType,
      decoration: const InputDecoration(
        labelText: 'Trip Type',
        border: OutlineInputBorder(),
      ),
      items: bookingTypes
          .map((t) => DropdownMenuItem(value: t, child: Text(t)))
          .toList(),
      onChanged: (value) {
        if (value == null) return;
        setState(() => _bookingType = value);
      },
    );
  }
}

