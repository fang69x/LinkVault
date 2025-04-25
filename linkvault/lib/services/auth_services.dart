import 'package:linkvault/services/api_services.dart';

import '../models/user_model.dart';

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
      await getCurrentUser();
      return true;
    } catch (e) {
      return false;
    }
  }
}
