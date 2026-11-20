import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ayodex/core/constants/app_colors.dart';
import 'package:ayodex/core/constants/app_dimensions.dart';
import 'package:ayodex/core/theme/text_theme.dart';
import 'package:ayodex/core/widgets/app_button.dart';
import 'package:ayodex/core/widgets/custom_card.dart';
import 'package:ayodex/core/widgets/status_badge.dart';
import '../controllers/pin_controller.dart';

class PinStatusScreen extends ConsumerStatefulWidget {
  const PinStatusScreen({super.key});

  @override
  ConsumerState<PinStatusScreen> createState() => _PinStatusScreenState();
}

class _PinStatusScreenState extends ConsumerState<PinStatusScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pinControllerProvider.notifier).fetchPinStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pinState = ref.watch(pinControllerProvider);
    final status = pinState.status;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Security & PIN'),
        elevation: 0,
      ),
      body: SafeArea(
        child: pinState.isLoading && status == null
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.base))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.p20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Lockout Warning Alert
                    if (status?.isLocked == true) ...[
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.p16),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withValues(alpha: 0.12),
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusMedium),
                          border: Border.all(
                              color: AppColors.danger.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.lock_clock_outlined,
                                color: AppColors.danger, size: 28),
                            const SizedBox(width: AppDimensions.p12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'PIN Temporarily Locked',
                                    style: AppTextTheme.headingMedium.copyWith(
                                      color: AppColors.danger,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Your transaction PIN has been temporarily locked due to excessive incorrect attempts. It will unlock automatically in ${status!.lockoutRemainingMinutes} minute(s).',
                                    style: AppTextTheme.bodyMedium
                                        .copyWith(color: AppColors.danger),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimensions.p20),
                    ],

                    // Transaction PIN Management Card
                    CustomCard(
                      title: 'Transaction PIN',
                      trailing: StatusBadge(
                        label:
                            status?.hasPin == true ? 'Configured' : 'Not Set',
                        color: status?.hasPin == true
                            ? AppColors.success
                            : AppColors.warning,
                        icon: status?.hasPin == true
                            ? Icons.check_circle
                            : Icons.warning_amber_rounded,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            status?.hasPin == true
                                ? 'Your 4 to 6 digit security PIN protects all withdrawals, exchanges, and transfer authorizations.'
                                : 'A Transaction PIN is required to authorize sensitive financial operations such as withdrawals and transfers.',
                            style: AppTextTheme.bodyMedium,
                          ),
                          const SizedBox(height: AppDimensions.p20),
                          if (status?.hasPin == true) ...[
                            AppButton(
                              text: 'Change Transaction PIN',
                              onPressed: status?.isLocked == true
                                  ? null
                                  : () => context.push('/security/change-pin'),
                            ),
                          ] else ...[
                            AppButton(
                              text: 'Set Transaction PIN',
                              onPressed: status?.isLocked == true
                                  ? null
                                  : () => context.push('/security/set-pin'),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.p20),

                    // Two-Factor Authentication Card
                    CustomCard(
                      title: 'Two-Factor Authentication',
                      trailing: const Icon(Icons.chevron_right,
                          color: AppColors.textMuted),
                      onTap: () => context.push('/security/2fa'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Add an extra layer of defense using Google Authenticator codes for logins and transactions.',
                            style: AppTextTheme.bodyMedium,
                          ),
                          const SizedBox(height: AppDimensions.p12),
                          Row(
                            children: [
                              Text(
                                'Manage 2FA Settings',
                                style: AppTextTheme.bodyMedium.copyWith(
                                  color: AppColors.base,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_forward,
                                  size: 14, color: AppColors.base),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
