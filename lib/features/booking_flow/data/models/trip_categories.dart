import 'trip_category_model.dart';

/// Predefined trip categories
class TripCategories {
  static const List<TripCategoryModel> all = [
    TripCategoryModel(
      id: 'school',
      label: 'School / College Transport',
      icon: '🏫',
      description: 'Daily school or college pickup and dropoff',
    ),
    TripCategoryModel(
      id: 'Journey',
      label: 'Journey / Other Trips',
      icon: '🚗',
      description: 'Special trips, excursions, and custom destinations',
    ),
  ];
}
