// lib/features/driver/bookings/data/booking_model.dart
class BookingModel {
  final String id;
  final String createdAt;
  final String status; // 'pending', 'accepted', 'rejected'
  final String driverId;
  final String parentId;
  final double price;
  final String homeLocation;
  final String schoolLocation;

  // Relations
  final String? parentName;
  final String? parentPhoto;
  final String? parentPhone;
  final List<BookingChildModel> children;

  BookingModel({
    required this.id,
    required this.createdAt,
    required this.status,
    required this.driverId,
    required this.parentId,
    required this.price,
    required this.homeLocation,
    required this.schoolLocation,
    this.parentName,
    this.parentPhoto,
    this.parentPhone,
    this.children = const [],
  });

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      id: map['id'] ?? '',
      createdAt: map['created_at'] ?? '',
      status: map['status'] ?? 'pending',
      driverId: map['driver_id'] ?? '',
      parentId: map['parent_id'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      homeLocation: map['hometxt_location'] ?? '',
      schoolLocation: map['schooltxt_location'] ?? '',
      parentName: map['parent_name'],
      parentPhoto: map['parent_photo'],
      parentPhone: map['parent_phone'],
      children:
          (map['children'] as List<dynamic>?)
              ?.map((c) => BookingChildModel.fromMap(c))
              .toList() ??
          [],
    );
  }

  bool get isExpired {
    if (status != 'pending') return false;
    final created = DateTime.tryParse(createdAt);
    if (created == null) return false;
    // Example: Expired if older than 7 days
    return DateTime.now().difference(created).inDays > 7;
  }
}

class BookingChildModel {
  final String id;
  final String name;
  final String schoolName;
  final String grade;

  BookingChildModel({
    required this.id,
    required this.name,
    required this.schoolName,
    required this.grade,
  });

  factory BookingChildModel.fromMap(Map<String, dynamic> map) {
    return BookingChildModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      schoolName: map['school_name'] ?? '',
      grade: map['grade'] ?? '',
    );
  }
}
