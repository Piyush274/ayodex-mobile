import 'package:flutter/material.dart';
import 'package:ayodex/core/constants/app_colors.dart';
import 'package:ayodex/core/constants/app_dimensions.dart';
import 'package:ayodex/core/theme/text_theme.dart';
import 'package:ayodex/features/exchange/data/models/exchange_model.dart';

class RecentActivityList extends StatelessWidget {
  final List<ExchangeModel> exchanges;
  final ValueChanged<ExchangeModel>? onExchangeTap;

  const RecentActivityList({
    super.key,
    required this.exchanges,
    this.onExchangeTap,
  });

  Color _getStatusColor(int status) {
    switch (status) {
      case 1:
        return AppColors.success;
      case 2:
        return AppColors.warning;
      case 3:
        return AppColors.danger;
      case 4:
        return AppColors.info;
      default:
        return AppColors.textMuted;
    }
  }

  String _getStatusText(int status) {
    switch (status) {
      case 1:
        return 'Approved';
      case 2:
        return 'Pending';
      case 3:
        return 'Canceled';
      case 4:
        return 'Refunded';
      default:
        return 'Initiated';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Activity', style: AppTextTheme.headingMedium),
            if (exchanges.isNotEmpty)
              Text(
                'Latest ${exchanges.length}',
                style: AppTextTheme.caption.copyWith(color: AppColors.textMuted),
              ),
          ],
        ),
        const SizedBox(height: AppDimensions.p12),
        if (exchanges.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppDimensions.p24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.inbox_outlined, size: 40, color: AppColors.textMuted),
                  const SizedBox(height: 8),
                  Text(
                    'No recent transactions found',
                    style: AppTextTheme.bodyMedium.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: exchanges.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppDimensions.p8),
            itemBuilder: (context, index) {
              final item = exchanges[index];
              final statusColor = _getStatusColor(item.status);

              return Card(
                elevation: 0,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  side: const BorderSide(color: AppColors.border),
                ),
                color: AppColors.surface,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.base.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.swap_horiz_rounded, color: AppColors.base),
                  ),
                  title: Text(
                    '${item.sendingAmount} -> ${item.receivingAmount}',
                    style: AppTextTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Exchange #${item.exchangeId}',
                    style: AppTextTheme.caption.copyWith(fontFamily: 'monospace'),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor.withOpacity(0.4)),
                    ),
                    child: Text(
                      _getStatusText(item.status),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                  onTap: () => onExchangeTap?.call(item),
                ),
              );
            },
          ),
      ],
    );
  }
}
