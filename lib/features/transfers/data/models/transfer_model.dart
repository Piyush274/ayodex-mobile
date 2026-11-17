import 'package:decimal/decimal.dart';

class TransferEventModel {
  final int? id;
  final String status;
  final String? note;
  final DateTime? createdAt;

  const TransferEventModel({
    this.id,
    required this.status,
    this.note,
    this.createdAt,
  });

  factory TransferEventModel.fromJson(Map<String, dynamic> json) {
    return TransferEventModel(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      status: json['status']?.toString() ?? '',
      note: json['note']?.toString(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'status': status,
    'note': note,
    'created_at': createdAt?.toIso8601String(),
  };
}

class TransferModel {
  final String trx;
  final String status;
  final String destinationType;
  final String? bankCode;
  final String? accountName;
  final String? accountMasked;
  final Decimal amount;
  final Decimal providerFee;
  final Decimal serviceFee;
  final Decimal totalDebit;
  final String currency;
  final DateTime? settledAt;
  final DateTime? createdAt;
  final List<TransferEventModel> events;

  const TransferModel({
    required this.trx,
    required this.status,
    this.destinationType = 'bank',
    this.bankCode,
    this.accountName,
    this.accountMasked,
    required this.amount,
    required this.providerFee,
    required this.serviceFee,
    required this.totalDebit,
    this.currency = 'NGN',
    this.settledAt,
    this.createdAt,
    this.events = const [],
  });

  bool get isPending => status == 'initiated' || status == 'processing' || status == 'manual_review';
  bool get isSuccess => status == 'success';
  bool get isFailed => status == 'failed_refunded' || status == 'failed_partial_refund';

  String get statusDisplay {
    switch (status) {
      case 'success':
        return 'Completed';
      case 'processing':
        return 'Processing';
      case 'initiated':
        return 'Initiated';
      case 'failed_refunded':
        return 'Failed (Refunded)';
      case 'failed_partial_refund':
        return 'Partially Refunded';
      case 'manual_review':
        return 'Under Review';
      default:
        return status;
    }
  }

  factory TransferModel.fromJson(Map<String, dynamic> json) {
    final rawEvents = json['events'] as List<dynamic>? ?? [];
    final parsedEvents = rawEvents
        .whereType<Map<String, dynamic>>()
        .map((e) => TransferEventModel.fromJson(e))
        .toList();

    return TransferModel(
      trx: json['trx']?.toString() ?? '',
      status: json['status']?.toString() ?? 'processing',
      destinationType: json['destination_type']?.toString() ?? 'bank',
      bankCode: json['bank_code']?.toString(),
      accountName: json['account_name']?.toString(),
      accountMasked: json['account_masked']?.toString() ?? json['account_number_masked']?.toString(),
      amount: Decimal.tryParse(json['amount']?.toString() ?? '0') ?? Decimal.zero,
      providerFee: Decimal.tryParse(json['provider_fee']?.toString() ?? '0') ?? Decimal.zero,
      serviceFee: Decimal.tryParse(json['service_fee']?.toString() ?? '0') ?? Decimal.zero,
      totalDebit: Decimal.tryParse(json['total_debit']?.toString() ?? '0') ?? Decimal.zero,
      currency: json['currency']?.toString() ?? 'NGN',
      settledAt: json['settled_at'] != null ? DateTime.tryParse(json['settled_at'].toString()) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      events: parsedEvents,
    );
  }

  Map<String, dynamic> toJson() => {
    'trx': trx,
    'status': status,
    'destination_type': destinationType,
    'bank_code': bankCode,
    'account_name': accountName,
    'account_masked': accountMasked,
    'amount': amount.toString(),
    'provider_fee': providerFee.toString(),
    'service_fee': serviceFee.toString(),
    'total_debit': totalDebit.toString(),
    'currency': currency,
    'settled_at': settledAt?.toIso8601String(),
    'created_at': createdAt?.toIso8601String(),
    'events': events.map((e) => e.toJson()).toList(),
  };
}
