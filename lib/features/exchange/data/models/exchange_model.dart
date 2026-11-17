import 'package:decimal/decimal.dart';
import 'currency_model.dart';

class ExchangeModel {
  final int id;
  final String exchangeId;
  final int? userId;
  final int sendCurrencyId;
  final int receiveCurrencyId;
  final Decimal sendingAmount;
  final Decimal receivingAmount;
  final Decimal sendingCharge;
  final Decimal receivingCharge;
  final Decimal totalSendingAmount;
  final Decimal totalReceivedAmount;
  final String destinationType; // 'wallet' or 'external'
  final String? walletId;
  final int status; // 0=initial, 1=approved, 2=pending, 3=refund, 9=cancel
  final String? payoutStatus;
  final bool isAutometic;
  final String? redirectUrl;
  final String? pdfDownloadPath;
  final DateTime? createdAt;
  final CurrencyModel? sendCurrency;
  final CurrencyModel? receivedCurrency;

  const ExchangeModel({
    required this.id,
    required this.exchangeId,
    this.userId,
    required this.sendCurrencyId,
    required this.receiveCurrencyId,
    required this.sendingAmount,
    required this.receivingAmount,
    required this.sendingCharge,
    required this.receivingCharge,
    required this.totalSendingAmount,
    required this.totalReceivedAmount,
    this.destinationType = 'wallet',
    this.walletId,
    this.status = 2,
    this.payoutStatus,
    this.isAutometic = false,
    this.redirectUrl,
    this.pdfDownloadPath,
    this.createdAt,
    this.sendCurrency,
    this.receivedCurrency,
  });

  bool get isWalletDestination => destinationType == 'wallet';
  bool get isPending => status == 2;
  bool get isApproved => status == 1;
  bool get isRefunded => status == 3;
  bool get isCanceled => status == 9;

  String get statusText {
    switch (status) {
      case 1:
        return 'Approved';
      case 2:
        return 'Pending';
      case 3:
        return 'Refunded';
      case 9:
        return 'Canceled';
      default:
        return 'Initiated';
    }
  }

  factory ExchangeModel.fromJson(Map<String, dynamic> json) {
    return ExchangeModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      exchangeId: json['exchange_id']?.toString() ?? '',
      userId: json['user_id'] != null ? int.tryParse(json['user_id'].toString()) : null,
      sendCurrencyId: json['send_currency_id'] is int
          ? json['send_currency_id'] as int
          : int.tryParse(json['send_currency_id']?.toString() ?? '0') ?? 0,
      receiveCurrencyId: json['receive_currency_id'] is int
          ? json['receive_currency_id'] as int
          : int.tryParse(json['receive_currency_id']?.toString() ?? '0') ?? 0,
      sendingAmount: Decimal.tryParse(json['sending_amount']?.toString() ?? '0') ?? Decimal.zero,
      receivingAmount: Decimal.tryParse(json['receiving_amount']?.toString() ?? '0') ?? Decimal.zero,
      sendingCharge: Decimal.tryParse(json['sending_charge']?.toString() ?? '0') ?? Decimal.zero,
      receivingCharge: Decimal.tryParse(json['receiving_charge']?.toString() ?? '0') ?? Decimal.zero,
      totalSendingAmount: Decimal.tryParse(json['total_sending_amount']?.toString() ?? json['sending_amount']?.toString() ?? '0') ?? Decimal.zero,
      totalReceivedAmount: Decimal.tryParse(json['total_received_amount']?.toString() ?? json['receiving_amount']?.toString() ?? '0') ?? Decimal.zero,
      destinationType: json['destination_type']?.toString() ?? 'wallet',
      walletId: json['wallet_id']?.toString(),
      status: json['status'] is int ? json['status'] as int : int.tryParse(json['status']?.toString() ?? '2') ?? 2,
      payoutStatus: json['payout_status']?.toString(),
      isAutometic: json['is_autometic'] == 1 || json['is_autometic'] == '1' || json['is_autometic'] == true,
      redirectUrl: json['redirect_url']?.toString(),
      pdfDownloadPath: json['pdfDownloadPath']?.toString() ?? json['pdf_download_path']?.toString(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      sendCurrency: json['send_currency'] != null && json['send_currency'] is Map<String, dynamic>
          ? CurrencyModel.fromJson(json['send_currency'] as Map<String, dynamic>)
          : null,
      receivedCurrency: json['received_currency'] != null && json['received_currency'] is Map<String, dynamic>
          ? CurrencyModel.fromJson(json['received_currency'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'exchange_id': exchangeId,
    'user_id': userId,
    'send_currency_id': sendCurrencyId,
    'receive_currency_id': receiveCurrencyId,
    'sending_amount': sendingAmount.toString(),
    'receiving_amount': receivingAmount.toString(),
    'sending_charge': sendingCharge.toString(),
    'receiving_charge': receivingCharge.toString(),
    'total_sending_amount': totalSendingAmount.toString(),
    'total_received_amount': totalReceivedAmount.toString(),
    'destination_type': destinationType,
    'wallet_id': walletId,
    'status': status,
    'payout_status': payoutStatus,
    'is_autometic': isAutometic ? 1 : 0,
    'redirect_url': redirectUrl,
    'pdf_download_path': pdfDownloadPath,
    'created_at': createdAt?.toIso8601String(),
  };
}
