import 'package:decimal/decimal.dart';
import 'package:ayodex/features/exchange/data/models/currency_model.dart';

class WithdrawalModel {
  final int id;
  final int? userId;
  final int currencyId;
  final Decimal amount;
  final Decimal rate;
  final Decimal charge;
  final Decimal finalAmount;
  final int status; // 1=success, 2=pending, 3=reject
  final String? adminFeedback;
  final CurrencyModel? currency;
  final DateTime? createdAt;

  const WithdrawalModel({
    required this.id,
    this.userId,
    required this.currencyId,
    required this.amount,
    required this.rate,
    required this.charge,
    required this.finalAmount,
    this.status = 2,
    this.adminFeedback,
    this.currency,
    this.createdAt,
  });

  bool get isPending => status == 2;
  bool get isSuccess => status == 1;
  bool get isRejected => status == 3;

  String get statusDisplay {
    switch (status) {
      case 1:
        return 'Approved';
      case 2:
        return 'Pending';
      case 3:
        return 'Rejected';
      default:
        return 'Initiated';
    }
  }

  factory WithdrawalModel.fromJson(Map<String, dynamic> json) {
    return WithdrawalModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userId: json['user_id'] != null ? int.tryParse(json['user_id'].toString()) : null,
      currencyId: json['currency_id'] is int
          ? json['currency_id'] as int
          : int.tryParse(json['currency_id']?.toString() ?? '0') ?? 0,
      amount: Decimal.tryParse(json['amount']?.toString() ?? '0') ?? Decimal.zero,
      rate: Decimal.tryParse(json['rate']?.toString() ?? '1') ?? Decimal.one,
      charge: Decimal.tryParse(json['charge']?.toString() ?? '0') ?? Decimal.zero,
      finalAmount: Decimal.tryParse(json['final_amount']?.toString() ?? json['final_amo']?.toString() ?? '0') ?? Decimal.zero,
      status: json['status'] is int ? json['status'] as int : int.tryParse(json['status']?.toString() ?? '2') ?? 2,
      adminFeedback: json['admin_feedback']?.toString(),
      currency: json['currency'] != null && json['currency'] is Map<String, dynamic>
          ? CurrencyModel.fromJson(json['currency'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'currency_id': currencyId,
    'amount': amount.toString(),
    'rate': rate.toString(),
    'charge': charge.toString(),
    'final_amount': finalAmount.toString(),
    'status': status,
    'admin_feedback': adminFeedback,
    'created_at': createdAt?.toIso8601String(),
  };
}
