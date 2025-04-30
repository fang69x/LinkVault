import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linkvault/models/user_model.dart';
import 'package:linkvault/services/auth_services.dart';
import 'package:linkvault/utils/logger.dart';

// Authentication state class
class AuthState {
  final bool isAuthenticated;
  final User? user;
  final bool isLoading;
  final String? error;
  final AuthStatus status;

  const AuthState({
    required this.isAuthenticated,
    this.user,
    required this.isLoading,
    this.error,
    required this.status,
  });

  factory AuthState.initial() => const AuthState(
        isAuthenticated: false,
        user: null,
        isLoading: true, // Start with loading state to check token
        error: null,
        status: AuthStatus.initial,
      );

  AuthState copyWith({
    bool? isAuthenticated,
    User? user,
    bool? isLoading,
    String? error,
    AuthStatus? status,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      status: status ?? this.status,
    );
  }

  // Reset the error state only
  AuthState clearError() {
    return copyWith(error: null);
  }
}

// Authentication status enum for more granular state handling
enum AuthStatus {
  initial,
  checkingAuth,
  authenticated,
  unauthenticated,
  loginInProgress,
  registerInProgress,
  error,
}

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Auth notifier that handles all authentication operations
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final Logger _logger = Logger('AuthNotifier');

  AuthNotifier(this._authService) : super(AuthState.initial()) {
    // Immediately check auth status on initialization
    checkAuthStatus();
  }

  // Check if user is authenticated using token
  Future<bool> checkAuthStatus() async {
    state = state.copyWith(
        isLoading: true, status: AuthStatus.checkingAuth, error: null);

    try {
      final tokenValid = await _authService.verifyToken();

      if (tokenValid) {
        final user = await _authService.getCurrentUser();
        state = state.copyWith(
          isAuthenticated: true,
          user: user,
          isLoading: false,
          status: AuthStatus.authenticated,
        );
        _logger.info('User authenticated: ${user.name}');
        return true;
      } else {
        state = state.copyWith(
          isAuthenticated: false,
          user: null,
          isLoading: false,
          status: AuthStatus.unauthenticated,
        );
        _logger.info('User not authenticated');
        return false;
      }
    } catch (e) {
      _logger.error('Auth check error: $e');
      state = state.copyWith(
        isAuthenticated: false,
        user: null,
        isLoading: false,
        error: e.toString(),
        status: AuthStatus.error,
      );
      return false;
    }
  }

  // User login
  Future<void> login(String email, String password) async {
    try {
      state = state.copyWith(
          isLoading: true, error: null, status: AuthStatus.loginInProgress);

      _logger.info('Attempting login for: $email');
      final user = await _authService.login(email, password);

      state = state.copyWith(
        isAuthenticated: true,
        user: user,
        isLoading: false,
        status: AuthStatus.authenticated,
      );
      _logger.info('Login successful for: $email');
    } catch (e) {
      _logger.error('Login error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e is SocketException
            ? 'Connection failed. Check your network'
            : e.toString(),
        status: AuthStatus.error,
      );
      rethrow;
    }
  }

  // User registration
  Future<void> register(String name, String email, String password,
      {String? avatarPath}) async {
    state = state.copyWith(
        isLoading: true, error: null, status: AuthStatus.registerInProgress);

    try {
      _logger.info('Attempting registration for: $email');
      final user = await _authService.register(
        name,
        email,
        password,
        avatarPath: avatarPath,
      );

      state = state.copyWith(
        isAuthenticated: true,
        user: user,
        isLoading: false,
        status: AuthStatus.authenticated,
      );
      _logger.info('Registration successful for: $email');
    } catch (e) {
      _logger.error('Registration error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        status: AuthStatus.error,
      );
      rethrow;
    }
  }

  // User logout
  Future<void> logout({bool silent = false}) async {
    if (!silent) {
      state = state.copyWith(isLoading: true);
    }

    try {
      _logger.info('Logging out user');
      await _authService.logout();

      state = AuthState.initial().copyWith(
        isLoading: false,
        status: AuthStatus.unauthenticated,
      );
      _logger.info('Logout successful');
    } catch (e) {
      _logger.error('Logout error: $e');
      if (!silent) {
        state = state.copyWith(
          isLoading: false,
          error: e.toString(),
        );
      }
    }
  }

  // Update user information
  Future<void> updateUser(User user) async {
    state = state.copyWith(user: user);
    _logger.info('Updated user: ${user.name}');
  }

  // Clear any error messages
  void clearError() {
    state = state.clearError();
  }
}

// Auth notifier provider
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

// Convenience providers for specific auth states
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).isAuthenticated;
});

final authUserProvider = Provider<User?>((ref) {
  return ref.watch(authNotifierProvider).user;
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authNotifierProvider).error;
});

final authStatusProvider = Provider<AuthStatus>((ref) {
  return ref.watch(authNotifierProvider).status;
});
