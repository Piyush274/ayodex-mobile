import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:decimal/decimal.dart';
import 'package:ayodex/features/transfers/data/models/bank_model.dart';
import 'package:ayodex/features/transfers/data/models/transfer_model.dart';
import 'package:ayodex/features/transfers/data/models/transfer_quote_model.dart';
import 'package:ayodex/features/transfers/presentation/widgets/transfer_status_timeline.dart';

void main() {
  group('Transfer Quote Expiry Logic', () {
    test('Quote is marked expired after validity duration', () {
      final now = DateTime.now();
      final expiredQuote = TransferQuoteModel(
        quoteId: 'uuid-1',
        amount: Decimal.parse('500.00'),
        providerFee: Decimal.parse('10.00'),
        serviceFee: Decimal.parse('5.00'),
        totalDebit: Decimal.parse('515.00'),
        currency: 'NGN',
        destinationType: 'opay_wallet',
        accountName: 'JOHN DOE',
        accountMasked: '801****678',
        expiresAt: now.subtract(const Duration(seconds: 1)),
        validitySeconds: 120,
      );

      expect(expiredQuote.isExpired, isTrue);

      final validQuote = TransferQuoteModel(
        quoteId: 'uuid-2',
        amount: Decimal.parse('500.00'),
        providerFee: Decimal.parse('10.00'),
        serviceFee: Decimal.parse('5.00'),
        totalDebit: Decimal.parse('515.00'),
        currency: 'NGN',
        destinationType: 'opay_wallet',
        accountName: 'JOHN DOE',
        accountMasked: '801****678',
        expiresAt: now.add(const Duration(seconds: 60)),
        validitySeconds: 120,
      );

      expect(validQuote.isExpired, isFalse);
    });
  });

  group('BankModel & TransferModel Tests', () {
    test('BankModel parses correctly and detects opay type', () {
      final opayBank = BankModel.fromJson({
        'id': '1',
        'code': 'opay',
        'name': 'OPay / PayCom',
        'type': 'opay_wallet',
      });
      expect(opayBank.isOpay, isTrue);

      final commercialBank = BankModel.fromJson({
        'id': '2',
        'code': 'gtb',
        'name': 'Guaranty Trust Bank',
        'type': 'bank',
      });
      expect(commercialBank.isOpay, isFalse);
    });

    test('TransferModel status helpers work accurately', () {
      final transfer = TransferModel(
        trx: 'TRX123',
        status: 'processing',
        amount: Decimal.parse('5000.00'),
        providerFee: Decimal.parse('20.00'),
        serviceFee: Decimal.parse('10.00'),
        totalDebit: Decimal.parse('5030.00'),
      );
      expect(transfer.isPending, isTrue);
      expect(transfer.isSuccess, isFalse);
      expect(transfer.statusDisplay, 'Processing');
    });
  });

  group('TransferStatusTimeline Widget Tests', () {
    testWidgets('Renders timeline events properly', (tester) async {
      final events = [
        TransferEventModel(
          status: 'initiated',
          note: 'Initiated from wallet',
          createdAt: DateTime.now(),
        ),
        TransferEventModel(
          status: 'processing',
          note: 'Processing with banking switch',
          createdAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TransferStatusTimeline(
            events: events,
            currentStatus: 'processing',
          ),
        ),
      ));

      expect(find.text('Transfer Initiated'), findsOneWidget);
      expect(find.text('Processing with Bank'), findsOneWidget);
      expect(find.text('Initiated from wallet'), findsOneWidget);
    });
  });
}
