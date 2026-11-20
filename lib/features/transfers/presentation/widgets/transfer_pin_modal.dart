import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayodex/core/constants/app_colors.dart';
import 'package:ayodex/core/constants/app_dimensions.dart';
import 'package:ayodex/core/theme/text_theme.dart';
import 'package:ayodex/core/widgets/app_button.dart';
import 'package:ayodex/core/widgets/app_text_field.dart';
import 'package:ayodex/features/auth/presentation/controllers/auth_controller.dart';
import 'package:ayodex/features/transfers/data/models/transfer_model.dart';
import 'package:ayodex/features/transfers/presentation/controllers/transfer_controller.dart';

class TransferPinModal extends ConsumerStatefulWidget {
  final String quoteId;
  final ValueChanged<TransferModel> onTransferCompleted;

  const TransferPinModal({
    super.key,
    required this.quoteId,
    required this.onTransferCompleted,
  });

  @override
  ConsumerState<TransferPinModal> createState() => _TransferPinModalState();
}

class _TransferPinModalState extends ConsumerState<TransferPinModal> {
  final _pinController = TextEditingController();
  final _twoFactorController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _errorMessage;

  @override
  void dispose() {
    _pinController.dispose();
    _twoFactorController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _errorMessage = null);

    final transfer = await ref.read(transferControllerProvider.notifier).confirmTransfer(
      pin: _pinController.text.trim(),
      twofactorCode: _twoFactorController.text.trim().isNotEmpty
          ? _twoFactorController.text.trim()
          : null,
    );

    if (!mounted) return;

    if (transfer != null) {
      Navigator.of(context).pop();
      widget.onTransferCompleted(transfer);
    } else {
      final error = ref.read(transferControllerProvider).errorMessage;
      setState(() {
        _errorMessage = error ?? 'Transfer confirmation failed. Please check your PIN.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final transferState = ref.watch(transferControllerProvider);
    final user = ref.watch(authControllerProvider).user;
    final requires2fa = user?.ts == 1;

    return Container(
      padding: EdgeInsets.only(
        top: AppDimensions.p20,
        left: AppDimensions.p20,
        right: AppDimensions.p20,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppDimensions.p20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusLarge)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Confirm Transfer',
                    style: AppTextTheme.headingMedium.copyWith(fontSize: 18),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your 4-digit transaction PIN to authorize this payout.',
                style: AppTextTheme.bodyMedium.copyWith(color: AppColors.body),
              ),
              const SizedBox(height: 20),

              // PIN Input
              AppTextField(
                label: 'Transaction PIN',
                hint: '****',
                controller: _pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
                prefixIcon: const Icon(Icons.lock_outline),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter your transaction PIN';
                  }
                  if (val.trim().length < 4) {
                    return 'PIN must be at least 4 digits';
                  }
                  return null;
                },
              ),

              if (requires2fa) ...[
                const SizedBox(height: 16),
                AppTextField(
                  label: '2FA Authenticator Code',
                  hint: '6-digit OTP code',
                  controller: _twoFactorController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
                  prefixIcon: const Icon(Icons.security),
                  validator: (val) {
                    if (val == null || val.trim().length != 6) {
                      return 'Please enter your 6-digit Google Authenticator code';
                    }
                    return null;
                  },
                ),
              ],

              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(AppDimensions.p12),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.danger, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: AppTextTheme.caption.copyWith(color: AppColors.danger),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),
              AppButton(
                text: 'Authorize Transfer',
                isLoading: transferState.isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
