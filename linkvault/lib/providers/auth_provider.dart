import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linkvault/models/user_model.dart';
import 'package:linkvault/services/auth_services.dart';

class AuthState {
  final bool isAuthenticated;
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({
    required this.isAuthenticated,
    this.user,
    required this.isLoading,
    this.error,
  });

  factory AuthState.initial() => AuthState(
        isAuthenticated: false,
        user: null,
        isLoading: false,
        error: null,
      );

  AuthState copyWith({
    bool? isAuthenticated,
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final _controller = StreamController<AuthState>.broadcast();

  AuthNotifier(this._authService) : super(AuthState.initial());

  Stream<AuthState> get stream => _controller.stream;

  @override
  set state(AuthState value) {
    super.state = value;
    _controller.add(value);
  }

  Future<void> checkAuthStatus() async {
    // Set loading to true at the beginning
    state = state.copyWith(isLoading: true, error: null);

    try {
      final tokenValid = await _authService.verifyToken();

      if (tokenValid) {
        final user = await _authService.getCurrentUser();
        state = state.copyWith(
          isAuthenticated: true,
          user: user,
          isLoading: false,
        );
      } else {
        await logout(silent: true);
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      await logout(silent: true);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authService.login(email, password);
      state = state.copyWith(
        isAuthenticated: true,
        user: user,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> register(String name, String email, String password,
      {String? avatarPath}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
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
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> logout({bool silent = false}) async {
    if (!silent) state = state.copyWith(isLoading: true);
    try {
      await _authService.logout();
      state = AuthState.initial();
    } catch (e) {
      if (!silent) {
        state = state.copyWith(
          isLoading: false,
          error: e.toString(),
        );
      }
    }
  }

  Future<void> updateUser(User user) async {
    state = state.copyWith(user: user);
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});
