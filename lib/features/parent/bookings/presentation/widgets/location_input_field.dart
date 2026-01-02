import 'dart:convert'; // For JSON decoding
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http; // Import HTTP
import '../../../../../core/widgets/map_picker_screen.dart';

class LocationInputField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final Function(double lat, double lng) onLocationSelected;

  const LocationInputField({
    super.key,
    required this.label,
    required this.controller,
    required this.onLocationSelected,
  });

  @override
  State<LocationInputField> createState() => _LocationInputFieldState();
}

class _LocationInputFieldState extends State<LocationInputField> {
  bool _isLoading = false;
  bool _hasCoordinates = false;

  // --- NEW HELPER: Fetch Address from OSM (Works on Emulators too) ---
  Future<void> _updateLocation(double lat, double lng) async {
    setState(() => _isLoading = true);
    
    try {
      // 1. Save Coordinates Immediately (This makes functionality #3 work)
      widget.onLocationSelected(lat, lng);
      setState(() => _hasCoordinates = true);

      // 2. Fetch Meaningful Name from OpenStreetMap API
      // We use 'http' because native geocoding often fails on Simulators
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1',
      );

      final response = await http.get(
        url,
        headers: {
          // OSM requires a User-Agent identifying your app
          'User-Agent': 'com.example.gotosco_v3', 
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // 3. Construct Clean Address
        final addressObj = data['address'];
        String displayName = "";

        if (addressObj != null) {
          // Build a readable string like: "Muscat Grand Mall, Al Khuwayr"
          List<String?> parts = [
            addressObj['building'],
            addressObj['road'],
            addressObj['suburb'] ?? addressObj['neighbourhood'],
            addressObj['city'] ?? addressObj['town'],
          ];

          displayName = parts
              .where((e) => e != null && e.isNotEmpty)
              .toSet()
              .join(', ');
        }

        // Fallback to the raw display name if our construction failed
        if (displayName.isEmpty) {
          displayName = data['display_name']?.split(',').take(3).join(',') ?? "";
        }

        // 4. Update UI
        if (displayName.isNotEmpty) {
          widget.controller.text = displayName;
        } else {
          widget.controller.text = "${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}";
        }
      } else {
        // Fallback if API fails
        widget.controller.text = "${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}";
      }

    } catch (e) {
      debugPrint("Geocoding Error: $e");
      // Fallback on error
      if (widget.controller.text.isEmpty) {
        widget.controller.text = "${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}";
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- ACTION 1: GPS ---
  Future<void> _useCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isLoading = false);
          return;
        }
      }
      
      final pos = await Geolocator.getCurrentPosition();
      await _updateLocation(pos.latitude, pos.longitude);
      
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // --- ACTION 2: MAP PICKER ---
  Future<void> _openMapPicker() async {
    final LatLng? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapPickerScreen()),
    );

    if (result != null) {
      await _updateLocation(result.latitude, result.longitude);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.label, style: const TextStyle(fontWeight: FontWeight.bold)),
            if (_hasCoordinates)
              const Row(
                children: [
                  Icon(Icons.check_circle, size: 14, color: Colors.green),
                  SizedBox(width: 4),
                  Text("Location Pin Set", style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                ],
              )
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          decoration: InputDecoration(
            hintText: "Search map or type address...",
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: _isLoading 
              ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2))
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.my_location, color: Colors.blueAccent),
                      onPressed: _useCurrentLocation,
                      tooltip: "Use Current Location",
                    ),
                    IconButton(
                      icon: const Icon(Icons.map_outlined, color: Colors.indigo),
                      onPressed: _openMapPicker,
                      tooltip: "Pick on Map",
                    ),
                  ],
                ),
          ),
          onChanged: (val) {
            // Keep coordinates if user edits text
          },
        ),
      ],
    );
  }
}