import 'trip_category_model.dart';

/// Predefined trip categories
class TripCategories {
  static const List<TripCategoryModel> all = [
    TripCategoryModel(
      id: 'school',
      label: 'School Transport',
      icon: '🏫',
      description: 'Daily school pickup and dropoff',
    ),
    TripCategoryModel(
      id: 'Journey',
      label: 'Journey Trip',
      icon: '🚗',
      description: 'Special trips and excursions',
    ),
    TripCategoryModel(
      id: 'Other',
      label: 'Other',
      icon: '📍',
      description: 'Custom destinations',
    ),
  ];
}
