import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayodex/core/models/dynamic_form_model.dart';
import 'package:ayodex/core/widgets/dynamic_form_builder.dart';
import 'package:ayodex/features/kyc/presentation/screens/kyc_status_screen.dart';

void main() {
  group('DynamicFormBuilder Tests', () {
    testWidgets('Renders text field and file picker based on dynamic schema', (tester) async {
      final schema = DynamicFormModel.fromJson({
        'nin_number': {
          'name': 'National Identity Number',
          'label': 'nin_number',
          'type': 'text',
          'is_required': 'required',
          'instruction': 'Enter 11 digits',
          'extensions': '',
          'options': [],
          'width': '12'
        },
        'id_card_front': {
          'name': 'ID Card Front',
          'label': 'id_card_front',
          'type': 'file',
          'is_required': 'required',
          'instruction': 'Upload front image',
          'extensions': 'jpg,png',
          'options': [],
          'width': '12'
        }
      });

      final formKey = GlobalKey<FormState>();
      final Map<String, dynamic> formData = {};

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: DynamicFormBuilder(
              formKey: formKey,
              schema: schema,
              onChanged: (data) => formData.addAll(data),
            ),
          ),
        ),
      ));

      expect(find.text('National Identity Number'), findsOneWidget);
      expect(find.text('ID Card Front'), findsOneWidget);
      expect(find.text('Upload front image'), findsOneWidget);
    });
  });

  group('KycStatusScreen Tests', () {
    testWidgets('Renders KYC Status Screen correctly', (tester) async {
      await tester.pumpWidget(const ProviderScope(
        child: MaterialApp(
          home: KycStatusScreen(),
        ),
      ));

      expect(find.text('KYC Status'), findsOneWidget);
      expect(find.text('Identity Verification Required'), findsOneWidget);
      expect(find.text('Submit Verification Documents'), findsOneWidget);
    });
  });
}
