import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ayodex/core/constants/app_colors.dart';
import 'package:ayodex/core/constants/app_dimensions.dart';
import 'package:ayodex/core/theme/text_theme.dart';
import 'package:ayodex/core/widgets/app_button.dart';
import 'package:ayodex/core/widgets/custom_card.dart';
import 'package:ayodex/core/widgets/status_badge.dart';
import 'package:ayodex/features/auth/presentation/controllers/auth_controller.dart';
import '../controllers/kyc_controller.dart';

class KycStatusScreen extends ConsumerWidget {
  const KycStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;
    final kycState = ref.watch(kycControllerProvider);

    // Determine current status
    final isVerified = user?.isKycVerified == true || kycState.status == KycReviewStatus.verified;
    final isUnderReview = user?.isKycPending == true || kycState.status == KycReviewStatus.underReview;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('KYC Status'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.p24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isVerified) ...[
                // Verified Card
                CustomCard(
                  title: 'Verification Complete',
                  trailing: const StatusBadge(
                    label: 'Verified',
                    color: AppColors.success,
                    icon: Icons.check_circle,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.verified, size: 56, color: AppColors.success),
                      ),
                      const SizedBox(height: AppDimensions.p20),
                      Text(
                        'Your identity has been verified',
                        style: AppTextTheme.headingLarge.copyWith(fontSize: 22),
                      ),
                      const SizedBox(height: AppDimensions.p8),
                      const Text(
                        'Full account access is active. You can now execute currency exchanges, bank transfers, and withdrawals without limits.',
                        style: AppTextTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppDimensions.p24),
                      AppButton(
                        text: 'Go to Dashboard',
                        onPressed: () => context.go('/dashboard'),
                      ),
                    ],
                  ),
                ),
              ] else if (isUnderReview) ...[
                // Under Review Card
                CustomCard(
                  title: 'Documents Under Review',
                  trailing: const StatusBadge(
                    label: 'Under Review',
                    color: AppColors.warning,
                    icon: Icons.pending_outlined,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.schedule, size: 56, color: AppColors.warning),
                      ),
                      const SizedBox(height: AppDimensions.p20),
                      Text(
                        'Compliance Review in Progress',
                        style: AppTextTheme.headingLarge.copyWith(fontSize: 22),
                      ),
                      const SizedBox(height: AppDimensions.p8),
                      const Text(
                        'Your submitted documents are currently being reviewed by our compliance officers. Review typically takes 15 to 30 minutes.',
                        style: AppTextTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppDimensions.p24),
                      AppButton(
                        text: 'Back to Dashboard',
                        variant: AppButtonVariant.outline,
                        onPressed: () => context.go('/dashboard'),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Unverified / Rejected Card
                CustomCard(
                  title: 'Identity Verification Required',
                  trailing: const StatusBadge(
                    label: 'Unverified',
                    color: AppColors.danger,
                    icon: Icons.error_outline,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.shield_outlined, size: 56, color: AppColors.danger),
                      ),
                      const SizedBox(height: AppDimensions.p20),
                      Text(
                        'Verification Incomplete',
                        style: AppTextTheme.headingLarge.copyWith(fontSize: 22),
                      ),
                      const SizedBox(height: AppDimensions.p8),
                      const Text(
                        'Financial regulations require identity verification before participating in currency exchanges or making withdrawals.',
                        style: AppTextTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppDimensions.p24),
                      AppButton(
                        text: 'Submit Verification Documents',
                        onPressed: () => context.push('/kyc'),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
