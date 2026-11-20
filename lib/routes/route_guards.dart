import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ayodex/features/auth/presentation/controllers/auth_controller.dart';

class RouteGuards {
  RouteGuards._();

  static String? evaluate(BuildContext context, GoRouterState state, AuthState authState) {
    final path = state.uri.path;
    final isAuthenticated = authState.status == AuthStatus.authenticated;
    final isBanned = authState.status == AuthStatus.banned;
    final isProfileIncomplete = authState.status == AuthStatus.profileIncomplete;

    final isPublicRoute = path == '/' ||
        path == '/onboarding' ||
        path == '/login' ||
        path == '/register' ||
        path == '/banned' ||
        path.startsWith('/password') ||
        path.startsWith('/policies') ||
        path.startsWith('/policy') ||
        path == '/faq' ||
        path == '/contact';

    // Banned check
    if (isBanned) {
      return path == '/banned' ? null : '/banned';
    }

    // Incomplete profile check
    if (isProfileIncomplete) {
      return path == '/complete-profile' ? null : '/complete-profile';
    }

    // Unauthenticated user attempting to access protected route
    if (!isAuthenticated && !isPublicRoute) {
      return '/login';
    }

    // Authenticated user attempting to visit login/register/onboarding
    if (isAuthenticated && (path == '/login' || path == '/register' || path == '/onboarding')) {
      return '/dashboard';
    }

    return null;
  }
}
