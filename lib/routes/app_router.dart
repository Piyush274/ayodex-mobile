import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ayodex/core/constants/app_colors.dart';
import 'package:ayodex/core/constants/app_dimensions.dart';
import 'package:ayodex/core/constants/app_strings.dart';
import 'package:ayodex/core/theme/text_theme.dart';
import 'package:ayodex/core/widgets/app_button.dart';
import 'package:ayodex/core/widgets/custom_card.dart';
import 'package:ayodex/features/auth/presentation/controllers/auth_controller.dart';
import 'package:ayodex/features/auth/presentation/screens/complete_profile_screen.dart';
import 'package:ayodex/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:ayodex/features/auth/presentation/screens/login_screen.dart';
import 'package:ayodex/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:ayodex/features/auth/presentation/screens/register_screen.dart';
import 'package:ayodex/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:ayodex/features/auth/presentation/screens/splash_screen.dart';
import 'package:ayodex/features/auth/presentation/screens/verify_reset_code_screen.dart';
import 'package:ayodex/features/auth/presentation/screens/authorization_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) {
          final refCode = state.uri.queryParameters['ref'] ?? state.uri.queryParameters['reference'];
          return RegisterScreen(referralCode: refCode);
        },
      ),
      GoRoute(
        path: '/complete-profile',
        name: 'complete-profile',
        builder: (context, state) => const CompleteProfileScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const _DashboardPlaceholderScreen(),
      ),
      GoRoute(
        path: '/banned',
        name: 'banned',
        builder: (context, state) => const _BannedScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/verify-reset-code',
        name: 'verify-reset-code',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final email = extra?['email'] ?? state.uri.queryParameters['email'] ?? '';
          return VerifyResetCodeScreen(email: email);
        },
      ),
      GoRoute(
        path: '/reset-password',
        name: 'reset-password',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final email = extra?['email'] ?? state.uri.queryParameters['email'] ?? '';
          final token = extra?['token'] ?? state.uri.queryParameters['token'] ?? '';
          return ResetPasswordScreen(email: email, token: token);
        },
      ),
      GoRoute(
        path: '/authorization',
        name: 'authorization',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final typeString = extra?['type'] ?? state.uri.queryParameters['type'] ?? 'email';
          AuthorizationType type;
          if (typeString == 'sms') {
            type = AuthorizationType.sms;
          } else if (typeString == '2fa' || typeString == 'g2fa') {
            type = AuthorizationType.twoFactor;
          } else {
            type = AuthorizationType.email;
          }
          return AuthorizationScreen(type: type);
        },
      ),
    ],
  );
});

class _DashboardPlaceholderScreen extends ConsumerWidget {
  const _DashboardPlaceholderScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
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
          padding: const EdgeInsets.all(AppDimensions.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomCard(
                title: 'Welcome to ${AppStrings.appName}',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user != null ? 'Logged in as ${user.fullName}' : 'Authenticated User',
                      style: AppTextTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppDimensions.p12),
                    if (user != null) ...[
                      Text('Username: @${user.username}', style: AppTextTheme.bodyMedium),
                      const SizedBox(height: 4),
                      Text('Email: ${user.email}', style: AppTextTheme.bodyMedium),
                      const SizedBox(height: 4),
                      Text('Country: ${user.countryName ?? "N/A"} (+${user.dialCode})', style: AppTextTheme.bodyMedium),
                      const SizedBox(height: 4),
                      Text('Mobile: ${user.mobile}', style: AppTextTheme.bodyMedium),
                    ],
                    const SizedBox(height: AppDimensions.p16),
                    AppButton(
                      text: 'Log Out',
                      variant: AppButtonVariant.outline,
                      onPressed: () async {
                        await ref.read(authControllerProvider.notifier).logout();
                        if (context.mounted) {
                          context.go('/login');
                        }
                      },
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

class _BannedScreen extends ConsumerWidget {
  const _BannedScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.p24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.block_flipped, size: 72, color: AppColors.danger),
              const SizedBox(height: AppDimensions.p24),
              Text(
                'Account Suspended',
                style: AppTextTheme.displayLarge.copyWith(fontSize: 24, color: AppColors.danger),
              ),
              const SizedBox(height: AppDimensions.p12),
              Text(
                'Your account has been deactivated or banned. Please reach out to customer support for assistance.',
                textAlign: TextAlign.center,
                style: AppTextTheme.bodyMedium,
              ),
              const SizedBox(height: AppDimensions.p32),
              AppButton(
                text: 'Back to Sign In',
                onPressed: () async {
                  await ref.read(authControllerProvider.notifier).logout();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
