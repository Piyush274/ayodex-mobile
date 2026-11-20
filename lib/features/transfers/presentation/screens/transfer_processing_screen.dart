import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ayodex/core/constants/app_colors.dart';
import 'package:ayodex/core/constants/app_dimensions.dart';
import 'package:ayodex/core/theme/text_theme.dart';
import 'package:ayodex/core/widgets/app_button.dart';
import 'package:ayodex/core/widgets/custom_card.dart';
import 'package:ayodex/core/widgets/status_badge.dart';
import '../controllers/transfer_controller.dart';

class TransferProcessingScreen extends ConsumerWidget {
  final String trx;

  const TransferProcessingScreen({super.key, required this.trx});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transfer = ref.watch(transferControllerProvider).lastTransfer;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          context.go('/dashboard');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Transfer Status'),
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),

              // Animated/Visual Status Icon
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 48,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'Transfer Dispatched!',
                style: AppTextTheme.headingLarge.copyWith(fontSize: 22),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Your payout instruction has been safely delivered to the banking network.',
                style: AppTextTheme.bodyMedium.copyWith(color: AppColors.body),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              // Receipt Card
              CustomCard(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Transaction Ref', style: AppTextTheme.bodyMedium.copyWith(color: AppColors.textMuted)),
                        Row(
                          children: [
                            Text(
                              trx,
                              style: AppTextTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 6),
                            InkWell(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: trx));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Reference copied to clipboard!')),
                                );
                              },
                              child: const Icon(Icons.copy, size: 16, color: AppColors.base),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    if (transfer != null) ...[
                      _buildReceiptRow('Status', ''),
                      _buildReceiptRow('Beneficiary', transfer.accountName ?? 'N/A'),
                      _buildReceiptRow('Account', transfer.accountMasked ?? '**********'),
                      _buildReceiptRow('Amount', '₦${transfer.amount.toStringAsFixed(2)}'),
                      _buildReceiptRow('Total Debit', '₦${transfer.totalDebit.toStringAsFixed(2)}'),
                    ] else ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Status', style: AppTextTheme.bodyMedium.copyWith(color: AppColors.textMuted)),
                          const StatusBadge(label: 'Processing', color: AppColors.warning),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Reassurance message
              Container(
                padding: const EdgeInsets.all(AppDimensions.p16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.base, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Processing usually completes in seconds. You can track this transfer in your history anytime.',
                        style: AppTextTheme.caption.copyWith(color: AppColors.body),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Action Buttons
              AppButton(
                text: 'View Transfer Receipt',
                onPressed: () => context.push('/transfer/detail/$trx'),
              ),
              const SizedBox(height: 12),
              AppButton(
                text: 'Back to Dashboard',
                variant: AppButtonVariant.outline,
                onPressed: () => context.go('/dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    if (label == 'Status') {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextTheme.bodyMedium.copyWith(color: AppColors.textMuted)),
            const StatusBadge(label: 'Processing', color: AppColors.warning),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextTheme.bodyMedium.copyWith(color: AppColors.textMuted)),
          Text(value, style: AppTextTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
