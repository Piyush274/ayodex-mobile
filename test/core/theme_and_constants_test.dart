import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ayodex/core/constants/app_colors.dart';
import 'package:ayodex/core/constants/app_dimensions.dart';
import 'package:ayodex/core/constants/api_endpoints.dart';
import 'package:ayodex/core/theme/app_theme.dart';
import 'package:ayodex/core/widgets/app_button.dart';
import 'package:ayodex/core/widgets/status_badge.dart';

void main() {
  group('Theme & Constants Unit Tests', () {
    test('AppColors matches orange_oasis website palette', () {
      expect(AppColors.base.value, 0xFFFF6033);
      expect(AppColors.accent.value, 0xFF110226);
      expect(AppColors.heading.value, 0xFF353A69);
      expect(AppColors.body.value, 0xFF515E80);
      expect(AppColors.background.value, 0xFFF7F9FC);
      expect(AppColors.border.value, 0xFFEBEBEB);
      expect(AppColors.success.value, 0xFF28C76F);
      expect(AppColors.danger.value, 0xFFEA5455);
    });

    test('ApiEndpoints base URL and paths are accurately defined', () {
      expect(ApiEndpoints.baseUrl, 'https://ayodex.com/api');
      expect(ApiEndpoints.login, '/login');
      expect(ApiEndpoints.register, '/register');
      expect(ApiEndpoints.transferConfirm, '/transfer/confirm');
      expect(ApiEndpoints.withdrawSave, '/withdraw/save');
    });

    test('AppTheme generates light theme with brand primary color', () {
      final theme = AppTheme.lightTheme;
      expect(theme.primaryColor, AppColors.base);
      expect(theme.scaffoldBackgroundColor, AppColors.background);
    });
  });

  group('Core Widgets Tests', () {
    testWidgets('AppButton renders text and triggers callback', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AppButton(
            text: 'Test Button',
            onPressed: () => tapped = true,
          ),
        ),
      ));

      expect(find.text('Test Button'), findsOneWidget);
      await tester.tap(find.byType(AppButton));
      expect(tapped, isTrue);
    });

    testWidgets('StatusBadge displays label and correct background', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: StatusBadge(
            label: 'Approved',
            color: AppColors.success,
          ),
        ),
      ));

      expect(find.text('Approved'), findsOneWidget);
    });
  });
}
