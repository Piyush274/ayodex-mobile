import 'package:decimal/decimal.dart';
import 'package:ayodex/core/models/user_model.dart';
import 'package:ayodex/features/exchange/data/models/exchange_model.dart';

class ExchangeCounts {
  final int pending;
  final int approved;
  final int refunded;
  final int cancel;
  final int total;

  const ExchangeCounts({
    this.pending = 0,
    this.approved = 0,
    this.refunded = 0,
    this.cancel = 0,
    this.total = 0,
  });

  factory ExchangeCounts.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ExchangeCounts();
    return ExchangeCounts(
      pending: int.tryParse(json['pending']?.toString() ?? '0') ?? 0,
      approved: int.tryParse(json['approved']?.toString() ?? '0') ?? 0,
      refunded: int.tryParse(json['refunded']?.toString() ?? '0') ?? 0,
      cancel: int.tryParse(json['cancel']?.toString() ?? '0') ?? 0,
      total: int.tryParse(json['total']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'pending': pending,
    'approved': approved,
    'refunded': refunded,
    'cancel': cancel,
    'total': total,
  };
}

class TicketCounts {
  final int answer;
  final int reapply;

  const TicketCounts({
    this.answer = 0,
    this.reapply = 0,
  });

  factory TicketCounts.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const TicketCounts();
    return TicketCounts(
      answer: int.tryParse(json['answer']?.toString() ?? '0') ?? 0,
      reapply: int.tryParse(json['reapply']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'answer': answer,
    'reapply': reapply,
  };
}

class DashboardDataModel {
  final Decimal balance;
  final ExchangeCounts exchangeCount;
  final TicketCounts ticketCount;
  final List<ExchangeModel> latestExchange;
  final UserModel? user;

  const DashboardDataModel({
    required this.balance,
    required this.exchangeCount,
    required this.ticketCount,
    this.latestExchange = const [],
    this.user,
  });

  factory DashboardDataModel.fromJson(Map<String, dynamic> json) {
    final rawList = json['latest_exchange'] as List<dynamic>? ?? [];
    final exchanges = rawList
        .whereType<Map<String, dynamic>>()
        .map((e) => ExchangeModel.fromJson(e))
        .toList();

    return DashboardDataModel(
      balance: Decimal.tryParse(json['balance']?.toString() ?? '0') ?? Decimal.zero,
      exchangeCount: ExchangeCounts.fromJson(json['exchange_count'] as Map<String, dynamic>?),
      ticketCount: TicketCounts.fromJson(json['ticket_count'] as Map<String, dynamic>?),
      latestExchange: exchanges,
      user: json['user'] != null && json['user'] is Map<String, dynamic>
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'balance': balance.toString(),
    'exchange_count': exchangeCount.toJson(),
    'ticket_count': ticketCount.toJson(),
    'latest_exchange': latestExchange.map((e) => e.toJson()).toList(),
    'user': user?.toJson(),
  };
}
