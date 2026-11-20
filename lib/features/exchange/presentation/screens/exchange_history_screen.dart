import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ayodex/core/constants/app_colors.dart';
import 'package:ayodex/core/constants/app_dimensions.dart';
import 'package:ayodex/core/theme/text_theme.dart';
import 'package:ayodex/core/widgets/status_badge.dart';
import '../controllers/exchange_controller.dart';
import 'package:ayodex/features/exchange/data/models/exchange_model.dart';

class ExchangeHistoryScreen extends ConsumerStatefulWidget {
  final String? initialScope;

  const ExchangeHistoryScreen({super.key, this.initialScope});

  @override
  ConsumerState<ExchangeHistoryScreen> createState() => _ExchangeHistoryScreenState();
}

class _ExchangeHistoryScreenState extends ConsumerState<ExchangeHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _scopes = ['all', 'pending', 'approved', 'refunded', 'cancel'];

  @override
  void initState() {
    super.initState();
    int initialIndex = 0;
    if (widget.initialScope != null) {
      final idx = _scopes.indexOf(widget.initialScope!.toLowerCase());
      if (idx != -1) initialIndex = idx;
    }

    _tabController = TabController(length: _scopes.length, vsync: this, initialIndex: initialIndex);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        final scope = _scopes[_tabController.index];
        ref.read(exchangeControllerProvider.notifier).loadHistory(
          scope: scope == 'all' ? null : scope,
        );
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final scope = _scopes[initialIndex];
      ref.read(exchangeControllerProvider.notifier).loadHistory(
        scope: scope == 'all' ? null : scope,
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
    final state = ref.watch(exchangeControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Exchange History'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.base,
          unselectedLabelColor: AppColors.heading,
          indicatorColor: AppColors.base,
          tabs: _scopes.map((s) => Tab(text: s.toUpperCase())).toList(),
        ),
      ),
      body: SafeArea(
        child: state.isLoading && state.history.isEmpty
            ? const Center(child: CircularProgressIndicator(color: AppColors.base))
            : state.history.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.swap_horiz_rounded, size: 54, color: AppColors.textMuted),
                        const SizedBox(height: 12),
                        Text('No exchanges in this category', style: AppTextTheme.headingMedium.copyWith(color: AppColors.textMuted)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(AppDimensions.p16),
                    itemCount: state.history.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppDimensions.p12),
                    itemBuilder: (context, index) {
                      final item = state.history[index];
                      final statusColor = _getStatusColor(item.status);

                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                          side: const BorderSide(color: AppColors.border),
                        ),
                        color: AppColors.surface,
                        child: InkWell(
                          onTap: () => context.push('/exchange/details?id=${item.exchangeId}'),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                          child: Padding(
                            padding: const EdgeInsets.all(AppDimensions.p16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Order #${item.exchangeId}',
                                      style: AppTextTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    StatusBadge(
                                      label: _getStatusText(item.status),
                                      color: statusColor,
                                    ),
                                  ],
                                ),
                                const Divider(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Send', style: AppTextTheme.caption),
                                        Text('${item.sendingAmount}', style: AppTextTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    const Icon(Icons.arrow_forward_rounded, color: AppColors.textMuted, size: 20),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text('Receive', style: AppTextTheme.caption),
                                        Text('${item.totalReceivedAmount}', style: AppTextTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.success)),
                                      ],
                                    ),
                                  ],
                                ),
                                if (item.createdAt != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    DateFormat('dd MMM yyyy, HH:mm').format(item.createdAt!),
                                    style: AppTextTheme.caption,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
