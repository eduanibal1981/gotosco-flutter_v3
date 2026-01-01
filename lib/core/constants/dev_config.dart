// lib/core/constants/dev_config.dart
// ⚠️ DEV ONLY - Set to false before production!

class DevConfig {
  /// When true, bypasses all authentication checks
  static const bool bypassAuth = true;

  /// Default role for dev mode: 'parent' or 'driver'
  static const String defaultRole = 'parent';

  /// Test password for DEV mode sign-in
  static const String testPassword = '123456';

  // Test user data
  static const Map<String, dynamic> testDriver = {
    'id': '185aa4fc-999b-479d-a189-d3a0f5e6965e',
    'email': 'driver109@gmail.com',
    'full_name': 'Test Driver',
    'role': 'driver',
  };

  static const Map<String, dynamic> testParent = {
    'id': 'c38b0635-fcb9-4474-9635-467132a9720c',
    'email': 'thehonest@gmail.com',
    'full_name': 'Test Parent',
    'role': 'parent',
  };
}
