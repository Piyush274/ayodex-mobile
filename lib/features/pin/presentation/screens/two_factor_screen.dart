import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayodex/core/constants/app_colors.dart';
import 'package:ayodex/core/constants/app_dimensions.dart';
import 'package:ayodex/core/theme/text_theme.dart';
import 'package:ayodex/core/widgets/app_button.dart';
import 'package:ayodex/core/widgets/custom_card.dart';
import 'package:ayodex/core/widgets/status_badge.dart';
import 'package:ayodex/features/auth/presentation/controllers/auth_controller.dart';
import 'package:ayodex/features/auth/presentation/widgets/otp_pin_input.dart';
import '../controllers/pin_controller.dart';

class TwoFactorScreen extends ConsumerStatefulWidget {
  const TwoFactorScreen({super.key});

  @override
  ConsumerState<TwoFactorScreen> createState() => _TwoFactorScreenState();
}

class _TwoFactorScreenState extends ConsumerState<TwoFactorScreen> {
  String _otpCode = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pinControllerProvider.notifier).fetchTwoFactor();
    });
  }

  Future<void> _handleEnable2fa() async {
    final twoFactor = ref.read(pinControllerProvider).twoFactor;
    if (twoFactor == null || twoFactor.secret.isEmpty) return;

    if (_otpCode.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Please enter all 6 digits of the authenticator code')),
      );
      return;
    }

    final success =
        await ref.read(pinControllerProvider.notifier).enableTwoFactor(
              key: twoFactor.secret,
              code: _otpCode,
            );

    if (mounted && success) {
      await ref.read(authControllerProvider.notifier).initialize();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Two-factor authentication enabled successfully!')),
      );
      setState(() => _otpCode = '');
    }
  }

  Future<void> _handleDisable2fa() async {
    if (_otpCode.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Please enter all 6 digits of the authenticator code')),
      );
      return;
    }

    final success = await ref
        .read(pinControllerProvider.notifier)
        .disableTwoFactor(_otpCode);

    if (mounted && success) {
      await ref.read(authControllerProvider.notifier).initialize();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Two-factor authentication disabled successfully!')),
      );
      setState(() => _otpCode = '');
    }
  }

  @override
  Widget build(BuildContext context) {
    final pinState = ref.watch(pinControllerProvider);
    final twoFactor = pinState.twoFactor;
    final isEnabled = twoFactor?.isEnabled ?? false;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Two-Factor Authentication'),
        elevation: 0,
      ),
      body: SafeArea(
        child: pinState.isLoading && twoFactor == null
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.base))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.p20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Error Banner
                    if (pinState.errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.p12),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusMedium),
                          border: Border.all(
                              color: AppColors.danger.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.error_outline,
                                color: AppColors.danger, size: 20),
                            const SizedBox(width: AppDimensions.p8),
                            Expanded(
                              child: Text(
                                pinState.errorMessage!,
                                style: AppTextTheme.bodyMedium
                                    .copyWith(color: AppColors.danger),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimensions.p16),
                    ],

                    // Success Banner
                    if (pinState.successMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.p12),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.12),
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusMedium),
                          border: Border.all(
                              color: AppColors.success.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline,
                                color: AppColors.success, size: 20),
                            const SizedBox(width: AppDimensions.p8),
                            Expanded(
                              child: Text(
                                pinState.successMessage!,
                                style: AppTextTheme.bodyMedium
                                    .copyWith(color: AppColors.success),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimensions.p16),
                    ],

                    if (!isEnabled) ...[
                      // Enable 2FA Setup Flow
                      CustomCard(
                        title: 'Add Your Account',
                        trailing: const StatusBadge(
                          label: 'Disabled',
                          color: AppColors.warning,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Use Google Authenticator to add an extra layer of security. Scan the QR code or manually enter the setup key below.',
                              style: AppTextTheme.bodyMedium,
                            ),
                            const SizedBox(height: AppDimensions.p20),

                            // Setup Key Box
                            Text(
                              'Setup Key',
                              style: AppTextTheme.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.heading,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.p8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusMedium),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: SelectableText(
                                      twoFactor?.secret ?? 'Generating...',
                                      style: AppTextTheme.bodyLarge.copyWith(
                                        fontFamily: 'monospace',
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.copy,
                                        size: 20, color: AppColors.base),
                                    tooltip: 'Copy Key',
                                    onPressed:
                                        twoFactor?.secret.isNotEmpty == true
                                            ? () {
                                                Clipboard.setData(ClipboardData(
                                                    text: twoFactor!.secret));
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                      content: Text(
                                                          'Secret key copied to clipboard')),
                                                );
                                              }
                                            : null,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'If entering manually, type the key into Google Authenticator without spaces.',
                              style: AppTextTheme.caption,
                            ),
                            const SizedBox(height: AppDimensions.p24),

                            // Enter Code to Enable
                            Text(
                              'Enter 6-digit Authenticator Code',
                              style: AppTextTheme.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.heading,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.p12),
                            OtpPinInput(
                              length: 6,
                              onChanged: (val) =>
                                  setState(() => _otpCode = val),
                              onCompleted: (val) {
                                setState(() => _otpCode = val);
                                _handleEnable2fa();
                              },
                            ),
                            const SizedBox(height: AppDimensions.p24),
                            AppButton(
                              text: 'Enable 2FA',
                              isLoading: pinState.isLoading,
                              onPressed: _otpCode.length == 6
                                  ? _handleEnable2fa
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Disable 2FA Flow
                      CustomCard(
                        title: 'Two-Factor Authentication',
                        trailing: const StatusBadge(
                          label: 'Active',
                          color: AppColors.success,
                          icon: Icons.check_circle,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Your account is currently protected with Google Authenticator 2FA. To disable it, enter a 6-digit code from your app.',
                              style: AppTextTheme.bodyMedium,
                            ),
                            const SizedBox(height: AppDimensions.p24),
                            Text(
                              'Enter Authenticator Code',
                              style: AppTextTheme.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.heading,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.p12),
                            OtpPinInput(
                              length: 6,
                              onChanged: (val) =>
                                  setState(() => _otpCode = val),
                              onCompleted: (val) {
                                setState(() => _otpCode = val);
                                _handleDisable2fa();
                              },
                            ),
                            const SizedBox(height: AppDimensions.p24),
                            AppButton(
                              text: 'Disable 2FA',
                              variant: AppButtonVariant.outline,
                              isLoading: pinState.isLoading,
                              onPressed: _otpCode.length == 6
                                  ? _handleDisable2fa
                                  : null,
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
