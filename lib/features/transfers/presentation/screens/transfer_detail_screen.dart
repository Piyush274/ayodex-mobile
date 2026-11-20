import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ayodex/core/constants/app_colors.dart';
import 'package:ayodex/core/constants/app_dimensions.dart';
import 'package:ayodex/core/theme/text_theme.dart';
import 'package:ayodex/core/widgets/custom_card.dart';
import 'package:ayodex/core/widgets/status_badge.dart';
import 'package:ayodex/features/transfers/data/models/transfer_model.dart';
import 'package:ayodex/features/transfers/data/repositories/transfer_repository.dart';
import 'package:ayodex/features/transfers/presentation/widgets/transfer_status_timeline.dart';

class TransferDetailScreen extends ConsumerStatefulWidget {
  final String trx;

  const TransferDetailScreen({super.key, required this.trx});

  @override
  ConsumerState<TransferDetailScreen> createState() => _TransferDetailScreenState();
}

class _TransferDetailScreenState extends ConsumerState<TransferDetailScreen> {
  TransferModel? _transfer;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final transfer = await ref.read(transferRepositoryProvider).getTransferDetail(widget.trx);
      if (mounted) {
        setState(() {
          _transfer = transfer;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer Receipt'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share Reference',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: 'AYODEX Transfer Ref: ${widget.trx}'));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Transfer reference copied to clipboard!')),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
                      const SizedBox(height: 16),
                      Text('Error loading transfer receipt', style: AppTextTheme.bodyLarge),
                      const SizedBox(height: 8),
                      Text(_errorMessage!, style: AppTextTheme.caption.copyWith(color: AppColors.textMuted)),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _loadDetail, child: const Text('Retry')),
                    ],
                  ),
                )
              : _transfer == null
                  ? const Center(child: Text('Transfer not found'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(AppDimensions.p16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header Card
                          CustomCard(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Transfer Amount', style: AppTextTheme.caption.copyWith(color: AppColors.textMuted)),
                                    StatusBadge(
                                      label: _transfer!.statusDisplay,
                                      color: _transfer!.isSuccess
                                          ? AppColors.success
                                          : _transfer!.isFailed
                                              ? AppColors.danger
                                              : AppColors.warning,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '₦${_transfer!.amount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.base,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceSubtle,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('TRX: ${widget.trx}', style: AppTextTheme.caption.copyWith(fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 6),
                                      InkWell(
                                        onTap: () {
                                          Clipboard.setData(ClipboardData(text: widget.trx));
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('TRX copied to clipboard')),
                                          );
                                        },
                                        child: const Icon(Icons.copy, size: 14, color: AppColors.base),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Beneficiary and Transfer Metadata
                          CustomCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Transfer Details', style: AppTextTheme.headingMedium.copyWith(fontSize: 16)),
                                const SizedBox(height: 12),
                                const Divider(height: 1),
                                const SizedBox(height: 12),
                                _buildDetailRow('Recipient Name', _transfer!.accountName ?? 'N/A'),
                                const SizedBox(height: 8),
                                _buildDetailRow('Bank / Provider', _transfer!.bankCode?.toUpperCase() ?? 'Bank'),
                                const SizedBox(height: 8),
                                _buildDetailRow('Account Masked', _transfer!.accountMasked ?? '**********'),
                                const SizedBox(height: 8),
                                _buildDetailRow('Destination Type', _transfer!.destinationType == 'opay_wallet' ? 'OPay Wallet' : 'Bank Account'),
                                const SizedBox(height: 8),
                                _buildDetailRow('Provider Fee', '₦${_transfer!.providerFee.toStringAsFixed(2)}'),
                                const SizedBox(height: 8),
                                _buildDetailRow('Service Fee', '₦${_transfer!.serviceFee.toStringAsFixed(2)}'),
                                const SizedBox(height: 8),
                                _buildDetailRow('Total Debited', '₦${_transfer!.totalDebit.toStringAsFixed(2)}'),
                                if (_transfer!.createdAt != null) ...[
                                  const SizedBox(height: 8),
                                  _buildDetailRow(
                                    'Initiated At',
                                    DateFormat('MMM dd, yyyy • hh:mm:ss a').format(_transfer!.createdAt!),
                                  ),
                                ],
                                if (_transfer!.settledAt != null) ...[
                                  const SizedBox(height: 8),
                                  _buildDetailRow(
                                    'Settled At',
                                    DateFormat('MMM dd, yyyy • hh:mm:ss a').format(_transfer!.settledAt!),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Lifecycle Timeline
                          CustomCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Status Timeline', style: AppTextTheme.headingMedium.copyWith(fontSize: 16)),
                                const SizedBox(height: 16),
                                TransferStatusTimeline(
                                  events: _transfer!.events,
                                  currentStatus: _transfer!.status,
                                ),
                              ],
                            ),
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
