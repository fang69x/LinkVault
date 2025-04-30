import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linkvault/models/bookmark_model.dart';
import 'package:linkvault/providers/auth_provider.dart';
import 'package:linkvault/routes/app_routes.dart';
import 'package:linkvault/screens/auth_screen.dart';
import 'package:linkvault/screens/bookmark_detail_screen.dart';
import 'package:linkvault/screens/create_bookmark_screen.dart';
import 'package:linkvault/screens/home_screen.dart';
import 'package:linkvault/screens/search_screen.dart';
import 'package:linkvault/screens/splash_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    redirect: (BuildContext context, GoRouterState state) {
      final isAuth = authState.isAuthenticated;
      final isLoading = authState.isLoading;
      final isSplash = state.uri.toString() == AppRoutes.splash;
      final isAuthRoute = state.uri.toString() == AppRoutes.auth;

      // Show splash while initializing
      if (isLoading) return AppRoutes.splash;

      // Redirect unauthenticated users to auth
      if (!isAuth && !isAuthRoute) return AppRoutes.auth;

      // Redirect authenticated users away from auth/splash
      if (isAuth && (isAuthRoute || isSplash)) return AppRoutes.home;

      return null; // No redirect
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (context, state) =>
            const MaterialPage(child: SplashScreen()),
      ),
      GoRoute(
        path: AppRoutes.auth,
        pageBuilder: (context, state) =>
            const MaterialPage(child: AuthScreen()),
      ),
      GoRoute(
        path: AppRoutes.home,
        pageBuilder: (context, state) =>
            const MaterialPage(child: HomeScreen()),
      ),
      GoRoute(
        path: AppRoutes.search,
        pageBuilder: (context, state) =>
            const MaterialPage(child: SearchScreen()),
      ),
      GoRoute(
        path: AppRoutes.createBookmark,
        pageBuilder: (context, state) =>
            const MaterialPage(child: CreateBookmarkScreen()),
      ),
      GoRoute(
        path: AppRoutes.bookmarkDetails,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return MaterialPage(child: BookmarkDetailScreen(bookmarkId: id));
        },
      ),
      GoRoute(
        path: AppRoutes.editBookmark,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          final bookmark = state.extra as Bookmark;
          return MaterialPage(child: CreateBookmarkScreen(bookmark: bookmark));
        },
      ),
    ],
    errorPageBuilder: (context, state) => MaterialPage(
      child: Scaffold(
        body: Center(
          child: Text('Route not found: ${state.uri.toString()}'),
        ),
      ),
    ),
  );
});
