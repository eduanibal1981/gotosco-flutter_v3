/// Helper to parse PostGIS Geometry WKT string (e.g., "SRID=4326;POINT(12.34 56.78)")
/// Returns a map with 'lat' and 'lng' keys as doubles, or null if parsing fails.
Map<String, double>? parseGeoLocation(String? geoString) {
  if (geoString == null || geoString.isEmpty) return null;

  try {
    // Regex matches "POINT(lng lat)" ignoring SRID prefix if present
    // Matches: POINT(12.34 56.78) or POINT(12.34 56.78)
    // Supports integers and decimals
    final regExp = RegExp(r'POINT\s*\(\s*([-\d.]+)\s+([-\d.]+)\s*\)');
    final match = regExp.firstMatch(geoString);

    if (match != null) {
      final lng = double.tryParse(match.group(1)!);
      final lat = double.tryParse(match.group(2)!);

      if (lat != null && lng != null) {
        return {'lat': lat, 'lng': lng};
      }
    }
  } catch (e) {
    // ignore parsing errors
  }
  return null;
}
