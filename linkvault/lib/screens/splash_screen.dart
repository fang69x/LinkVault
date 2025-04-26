import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linkvault/utils/theme.dart';
import 'package:linkvault/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  // Use a late variable and initialize it only once.
  late Future<void> _authCheckFuture;
  bool _navigated = false; // Track navigation

  @override
  void initState() {
    super.initState();
    // Initialize the future in initState.  This ensures it only runs once.
    _authCheckFuture = _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    if (_navigated) return; // Add this check at the beginning
    _navigated = true; // set the flag

    try {
      final authNotifier = ref.read(authNotifierProvider.notifier);
      final isAuthenticated =
          await authNotifier.checkAuthStatus(); // Await here
      if (mounted) {
        // use mounted check
        if (isAuthenticated) {
          context.go('/home');
        } else {
          context.go('/login');
        }
      }
    } catch (e) {
      if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use a FutureBuilder to handle the asynchronous operation.
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
            // Show the loading indicator while checking the auth status.
            FutureBuilder(
              future: _authCheckFuture, // Use the future here
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  );
                }
                //  Removed the check for snapshot.hasError.  The _checkAuthAndNavigate
                //  function now handles errors internally and navigates to /login.
                return const SizedBox.shrink(); //  Return an empty widget.
              },
            ),
          ],
        ),
      ),
    );
  }
}
