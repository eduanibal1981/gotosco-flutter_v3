import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotosco_v3/features/auth/application/auth_controller.dart';
import 'package:gotosco_v3/features/auth/presentation/login_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Mock AuthController
class MockAuthController extends AuthController {
  @override
  FutureOr<AuthResult?> build() => null;
}

void main() {
  testWidgets('LoginScreen shows inline errors on empty submission', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(() => MockAuthController()),
        ],
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    // Find the Login button
    final loginButton = find.text('LOGIN');
    expect(loginButton, findsOneWidget);

    // Tap it without entering text
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    // Expect NO SnackBar
    expect(find.byType(SnackBar), findsNothing);

    // Expect Inline Errors
    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets('LoginScreen validates email format', (tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(() => MockAuthController()),
        ],
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    // Enter invalid email
    // We find the TextFormField by its label
    final emailField = find.widgetWithText(TextFormField, 'Email Address');
    await tester.enterText(emailField, 'not-an-email');

    // Tap login
    await tester.tap(find.text('LOGIN'));
    await tester.pumpAndSettle();

    // Expect Email Format Error
    expect(find.text('Please enter a valid email'), findsOneWidget);
  });
}
