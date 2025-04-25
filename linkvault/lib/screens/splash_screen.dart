import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linkvault/providers/auth_provider.dart';
import 'package:linkvault/utils/theme.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Just trigger auth check - router will handle navigation
      ref.read(authNotifierProvider.notifier).checkAuthStatus();
    });
  }

  // Future<void> _checkAuthAndNavigate() async {
  //   try {
  //     // Perform auth check (will update state)
  //     await ref.read(authNotifierProvider.notifier).checkAuthStatus();

  //     // Let the router handle navigation based on updated state
  //     // No need for manual navigation here
  //   } catch (e) {
  //     // Fallback to login if something fails
  //     if (mounted) GoRouter.of(context).go('/login');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // In SplashScreen build()
    final isLoading =
        ref.watch(authNotifierProvider.select((s) => s.isLoading));

    if (isLoading) {
      return const CircularProgressIndicator(
        color: Colors.red,
      );
    }
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.bookmark_outlined,
                size: 80,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'LinkVault',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your personal bookmark manager',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 48),
            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
