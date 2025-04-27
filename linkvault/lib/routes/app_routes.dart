import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linkvault/providers/auth_provider.dart';
import 'package:linkvault/screens/bookmark_detail_screen.dart';
import 'package:linkvault/screens/create_bookmark_screen.dart';
import 'package:linkvault/screens/home_screen.dart';
import 'package:linkvault/screens/login_screen.dart';
import 'package:linkvault/screens/register_screen.dart';
import 'package:linkvault/screens/search_screen.dart';
import 'package:linkvault/screens/splash_screen.dart';

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
      GoRoute(
        path: '/bookmark/create',
        builder: (context, state) => const CreateBookmarkScreen(),
      ),
      GoRoute(
        path: '/bookmark/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return BookmarkDetailScreen(bookmarkId: id);
        },
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/edit-bookmark',
        builder: (context, state) {
          final bookmark = state.extra;
          return Scaffold(
            appBar: AppBar(title: const Text('Edit Bookmark')),
            body: Center(child: Text('Edit Bookmark Page for: $bookmark')),
          );
        },
      ),
    ],
    redirect: (context, state) {
      final isSplash = state.matchedLocation == '/';
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      final isHome = state.matchedLocation == '/home';

      // Splash screen handling
      if (isSplash) return null;

      // Authentication state handling
      if (authState.isLoading) return null;

      if (!authState.isAuthenticated) {
        return isAuthRoute ? null : '/login';
      }

      return isAuthRoute ? '/home' : null;
    },
    refreshListenable: GoRouterRefreshStream(authNotifier.stream),
  );
});
