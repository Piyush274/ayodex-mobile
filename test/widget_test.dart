import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ayodex/main.dart';
import 'package:ayodex/core/widgets/app_button.dart';

void main() {
  testWidgets('AyodexApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AyodexApp());

    expect(find.text('AYODEX'), findsOneWidget);
    expect(find.text('AYODEX Theme & Design System'), findsOneWidget);
    expect(find.byType(AppButton), findsWidgets);
  });
}
