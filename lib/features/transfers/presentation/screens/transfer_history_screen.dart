import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ayodex/core/constants/app_colors.dart';
import 'package:ayodex/core/constants/app_dimensions.dart';
import 'package:ayodex/core/theme/text_theme.dart';
import 'package:ayodex/core/widgets/custom_card.dart';
import 'package:ayodex/core/widgets/status_badge.dart';
import 'package:ayodex/features/transfers/data/models/transfer_model.dart';
import 'package:ayodex/features/transfers/presentation/controllers/transfer_controller.dart';

class TransferHistoryScreen extends ConsumerStatefulWidget {
  const TransferHistoryScreen({super.key});

  @override
  ConsumerState<TransferHistoryScreen> createState() => _TransferHistoryScreenState();
}

class _TransferHistoryScreenState extends ConsumerState<TransferHistoryScreen> {
  String _selectedStatus = 'all';
  final List<String> _statuses = ['all', 'processing', 'success', 'failed_refunded'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(transferControllerProvider.notifier).loadTransferHistory(refresh: true, status: _selectedStatus);
    });
  }

  void _onStatusFilterSelected(String status) {
    setState(() => _selectedStatus = status);
    ref.read(transferControllerProvider.notifier).loadTransferHistory(refresh: true, status: status);
  }

  String _filterLabel(String status) {
    switch (status) {
      case 'all':
        return 'All';
      case 'processing':
        return 'Processing';
      case 'success':
        return 'Completed';
      case 'failed_refunded':
        return 'Failed / Refunded';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transferControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New Transfer',
            onPressed: () => context.push('/transfer/new'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.p16, vertical: 12),
            child: Row(
              children: _statuses.map((status) {
                final isSelected = _selectedStatus == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(_filterLabel(status)),
                    selected: isSelected,
                    onSelected: (_) => _onStatusFilterSelected(status),
                    selectedColor: AppColors.baseLight.withOpacity(0.2),
                    checkmarkColor: AppColors.base,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.base : AppColors.body,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),

          // Transfers List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(transferControllerProvider.notifier).loadTransferHistory(
                  refresh: true,
                  status: _selectedStatus,
                );
              },
              child: state.isLoading && state.history.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : state.history.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.textMuted),
                              const SizedBox(height: 16),
                              const Text('No transfer history found', style: AppTextTheme.bodyLarge),
                              const SizedBox(height: 8),
                              Text(
                                'Your payout transfers will appear here',
                                style: AppTextTheme.caption.copyWith(color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(AppDimensions.p16),
                          itemCount: state.history.length + (state.hasMoreHistory ? 1 : 0),
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            if (index == state.history.length) {
                              return Center(
                                child: TextButton(
                                  onPressed: () {
                                    ref.read(transferControllerProvider.notifier).loadTransferHistory(
                                      status: _selectedStatus,
                                    );
                                  },
                                  child: const Text('Load More'),
                                ),
                              );
                            }

                            final transfer = state.history[index];
                            return _buildTransferCard(transfer);
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransferCard(TransferModel transfer) {
    final dateStr = transfer.createdAt != null
        ? DateFormat('MMM dd, yyyy • hh:mm a').format(transfer.createdAt!)
        : 'N/A';

    return CustomCard(
      onTap: () => context.push('/transfer/detail/${transfer.trx}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: transfer.destinationType == 'opay_wallet'
                        ? AppColors.baseLight.withOpacity(0.2)
                        : AppColors.surfaceSubtle,
                    child: Icon(
                      transfer.destinationType == 'opay_wallet'
                          ? Icons.account_balance_wallet
                          : Icons.account_balance,
                      size: 18,
                      color: AppColors.base,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transfer.accountName ?? 'Beneficiary',
                        style: AppTextTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${transfer.bankCode?.toUpperCase() ?? 'BANK'} • ${transfer.accountMasked ?? '***'}',
                        style: AppTextTheme.caption.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
              StatusBadge(
                label: transfer.statusDisplay,
                color: transfer.isSuccess
                    ? AppColors.success
                    : transfer.isFailed
                        ? AppColors.danger
                        : AppColors.warning,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateStr,
                style: AppTextTheme.caption.copyWith(color: AppColors.textMuted),
              ),
              Text(
                '- ₦${transfer.totalDebit.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: transfer.isFailed ? AppColors.textMuted : AppColors.heading,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
