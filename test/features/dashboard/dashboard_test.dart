import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:decimal/decimal.dart';
import 'package:ayodex/features/dashboard/presentation/widgets/wallet_balance_card.dart';
import 'package:ayodex/features/wallet/presentation/widgets/transaction_card.dart';
import 'package:ayodex/features/wallet/data/models/transaction_model.dart';

void main() {
  group('WalletBalanceCard Widget Tests', () {
    testWidgets('Toggling eye icon obscures and reveals balance', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: WalletBalanceCard(
            balance: Decimal.parse('4300.00'),
            currencySymbol: 'USD',
            onExchangeTap: () {},
            onTransferTap: () {},
            onWithdrawTap: () {},
          ),
        ),
      ));

      expect(find.textContaining('4,300.00'), findsOneWidget);

      // Tap toggle visibility icon
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pumpAndSettle();

      expect(find.text('••••••••'), findsOneWidget);

      // Tap again to reveal
      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pumpAndSettle();

      expect(find.textContaining('4,300.00'), findsOneWidget);
    });
  });

  group('TransactionCard Widget Tests', () {
    testWidgets('Displays green plus for credit and red minus for debit', (tester) async {
      final creditTrx = TransactionModel(
        id: 1,
        amount: Decimal.parse('250.00'),
        charge: Decimal.zero,
        postBalance: Decimal.parse('4550.00'),
        trxType: '+',
        trx: 'CR1234567890',
        details: 'Deposit via Bank',
        remark: 'deposit',
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TransactionCard(transaction: creditTrx),
        ),
      ));

      expect(find.text('+250.00'), findsOneWidget);
      expect(find.text('CR1234567890'), findsOneWidget);
    });
  });
}
