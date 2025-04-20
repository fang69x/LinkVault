import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/constants.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});
  @override
  String toString() => 'ApiException: $message (status code: $statusCode)';
}

class ApiServices {
  final _storage = const FlutterSecureStorage();

  //get auth token
  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  // save auth token
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

//clear auth token
  Future<void> clearToken() async {
    await _storage.delete(key: 'auth_token');
  }
// headers with auth token

  Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

// get request
  Future<dynamic> get(String endpoint) async {
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse(ApiConstants.baseUrl + endpoint),
      headers: headers,
    );
    return _handleResponse(response);
  }

// post request

  Future<dynamic> post(String endpoint, dynamic data) async {
    final headers = await getHeaders();
    final response = await http.post(
      Uri.parse(ApiConstants.baseUrl + endpoint),
      headers: headers,
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

//post with multipart (for image upload)
  Future<dynamic> postMultipart(String endpoint, Map<String, String> fields,
      String filePath, String fileField) async {
    final token = await getToken();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(ApiConstants.baseUrl + endpoint),
    );

    // Add auth header
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    // Add text fields
    request.fields.addAll(fields);

    // Add file if provided
    if (filePath.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath(fileField, filePath));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return _handleResponse(response);
  }

  // PUT request
  Future<dynamic> put(String endpoint, dynamic data) async {
    final headers = await getHeaders();
    final response = await http.put(
      Uri.parse(ApiConstants.baseUrl + endpoint),
      headers: headers,
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  // DELETE request
  Future<dynamic> delete(String endpoint) async {
    final headers = await getHeaders();
    final response = await http.delete(
      Uri.parse(ApiConstants.baseUrl + endpoint),
      headers: headers,
    );
    return _handleResponse(response);
  }

  // Handle API response
  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final responseBody =
        response.body.isNotEmpty ? jsonDecode(response.body) : null;

    if (statusCode >= 200 && statusCode < 300) {
      return responseBody;
    } else {
      final message = responseBody != null && responseBody['message'] != null
          ? responseBody['message']
          : 'Unknown error occurred';
      throw ApiException(message, statusCode: statusCode);
    }
  }
}
