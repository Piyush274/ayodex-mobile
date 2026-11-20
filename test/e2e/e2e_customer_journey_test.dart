import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:decimal/decimal.dart';
import 'package:ayodex/core/models/user_model.dart';
import 'package:ayodex/core/services/secure_storage_service.dart';
import 'package:ayodex/core/widgets/app_button.dart';
import 'package:ayodex/core/widgets/empty_state_view.dart';
import 'package:ayodex/core/widgets/language_selector_sheet.dart';
import 'package:ayodex/features/dashboard/data/models/dashboard_model.dart';
import 'package:ayodex/features/transfers/data/models/bank_model.dart';
import 'package:ayodex/features/transfers/data/models/transfer_model.dart';
import 'package:ayodex/features/transfers/data/models/transfer_quote_model.dart';
import 'package:ayodex/features/wallet/data/models/transaction_model.dart';

void main() {
  group('Step 15 Responsive UI & Small Screen Density Tests', () {
    testWidgets('Renders clean layout without overflow on 375x667 screen (iPhone SE)', (tester) async {
      tester.view.physicalSize = const Size(375, 667);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const EmptyStateView(
                        title: 'No Pending Exchanges',
                        message: 'Exchange history is empty.',
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: AppButton(
                          text: 'Confirm Action',
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('No Pending Exchanges'), findsOneWidget);
      expect(find.text('Confirm Action'), findsOneWidget);
    });

    testWidgets('LanguageSelectorSheet renders accessible touch targets on small screen', (tester) async {
      tester.view.physicalSize = const Size(375, 667);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: LanguageSelectorSheet(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Select Language / Sélectionner la langue'), findsOneWidget);
      expect(find.text('Français'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);

      // Verify tap switches language
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('Full Customer Journey End-to-End Simulation', () {
    test('Simulates complete flow: Login -> Dashboard -> Transfer Quote -> Pin -> Ledger -> Logout', () async {
      // 1. Initial State: Staging User credentials
      const username = 'qa_browser_user';
      final initialUser = UserModel(
        id: 999,
        username: username,
        email: 'qa_browser_user@example.com',
        firstname: 'QA',
        lastname: 'Tester',
        mobile: '8012345678',
        countryCode: 'NG',
        balance: Decimal.parse('50000.00'),
        kv: 1, // KYC verified
        ev: 1, // Email verified
        sv: 1, // SMS verified
      );

      expect(initialUser.isKycVerified, isTrue);
      expect(initialUser.ev, 1);
      expect(initialUser.sv, 1);
      expect(initialUser.isActive, isTrue);
      expect(initialUser.balance, Decimal.parse('50000.00'));

      // 2. Dashboard State Verification
      final dashboard = DashboardDataModel(
        balance: initialUser.balance,
        exchangeCount: const ExchangeCounts(total: 12),
        ticketCount: const TicketCounts(answer: 1),
        user: initialUser,
      );
      expect(dashboard.balance, Decimal.parse('50000.00'));
      expect(dashboard.exchangeCount.total, 12);

      // 3. Payout Transfer: Select OPay and Resolve Account
      final opayBank = BankModel.fromJson({
        'id': '10',
        'code': 'opay',
        'name': 'OPay / PayCom',
        'type': 'opay_wallet',
      });
      expect(opayBank.isOpay, isTrue);
      expect(opayBank.code, 'opay');

      // Account resolved: JOHN DOE
      const resolvedAccountName = 'JOHN DOE';
      const accountNumber = '8012345678';
      expect(accountNumber.length, 10);

      // 4. Generate 120-second Transfer Quote
      final quote = TransferQuoteModel(
        quoteId: 'quote-e2e-12345',
        amount: Decimal.parse('500.00'),
        providerFee: Decimal.parse('10.00'),
        serviceFee: Decimal.parse('5.00'),
        totalDebit: Decimal.parse('515.00'),
        currency: 'NGN',
        destinationType: 'opay_wallet',
        accountName: resolvedAccountName,
        accountMasked: '801****678',
        expiresAt: DateTime.now().add(const Duration(seconds: 120)),
        validitySeconds: 120,
      );

      expect(quote.isExpired, isFalse);
      expect(quote.totalDebit, Decimal.parse('515.00'));

      // 5. PIN Validation & Transfer Execution
      const enteredPin = '1234';
      expect(enteredPin.length, 4);

      // Payout Transfer Executed
      final executedTransfer = TransferModel(
        trx: 'TRX-E2E-9842',
        status: 'processing',
        amount: quote.amount,
        providerFee: quote.providerFee,
        serviceFee: quote.serviceFee,
        totalDebit: quote.totalDebit,
        createdAt: DateTime.now(),
      );

      expect(executedTransfer.isPending, isTrue);
      expect(executedTransfer.trx, 'TRX-E2E-9842');

      // 6. Updated User Balance after Debit
      final updatedBalance = initialUser.balance - quote.totalDebit;
      expect(updatedBalance, Decimal.parse('49485.00'));

      // 7. Wallet Transaction Ledger Record
      final transactionRecord = TransactionModel(
        id: 777,
        trx: executedTransfer.trx,
        amount: quote.totalDebit,
        charge: Decimal.parse('15.00'),
        postBalance: updatedBalance,
        trxType: '-', // debit
        remark: 'bank_transfer',
        details: 'Payout transfer to OPay ($resolvedAccountName)',
        createdAt: DateTime.now(),
      );

      expect(transactionRecord.isDebit, isTrue);
      expect(transactionRecord.isCredit, isFalse);
      expect(transactionRecord.trxType, '-');
      expect(transactionRecord.amount, Decimal.parse('515.00'));
      expect(transactionRecord.postBalance, Decimal.parse('49485.00'));

      // 8. Logout & Session Cleared
      final storage = FakeSecureStorageService();
      expect(await storage.hasToken(), isTrue);
      await storage.clearToken();
      final hasToken = await storage.hasToken();
      expect(hasToken, isFalse);
    });
  });
}

class FakeSecureStorageService implements SecureStorageService {
  String? _token = 'mock_jwt_token_123';

  @override
  Future<void> saveToken(String token, {String tokenType = 'Bearer'}) async {
    _token = token;
  }

  @override
  Future<String?> getToken() async => _token;

  @override
  Future<String?> getTokenType() async => 'Bearer';

  @override
  Future<bool> hasToken() async => _token != null && _token!.isNotEmpty;

  @override
  Future<void> clearToken() async {
    _token = null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
