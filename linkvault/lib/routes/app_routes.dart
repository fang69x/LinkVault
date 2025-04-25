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
      // Skip redirect during loading
      if (authState.isLoading) return null;

      final isLoggedIn = authState.isAuthenticated;
      final isSplash = state.matchedLocation == '/';
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
// In router redirect
      debugPrint('''
Redirect Decision:
- isLoggedIn: $isLoggedIn
- currentRoute: ${state.matchedLocation}
- isLoading: ${authState.isLoading}
''');
      // If logged in and trying to access auth/splash, go home
      if (isLoggedIn && (isSplash || isAuthRoute)) {
        return '/home';
      }

      // If not logged in and trying to access protected routes, go login
      if (!isLoggedIn && !isAuthRoute && !isSplash) {
        return '/login';
      }

      return null; // No redirect needed
    },
    refreshListenable: GoRouterRefreshStream(
      ref.watch(authNotifierProvider.notifier).stream,
    ),
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
