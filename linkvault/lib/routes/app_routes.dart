import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linkvault/screens/bookmark_detail_screen.dart';
import 'package:linkvault/screens/create_bookmark_screen.dart';
import 'package:linkvault/screens/home_screen.dart';
import 'package:linkvault/screens/login_screen.dart';
import 'package:linkvault/screens/register_screen.dart';
import 'package:linkvault/screens/search_screen.dart';
import 'package:linkvault/screens/splash_screen.dart';
import 'package:linkvault/services/auth_services.dart';

// Auth state provider to determine if user is logged in
final authStateProvider = StreamProvider<bool>((ref) async* {
  final authService = ref.watch(authServiceProvider);

  // Initial check
  bool isLoggedIn = await authService.isLoggedIn();
  yield isLoggedIn;

  // Stream of auth state changes
  while (true) {
    await Future.delayed(const Duration(seconds: 2));
    isLoggedIn = await authService.isLoggedIn();
    yield isLoggedIn;
  }
});

// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

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
      // GoRoute(
      //   path: '/home',
      //   builder: (context, state) => const HomeScreen(),
      // ),
      // GoRoute(
      //   path: '/search',
      //   builder: (context, state) => const SearchScreen(),
      // ),
      // GoRoute(
      //   path: '/bookmark/create',
      //   builder: (context, state) => const CreateBookmarkScreen(),
      // ),
      // GoRoute(
      //   path: '/bookmark/:id',
      //   builder: (context, state) {
      //     final id = state.pathParameters['id']!;
      //     return BookmarkDetailScreen(bookmarkId: id);
      //   },
      // ),
    ],
    redirect: (context, state) {
      // Show splash screen while loading auth state
      if (authState.isLoading) return null;

      final isLoggedIn = authState.valueOrNull ?? false;
      final isLoginRoute = state.matchedLocation == '/login';
      final isRegisterRoute = state.matchedLocation == '/register';
      final isSplashRoute = state.matchedLocation == '/';

      // If not logged in and not on auth pages, redirect to login
      if (!isLoggedIn && !isLoginRoute && !isRegisterRoute && !isSplashRoute) {
        return '/login';
      }

      // If logged in and on auth pages, redirect to home
      if (isLoggedIn && (isLoginRoute || isRegisterRoute || isSplashRoute)) {
        return '/home';
      }

      // No redirect needed
      return null;
    },
    refreshListenable:
        GoRouterRefreshStream(ref.watch(authStateProvider.stream)),
  );
});

// Helper class to refresh router when auth state changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

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
