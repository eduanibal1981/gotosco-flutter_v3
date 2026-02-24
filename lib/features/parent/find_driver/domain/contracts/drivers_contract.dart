import '../models/driver_ad_model.dart';

abstract class DriversContract {
  Future<List<DriverAdModel>> searchDrivers(
    Map<String, dynamic> filters, {
    int limit = 20,
    int offset = 0,
    double? parentLat,
    double? parentLng,
  });

  Future<List<DriverAdModel>> getNearbyDrivers({int limit = 5});

  Future<List<String>> getSavedDriverIds();

  Future<List<DriverAdModel>> getFavoriteDrivers();

  Future<void> toggleFavorite(String driverId);

  Future<({double min, double max})> getPriceLimits();
}
