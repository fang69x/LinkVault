import 'package:linkvault/services/api_services.dart';
import '../models/user_model.dart';
import 'package:flutter/foundation.dart' show debugPrint;

class AuthService {
  final ApiServices _apiService = ApiServices();

  // Get current user details from the API
  Future<User> getCurrentUser() async {
    try {
      debugPrint('Fetching current user details');
      final response = await _apiService.get('/api/auth/me');

      if (response['user'] == null) {
        throw Exception('User data not found in response');
      }

      debugPrint('User details fetched successfully');
      return User.fromJson(response['user']);
    } catch (e) {
      debugPrint('getCurrentUser error: $e');
      rethrow;
    }
  }

  // User registration with optional avatar
  Future<User> register(String name, String email, String password,
      {String? avatarPath}) async {
    try {
      debugPrint('Attempting to register user: $email');
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

      if (response['token'] == null) {
        throw Exception('Registration successful but no token received');
      }

      if (response['user'] == null) {
        throw Exception('Registration successful but no user data received');
      }

      await _apiService.saveToken(response['token']);
      debugPrint("Token saved after registration");

      return User.fromJson(response['user']);
    } catch (e) {
      debugPrint('Registration failed: $e');
      rethrow;
    }
  }

  // User login
  Future<User> login(String email, String password) async {
    try {
      debugPrint('Attempting login for user: $email');
      final data = {
        'email': email,
        'password': password,
      };

      final response = await _apiService.post('/api/auth/login', data);

      if (response['token'] == null) {
        throw Exception('Login successful but no token received');
      }

      if (response['user'] == null) {
        throw Exception('Login successful but no user data received');
      }

      await _apiService.saveToken(response['token']);

      // Validate token was actually saved
      final savedToken = await _apiService.getToken();
      if (savedToken == null || savedToken.isEmpty) {
        throw Exception('Failed to save authentication token');
      }

      debugPrint('Login successful, token saved');
      return User.fromJson(response['user']);
    } catch (e) {
      debugPrint('Login failed: $e');
      rethrow;
    }
  }

  // Check if user is logged in based on token existence
  Future<bool> isLoggedIn() async {
    final token = await _apiService.getToken();
    return token != null && token.isNotEmpty;
  }

  // Logout user
  Future<void> logout() async {
    try {
      debugPrint('Logging out user');
      // Optionally notify server about logout if your API supports it
      // await _apiService.post('/api/auth/logout', {});

      await _apiService.clearToken();
      debugPrint('Logout successful, token cleared');
    } catch (e) {
      debugPrint('Logout failed: $e');
      // Still clear the token locally even if server logout fails
      await _apiService.clearToken();
      rethrow;
    }
  }

  // Verify if the stored token is valid
  Future<bool> verifyToken() async {
    try {
      final token = await _apiService.getToken();
      if (token == null || token.isEmpty) {
        debugPrint("No token found or token is empty");
        return false;
      }

      // Verify token validity by making a request to protected endpoint
      await getCurrentUser();
      debugPrint("Token verified successfully");
      return true;
    } catch (e) {
      debugPrint("Token verification failed: $e");
      // If token verification fails, clear the invalid token
      await _apiService.clearToken();
      return false;
    }
  }
}
