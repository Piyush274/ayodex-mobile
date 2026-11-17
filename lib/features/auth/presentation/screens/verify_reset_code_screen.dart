import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ayodex/core/constants/app_colors.dart';
import 'package:ayodex/core/constants/app_dimensions.dart';
import 'package:ayodex/core/theme/text_theme.dart';
import 'package:ayodex/core/widgets/app_button.dart';
import '../widgets/otp_pin_input.dart';
import '../../data/repositories/password_reset_repository.dart';

class VerifyResetCodeScreen extends ConsumerStatefulWidget {
  final String email;

  const VerifyResetCodeScreen({super.key, required this.email});

  @override
  ConsumerState<VerifyResetCodeScreen> createState() => _VerifyResetCodeScreenState();
}

class _VerifyResetCodeScreenState extends ConsumerState<VerifyResetCodeScreen> {
  String _enteredCode = '';
  bool _isLoading = false;
  String? _errorMessage;

  int _resendCooldown = 120;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  void _startCooldown() {
    setState(() => _resendCooldown = 120);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown <= 1) {
        timer.cancel();
        setState(() => _resendCooldown = 0);
      } else {
        setState(() => _resendCooldown--);
      }
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  String _maskEmail(String email) {
    if (!email.contains('@')) return email;
    final parts = email.split('@');
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 2) {
      return '${name[0]}***@$domain';
    }
    return '${name.substring(0, 2)}***${name.substring(name.length - 1)}@$domain';
  }

  Future<void> _handleVerify() async {
    if (_enteredCode.length < 6) {
      setState(() => _errorMessage = 'Please enter all 6 digits of the verification code');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(passwordResetRepositoryProvider);
      final token = await repo.verifyCode(
        email: widget.email,
        code: _enteredCode,
      );

      if (mounted) {
        context.push('/reset-password', extra: {
          'email': widget.email,
          'token': token,
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleResendCode() async {
    if (_resendCooldown > 0) return;

    try {
      final repo = ref.read(passwordResetRepositoryProvider);
      await repo.sendResetCode(widget.email);
      _startCooldown();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('A new verification code has been sent.')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Verify Code'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.p24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppDimensions.p16),
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mark_email_read_outlined,
                    size: 42,
                    color: AppColors.info,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.p24),
              Text(
                'Enter Verification Code',
                textAlign: TextAlign.center,
                style: AppTextTheme.displayLarge.copyWith(fontSize: 24),
              ),
              const SizedBox(height: AppDimensions.p8),
              Text(
                'A 6-digit verification code has been sent to ${_maskEmail(widget.email)}',
                textAlign: TextAlign.center,
                style: AppTextTheme.bodyMedium,
              ),
              const SizedBox(height: AppDimensions.p32),

              // Error Banner
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppDimensions.p12),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                    border: Border.all(color: AppColors.danger.withOpacity(0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.danger, size: 20),
                      const SizedBox(width: AppDimensions.p8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: AppTextTheme.bodyMedium.copyWith(color: AppColors.danger),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.p24),
              ],

              // 6-digit OTP Box
              OtpPinInput(
                length: 6,
                onChanged: (val) {
                  _enteredCode = val;
                  if (_errorMessage != null) {
                    setState(() => _errorMessage = null);
                  }
                },
                onCompleted: (val) {
                  _enteredCode = val;
                  _handleVerify();
                },
              ),
              const SizedBox(height: AppDimensions.p32),

              // Verify Button
              AppButton(
                text: 'Verify Code',
                isLoading: _isLoading,
                onPressed: _enteredCode.length == 6 ? _handleVerify : null,
              ),
              const SizedBox(height: AppDimensions.p24),

              // Resend Code with timer
              Center(
                child: _resendCooldown > 0
                    ? Text(
                        'Resend code in ${_resendCooldown}s',
                        style: AppTextTheme.bodyMedium.copyWith(color: AppColors.textMuted),
                      )
                    : TextButton(
                        onPressed: _handleResendCode,
                        child: Text(
                          'Resend Code',
                          style: AppTextTheme.bodyMedium.copyWith(
                            color: AppColors.base,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
