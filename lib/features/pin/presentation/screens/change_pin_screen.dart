import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ayodex/core/constants/app_colors.dart';
import 'package:ayodex/core/constants/app_dimensions.dart';
import 'package:ayodex/core/theme/text_theme.dart';
import 'package:ayodex/core/widgets/app_button.dart';
import 'package:ayodex/core/widgets/app_text_field.dart';
import '../controllers/pin_controller.dart';

class ChangePinScreen extends ConsumerStatefulWidget {
  const ChangePinScreen({super.key});

  @override
  ConsumerState<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends ConsumerState<ChangePinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _currentPinController = TextEditingController();
  final _newPinController = TextEditingController();
  final _newPinConfirmController = TextEditingController();
  final _authenticatorController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _currentPinController.dispose();
    _newPinController.dispose();
    _newPinConfirmController.dispose();
    _authenticatorController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await ref.read(pinControllerProvider.notifier).changePin(
          password: _passwordController.text,
          currentPin: _currentPinController.text,
          pin: _newPinController.text,
          pinConfirmation: _newPinConfirmController.text,
          authenticatorCode: _authenticatorController.text.trim().isEmpty
              ? null
              : _authenticatorController.text.trim(),
        );

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction PIN updated successfully!')),
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
        title: const Text('Change Transaction PIN'),
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
                      color: AppColors.info.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_reset,
                      size: 38,
                      color: AppColors.info,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.p20),
                Text(
                  'Change Security PIN',
                  textAlign: TextAlign.center,
                  style: AppTextTheme.displayLarge.copyWith(fontSize: 24),
                ),
                const SizedBox(height: AppDimensions.p8),
                const Text(
                  'Enter your current account credentials and specify your new 4 to 6 digit transaction PIN.',
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
                  key: const Key('change_pin_password'),
                  controller: _passwordController,
                  label: 'Account Password',
                  hint: 'Enter your account password',
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

                // Current PIN
                AppTextField(
                  key: const Key('change_pin_current'),
                  controller: _currentPinController,
                  label: 'Current PIN',
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
                      return 'Current PIN is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.p16),

                // New PIN
                AppTextField(
                  key: const Key('change_pin_new'),
                  controller: _newPinController,
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
                      return 'New PIN is required';
                    }
                    if (value.length < 4 || value.length > 6) {
                      return 'PIN must be between 4 and 6 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.p16),

                // Confirm New PIN
                AppTextField(
                  key: const Key('change_pin_confirm'),
                  controller: _newPinConfirmController,
                  label: 'Confirm New PIN',
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
                    if (value != _newPinController.text) {
                      return 'New PINs do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.p16),

                // 2FA Code if required
                if (requires2fa) ...[
                  AppTextField(
                    key: const Key('change_pin_2fa_code'),
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
                  text: 'Update PIN',
                  isLoading: pinState.isLoading,
                  onPressed: _handleChangePin,
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
