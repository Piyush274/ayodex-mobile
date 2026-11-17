import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayodex/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:ayodex/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:ayodex/features/auth/presentation/screens/authorization_screen.dart';
import 'package:ayodex/features/auth/presentation/widgets/otp_pin_input.dart';

void main() {
  group('ForgotPasswordScreen Tests', () {
    testWidgets('Empty input displays validation error', (tester) async {
      await tester.pumpWidget(const ProviderScope(
        child: MaterialApp(
          home: ForgotPasswordScreen(),
        ),
      ));

      await tester.tap(find.text('Send Reset Code'));
      await tester.pumpAndSettle();

      expect(find.text('Email or username is required'), findsOneWidget);
    });
  });

  group('OtpPinInput Widget Tests', () {
    testWidgets('OtpPinInput renders 6 input boxes and captures 6 digits', (tester) async {
      String capturedCode = '';
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: OtpPinInput(
            length: 6,
            onCompleted: (code) => capturedCode = code,
          ),
        ),
      ));

      expect(find.byType(TextField), findsNWidgets(6));

      // Enter digits into boxes
      for (int i = 0; i < 6; i++) {
        await tester.enterText(find.byType(TextField).at(i), '$i');
        await tester.pump();
      }

      expect(capturedCode, '012345');
    });
  });

  group('ResetPasswordScreen Widget Tests', () {
    testWidgets('Validates empty and mismatch passwords', (tester) async {
      await tester.pumpWidget(const ProviderScope(
        child: MaterialApp(
          home: ResetPasswordScreen(
            email: 'test@ayodex.com',
            token: 'test_token',
          ),
        ),
      ));

      await tester.tap(find.text('Reset Password'));
      await tester.pumpAndSettle();

      expect(find.text('Password is required'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('reset_new_password')), 'Password123');
      await tester.enterText(find.byKey(const Key('reset_confirm_password')), 'Password456');

      await tester.tap(find.text('Reset Password'));
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });
  });

  group('AuthorizationScreen Widget Tests', () {
    testWidgets('Renders 2FA challenge correctly', (tester) async {
      await tester.pumpWidget(const ProviderScope(
        child: MaterialApp(
          home: AuthorizationScreen(
            type: AuthorizationType.twoFactor,
          ),
        ),
      ));

      expect(find.text('Two-Factor Authentication'), findsWidgets);
      expect(find.text('Verify & Continue'), findsOneWidget);
      expect(find.byType(OtpPinInput), findsOneWidget);
    });
  });
}
