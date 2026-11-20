import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ayodex/core/widgets/empty_state_view.dart';
import 'package:ayodex/core/widgets/error_state_view.dart';

void main() {
  group('Empty & Error States Widget Tests', () {
    testWidgets('EmptyStateView renders title, message, and button', (tester) async {
      bool actionTapped = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: EmptyStateView(
            title: 'No Exchanges Found',
            message: 'You have not made any currency exchanges yet.',
            buttonText: 'Start Exchange',
            onAction: () => actionTapped = true,
          ),
        ),
      ));

      expect(find.text('No Exchanges Found'), findsOneWidget);
      expect(find.text('Start Exchange'), findsOneWidget);

      await tester.tap(find.text('Start Exchange'));
      expect(actionTapped, isTrue);
    });

    testWidgets('ErrorStateView renders error and retry button', (tester) async {
      bool retryTapped = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ErrorStateView(
            errorMessage: 'Unable to connect to server.',
            onRetry: () => retryTapped = true,
          ),
        ),
      ));

      expect(find.text('Unable to connect to server.'), findsOneWidget);
      await tester.tap(find.text('Try Again'));
      expect(retryTapped, isTrue);
    });
  });
}
