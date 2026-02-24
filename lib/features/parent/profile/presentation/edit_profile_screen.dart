import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gotosco_v3/core/models/user_model.dart';
import 'package:latlong2/latlong.dart';
import 'package:gotosco_v3/core/widgets/map_picker_screen.dart';
import '../application/parent_profile_controller.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key, required this.user});

  final UserModel user;

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;
  XFile? _imageFile;

  // Location State
  LatLng? _selectedLocation;
  bool _isGeocoding = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.fullName);
    _phoneController = TextEditingController(text: widget.user.phone);
    _locationController = TextEditingController(text: widget.user.locationText);

    // Initialize Location
    if (widget.user.locationLat != null && widget.user.locationLng != null) {
      _selectedLocation = LatLng(
        widget.user.locationLat!,
        widget.user.locationLng!,
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(builder: (context) => const MapPickerScreen()),
    );

    if (result != null) {
      setState(() {
        _selectedLocation = result;
        _isGeocoding = true;
      });

      try {
        final resolvedAddress = await ref
            .read(parentProfileControllerProvider.notifier)
            .reverseGeocode(
              latitude: result.latitude,
              longitude: result.longitude,
            );

        if (mounted) {
          setState(() {
            _locationController.text = resolvedAddress;
          });
        }
      } catch (_) {
        if (mounted) {
          final coordinates =
              "${result.latitude.toStringAsFixed(6)}, ${result.longitude.toStringAsFixed(6)}";
          setState(() {
            _locationController.text = coordinates;
          });
        }
      } finally {
        if (mounted) {
          setState(() {
            _isGeocoding = false;
          });
        }
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Name cannot be empty')));
      return;
    }

    // Phone validation
    if (_phoneController.text.isNotEmpty && _phoneController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid phone number')),
      );
      return;
    }

    try {
      await ref
          .read(parentProfileControllerProvider.notifier)
          .saveProfile(
            user: widget.user,
            fullName: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            imageFile: _imageFile,
            locationText: _locationController.text.trim(),
            locationLat: _selectedLocation?.latitude,
            locationLng: _selectedLocation?.longitude,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Error updating profile: $e';
        if (e.toString().contains('23505') ||
            e.toString().contains('users_phone_key')) {
          errorMessage =
              'This phone number is already associated with another account.';
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controllerState = ref.watch(parentProfileControllerProvider);
    final isSaving = controllerState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Photo Picker
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.indigo.shade50,
                    backgroundImage: _imageFile != null
                        ? (kIsWeb
                              ? NetworkImage(_imageFile!.path)
                              : FileImage(File(_imageFile!.path))
                                    as ImageProvider)
                        : (widget.user.photoUrl != null
                                  ? NetworkImage(widget.user.photoUrl!)
                                  : null)
                              as ImageProvider?,
                    child: _imageFile == null && widget.user.photoUrl == null
                        ? Text(
                            widget.user.fullName.isNotEmpty
                                ? widget.user.fullName[0].toUpperCase()
                                : 'U',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo.shade300,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.indigo,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Name Field
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Phone Field
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: const Icon(Icons.phone_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Read-only Email
            TextField(
              controller: TextEditingController(text: widget.user.email),
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email_outlined),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Location Field
            TextField(
              controller: _locationController,
              readOnly:
                  true, // Keep it read-only so they must use the map picker
              onTap: _pickLocation,
              maxLines: null, // Allow multiline for long addresses
              decoration: InputDecoration(
                labelText: 'Home Address',
                hintText: _isGeocoding
                    ? 'Fetching address...'
                    : 'Tap to set location',
                prefixIcon: const Icon(Icons.location_on_outlined),
                suffixIcon: const Icon(Icons.map),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                helperText: _locationController.text.isNotEmpty
                    ? 'This location will be used as default for new bookings'
                    : null,
              ),
            ),

            const SizedBox(height: 40),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
