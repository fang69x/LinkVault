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

// Helper class to refresh router when auth state changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) {
      if (_isDisposed) return;
      notifyListeners();
    });
  }

  late final StreamSubscription _subscription;
  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    _subscription.cancel();
    super.dispose();
  }
}

// Auth state provider
final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authNotifierProvider.notifier);
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
      final String? matchedLocation = state.matchedLocation;
      final bool isLoggedIn = authState.isAuthenticated;
      final bool isLoginRoute = matchedLocation == '/login';
      final bool isRegisterRoute = matchedLocation == '/register';
      final bool isHomeRoute = matchedLocation == '/home';
      final bool isSplashRoute = matchedLocation == '/';

      // 1. Always allow the splash screen.
      if (isSplashRoute) {
        return null;
      }

      // 2. If the user is not logged in
      if (!isLoggedIn) {
        // ...and is on login or register, allow.
        if (isLoginRoute || isRegisterRoute) {
          return null;
        }
        // ...otherwise, redirect to login.
        return '/login';
      }

      // 3. If the user is logged in
      if (isLoggedIn) {
        // ...and is on login or register, redirect to home.
        if (isLoginRoute || isRegisterRoute) {
          return '/home';
        }
        // ...and is on home, allow.  Important:  Only allow if *already* on home.
        if (isHomeRoute) {
          return null;
        }
        return '/home'; // Ensure we go to home.
      }
      return null;
    },
    refreshListenable: GoRouterRefreshStream(
      authNotifier.stream, // Use the stream from the notifier.
    ),
  );
});
