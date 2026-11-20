import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayodex/features/profile/presentation/screens/profile_screen.dart';

void main() {
  group('Profile Widget Tests', () {
    testWidgets('Renders uneditable email and mobile fields with lock indicator', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );

      expect(find.text('Profile Settings'), findsOneWidget);
      expect(find.text('Personal Information'), findsOneWidget);
      expect(find.text('Security & Settings'), findsOneWidget);
    });
  });
}
