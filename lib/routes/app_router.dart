import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ayodex/core/constants/app_colors.dart';
import 'package:ayodex/core/constants/app_dimensions.dart';
import 'package:ayodex/core/theme/text_theme.dart';
import 'package:ayodex/core/widgets/app_button.dart';
import 'package:ayodex/core/widgets/app_shell_scaffold.dart';
import 'package:ayodex/routes/route_guards.dart';
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
import 'package:ayodex/features/pin/presentation/screens/pin_status_screen.dart';
import 'package:ayodex/features/pin/presentation/screens/set_pin_screen.dart';
import 'package:ayodex/features/pin/presentation/screens/change_pin_screen.dart';
import 'package:ayodex/features/pin/presentation/screens/two_factor_screen.dart';
import 'package:ayodex/features/kyc/presentation/screens/kyc_form_screen.dart';
import 'package:ayodex/features/kyc/presentation/screens/kyc_status_screen.dart';
import 'package:ayodex/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:ayodex/features/wallet/presentation/screens/transactions_screen.dart';
import 'package:ayodex/features/exchange/presentation/screens/exchange_create_screen.dart';
import 'package:ayodex/features/exchange/presentation/screens/exchange_preview_screen.dart';
import 'package:ayodex/features/exchange/presentation/screens/exchange_manual_payment_screen.dart';
import 'package:ayodex/features/exchange/presentation/screens/exchange_history_screen.dart';
import 'package:ayodex/features/exchange/presentation/screens/exchange_detail_screen.dart';
import 'package:ayodex/features/exchange/presentation/screens/exchange_track_screen.dart';
import 'package:ayodex/features/transfers/presentation/screens/transfer_new_screen.dart';
import 'package:ayodex/features/transfers/presentation/screens/transfer_quote_preview_screen.dart';
import 'package:ayodex/features/transfers/presentation/screens/transfer_processing_screen.dart';
import 'package:ayodex/features/transfers/presentation/screens/transfer_history_screen.dart';
import 'package:ayodex/features/transfers/presentation/screens/transfer_detail_screen.dart';
import 'package:ayodex/features/withdraw/presentation/screens/withdraw_methods_screen.dart';
import 'package:ayodex/features/withdraw/presentation/screens/withdraw_history_screen.dart';
import 'package:ayodex/features/support/presentation/screens/support_tickets_screen.dart';
import 'package:ayodex/features/support/presentation/screens/create_ticket_screen.dart';
import 'package:ayodex/features/support/presentation/screens/ticket_view_screen.dart';
import 'package:ayodex/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:ayodex/features/profile/presentation/screens/profile_screen.dart';
import 'package:ayodex/features/profile/presentation/screens/change_password_screen.dart';
import 'package:ayodex/features/profile/presentation/screens/affiliate_screen.dart';
import 'package:ayodex/features/profile/presentation/screens/policy_screen.dart';
import 'package:ayodex/features/profile/presentation/screens/faq_screen.dart';
import 'package:ayodex/features/profile/presentation/screens/contact_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) => RouteGuards.evaluate(context, state, ref.read(authControllerProvider)),
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
          final refCode = state.uri.queryParameters['ref'] ??
              state.uri.queryParameters['reference'];
          return RegisterScreen(referralCode: refCode);
        },
      ),
      GoRoute(
        path: '/complete-profile',
        name: 'complete-profile',
        builder: (context, state) => const CompleteProfileScreen(),
      ),
      // Main Persistent Navigation Shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShellScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                name: 'dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/exchange/create',
                name: 'exchange-create',
                builder: (context, state) => const ExchangeCreateScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/transfer/new',
                name: 'transfer-new',
                builder: (context, state) => const TransferNewScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/transactions',
                name: 'transactions',
                builder: (context, state) => const TransactionsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
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
          final email =
              extra?['email'] ?? state.uri.queryParameters['email'] ?? '';
          return VerifyResetCodeScreen(email: email);
        },
      ),
      GoRoute(
        path: '/reset-password',
        name: 'reset-password',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final email =
              extra?['email'] ?? state.uri.queryParameters['email'] ?? '';
          final token =
              extra?['token'] ?? state.uri.queryParameters['token'] ?? '';
          return ResetPasswordScreen(email: email, token: token);
        },
      ),
      GoRoute(
        path: '/authorization',
        name: 'authorization',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final typeString =
              extra?['type'] ?? state.uri.queryParameters['type'] ?? 'email';
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
      GoRoute(
        path: '/security/pin',
        name: 'security-pin',
        builder: (context, state) => const PinStatusScreen(),
      ),
      GoRoute(
        path: '/security/set-pin',
        name: 'security-set-pin',
        builder: (context, state) => const SetPinScreen(),
      ),
      GoRoute(
        path: '/security/change-pin',
        name: 'security-change-pin',
        builder: (context, state) => const ChangePinScreen(),
      ),
      GoRoute(
        path: '/security/2fa',
        name: 'security-2fa',
        builder: (context, state) => const TwoFactorScreen(),
      ),
      GoRoute(
        path: '/kyc',
        name: 'kyc',
        builder: (context, state) => const KycFormScreen(),
      ),
      GoRoute(
        path: '/kyc/status',
        name: 'kyc-status',
        builder: (context, state) => const KycStatusScreen(),
      ),
      GoRoute(
        path: '/exchange/preview',
        name: 'exchange-preview',
        builder: (context, state) {
          final id = state.uri.queryParameters['id'] ?? (state.extra as Map<String, dynamic>?)?['id'] ?? '';
          return ExchangePreviewScreen(exchangeId: id);
        },
      ),
      GoRoute(
        path: '/exchange/manual',
        name: 'exchange-manual',
        builder: (context, state) {
          final id = state.uri.queryParameters['id'] ?? (state.extra as Map<String, dynamic>?)?['id'] ?? '';
          return ExchangeManualPaymentScreen(exchangeId: id);
        },
      ),
      GoRoute(
        path: '/exchange/history',
        name: 'exchange-history',
        builder: (context, state) {
          final scope = state.uri.queryParameters['scope'];
          return ExchangeHistoryScreen(initialScope: scope);
        },
      ),
      GoRoute(
        path: '/exchange/details',
        name: 'exchange-details',
        builder: (context, state) {
          final id = state.uri.queryParameters['id'] ?? (state.extra as Map<String, dynamic>?)?['id'] ?? '';
          return ExchangeDetailScreen(exchangeId: id);
        },
      ),
      GoRoute(
        path: '/exchange/track',
        name: 'exchange-track',
        builder: (context, state) {
          final id = state.uri.queryParameters['id'] ?? (state.extra as Map<String, dynamic>?)?['id'];
          return ExchangeTrackScreen(initialExchangeId: id);
        },
      ),
      GoRoute(
        path: '/transfer/quote/:id',
        name: 'transfer-quote',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return TransferQuotePreviewScreen(quoteId: id);
        },
      ),
      GoRoute(
        path: '/transfer/processing/:trx',
        name: 'transfer-processing',
        builder: (context, state) {
          final trx = state.pathParameters['trx'] ?? '';
          return TransferProcessingScreen(trx: trx);
        },
      ),
      GoRoute(
        path: '/transfer/history',
        name: 'transfer-history',
        builder: (context, state) => const TransferHistoryScreen(),
      ),
      GoRoute(
        path: '/transfer/detail/:trx',
        name: 'transfer-detail',
        builder: (context, state) {
          final trx = state.pathParameters['trx'] ?? '';
          return TransferDetailScreen(trx: trx);
        },
      ),
      GoRoute(
        path: '/withdraw',
        name: 'withdraw-methods',
        builder: (context, state) => const WithdrawMethodsScreen(),
      ),
      GoRoute(
        path: '/withdraw/history',
        name: 'withdraw-history',
        builder: (context, state) => const WithdrawHistoryScreen(),
      ),
      GoRoute(
        path: '/support',
        name: 'support-tickets',
        builder: (context, state) => const SupportTicketsScreen(),
      ),
      GoRoute(
        path: '/support/create',
        name: 'support-create',
        builder: (context, state) => const CreateTicketScreen(),
      ),
      GoRoute(
        path: '/support/view/:ticket',
        name: 'support-view',
        builder: (context, state) {
          final ticket = state.pathParameters['ticket'] ?? '';
          return TicketViewScreen(ticketNumber: ticket);
        },
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/profile/change-password',
        name: 'change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/affiliate',
        name: 'affiliate',
        builder: (context, state) => const AffiliateScreen(),
      ),
      GoRoute(
        path: '/policies',
        name: 'policies',
        builder: (context, state) => const PolicyScreen(),
      ),
      GoRoute(
        path: '/policy/:slug',
        name: 'policy-detail',
        builder: (context, state) {
          final slug = state.pathParameters['slug'];
          return PolicyScreen(slug: slug);
        },
      ),
      GoRoute(
        path: '/faq',
        name: 'faq',
        builder: (context, state) => const FaqScreen(),
      ),
      GoRoute(
        path: '/contact',
        name: 'contact',
        builder: (context, state) => const ContactScreen(),
      ),
    ],
  );
});

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
              const Icon(Icons.block_flipped,
                  size: 72, color: AppColors.danger),
              const SizedBox(height: AppDimensions.p24),
              Text(
                'Account Suspended',
                style: AppTextTheme.displayLarge
                    .copyWith(fontSize: 24, color: AppColors.danger),
              ),
              const SizedBox(height: AppDimensions.p12),
              const Text(
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
