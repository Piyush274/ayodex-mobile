import 'package:decimal/decimal.dart';
import '../../../../core/models/dynamic_form_model.dart';

class CurrencyModel {
  final int id;
  final String name;
  final String curSym;
  final Decimal buyAt;
  final Decimal sellAt;
  final Decimal fixedChargeForBuy;
  final Decimal percentChargeForBuy;
  final Decimal fixedChargeForSell;
  final Decimal percentChargeForSell;
  final Decimal reserve;
  final Decimal minimumLimitForBuy;
  final Decimal maximumLimitForBuy;
  final Decimal minimumLimitForSell;
  final Decimal maximumLimitForSell;
  final String? image;
  final bool availableForSell;
  final bool availableForBuy;
  final DynamicFormModel? userDetailsData;
  final DynamicFormModel? trxProofData;

  const CurrencyModel({
    required this.id,
    required this.name,
    required this.curSym,
    required this.buyAt,
    required this.sellAt,
    required this.fixedChargeForBuy,
    required this.percentChargeForBuy,
    required this.fixedChargeForSell,
    required this.percentChargeForSell,
    required this.reserve,
    required this.minimumLimitForBuy,
    required this.maximumLimitForBuy,
    required this.minimumLimitForSell,
    required this.maximumLimitForSell,
    this.image,
    this.availableForSell = true,
    this.availableForBuy = true,
    this.userDetailsData,
    this.trxProofData,
  });

  factory CurrencyModel.fromJson(Map<String, dynamic> json) {
    return CurrencyModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      curSym: json['cur_sym']?.toString() ?? '',
      buyAt: Decimal.tryParse(json['buy_at']?.toString() ?? '0') ?? Decimal.zero,
      sellAt: Decimal.tryParse(json['sell_at']?.toString() ?? '0') ?? Decimal.zero,
      fixedChargeForBuy: Decimal.tryParse(json['fixed_charge_for_buy']?.toString() ?? '0') ?? Decimal.zero,
      percentChargeForBuy: Decimal.tryParse(json['percent_charge_for_buy']?.toString() ?? '0') ?? Decimal.zero,
      fixedChargeForSell: Decimal.tryParse(json['fixed_charge_for_sell']?.toString() ?? '0') ?? Decimal.zero,
      percentChargeForSell: Decimal.tryParse(json['percent_charge_for_sell']?.toString() ?? '0') ?? Decimal.zero,
      reserve: Decimal.tryParse(json['reserve']?.toString() ?? '0') ?? Decimal.zero,
      minimumLimitForBuy: Decimal.tryParse(json['minimum_limit_for_buy']?.toString() ?? '0') ?? Decimal.zero,
      maximumLimitForBuy: Decimal.tryParse(json['maximum_limit_for_buy']?.toString() ?? '0') ?? Decimal.zero,
      minimumLimitForSell: Decimal.tryParse(json['minimum_limit_for_sell']?.toString() ?? '0') ?? Decimal.zero,
      maximumLimitForSell: Decimal.tryParse(json['maximum_limit_for_sell']?.toString() ?? '0') ?? Decimal.zero,
      image: json['image']?.toString(),
      availableForSell: json['available_for_sell'] == 1 || json['available_for_sell'] == '1' || json['available_for_sell'] == true,
      availableForBuy: json['available_for_buy'] == 1 || json['available_for_buy'] == '1' || json['available_for_buy'] == true,
      userDetailsData: json['user_details_data'] != null ? DynamicFormModel.fromJson(json['user_details_data']) : null,
      trxProofData: json['trx_proof_data'] != null ? DynamicFormModel.fromJson(json['trx_proof_data']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'cur_sym': curSym,
    'buy_at': buyAt.toString(),
    'sell_at': sellAt.toString(),
    'fixed_charge_for_buy': fixedChargeForBuy.toString(),
    'percent_charge_for_buy': percentChargeForBuy.toString(),
    'fixed_charge_for_sell': fixedChargeForSell.toString(),
    'percent_charge_for_sell': percentChargeForSell.toString(),
    'reserve': reserve.toString(),
    'minimum_limit_for_buy': minimumLimitForBuy.toString(),
    'maximum_limit_for_buy': maximumLimitForBuy.toString(),
    'minimum_limit_for_sell': minimumLimitForSell.toString(),
    'maximum_limit_for_sell': maximumLimitForSell.toString(),
    'image': image,
    'available_for_sell': availableForSell ? 1 : 0,
    'available_for_buy': availableForBuy ? 1 : 0,
  };
}
