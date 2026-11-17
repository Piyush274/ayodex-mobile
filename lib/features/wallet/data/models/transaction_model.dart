import 'package:decimal/decimal.dart';

class TransactionModel {
  final int id;
  final int? userId;
  final Decimal amount;
  final Decimal charge;
  final Decimal postBalance;
  final String trxType; // '+' or '-'
  final String trx;
  final String details;
  final String remark;
  final DateTime? createdAt;

  const TransactionModel({
    required this.id,
    this.userId,
    required this.amount,
    required this.charge,
    required this.postBalance,
    required this.trxType,
    required this.trx,
    required this.details,
    required this.remark,
    this.createdAt,
  });

  bool get isCredit => trxType == '+';
  bool get isDebit => trxType == '-';

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userId: json['user_id'] != null ? int.tryParse(json['user_id'].toString()) : null,
      amount: Decimal.tryParse(json['amount']?.toString() ?? '0') ?? Decimal.zero,
      charge: Decimal.tryParse(json['charge']?.toString() ?? '0') ?? Decimal.zero,
      postBalance: Decimal.tryParse(json['post_balance']?.toString() ?? '0') ?? Decimal.zero,
      trxType: json['trx_type']?.toString() ?? '-',
      trx: json['trx']?.toString() ?? '',
      details: json['details']?.toString() ?? '',
      remark: json['remark']?.toString() ?? '',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'amount': amount.toString(),
    'charge': charge.toString(),
    'post_balance': postBalance.toString(),
    'trx_type': trxType,
    'trx': trx,
    'details': details,
    'remark': remark,
    'created_at': createdAt?.toIso8601String(),
  };
}
