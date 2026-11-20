import 'package:flutter_test/flutter_test.dart';
import 'package:decimal/decimal.dart';
import 'package:ayodex/core/models/user_model.dart';
import 'package:ayodex/core/models/general_setting_model.dart';
import 'package:ayodex/core/models/dynamic_form_model.dart';
import 'package:ayodex/core/models/paginated_response.dart';
import 'package:ayodex/features/transfers/data/models/bank_model.dart';
import 'package:ayodex/features/transfers/data/models/transfer_quote_model.dart';
import 'package:ayodex/features/transfers/data/models/transfer_model.dart';
import 'package:ayodex/features/wallet/data/models/transaction_model.dart';

void main() {
  group('UserModel Deserialization Tests', () {
    test('Parses User JSON correctly with Decimal balance and status flags',
        () {
      final json = {
        'id': 13,
        'firstname': 'Jane',
        'lastname': 'Doe',
        'username': 'jane_doe',
        'email': 'jane@example.com',
        'dial_code': '229',
        'mobile': '97000001',
        'country_code': 'BJ',
        'country_name': 'Benin',
        'balance': '4300.50000000',
        'status': 1,
        'kv': 1,
        'ev': 1,
        'sv': 1,
        'ts': 0,
        'profile_complete': 1,
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 13);
      expect(user.fullName, 'Jane Doe');
      expect(user.balance, Decimal.parse('4300.50000000'));
      expect(user.isKycVerified, isTrue);
      expect(user.isProfileComplete, isTrue);
      expect(user.is2faEnabled, isFalse);
    });
  });

  group('GeneralSettingModel Deserialization Tests', () {
    test('Parses GeneralSetting with flags and validity seconds', () {
      final json = {
        'site_name': 'AYODEX',
        'cur_text': 'NGN',
        'cur_sym': '₦',
        'base_color': 'FF6033',
        'active_template': 'orange_oasis',
        'transfer_enabled': 1,
        'withdraw_enabled': 1,
        'registration': 1,
        'agree': 1,
        'secure_password': 0,
        'transfer_quote_validity_seconds': 120,
      };

      final settings = GeneralSettingModel.fromJson(json);
      expect(settings.siteName, 'AYODEX');
      expect(settings.curText, 'NGN');
      expect(settings.transferEnabled, isTrue);
      expect(settings.transferQuoteValiditySeconds, 120);
    });
  });

  group('DynamicFormModel Parsing Tests', () {
    test('Parses dynamic schema with text and file fields', () {
      final json = {
        'nin_number': {
          'name': 'National ID Number',
          'label': 'nin_number',
          'type': 'text',
          'is_required': 'required',
          'instruction': 'Enter 10 digits',
          'extensions': '',
          'options': [],
          'width': '12'
        },
        'id_document': {
          'name': 'ID Proof File',
          'label': 'id_document',
          'type': 'file',
          'is_required': 'required',
          'instruction': 'Upload PDF or JPG',
          'extensions': 'jpg,png,pdf',
          'options': [],
          'width': '12'
        }
      };

      final form = DynamicFormModel.fromJson(json);
      expect(form.fields.length, 2);
      expect(form.fields['nin_number']?.isRequired, isTrue);
      expect(form.fields['id_document']?.type, 'file');
      expect(form.fields['id_document']?.allowedExtensions, contains('pdf'));
    });
  });

  group('Transfer Models Deserialization Tests', () {
    test('Parses TransferQuote JSON with Decimal calculations', () {
      final json = {
        'quote_id': '80bd46ee-1234-4567-8901',
        'amount': '500.00000000',
        'provider_fee': '10.00000000',
        'service_fee': '5.00000000',
        'total_debit': '515.00000000',
        'currency': 'NGN',
        'destination_type': 'opay_wallet',
        'account_name': 'JOHN DOE',
        'account_masked': '801****678',
        'expires_at': '2026-11-17T15:00:00Z',
        'validity_seconds': 120
      };

      final quote = TransferQuoteModel.fromJson(json);
      expect(quote.totalDebit, Decimal.parse('515.00000000'));
      expect(quote.validitySeconds, 120);
      expect(quote.accountName, 'JOHN DOE');
    });

    test('Parses TransferModel with events timeline', () {
      final json = {
        'trx': 'EUYMBL7FL39N',
        'status': 'processing',
        'destination_type': 'bank',
        'bank_code': '058',
        'amount': '500.00000000',
        'provider_fee': '10.00000000',
        'service_fee': '5.00000000',
        'total_debit': '515.00000000',
        'currency': 'NGN',
        'account_name': 'JOHN DOE',
        'account_masked': '012****789',
        'created_at': '2026-11-17T14:30:00Z',
        'events': [
          {
            'status': 'initiated',
            'note': 'Transfer initiated by user',
            'created_at': '2026-11-17T14:30:00Z'
          },
          {
            'status': 'processing',
            'note': 'Sent to payout gateway',
            'created_at': '2026-11-17T14:30:05Z'
          }
        ]
      };

      final transfer = TransferModel.fromJson(json);
      expect(transfer.trx, 'EUYMBL7FL39N');
      expect(transfer.isPending, isTrue);
      expect(transfer.events.length, 2);
      expect(transfer.events.last.status, 'processing');
    });
  });

  group('Wallet & Transaction Model Tests', () {
    test('Parses TransactionModel with positive/negative type', () {
      final json = {
        'id': 101,
        'amount': '100.00000000',
        'charge': '0.00000000',
        'post_balance': '4300.00000000',
        'trx_type': '-',
        'trx': 'FF1TTQIMCBA9',
        'details': 'Transfer payout hold',
        'remark': 'transfer_hold',
        'created_at': '2026-11-17T14:00:00Z'
      };

      final trx = TransactionModel.fromJson(json);
      expect(trx.isDebit, isTrue);
      expect(trx.isCredit, isFalse);
      expect(trx.postBalance, Decimal.parse('4300.00000000'));
    });
  });

  group('PaginatedResponse Tests', () {
    test('Parses Laravel paginated envelope correctly', () {
      final json = {
        'current_page': 1,
        'last_page': 3,
        'per_page': 15,
        'total': 45,
        'data': [
          {'id': 1, 'code': 'opay', 'name': 'OPay'},
          {'id': 2, 'code': '058', 'name': 'GTBank'}
        ]
      };

      final paginated = PaginatedResponse<BankModel>.fromJson(
        json,
        (item) => BankModel.fromJson(item as Map<String, dynamic>),
      );

      expect(paginated.currentPage, 1);
      expect(paginated.lastPage, 3);
      expect(paginated.hasMorePages, isTrue);
      expect(paginated.data.length, 2);
      expect(paginated.data.first.code, 'opay');
    });
  });
}
