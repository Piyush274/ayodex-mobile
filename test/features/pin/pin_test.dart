import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayodex/features/pin/presentation/widgets/pin_code_keypad.dart';
import 'package:ayodex/features/pin/presentation/screens/set_pin_screen.dart';
import 'package:ayodex/features/pin/presentation/screens/change_pin_screen.dart';

void main() {
  group('PinCodeKeypad Widget Tests', () {
    testWidgets(
        'Keypad registers digits and triggers callback upon reaching length',
        (tester) async {
      String enteredPin = '';
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PinCodeKeypad(
            pinLength: 4,
            onPinComplete: (pin) => enteredPin = pin,
          ),
        ),
      ));

      // Tap digits 1, 2, 3, 4
      await tester.tap(find.text('1'));
      await tester.pump();
      await tester.tap(find.text('2'));
      await tester.pump();
      await tester.tap(find.text('3'));
      await tester.pump();
      await tester.tap(find.text('4'));
      await tester.pump();

      expect(enteredPin, '1234');
    });

    testWidgets('Backspace key removes last digit', (tester) async {
      int pinLengthCaptured = 0;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PinCodeKeypad(
            pinLength: 4,
            onChanged: (pin) => pinLengthCaptured = pin.length,
          ),
        ),
      ));

      await tester.tap(find.text('9'));
      await tester.pump();
      await tester.tap(find.text('8'));
      await tester.pump();
      expect(pinLengthCaptured, 2);

      // Tap backspace
      await tester.tap(find.byIcon(Icons.backspace_outlined));
      await tester.pump();
      expect(pinLengthCaptured, 1);
    });
  });

  group('SetPinScreen Widget Tests', () {
    testWidgets('Validates password and matching PIN fields', (tester) async {
      await tester.pumpWidget(const ProviderScope(
        child: MaterialApp(
          home: SetPinScreen(),
        ),
      ));

      await tester.ensureVisible(find.text('Save Transaction PIN'));
      await tester.tap(find.text('Save Transaction PIN'));
      await tester.pumpAndSettle();

      expect(find.text('Account password is required'), findsOneWidget);
      expect(find.text('PIN is required'), findsOneWidget);
    });
  });

  group('ChangePinScreen Widget Tests', () {
    testWidgets('Validates required fields on ChangePinScreen', (tester) async {
      await tester.pumpWidget(const ProviderScope(
        child: MaterialApp(
          home: ChangePinScreen(),
        ),
      ));

      await tester.ensureVisible(find.text('Update PIN'));
      await tester.tap(find.text('Update PIN'));
      await tester.pumpAndSettle();

      expect(find.text('Account password is required'), findsOneWidget);
      expect(find.text('Current PIN is required'), findsOneWidget);
      expect(find.text('New PIN is required'), findsOneWidget);
    });
  });
}
