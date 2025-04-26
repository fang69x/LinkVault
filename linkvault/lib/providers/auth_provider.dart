import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linkvault/models/user_model.dart';
import 'package:linkvault/services/api_services.dart';
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
    debugPrint('''AuthState Update:
    Authenticated: ${value.isAuthenticated}
    Loading: ${value.isLoading}
    Error: ${value.error}
  ''');
    _controller.add(value);
  }

  Future<bool> checkAuthStatus() async {
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
        return true;
      } else {
        state = state.copyWith(
          isAuthenticated: false,
          user: null,
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isAuthenticated: false,
        user: null,
        isLoading: false,
        error: e.toString(),
      );
      // Important:  Don't throw here, handle in the caller.
      return false; // Return false to indicate failure
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
      // Explicitly add to stream
      _controller.add(state);
      debugPrint(
          'Login successful - Token: ${await _authService.getCurrentUser()}');
    } catch (e, stackTrace) {
      debugPrint('Login error: $e');
      debugPrint('Stack trace: $stackTrace');
      state = state.copyWith(
        isLoading: false,
        error: e is SocketException
            ? 'Connection failed. Check your network'
            : e.toString(),
      );
      _controller.add(state);
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
      rethrow;
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

class AuthService {
  final ApiServices _apiService = ApiServices();

  Future<User> getCurrentUser() async {
    try {
      final response = await _apiService.get('/api/auth/me');
      return User.fromJson(response['user']);
    } catch (e) {
      rethrow;
    }
  }

  // User registration with optional avatar
  Future<User> register(String name, String email, String password,
      {String? avatarPath}) async {
    try {
      final Map<String, String> fields = {
        'name': name,
        'email': email,
        'password': password,
      };

      final response = await _apiService.postMultipart(
        '/api/auth/register',
        fields,
        avatarPath ?? '',
        'avatar',
      );

      await _apiService.saveToken(response['token']);
      print("Saving token: ${response['token']}");
      return User.fromJson(response['user']);
    } catch (e) {
      rethrow;
    }
  }

  // User login
  Future<User> login(String email, String password) async {
    try {
      final data = {
        'email': email,
        'password': password,
      };

      final response = await _apiService.post('/api/auth/login', data);

      await _apiService.saveToken(response['token']);
      return User.fromJson(response['user']);
    } catch (e) {
      rethrow;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _apiService.getToken();
    return token != null;
  }

  // Logout user
  Future<void> logout() async {
    await _apiService.clearToken();
  }

  Future<bool> verifyToken() async {
    try {
      // Check if token exists first
      final token = await _apiService.getToken();
      if (token == null || token.isEmpty) {
        print("No token found - first time user");
        return false;
      }
      // Only try to validate with the server if we have a token
      await getCurrentUser();
      return true;
    } catch (e) {
      print("Token verification failed: $e");
      return false;
    }
  }
}
