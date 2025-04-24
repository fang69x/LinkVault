import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linkvault/providers/auth_provider.dart';

import 'package:linkvault/screens/home_screen.dart';
import 'package:linkvault/screens/login_screen.dart';
import 'package:linkvault/screens/register_screen.dart';

import 'package:linkvault/screens/splash_screen.dart';
import 'package:linkvault/services/auth_services.dart';

// Auth state provider to determine if user is logged in
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);
  final authNotifier = ref.watch(authNotifierProvider.notifier);

  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
    redirect: (context, state) {
      if (authState.isLoading) return null;

      final isLoggedIn = authState.isAuthenticated;
      final isLoginRoute = state.matchedLocation == '/login';
      final isRegisterRoute = state.matchedLocation == '/register';
      final isSplashRoute = state.matchedLocation == '/';

      if (!isLoggedIn && !isLoginRoute && !isRegisterRoute && !isSplashRoute) {
        return '/login';
      }

      if (isLoggedIn && (isLoginRoute || isRegisterRoute || isSplashRoute)) {
        return '/home';
      }

      return null;
    },
    refreshListenable: GoRouterRefreshStream(authNotifier.stream),
  );
});

// Helper class to refresh router when auth state changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});
