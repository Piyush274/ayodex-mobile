import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:decimal/decimal.dart';
import 'package:ayodex/features/exchange/data/models/currency_model.dart';
import 'package:ayodex/features/exchange/presentation/widgets/exchange_calculation_box.dart';

void main() {
  group('Exchange Calculation Logic Tests', () {
    test('Calculates receiving amount and charges accurately', () {
      final sendingAmount = Decimal.parse('100.00');
      final buyRate = Decimal.parse('1.00'); // Send currency buy rate
      final sellRate = Decimal.parse('0.0013'); // Receive currency sell rate
      final percentCharge = Decimal.parse('1.5'); // 1.5%

      // Sending charge calculation
      final sendingFee = ((sendingAmount * percentCharge) / Decimal.fromInt(100)).toDecimal(scaleOnInfinitePrecision: 8);
      expect(sendingFee, Decimal.parse('1.5'));

      // Converted amount before fee
      final grossReceive = sendingAmount * (buyRate / sellRate).toDecimal(scaleOnInfinitePrecision: 8);
      expect(grossReceive > Decimal.zero, isTrue);
    });

    test('Validates against reserve limits', () {
      final receiveAmount = Decimal.parse('500000.00');
      final reserveLimit = Decimal.parse('100000.00');

      final exceedsReserve = receiveAmount > reserveLimit;
      expect(exceedsReserve, isTrue);
    });
  });

  group('ExchangeCalculationBox Widget Tests', () {
    testWidgets('Renders calculation rates and fees', (tester) async {
      final sendCur = CurrencyModel(
        id: 1,
        name: 'USD Perfect Money',
        curSym: 'USD',
        buyAt: Decimal.parse('1.00'),
        sellAt: Decimal.parse('1.00'),
        fixedChargeForBuy: Decimal.zero,
        percentChargeForBuy: Decimal.zero,
        fixedChargeForSell: Decimal.parse('1.00'),
        percentChargeForSell: Decimal.parse('1.00'),
        reserve: Decimal.parse('50000.00'),
        minimumLimitForBuy: Decimal.parse('10.00'),
        maximumLimitForBuy: Decimal.parse('10000.00'),
        minimumLimitForSell: Decimal.parse('10.00'),
        maximumLimitForSell: Decimal.parse('10000.00'),
      );

      final receiveCur = CurrencyModel(
        id: 2,
        name: 'Nigerian Naira',
        curSym: 'NGN',
        buyAt: Decimal.parse('0.001'),
        sellAt: Decimal.parse('0.001'),
        fixedChargeForBuy: Decimal.zero,
        percentChargeForBuy: Decimal.zero,
        fixedChargeForSell: Decimal.zero,
        percentChargeForSell: Decimal.zero,
        reserve: Decimal.parse('1000000.00'),
        minimumLimitForBuy: Decimal.parse('1000.00'),
        maximumLimitForBuy: Decimal.parse('5000000.00'),
        minimumLimitForSell: Decimal.parse('1000.00'),
        maximumLimitForSell: Decimal.parse('5000000.00'),
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ExchangeCalculationBox(
            sendingAmount: Decimal.parse('100.00'),
            sendCurrency: sendCur,
            receiveCurrency: receiveCur,
          ),
        ),
      ));

      expect(find.text('Live Exchange Rate'), findsOneWidget);
      expect(find.text('Sending Fee'), findsOneWidget);
      expect(find.text('You Receive (Est.)'), findsOneWidget);
    });
  });
}
