// lib/features/parent/profile/presentation/edit_profile_screen.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gotosco_v3/core/models/user_model.dart';
import 'package:gotosco_v3/features/auth/presentation/user_provider.dart';
import 'package:gotosco_v3/features/auth/data/auth_repository.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:gotosco_v3/core/widgets/map_picker_screen.dart';

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
  File? _imageFile;
  bool _isSaving = false;

  // Location State
  String? _locationText;
  LatLng? _selectedLocation;
  bool _isGeocoding = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.fullName);
    _phoneController = TextEditingController(text: widget.user.phone);
    _locationController = TextEditingController(text: widget.user.locationText);

    // Initialize Location
    _locationText = widget.user.locationText;
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
        _imageFile = File(pickedFile.path);
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
        // On Web, this might fail immediately if misconfigured
        List<Placemark> placemarks = await placemarkFromCoordinates(
          result.latitude,
          result.longitude,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;

          // Construct a more robust address string, explicitly EXCLUDING country
          final addressParts =
              {
                    place.name,
                    place.street,
                    place.subLocality,
                    place.locality,
                    place.administrativeArea,
                    // place.country, // Excluded as requested
                  }
                  .where(
                    (element) =>
                        element != null && element.toString().trim().isNotEmpty,
                  )
                  .toSet()
                  .toList();

          final formattedAddress = addressParts.join(', ');

          setState(() {
            if (formattedAddress.isNotEmpty) {
              _locationText = formattedAddress;
            } else {
              _locationText =
                  "${result.latitude.toStringAsFixed(6)}, ${result.longitude.toStringAsFixed(6)}";
            }
            _locationController.text = _locationText!;
          });
        } else {
          // Native Geocoder returned empty -> Try OSM
          await _fetchAddressFromOSM(result);
        }
      } catch (e) {
        // Native Geocoder Failed (e.g. Web error) -> Try OSM
        await _fetchAddressFromOSM(result);
      } finally {
        if (mounted) setState(() => _isGeocoding = false);
      }
    }
  }

  Future<void> _fetchAddressFromOSM(LatLng result) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${result.latitude}&lon=${result.longitude}&zoom=18&addressdetails=1',
      );

      // Nominatim requires a User-Agent
      final response = await http.get(
        url,
        headers: {'User-Agent': 'GotoscoApp/1.0'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Instead of taking full display_name, we parse address object to exclude country
        final address = data['address'] as Map<String, dynamic>?;

        if (address != null) {
          final parts =
              [
                    address['amenity'] ?? address['building'],
                    address['road'] ?? address['pedestrian'],
                    address['neighbourhood'] ?? address['suburb'],
                    address['city'] ?? address['town'] ?? address['village'],
                    address['state'] ?? address['region'],
                  ]
                  .where((e) => e != null && e.toString().isNotEmpty)
                  .toSet() // Deduplicate
                  .toList();

          final formattedAddress = parts.join(', ');

          if (formattedAddress.isNotEmpty) {
            if (mounted) {
              setState(() {
                _locationText = formattedAddress;
                _locationController.text = _locationText!;
              });
            }
            return; // Success
          }
        }

        // Fallback to display_name if detailed parsing failed, but try to strip country
        final displayName = data['display_name'] as String?;
        if (displayName != null && displayName.isNotEmpty) {
          // Heuristic: remove last part if it looks like a country?
          // Better to just use it as is if structured parsing failed.
          // Or just leave it.
          if (mounted) {
            setState(() {
              _locationText = displayName;
              _locationController.text = _locationText!;
            });
          }
          return;
        }
      }
    } catch (_) {
      // Ignore
    }

    // Final fallback to coordinates
    if (mounted) {
      setState(() {
        // If we already set something don't overwrite with coords unless explicit failure
        if (_locationController.text.isEmpty) {
          _locationText =
              "${result.latitude.toStringAsFixed(6)}, ${result.longitude.toStringAsFixed(6)}";
          _locationController.text = _locationText!;
        }
      });
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

    setState(() => _isSaving = true);

    try {
      String? photoUrl;
      if (_imageFile != null) {
        photoUrl = await ref
            .read(authRepositoryProvider)
            .uploadProfileImage(widget.user.id, _imageFile!);
      }

      await ref
          .read(authRepositoryProvider)
          .updateProfile(
            userId: widget.user.id,
            fullName: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            photoUrl: photoUrl,
            locationText: _locationController.text.trim(),
            locationLat: _selectedLocation?.latitude,
            locationLng: _selectedLocation?.longitude,
          );

      // Refresh user profile
      ref.invalidate(currentUserProfileProvider);

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
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        ? FileImage(_imageFile!)
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
                onPressed: _isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
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
