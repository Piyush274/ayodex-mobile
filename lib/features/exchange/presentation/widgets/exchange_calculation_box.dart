import 'package:flutter/material.dart';
import 'package:decimal/decimal.dart';
import 'package:ayodex/core/constants/app_colors.dart';
import 'package:ayodex/core/constants/app_dimensions.dart';
import 'package:ayodex/core/theme/text_theme.dart';
import 'package:ayodex/features/exchange/data/models/currency_model.dart';

class ExchangeCalculationBox extends StatelessWidget {
  final Decimal sendingAmount;
  final CurrencyModel sendCurrency;
  final CurrencyModel receiveCurrency;

  const ExchangeCalculationBox({
    super.key,
    required this.sendingAmount,
    required this.sendCurrency,
    required this.receiveCurrency,
  });

  Decimal get _sendingFee {
    final fixed = sendCurrency.fixedChargeForSell;
    final percent = ((sendingAmount * sendCurrency.percentChargeForSell) / Decimal.fromInt(100)).toDecimal(scaleOnInfinitePrecision: 8);
    return fixed + percent;
  }

  Decimal get _netSendingAmount {
    return sendingAmount > _sendingFee ? sendingAmount - _sendingFee : Decimal.zero;
  }

  Decimal get _convertedAmount {
    if (receiveCurrency.buyAt <= Decimal.zero) return Decimal.zero;
    // Calculation: netSend * (send.sellAt / receive.buyAt)
    final rateRatio = (sendCurrency.sellAt / receiveCurrency.buyAt).toDecimal(scaleOnInfinitePrecision: 8);
    return _netSendingAmount * rateRatio;
  }

  Decimal get _receivingFee {
    final fixed = receiveCurrency.fixedChargeForBuy;
    final percent = ((_convertedAmount * receiveCurrency.percentChargeForBuy) / Decimal.fromInt(100)).toDecimal(scaleOnInfinitePrecision: 8);
    return fixed + percent;
  }

  Decimal get _finalReceiveAmount {
    return _convertedAmount > _receivingFee ? _convertedAmount - _receivingFee : Decimal.zero;
  }

  bool get _exceedsReserve => _finalReceiveAmount > receiveCurrency.reserve;
  bool get _belowMin => sendingAmount < sendCurrency.minimumLimitForSell;
  bool get _aboveMax => sendCurrency.maximumLimitForSell > Decimal.zero && sendingAmount > sendCurrency.maximumLimitForSell;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.p16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Live Exchange Rate', style: AppTextTheme.bodyMedium.copyWith(color: AppColors.textMuted)),
              Text(
                '1 ${sendCurrency.curSym} = ${((sendCurrency.sellAt / receiveCurrency.buyAt).toDecimal(scaleOnInfinitePrecision: 8)).toStringAsFixed(4)} ${receiveCurrency.curSym}',
                style: AppTextTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sending Fee', style: AppTextTheme.bodyMedium.copyWith(color: AppColors.textMuted)),
              Text(
                '${_sendingFee.toStringAsFixed(2)} ${sendCurrency.curSym}',
                style: AppTextTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Receiving Fee', style: AppTextTheme.bodyMedium.copyWith(color: AppColors.textMuted)),
              Text(
                '${_receivingFee.toStringAsFixed(2)} ${receiveCurrency.curSym}',
                style: AppTextTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('You Receive (Est.)', style: AppTextTheme.headingMedium.copyWith(fontSize: 16)),
              Text(
                '${_finalReceiveAmount.toStringAsFixed(2)} ${receiveCurrency.curSym}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.success,
                ),
              ),
            ],
          ),

          // Warnings
          if (_belowMin) ...[
            const SizedBox(height: 10),
            Text(
              'Minimum sending limit is ${sendCurrency.minimumLimitForSell} ${sendCurrency.curSym}',
              style: AppTextTheme.caption.copyWith(color: AppColors.danger),
            ),
          ],
          if (_aboveMax) ...[
            const SizedBox(height: 10),
            Text(
              'Maximum sending limit is ${sendCurrency.maximumLimitForSell} ${sendCurrency.curSym}',
              style: AppTextTheme.caption.copyWith(color: AppColors.danger),
            ),
          ],
          if (_exceedsReserve) ...[
            const SizedBox(height: 10),
            Text(
              'Amount exceeds available platform reserve (${receiveCurrency.reserve} ${receiveCurrency.curSym})',
              style: AppTextTheme.caption.copyWith(color: AppColors.danger),
            ),
          ],
        ],
      ),
    );
  }
}
