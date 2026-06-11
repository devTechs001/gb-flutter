import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String _baseUrl = AppConfig.backendUrl;
  String? _token;

  String get baseUrl => _baseUrl;

  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    return _token;
  }

  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  Future<Map<String, dynamic>> get(String path) async {
    final url = Uri.parse('$_baseUrl$path');
    final response = await http.get(url, headers: headers);
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    final url = Uri.parse('$_baseUrl$path');
    final response = await http.post(url, headers: headers, body: jsonEncode(body));
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body) async {
    final url = Uri.parse('$_baseUrl$path');
    final response = await http.put(url, headers: headers, body: jsonEncode(body));
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> patch(String path, Map<String, dynamic> body) async {
    final url = Uri.parse('$_baseUrl$path');
    final response = await http.patch(url, headers: headers, body: jsonEncode(body));
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> delete(String path) async {
    final url = Uri.parse('$_baseUrl$path');
    final response = await http.delete(url, headers: headers);
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> uploadFile(String path, File file, String fieldName) async {
    final url = Uri.parse('$_baseUrl$path');
    final request = http.MultipartRequest('POST', url);
    request.headers.addAll(headers);
    request.files.add(await http.MultipartFile.fromPath(fieldName, file.path));
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> uploadMultipleFiles(
    String path, List<File> files, String fieldName) async {
    final url = Uri.parse('$_baseUrl$path');
    final request = http.MultipartRequest('POST', url);
    request.headers.addAll(headers);
    for (final file in files) {
      request.files.add(await http.MultipartFile.fromPath(fieldName, file.path));
    }
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return jsonDecode(response.body);
  }
}
