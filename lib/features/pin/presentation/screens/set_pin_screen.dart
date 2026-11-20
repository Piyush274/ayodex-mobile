import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ayodex/core/constants/app_colors.dart';
import 'package:ayodex/core/constants/app_dimensions.dart';
import 'package:ayodex/core/theme/text_theme.dart';
import 'package:ayodex/core/widgets/app_button.dart';
import 'package:ayodex/core/widgets/app_text_field.dart';
import '../controllers/pin_controller.dart';

class SetPinScreen extends ConsumerStatefulWidget {
  const SetPinScreen({super.key});

  @override
  ConsumerState<SetPinScreen> createState() => _SetPinScreenState();
}

class _SetPinScreenState extends ConsumerState<SetPinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _pinController = TextEditingController();
  final _pinConfirmController = TextEditingController();
  final _authenticatorController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _pinController.dispose();
    _pinConfirmController.dispose();
    _authenticatorController.dispose();
    super.dispose();
  }

  Future<void> _handleSetPin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await ref.read(pinControllerProvider.notifier).setPin(
          password: _passwordController.text,
          pin: _pinController.text,
          pinConfirmation: _pinConfirmController.text,
          authenticatorCode: _authenticatorController.text.trim().isEmpty
              ? null
              : _authenticatorController.text.trim(),
        );

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Transaction PIN configured successfully!')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pinState = ref.watch(pinControllerProvider);
    final requires2fa = pinState.status?.requires2fa ?? false;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Set Transaction PIN'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.p24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.base.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.pin_outlined,
                      size: 38,
                      color: AppColors.base,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.p20),
                Text(
                  'Create Your PIN',
                  textAlign: TextAlign.center,
                  style: AppTextTheme.displayLarge.copyWith(fontSize: 24),
                ),
                const SizedBox(height: AppDimensions.p8),
                const Text(
                  'Your 4 to 6 digit PIN is required to authorize all future transfers and withdrawals.',
                  textAlign: TextAlign.center,
                  style: AppTextTheme.bodyMedium,
                ),
                const SizedBox(height: AppDimensions.p24),

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

                // Account Password
                AppTextField(
                  key: const Key('set_pin_account_password'),
                  controller: _passwordController,
                  label: 'Account Password',
                  hint: 'Enter your current account password',
                  isPassword: true,
                  prefixIcon: const Icon(Icons.lock_outline,
                      size: 20, color: AppColors.textMuted),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Account password is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.p16),

                // New PIN
                AppTextField(
                  key: const Key('set_pin_field'),
                  controller: _pinController,
                  label: 'New PIN (4-6 digits)',
                  hint: '0000',
                  keyboardType: TextInputType.number,
                  isPassword: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  prefixIcon: const Icon(Icons.pin_outlined,
                      size: 20, color: AppColors.textMuted),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'PIN is required';
                    }
                    if (value.length < 4 || value.length > 6) {
                      return 'PIN must be between 4 and 6 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.p16),

                // Confirm PIN
                AppTextField(
                  key: const Key('set_pin_confirm_field'),
                  controller: _pinConfirmController,
                  label: 'Confirm PIN',
                  hint: '0000',
                  keyboardType: TextInputType.number,
                  isPassword: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  prefixIcon: const Icon(Icons.lock_reset_outlined,
                      size: 20, color: AppColors.textMuted),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'PIN confirmation is required';
                    }
                    if (value != _pinController.text) {
                      return 'PINs do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.p16),

                // 2FA Code if required
                if (requires2fa) ...[
                  AppTextField(
                    key: const Key('set_pin_2fa_code'),
                    controller: _authenticatorController,
                    label: '2FA Authenticator Code',
                    hint: '000000',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    prefixIcon: const Icon(Icons.security,
                        size: 20, color: AppColors.textMuted),
                    validator: (value) {
                      if (requires2fa && (value == null || value.isEmpty)) {
                        return '2FA code is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimensions.p16),
                ],

                const SizedBox(height: AppDimensions.p16),
                AppButton(
                  text: 'Save Transaction PIN',
                  isLoading: pinState.isLoading,
                  onPressed: _handleSetPin,
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
