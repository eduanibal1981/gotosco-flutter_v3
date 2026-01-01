import 'package:gotosco_v3/core/constants/enums.dart';

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String phone;
  final UserRole role;
  final String? photoUrl;

  // C# Constructor equivalent
  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.role,
    this.photoUrl,
  });

  // Factory Constructor: Simulates "UserModel.FromJson()" in C#
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      fullName: map['full_name'] ?? '',
      phone: map['phone'] ?? '',
      // Convert string 'driver' -> UserRole.driver
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.parent,
      ),
      photoUrl: map['photo_url'],
    );
  }

  // ToMap: Simulates "ToJson()"
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'role': role.name,
      'photo_url': photoUrl,
    };
  }
}
