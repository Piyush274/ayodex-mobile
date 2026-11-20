import 'package:flutter/material.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ayodex/core/constants/app_colors.dart';
import 'package:ayodex/core/constants/app_dimensions.dart';
import 'package:ayodex/core/theme/text_theme.dart';
import 'package:ayodex/features/auth/presentation/controllers/auth_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/exchange_summary_row.dart';
import '../widgets/recent_activity_list.dart';
import '../widgets/wallet_balance_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardControllerProvider.notifier).loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;
    final dashboardState = ref.watch(dashboardControllerProvider);
    final data = dashboardState.data;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.base.withOpacity(0.15),
              child: Text(
                user != null && user.firstname.isNotEmpty ? user.firstname[0].toUpperCase() : 'A',
                style: const TextStyle(color: AppColors.base, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: AppDimensions.p12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user != null ? 'Hello, ${user.firstname}' : 'Welcome Back',
                  style: AppTextTheme.headingMedium.copyWith(fontSize: 16),
                ),
                Text(
                  user != null ? '@${user.username}' : '',
                  style: AppTextTheme.caption,
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: AppColors.heading),
            tooltip: 'Transactions',
            onPressed: () => context.push('/transactions'),
          ),
          IconButton(
            icon: const Icon(Icons.security_rounded, color: AppColors.heading),
            tooltip: 'Security & PIN',
            onPressed: () => context.push('/security/pin'),
          ),
        ],
        elevation: 0,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.base,
          onRefresh: () async {
            await ref.read(dashboardControllerProvider.notifier).loadDashboard();
            await ref.read(authControllerProvider.notifier).initialize();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppDimensions.p16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // KYC Warning Banner if unverified
                if (user != null && !user.isKycVerified) ...[
                  InkWell(
                    onTap: () => context.push('/kyc'),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: user.isKycPending ? AppColors.warning.withOpacity(0.12) : AppColors.danger.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                        border: Border.all(
                          color: user.isKycPending ? AppColors.warning : AppColors.danger,
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            user.isKycPending ? Icons.schedule : Icons.warning_amber_rounded,
                            color: user.isKycPending ? AppColors.warning : AppColors.danger,
                            size: 20,
                          ),
                          const SizedBox(width: AppDimensions.p8),
                          Expanded(
                            child: Text(
                              user.isKycPending
                                  ? 'KYC Under Review — Compliance checks in progress'
                                  : 'KYC Required — Verify identity to unlock limits',
                              style: AppTextTheme.bodyMedium.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: user.isKycPending ? AppColors.warning : AppColors.danger,
                              ),
                            ),
                          ),
                          const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.p16),
                ],

                // Wallet Balance Card
                WalletBalanceCard(
                  balance: data?.balance ?? user?.balance ?? Decimal.zero,
                  currencySymbol: 'USD',
                  onExchangeTap: () => context.push('/exchange/create'),
                  onTransferTap: () => context.push('/transfer/new'),
                  onWithdrawTap: () => context.push('/withdraw'),
                ),
                const SizedBox(height: AppDimensions.p20),

                // Exchange Summary Row (Approved, Pending, Refunded, Canceled)
                if (data != null) ...[
                  ExchangeSummaryRow(
                    exchangeCounts: data.exchangeCount,
                    onScopeSelected: (scope) => context.push('/exchange/history?scope=$scope'),
                  ),
                  const SizedBox(height: AppDimensions.p20),
                ],

                // Recent Activity
                RecentActivityList(
                  exchanges: data?.latestExchange ?? [],
                  onExchangeTap: (ex) => context.push('/exchange/track?id=${ex.exchangeId}'),
                ),
                const SizedBox(height: AppDimensions.p24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
