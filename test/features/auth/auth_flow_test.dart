import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayodex/features/auth/presentation/screens/login_screen.dart';
import 'package:ayodex/features/auth/presentation/screens/register_screen.dart';
import 'package:ayodex/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:ayodex/features/auth/presentation/screens/complete_profile_screen.dart';

void main() {
  group('OnboardingScreen Widget Tests', () {
    testWidgets('Renders onboarding elements and action buttons', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: OnboardingScreen(),
      ));

      expect(find.text('Fast & Transparent Multi-Currency Exchange'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('EN'), findsOneWidget);
    });
  });

  group('LoginScreen Widget Tests', () {
    testWidgets('Validates empty username and password fields', (tester) async {
      await tester.pumpWidget(const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ));

      // Tap Login button without entering data
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Username or email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('Tapping password visibility toggles obscureText', (tester) async {
      await tester.pumpWidget(const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ));

      final passwordFieldFinder = find.byKey(const Key('login_password_field'));
      expect(passwordFieldFinder, findsOneWidget);

      final iconButtonFinder = find.byKey(const Key('password_visibility_toggle'));
      expect(iconButtonFinder, findsOneWidget);

      // Initially obscured
      var editableText = tester.widget<EditableText>(find.descendant(
        of: passwordFieldFinder,
        matching: find.byType(EditableText),
      ));
      expect(editableText.obscureText, isTrue);

      await tester.tap(iconButtonFinder);
      await tester.pumpAndSettle();

      editableText = tester.widget<EditableText>(find.descendant(
        of: passwordFieldFinder,
        matching: find.byType(EditableText),
      ));
      expect(editableText.obscureText, isFalse);
    });
  });

  group('RegisterScreen Widget Tests', () {
    testWidgets('Validates password mismatch', (tester) async {
      await tester.pumpWidget(const ProviderScope(
        child: MaterialApp(
          home: RegisterScreen(),
        ),
      ));

      await tester.enterText(find.byKey(const Key('reg_firstname')), 'John');
      await tester.enterText(find.byKey(const Key('reg_lastname')), 'Doe');
      await tester.enterText(find.byKey(const Key('reg_email')), 'john@test.com');
      await tester.enterText(find.byKey(const Key('reg_password')), 'Password#1');
      await tester.enterText(find.byKey(const Key('reg_password_confirmation')), 'Password#2');

      await tester.ensureVisible(find.text('Create Account'));
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });
  });

  group('CompleteProfileScreen Widget Tests', () {
    testWidgets('Validates empty mobile and username fields', (tester) async {
      await tester.pumpWidget(const ProviderScope(
        child: MaterialApp(
          home: CompleteProfileScreen(),
        ),
      ));

      await tester.ensureVisible(find.text('Complete Profile'));
      await tester.tap(find.text('Complete Profile'));
      await tester.pumpAndSettle();

      expect(find.text('Mobile number is required'), findsOneWidget);
      expect(find.text('Username is required'), findsOneWidget);
    });
  });
}
