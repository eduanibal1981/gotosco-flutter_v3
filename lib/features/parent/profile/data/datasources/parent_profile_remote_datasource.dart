import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

class ParentProfileRemoteDatasource {
  Future<String> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final formatted = _buildAddress([
          place.name,
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
        ]);
        if (formatted.isNotEmpty) return formatted;
      }
    } catch (_) {}

    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?format=json'
        '&lat=$latitude'
        '&lon=$longitude'
        '&zoom=18'
        '&addressdetails=1',
      );

      final response = await http.get(
        url,
        headers: const {'User-Agent': 'GotoscoApp/1.0'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>?;

        if (address != null) {
          final formatted = _buildAddress([
            address['amenity'] ?? address['building'],
            address['road'] ?? address['pedestrian'],
            address['neighbourhood'] ?? address['suburb'],
            address['city'] ?? address['town'] ?? address['village'],
            address['state'] ?? address['region'],
          ]);
          if (formatted.isNotEmpty) return formatted;
        }

        final displayName = data['display_name'] as String?;
        if (displayName != null && displayName.trim().isNotEmpty) {
          return displayName;
        }
      }
    } catch (_) {}

    return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  }

  String _buildAddress(List<dynamic> parts) {
    return parts
        .where((part) => part != null && part.toString().trim().isNotEmpty)
        .map((part) => part.toString().trim())
        .toSet()
        .join(', ');
  }
}
