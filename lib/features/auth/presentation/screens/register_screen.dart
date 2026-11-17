import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ayodex/core/constants/app_colors.dart';
import 'package:ayodex/core/constants/app_dimensions.dart';
import 'package:ayodex/core/constants/app_strings.dart';
import 'package:ayodex/core/theme/text_theme.dart';
import 'package:ayodex/core/widgets/app_button.dart';
import 'package:ayodex/core/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';
import '../widgets/social_login_buttons.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  final String? referralCode;

  const RegisterScreen({super.key, this.referralCode});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  late final TextEditingController _referralController;

  bool _agreeToTerms = false;
  bool _agreeError = false;

  // Password strength checks
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  @override
  void initState() {
    super.initState();
    _referralController = TextEditingController(text: widget.referralCode ?? '');
    _passwordController.addListener(_checkPasswordStrength);
  }

  void _checkPasswordStrength() {
    final text = _passwordController.text;
    setState(() {
      _hasMinLength = text.length >= 6;
      _hasUppercase = text.contains(RegExp(r'[A-Z]'));
      _hasNumber = text.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = text.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
    });
  }

  @override
  void dispose() {
    _passwordController.removeListener(_checkPasswordStrength);
    _firstnameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    setState(() {
      _agreeError = !_agreeToTerms;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_agreeToTerms) {
      return;
    }

    final authNotifier = ref.read(authControllerProvider.notifier);
    final success = await authNotifier.register(
      firstname: _firstnameController.text.trim(),
      lastname: _lastnameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      passwordConfirmation: _passwordConfirmController.text,
      agree: _agreeToTerms,
      reference: _referralController.text.trim().isEmpty ? null : _referralController.text.trim(),
    );

    if (mounted && success) {
      context.go('/complete-profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Register'),
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
                Text(
                  'Join ${AppStrings.appName}',
                  style: AppTextTheme.displayLarge.copyWith(fontSize: 28),
                ),
                const SizedBox(height: AppDimensions.p8),
                Text(
                  'Start exchanging crypto, fiat, and sending money across Benin & Nigeria.',
                  style: AppTextTheme.bodyMedium,
                ),
                const SizedBox(height: AppDimensions.p24),

                // Error message banner
                if (authState.errorMessage != null) ...[
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
                            authState.errorMessage!,
                            style: AppTextTheme.bodyMedium.copyWith(color: AppColors.danger),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.p16),
                ],

                // First name and Last name row
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        key: const Key('reg_firstname'),
                        controller: _firstnameController,
                        label: 'First Name',
                        hint: 'John',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'First name is required';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: AppDimensions.p12),
                    Expanded(
                      child: AppTextField(
                        key: const Key('reg_lastname'),
                        controller: _lastnameController,
                        label: 'Last Name',
                        hint: 'Doe',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Last name is required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.p16),

                // Email
                AppTextField(
                  key: const Key('reg_email'),
                  controller: _emailController,
                  label: 'Email Address',
                  hint: 'name@example.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.mail_outline, size: 20, color: AppColors.textMuted),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.p16),

                // Password
                AppTextField(
                  key: const Key('reg_password'),
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Enter strong password',
                  isPassword: true,
                  prefixIcon: const Icon(Icons.lock_outline, size: 20, color: AppColors.textMuted),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.p8),

                // Password Strength Indicator Pills
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _PasswordRuleChip(label: '6+ chars', valid: _hasMinLength),
                    _PasswordRuleChip(label: 'Uppercase', valid: _hasUppercase),
                    _PasswordRuleChip(label: 'Number', valid: _hasNumber),
                    _PasswordRuleChip(label: 'Special (!@#)', valid: _hasSpecialChar),
                  ],
                ),
                const SizedBox(height: AppDimensions.p16),

                // Confirm Password
                AppTextField(
                  key: const Key('reg_password_confirmation'),
                  controller: _passwordConfirmController,
                  label: 'Confirm Password',
                  hint: 'Repeat your password',
                  isPassword: true,
                  prefixIcon: const Icon(Icons.lock_reset_outlined, size: 20, color: AppColors.textMuted),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password confirmation is required';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.p16),

                // Referral Code (optional)
                AppTextField(
                  key: const Key('reg_referral'),
                  controller: _referralController,
                  label: 'Referral Code (Optional)',
                  hint: 'Enter referral code if any',
                  prefixIcon: const Icon(Icons.card_giftcard_outlined, size: 20, color: AppColors.textMuted),
                ),
                const SizedBox(height: AppDimensions.p16),

                // Terms and Conditions checkbox
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        key: const Key('reg_agree'),
                        value: _agreeToTerms,
                        activeColor: AppColors.base,
                        onChanged: (val) {
                          setState(() {
                            _agreeToTerms = val ?? false;
                            if (_agreeToTerms) _agreeError = false;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: AppDimensions.p8),
                    Expanded(
                      child: Text(
                        'I agree to the Terms of Service, Privacy Policy and Fee Policy.',
                        style: AppTextTheme.bodySmall.copyWith(color: AppColors.body),
                      ),
                    ),
                  ],
                ),
                if (_agreeError) ...[
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 32),
                    child: Text(
                      'You must agree to the terms and privacy policy',
                      style: AppTextTheme.bodySmall.copyWith(color: AppColors.danger),
                    ),
                  ),
                ],
                const SizedBox(height: AppDimensions.p24),

                // Create Account Button
                AppButton(
                  text: 'Create Account',
                  isLoading: authState.isLoading,
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: AppDimensions.p24),

                // Social Logins
                SocialLoginButtons(
                  onGoogleTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Google Sign-Up integration ready.')),
                    );
                  },
                  onFacebookTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Facebook Sign-Up integration ready.')),
                    );
                  },
                ),
                const SizedBox(height: AppDimensions.p24),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: AppTextTheme.bodyMedium.copyWith(color: AppColors.body),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: Text(
                        'Sign In',
                        style: AppTextTheme.bodyMedium.copyWith(
                          color: AppColors.base,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
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

class _PasswordRuleChip extends StatelessWidget {
  final String label;
  final bool valid;

  const _PasswordRuleChip({
    required this.label,
    required this.valid,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: valid ? AppColors.success.withOpacity(0.12) : AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: valid ? AppColors.success : AppColors.border,
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            valid ? Icons.check_circle : Icons.circle_outlined,
            size: 12,
            color: valid ? AppColors.success : AppColors.textMuted,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: valid ? AppColors.success : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
