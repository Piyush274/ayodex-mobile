import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ayodex/core/constants/app_colors.dart';
import 'package:ayodex/core/constants/app_dimensions.dart';
import 'package:ayodex/core/theme/text_theme.dart';
import 'package:ayodex/core/widgets/app_button.dart';
import 'package:ayodex/core/widgets/custom_card.dart';
import '../controllers/transfer_controller.dart';
import '../widgets/transfer_pin_modal.dart';

class TransferQuotePreviewScreen extends ConsumerStatefulWidget {
  final String quoteId;

  const TransferQuotePreviewScreen({super.key, required this.quoteId});

  @override
  ConsumerState<TransferQuotePreviewScreen> createState() => _TransferQuotePreviewScreenState();
}

class _TransferQuotePreviewScreenState extends ConsumerState<TransferQuotePreviewScreen> {
  Timer? _countdownTimer;
  int _secondsRemaining = 120;
  bool _isExpired = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    final quote = ref.read(transferControllerProvider).quote;
    if (quote != null) {
      final diff = quote.expiresAt.difference(DateTime.now()).inSeconds;
      _secondsRemaining = diff > 0 ? diff : 0;
      _isExpired = _secondsRemaining <= 0;
    }

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
          if (_secondsRemaining <= 0) {
            _isExpired = true;
            timer.cancel();
          }
        });
      } else {
        setState(() => _isExpired = true);
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _openPinModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransferPinModal(
        quoteId: widget.quoteId,
        onTransferCompleted: (transfer) {
          context.go('/transfer/processing/${transfer.trx}');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transferControllerProvider);
    final quote = state.quote;

    if (quote == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Transfer Quote')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline, size: 48, color: AppColors.textMuted),
              const SizedBox(height: 16),
              const Text('Quote details not found', style: AppTextTheme.bodyLarge),
              const SizedBox(height: 16),
              AppButton(
                text: 'Back to Transfer',
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
      );
    }

    final formattedMinutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final formattedSeconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    final progress = _secondsRemaining / (quote.validitySeconds > 0 ? quote.validitySeconds : 120);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer Preview'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Expiry Countdown Banner
            CustomCard(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isExpired ? Icons.timer_off : Icons.timer,
                            color: _isExpired ? AppColors.danger : AppColors.base,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isExpired ? 'Quote Expired' : 'Guaranteed Rate & Fees',
                            style: AppTextTheme.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _isExpired ? AppColors.danger : AppColors.heading,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _isExpired ? '00:00' : '$formattedMinutes:$formattedSeconds',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: _isExpired ? AppColors.danger : AppColors.base,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _isExpired ? 0.0 : progress.clamp(0.0, 1.0),
                      backgroundColor: AppColors.surfaceSubtle,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _isExpired ? AppColors.danger : AppColors.base,
                      ),
                      minHeight: 6,
                    ),
                  ),
                  if (_isExpired) ...[
                    const SizedBox(height: 12),
                    Text(
                      'This quote has expired. Please go back to calculate a fresh transfer quote.',
                      style: AppTextTheme.caption.copyWith(color: AppColors.danger),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Beneficiary Details Card
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Recipient Information', style: AppTextTheme.headingMedium.copyWith(fontSize: 16)),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  _buildDetailRow('Account Name', quote.accountName ?? 'N/A'),
                  const SizedBox(height: 8),
                  _buildDetailRow('Bank / Provider', quote.bankCode?.toUpperCase() ?? 'Bank'),
                  const SizedBox(height: 8),
                  _buildDetailRow('Account Number', quote.accountMasked ?? '**********'),
                  const SizedBox(height: 8),
                  _buildDetailRow('Destination Type', quote.destinationType == 'opay_wallet' ? 'OPay Wallet' : 'Bank Account'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Financial Summary Card
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Fee & Debit Breakdown', style: AppTextTheme.headingMedium.copyWith(fontSize: 16)),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  _buildDetailRow('Transfer Amount', '₦${quote.amount.toStringAsFixed(2)}'),
                  const SizedBox(height: 8),
                  _buildDetailRow('Provider Payout Fee', '₦${quote.providerFee.toStringAsFixed(2)}'),
                  const SizedBox(height: 8),
                  _buildDetailRow('Platform Service Fee', '₦${quote.serviceFee.toStringAsFixed(2)}'),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Wallet Debit', style: AppTextTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                      Text(
                        '₦${quote.totalDebit.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.base,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Confirm CTA
            AppButton(
              text: _isExpired ? 'Quote Expired - Recalculate' : 'Confirm Transfer',
              onPressed: _isExpired
                  ? () => context.pop()
                  : _openPinModal,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextTheme.bodyMedium.copyWith(color: AppColors.body)),
        Flexible(
          child: Text(
            value,
            style: AppTextTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
