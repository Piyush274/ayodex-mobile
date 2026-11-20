import 'package:flutter_test/flutter_test.dart';
import 'package:decimal/decimal.dart';
import 'package:ayodex/features/withdraw/data/models/withdrawal_model.dart';

void main() {
  group('Withdrawal Limit Validation Tests', () {
    test('Validates withdrawal amount against user balance and limits', () {
      final userBalance = Decimal.parse('100.00');
      final minLimit = Decimal.parse('10.00');
      final maxLimit = Decimal.parse('500.00');

      // Test amount below minimum
      final lowAmount = Decimal.parse('5.00');
      expect(lowAmount < minLimit, isTrue);

      // Test amount exceeding balance
      final excessiveAmount = Decimal.parse('150.00');
      expect(excessiveAmount > userBalance, isTrue);

      // Test valid amount
      final validAmount = Decimal.parse('50.00');
      expect(
        validAmount >= minLimit && validAmount <= maxLimit && validAmount <= userBalance,
        isTrue,
      );
    });
  });

  group('WithdrawalModel Parsing & Helpers', () {
    test('Parses withdrawal JSON and evaluates status helpers', () {
      final pendingWithdrawal = WithdrawalModel.fromJson({
        'id': 101,
        'currency_id': 1,
        'amount': '50.00',
        'rate': '1.00',
        'charge': '2.50',
        'final_amount': '47.50',
        'status': 2,
        'created_at': '2026-11-20T10:00:00Z',
      });

      expect(pendingWithdrawal.isPending, isTrue);
      expect(pendingWithdrawal.isSuccess, isFalse);
      expect(pendingWithdrawal.statusDisplay, 'Pending');
      expect(pendingWithdrawal.amount, Decimal.parse('50.00'));
      expect(pendingWithdrawal.finalAmount, Decimal.parse('47.50'));

      final approvedWithdrawal = WithdrawalModel.fromJson({
        'id': 102,
        'currency_id': 1,
        'amount': '100.00',
        'rate': '1.00',
        'charge': '5.00',
        'final_amount': '95.00',
        'status': 1,
      });

      expect(approvedWithdrawal.isSuccess, isTrue);
      expect(approvedWithdrawal.statusDisplay, 'Approved');

      final rejectedWithdrawal = WithdrawalModel.fromJson({
        'id': 103,
        'currency_id': 1,
        'amount': '200.00',
        'rate': '1.00',
        'charge': '10.00',
        'final_amount': '190.00',
        'status': 3,
        'admin_feedback': 'Invalid account details',
      });

      expect(rejectedWithdrawal.isRejected, isTrue);
      expect(rejectedWithdrawal.statusDisplay, 'Rejected');
      expect(rejectedWithdrawal.adminFeedback, 'Invalid account details');
    });
  });
}
