import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayodex/core/constants/app_colors.dart';
import 'package:ayodex/core/constants/app_dimensions.dart';
import 'package:ayodex/core/theme/text_theme.dart';
import '../controllers/transaction_controller.dart';
import '../widgets/transaction_card.dart';
import '../widgets/transaction_filter_sheet.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(transactionControllerProvider.notifier).fetchInitial();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        ref.read(transactionControllerProvider.notifier).fetchNextPage();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _openFilterSheet(List<String> availableRemarks, String? currentRemark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TransactionFilterSheet(
        availableRemarks: availableRemarks,
        initialRemark: currentRemark,
        onApply: (selectedRemark) {
          ref.read(transactionControllerProvider.notifier).setRemark(selectedRemark);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transactionControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Transaction History'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list_rounded,
              color: state.selectedRemark != null ? AppColors.base : AppColors.heading,
            ),
            tooltip: 'Filter Remark',
            onPressed: () => _openFilterSheet(state.availableRemarks, state.selectedRemark),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar & Filter Chips Header
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.p16,
                AppDimensions.p12,
                AppDimensions.p16,
                AppDimensions.p12,
              ),
              color: AppColors.surface,
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by transaction number...',
                      prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textMuted),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                ref.read(transactionControllerProvider.notifier).setSearchQuery(null);
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    onSubmitted: (val) {
                      ref.read(transactionControllerProvider.notifier).setSearchQuery(val.trim());
                    },
                  ),
                  const SizedBox(height: AppDimensions.p12),

                  // Plus / Minus Type Chips
                  Row(
                    children: [
                      _TypeFilterChip(
                        label: 'All',
                        isSelected: state.selectedType == null,
                        onTap: () => ref.read(transactionControllerProvider.notifier).setType(null),
                      ),
                      const SizedBox(width: 8),
                      _TypeFilterChip(
                        label: 'Money In (+)',
                        isSelected: state.selectedType == '+',
                        color: AppColors.success,
                        onTap: () => ref.read(transactionControllerProvider.notifier).setType('+'),
                      ),
                      const SizedBox(width: 8),
                      _TypeFilterChip(
                        label: 'Money Out (-)',
                        isSelected: state.selectedType == '-',
                        color: AppColors.danger,
                        onTap: () => ref.read(transactionControllerProvider.notifier).setType('-'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Transactions List
            Expanded(
              child: RefreshIndicator(
                color: AppColors.base,
                onRefresh: () async {
                  await ref.read(transactionControllerProvider.notifier).fetchInitial();
                },
                child: state.isLoading && state.transactions.isEmpty
                    ? const Center(child: CircularProgressIndicator(color: AppColors.base))
                    : state.transactions.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.receipt_long_outlined, size: 54, color: AppColors.textMuted),
                                const SizedBox(height: 12),
                                Text(
                                  'No transactions found',
                                  style: AppTextTheme.headingMedium.copyWith(color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(AppDimensions.p16),
                            itemCount: state.transactions.length + (state.isLoadingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == state.transactions.length) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: CircularProgressIndicator(color: AppColors.base, strokeWidth: 2),
                                  ),
                                );
                              }
                              final trx = state.transactions[index];
                              return TransactionCard(transaction: trx);
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _TypeFilterChip({
    required this.label,
    required this.isSelected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppColors.base;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.12) : AppColors.surfaceSubtle,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? activeColor : AppColors.border,
            width: isSelected ? 1.2 : 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? activeColor : AppColors.body,
          ),
        ),
      ),
    );
  }
}
