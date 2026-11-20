import 'dart:async';
import 'package:material_ui/material_ui.dart';
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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  int _cooldownSeconds = 0;
  Timer? _cooldownTimer;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown(int seconds) {
    setState(() => _cooldownSeconds = seconds);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldownSeconds <= 1) {
        timer.cancel();
        setState(() => _cooldownSeconds = 0);
      } else {
        setState(() => _cooldownSeconds--);
      }
    });
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authNotifier = ref.read(authControllerProvider.notifier);
    final success = await authNotifier.login(
      _usernameController.text.trim(),
      _passwordController.text,
    );

    if (mounted) {
      final state = ref.read(authControllerProvider);
      if (success) {
        if (state.isProfileIncomplete) {
          context.go('/complete-profile');
        } else {
          context.go('/dashboard');
        }
      } else {
        if (state.errorMessage != null &&
            (state.errorMessage!.contains('429') ||
                state.errorMessage!
                    .toLowerCase()
                    .contains('too many requests'))) {
          _startCooldown(60);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Login'),
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
                // Header
                Text(
                  'Welcome Back',
                  style: AppTextTheme.displayLarge.copyWith(fontSize: 28),
                ),
                const SizedBox(height: AppDimensions.p8),
                const Text(
                  'Log in to your ${AppStrings.appName} account to manage exchanges, transfers, and wallet.',
                  style: AppTextTheme.bodyMedium,
                ),
                const SizedBox(height: AppDimensions.p24),

                // Error message banner
                if (authState.errorMessage != null) ...[
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
                            authState.errorMessage!,
                            style: AppTextTheme.bodyMedium
                                .copyWith(color: AppColors.danger),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.p16),
                ],

                // Rate limit cooldown banner
                if (_cooldownSeconds > 0) ...[
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.p12),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.12),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusMedium),
                      border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.timer_outlined,
                            color: AppColors.warning, size: 20),
                        const SizedBox(width: AppDimensions.p8),
                        Expanded(
                          child: Text(
                            'Too many login attempts. Please wait $_cooldownSeconds seconds.',
                            style: AppTextTheme.bodyMedium
                                .copyWith(color: AppColors.warning),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.p16),
                ],

                // Username / Email
                AppTextField(
                  key: const Key('login_username_field'),
                  controller: _usernameController,
                  label: 'Username or Email',
                  hint: 'Enter your username or email',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.person_outline,
                      size: 20, color: AppColors.textMuted),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Username or email is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.p16),

                // Password with visibility toggle
                AppTextField(
                  key: const Key('login_password_field'),
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Enter your password',
                  isPassword: true,
                  prefixIcon: const Icon(Icons.lock_outline,
                      size: 20, color: AppColors.textMuted),
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.p8),

                // Forgot Password link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Forgot Password?',
                      style: AppTextTheme.bodyMedium.copyWith(
                        color: AppColors.base,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.p24),

                // Sign In Button
                AppButton(
                  text: _cooldownSeconds > 0
                      ? 'Wait ($_cooldownSeconds s)'
                      : 'Sign In',
                  isLoading: authState.isLoading,
                  onPressed: _cooldownSeconds > 0 ? null : _handleLogin,
                ),
                const SizedBox(height: AppDimensions.p24),

                // Social Logins
                SocialLoginButtons(
                  onGoogleTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Google Sign-In integration ready.')),
                    );
                  },
                  onFacebookTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Facebook Sign-In integration ready.')),
                    );
                  },
                ),
                const SizedBox(height: AppDimensions.p32),

                // Register CTA Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: AppTextTheme.bodyMedium
                          .copyWith(color: AppColors.body),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => context.go('/register'),
                      child: Text(
                        'Create Account',
                        style: AppTextTheme.bodyMedium.copyWith(
                          color: AppColors.base,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.p16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
