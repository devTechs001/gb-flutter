import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String _baseUrl = AppConfig.backendUrl;
  String? _token;
  static const Duration _timeout = Duration(seconds: 30);

  Future<String?> getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    return _token;
  }

  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  Future<Map<String, dynamic>> get(String endpoint) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    final response = await http.get(uri, headers: _headers).timeout(_timeout);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode(body),
    ).timeout(_timeout);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    final response = await http.put(
      uri,
      headers: _headers,
      body: jsonEncode(body),
    ).timeout(_timeout);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> patch(String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    final response = await http.patch(
      uri,
      headers: _headers,
      body: jsonEncode(body),
    ).timeout(_timeout);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    final response = await http.delete(uri, headers: _headers).timeout(_timeout);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> uploadFile(
    String filePath,
    String remotePath, {
    String fieldName = 'file',
  }) async {
    final uri = Uri.parse('$_baseUrl/api/media/upload');
    final request = http.MultipartRequest('POST', uri);
    if (_token != null) {
      request.headers['Authorization'] = 'Bearer $_token';
    }
    request.fields['path'] = remotePath;
    request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));
    final streamedResponse = await request.send().timeout(const Duration(minutes: 5));
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> uploadMultipleFiles(
    List<String> filePaths,
    String remotePath, {
    String fieldName = 'files',
  }) async {
    final uri = Uri.parse('$_baseUrl/api/media/upload-multiple');
    final request = http.MultipartRequest('POST', uri);
    if (_token != null) {
      request.headers['Authorization'] = 'Bearer $_token';
    }
    request.fields['path'] = remotePath;
    for (final path in filePaths) {
      request.files.add(await http.MultipartFile.fromPath(fieldName, path));
    }
    final streamedResponse = await request.send().timeout(const Duration(minutes: 10));
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      body = {'success': false, 'error': 'Invalid response from server'};
    }
    if (response.statusCode >= 400) {
      throw ApiException(
        response.statusCode,
        body['error'] as String? ?? 'Request failed',
      );
    }
    return body;
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}
