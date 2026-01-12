// lib/core/models/user_session.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_session.freezed.dart';
part 'user_session.g.dart';

/// Represents the current user's session with multi-role support.
///
/// A user can have multiple roles (e.g., both parent and driver).
/// The `activeRole` tracks which role is currently being used in the app.
@freezed
abstract class UserSession with _$UserSession {
  const factory UserSession({
    required String userId,
    required String fullName,
    String? email,
    String? phone,
    String? photoUrl,
    required List<String> roles,
    required String activeRole,
    @Default('phone') String authProvider,
  }) = _UserSession;

  const UserSession._();

  /// Factory constructor for JSON deserialization
  factory UserSession.fromJson(Map<String, dynamic> json) =>
      _$UserSessionFromJson(json);

  /// Computed properties for convenience
  bool get isDriver => roles.contains('driver');
  bool get isParent => roles.contains('parent');
  bool get isDualRole => roles.length > 1;
  bool get isGoogleAuth => authProvider == 'google';
  bool get isPhoneAuth => authProvider == 'phone';
  bool get isAppleAuth => authProvider == 'apple';
  bool get hasRoles => roles.isNotEmpty;
}
