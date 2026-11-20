import 'package:flutter/material.dart';
import 'package:ayodex/core/constants/app_colors.dart';
import 'package:ayodex/core/constants/app_dimensions.dart';
import 'package:ayodex/core/theme/text_theme.dart';
import '../../data/models/dashboard_model.dart';

class ExchangeSummaryRow extends StatelessWidget {
  final ExchangeCounts exchangeCounts;
  final ValueChanged<String>? onScopeSelected;

  const ExchangeSummaryRow({
    super.key,
    required this.exchangeCounts,
    this.onScopeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Exchange Overview', style: AppTextTheme.headingMedium),
        const SizedBox(height: AppDimensions.p12),
        Row(
          children: [
            Expanded(
              child: _StatusCard(
                label: 'Approved',
                count: exchangeCounts.approved,
                color: AppColors.success,
                icon: Icons.check_circle_outline,
                onTap: () => onScopeSelected?.call('approved'),
              ),
            ),
            const SizedBox(width: AppDimensions.p8),
            Expanded(
              child: _StatusCard(
                label: 'Pending',
                count: exchangeCounts.pending,
                color: AppColors.warning,
                icon: Icons.schedule_outlined,
                onTap: () => onScopeSelected?.call('pending'),
              ),
            ),
            const SizedBox(width: AppDimensions.p8),
            Expanded(
              child: _StatusCard(
                label: 'Refunded',
                count: exchangeCounts.refunded,
                color: AppColors.info,
                icon: Icons.replay_outlined,
                onTap: () => onScopeSelected?.call('refunded'),
              ),
            ),
            const SizedBox(width: AppDimensions.p8),
            Expanded(
              child: _StatusCard(
                label: 'Canceled',
                count: exchangeCounts.cancel,
                color: AppColors.danger,
                icon: Icons.cancel_outlined,
                onTap: () => onScopeSelected?.call('cancel'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;

  const _StatusCard({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 6),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
