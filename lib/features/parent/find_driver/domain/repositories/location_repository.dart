abstract class LocationRepository {
  Future<List<Map<String, dynamic>>> getCities();
  Future<List<Map<String, dynamic>>> getAreas({String? cityId});
  Future<List<Map<String, dynamic>>> getSchools({
    String? areaId,
    String? cityId,
  });
}
