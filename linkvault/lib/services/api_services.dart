import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/constants.dart';
import 'dart:html' as html;

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});
  @override
  String toString() => 'ApiException: $message (status code: $statusCode)';
}

class ApiServices {
  final _secureStorage = const FlutterSecureStorage();

  //get auth token
  Future<String?> getToken() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } else {
      return await _secureStorage.read(key: 'auth_token');
    }
  }

  // Save auth token
  Future<void> saveToken(String token) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
    } else {
      await _secureStorage.write(key: 'auth_token', value: token);
    }
  }

  // Clear auth token
  Future<void> clearToken() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
    } else {
      await _secureStorage.delete(key: 'auth_token');
    }
  }
// headers with auth token

  Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
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
  Future<Map<String, dynamic>> postMultipart(
    String endpoint,
    Map<String, String> fields,
    String? avatarPath,
    String fileFieldName,
  ) async {
    final uri = Uri.parse(ApiConstants.baseUrl + endpoint);
    final request = http.MultipartRequest('POST', uri);

    request.fields.addAll(fields);

    try {
      if (kIsWeb) {
        final file = await _pickWebFile();
        if (file == null) throw ApiException('No file selected.');

        final fileBytes = await _readFileBytes(file);
        request.files.add(
          http.MultipartFile.fromBytes(
            fileFieldName,
            fileBytes,
            filename: file.name,
          ),
        );
      } else if (avatarPath != null && avatarPath.isNotEmpty) {
        // Mobile: Use provided file path
        request.files.add(
          await http.MultipartFile.fromPath(
            fileFieldName,
            avatarPath,
          ),
        );
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(responseBody);
      } else {
        throw ApiException(
          'Upload failed (${response.statusCode})',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw ApiException('File upload error: ${e.toString()}');
    }
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
}

Future<html.File?> _pickWebFile() async {
  final completer = Completer<html.File?>();
  final input = html.FileUploadInputElement();
  input.accept = 'image/*'; // or customize as needed
  input.click();

  input.onChange.listen((event) {
    if (input.files!.isNotEmpty) {
      completer.complete(input.files!.first);
    } else {
      completer.complete(null); // User cancelled
    }
  });

  return completer.future;
}

Future<Uint8List> _readFileBytes(html.File file) async {
  final reader = html.FileReader();
  final completer = Completer<Uint8List>();

  reader.readAsArrayBuffer(file);
  reader.onLoadEnd.listen((_) {
    completer.complete(reader.result as Uint8List);
  });

  return completer.future;
}
