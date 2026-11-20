import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ayodex/core/constants/app_colors.dart';
import 'package:ayodex/core/constants/app_dimensions.dart';
import 'package:ayodex/core/theme/text_theme.dart';
import 'package:ayodex/core/widgets/custom_card.dart';
import 'package:ayodex/core/widgets/status_badge.dart';
import 'package:ayodex/features/withdraw/data/models/withdrawal_model.dart';
import 'package:ayodex/features/withdraw/presentation/controllers/withdraw_controller.dart';

class WithdrawHistoryScreen extends ConsumerStatefulWidget {
  const WithdrawHistoryScreen({super.key});

  @override
  ConsumerState<WithdrawHistoryScreen> createState() => _WithdrawHistoryScreenState();
}

class _WithdrawHistoryScreenState extends ConsumerState<WithdrawHistoryScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(withdrawControllerProvider.notifier).loadWithdrawHistory(refresh: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    ref.read(withdrawControllerProvider.notifier).loadWithdrawHistory(refresh: true, search: query.trim());
  }

  void _showDetailSheet(WithdrawalModel item) {
    final dateStr = item.createdAt != null
        ? DateFormat('MMM dd, yyyy • hh:mm a').format(item.createdAt!)
        : 'N/A';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppDimensions.p20),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusLarge)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Withdrawal Details', style: AppTextTheme.headingMedium.copyWith(fontSize: 18)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
              ],
            ),
            const SizedBox(height: 12),
            _buildRow('Status', ''),
            _buildRow('Requested Amount', '${item.amount} ${item.currency?.curSym ?? ''}'),
            _buildRow('Transaction Charge', '${item.charge} ${item.currency?.curSym ?? ''}'),
            _buildRow('Final Amount Received', '${item.finalAmount} ${item.currency?.curSym ?? ''}'),
            _buildRow('Exchange Rate', '1 : ${item.rate}'),
            _buildRow('Date Submitted', dateStr),
            if (item.adminFeedback != null && item.adminFeedback!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(AppDimensions.p12),
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Admin Feedback / Reason:', style: AppTextTheme.caption.copyWith(fontWeight: FontWeight.bold, color: AppColors.danger)),
                    const SizedBox(height: 4),
                    Text(item.adminFeedback!, style: AppTextTheme.bodyMedium.copyWith(color: AppColors.danger)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextTheme.bodyMedium.copyWith(color: AppColors.body)),
          Text(value, style: AppTextTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(withdrawControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Withdrawal Log'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New Withdrawal',
            onPressed: () => context.push('/withdraw'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Input
          Padding(
            padding: const EdgeInsets.all(AppDimensions.p16),
            child: TextField(
              controller: _searchController,
              onSubmitted: _onSearch,
              decoration: InputDecoration(
                hintText: 'Search by reference...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.surfaceSubtle,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ),
          const Divider(height: 1),

          // List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(withdrawControllerProvider.notifier).loadWithdrawHistory(refresh: true);
              },
              child: state.isLoading && state.history.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : state.history.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.account_balance_wallet_outlined, size: 64, color: AppColors.textMuted),
                              const SizedBox(height: 16),
                              const Text('No withdrawals found', style: AppTextTheme.bodyLarge),
                              const SizedBox(height: 8),
                              Text('Your past withdrawals will appear here', style: AppTextTheme.caption.copyWith(color: AppColors.textMuted)),
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
                                    ref.read(withdrawControllerProvider.notifier).loadWithdrawHistory();
                                  },
                                  child: const Text('Load More'),
                                ),
                              );
                            }

                            final item = state.history[index];
                            final dateStr = item.createdAt != null
                                ? DateFormat('MMM dd, yyyy • hh:mm a').format(item.createdAt!)
                                : 'N/A';

                            final Color statusColor = item.isSuccess
                                ? AppColors.success
                                : item.isRejected
                                    ? AppColors.danger
                                    : AppColors.warning;

                            return CustomCard(
                              onTap: () => _showDetailSheet(item),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Withdrawal #${item.id}',
                                        style: AppTextTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      StatusBadge(
                                        label: item.statusDisplay,
                                        color: statusColor,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
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
                                        '- ${item.amount} ${item.currency?.curSym ?? ''}',
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.base),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
