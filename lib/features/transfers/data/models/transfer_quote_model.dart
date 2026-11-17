import 'package:decimal/decimal.dart';

class TransferQuoteModel {
  final String quoteId;
  final Decimal amount;
  final Decimal providerFee;
  final Decimal serviceFee;
  final Decimal totalDebit;
  final String currency;
  final String destinationType;
  final String? bankCode;
  final String? accountName;
  final String? accountMasked;
  final DateTime expiresAt;
  final int validitySeconds;

  const TransferQuoteModel({
    required this.quoteId,
    required this.amount,
    required this.providerFee,
    required this.serviceFee,
    required this.totalDebit,
    required this.currency,
    required this.destinationType,
    this.bankCode,
    this.accountName,
    this.accountMasked,
    required this.expiresAt,
    this.validitySeconds = 120,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  factory TransferQuoteModel.fromJson(Map<String, dynamic> json) {
    DateTime parsedExpiresAt;
    if (json['expires_at'] != null) {
      parsedExpiresAt = DateTime.tryParse(json['expires_at'].toString()) ??
          DateTime.now().add(const Duration(seconds: 120));
    } else {
      parsedExpiresAt = DateTime.now().add(const Duration(seconds: 120));
    }

    return TransferQuoteModel(
      quoteId: json['quote_id']?.toString() ?? '',
      amount: Decimal.tryParse(json['amount']?.toString() ?? '0') ?? Decimal.zero,
      providerFee: Decimal.tryParse(json['provider_fee']?.toString() ?? '0') ?? Decimal.zero,
      serviceFee: Decimal.tryParse(json['service_fee']?.toString() ?? '0') ?? Decimal.zero,
      totalDebit: Decimal.tryParse(json['total_debit']?.toString() ?? '0') ?? Decimal.zero,
      currency: json['currency']?.toString() ?? 'NGN',
      destinationType: json['destination_type']?.toString() ?? 'bank',
      bankCode: json['bank_code']?.toString(),
      accountName: json['account_name']?.toString(),
      accountMasked: json['account_masked']?.toString(),
      expiresAt: parsedExpiresAt,
      validitySeconds: int.tryParse(json['validity_seconds']?.toString() ?? '120') ?? 120,
    );
  }

  Map<String, dynamic> toJson() => {
    'quote_id': quoteId,
    'amount': amount.toString(),
    'provider_fee': providerFee.toString(),
    'service_fee': serviceFee.toString(),
    'total_debit': totalDebit.toString(),
    'currency': currency,
    'destination_type': destinationType,
    'bank_code': bankCode,
    'account_name': accountName,
    'account_masked': accountMasked,
    'expires_at': expiresAt.toIso8601String(),
    'validity_seconds': validitySeconds,
  };
}
