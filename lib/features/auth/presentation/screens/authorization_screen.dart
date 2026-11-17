import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ayodex/core/constants/app_colors.dart';
import 'package:ayodex/core/constants/app_dimensions.dart';
import 'package:ayodex/core/theme/text_theme.dart';
import 'package:ayodex/core/widgets/app_button.dart';
import '../controllers/auth_controller.dart';
import '../widgets/otp_pin_input.dart';
import '../../data/repositories/password_reset_repository.dart';

enum AuthorizationType { email, sms, twoFactor }

class AuthorizationScreen extends ConsumerStatefulWidget {
  final AuthorizationType type;

  const AuthorizationScreen({
    super.key,
    required this.type,
  });

  @override
  ConsumerState<AuthorizationScreen> createState() => _AuthorizationScreenState();
}

class _AuthorizationScreenState extends ConsumerState<AuthorizationScreen> {
  String _enteredCode = '';
  bool _isLoading = false;
  String? _errorMessage;

  int _resendCooldown = 60;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    if (widget.type != AuthorizationType.twoFactor) {
      _startCooldown();
    }
  }

  void _startCooldown() {
    setState(() => _resendCooldown = 60);
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

  String get _title {
    switch (widget.type) {
      case AuthorizationType.email:
        return 'Verify Email Address';
      case AuthorizationType.sms:
        return 'Verify Phone Number';
      case AuthorizationType.twoFactor:
        return 'Two-Factor Authentication';
    }
  }

  String get _description {
    switch (widget.type) {
      case AuthorizationType.email:
        return 'We have sent a 6-digit verification code to your email address.';
      case AuthorizationType.sms:
        return 'We have sent an SMS containing a 6-digit verification code to your mobile number.';
      case AuthorizationType.twoFactor:
        return 'Enter the 6-digit code from your Google Authenticator app to continue.';
    }
  }

  IconData get _icon {
    switch (widget.type) {
      case AuthorizationType.email:
        return Icons.mark_email_read_outlined;
      case AuthorizationType.sms:
        return Icons.sms_outlined;
      case AuthorizationType.twoFactor:
        return Icons.security_rounded;
    }
  }

  Future<void> _handleVerify() async {
    if (_enteredCode.length < 6) {
      setState(() => _errorMessage = 'Please enter all 6 digits');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(passwordResetRepositoryProvider);
      switch (widget.type) {
        case AuthorizationType.email:
          await repo.verifyEmail(_enteredCode);
          break;
        case AuthorizationType.sms:
          await repo.verifyMobile(_enteredCode);
          break;
        case AuthorizationType.twoFactor:
          await repo.verifyG2fa(_enteredCode);
          break;
      }

      // Re-initialize or fetch updated user info
      await ref.read(authControllerProvider.notifier).initialize();

      if (mounted) {
        context.go('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleResend() async {
    if (_resendCooldown > 0) return;

    try {
      final repo = ref.read(passwordResetRepositoryProvider);
      final resendType = widget.type == AuthorizationType.email ? 'email' : 'sms';
      await repo.resendVerify(resendType);
      _startCooldown();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification code resent successfully.')),
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
        title: Text(_title),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.danger),
            tooltip: 'Logout',
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
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
                    color: AppColors.base.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _icon,
                    size: 42,
                    color: AppColors.base,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.p24),
              Text(
                _title,
                textAlign: TextAlign.center,
                style: AppTextTheme.displayLarge.copyWith(fontSize: 24),
              ),
              const SizedBox(height: AppDimensions.p8),
              Text(
                _description,
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
                text: 'Verify & Continue',
                isLoading: _isLoading,
                onPressed: _enteredCode.length == 6 ? _handleVerify : null,
              ),
              const SizedBox(height: AppDimensions.p24),

              // Resend Code (for Email and SMS)
              if (widget.type != AuthorizationType.twoFactor) ...[
                Center(
                  child: _resendCooldown > 0
                      ? Text(
                          'Resend code in ${_resendCooldown}s',
                          style: AppTextTheme.bodyMedium.copyWith(color: AppColors.textMuted),
                        )
                      : TextButton(
                          onPressed: _handleResend,
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
            ],
          ),
        ),
      ),
    );
  }
}
