import 'package:flutter/material.dart';
import 'package:ayodex/core/constants/app_colors.dart';
import 'package:ayodex/core/constants/app_dimensions.dart';
import 'package:ayodex/core/theme/text_theme.dart';
import 'package:ayodex/core/widgets/custom_card.dart';
import 'package:ayodex/features/exchange/data/models/currency_model.dart';

class WithdrawCurrencyCard extends StatelessWidget {
  final CurrencyModel currency;
  final bool isSelected;
  final VoidCallback onTap;

  const WithdrawCurrencyCard({
    super.key,
    required this.currency,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: isSelected
              ? Border.all(color: AppColors.base, width: 2)
              : Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        ),
        padding: const EdgeInsets.all(AppDimensions.p12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.surfaceSubtle,
              child: Text(
                currency.curSym,
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.base, fontSize: 12),
              ),
            ),
            const SizedBox(width: AppDimensions.p12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currency.name,
                    style: AppTextTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Limits: ${currency.minimumLimitForSell} - ${currency.maximumLimitForSell} ${currency.curSym}',
                    style: AppTextTheme.caption.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.base, size: 22)
            else
              const Icon(Icons.radio_button_unchecked, color: AppColors.textMuted, size: 22),
          ],
        ),
      ),
    );
  }
}
