import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'api_config.dart';

/// Thin HTTP client for the mysihat backend.
///
/// Attaches the bearer token when present, decodes JSON, and maps non-2xx
/// responses to [ApiException] so screens can show `error.message`.
class ApiClient {
  ApiClient({http.Client? httpClient, SharedPreferences? preferences})
    : _http = httpClient ?? http.Client(),
      _preferencesFuture = preferences != null
          ? Future.value(preferences)
          : SharedPreferences.getInstance();

  final http.Client _http;
  final Future<SharedPreferences> _preferencesFuture;
  String? _token;

  Future<void> initialize() async {
    final prefs = await _preferencesFuture;
    _token = prefs.getString(ApiConfig.tokenStorageKey);
  }

  String? get token => _token;

  bool get hasToken => _token != null && _token!.isNotEmpty;

  Future<void> setToken(String? token) async {
    _token = token;
    final prefs = await _preferencesFuture;
    if (token == null || token.isEmpty) {
      await prefs.remove(ApiConfig.tokenStorageKey);
    } else {
      await prefs.setString(ApiConfig.tokenStorageKey, token);
    }
  }

  Future<void> clearToken() => setToken(null);

  Future<Map<String, dynamic>?> getJson(String path, {Map<String, String>? query}) {
    return _send('GET', path, query: query);
  }

  Future<Map<String, dynamic>?> postJson(String path, [Map<String, dynamic>? body]) {
    return _send('POST', path, body: body);
  }

  Future<Map<String, dynamic>?> putJson(String path, [Map<String, dynamic>? body]) {
    return _send('PUT', path, body: body);
  }

  Future<Map<String, dynamic>?> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path').replace(queryParameters: query);
    final headers = <String, String>{
      'Accept': 'application/json',
      if (body != null) 'Content-Type': 'application/json',
      if (hasToken) 'Authorization': 'Bearer $_token',
    };

    late final http.Response response;
    try {
      switch (method) {
        case 'GET':
          response = await _http.get(uri, headers: headers);
        case 'POST':
          response = await _http.post(uri, headers: headers, body: body == null ? null : jsonEncode(body));
        case 'PUT':
          response = await _http.put(uri, headers: headers, body: body == null ? null : jsonEncode(body));
        default:
          throw ApiException(0, 'Unsupported HTTP method: $method');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        0,
        'Cannot reach the API at ${ApiConfig.baseUrl}. Is the backend running?',
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      final decoded = jsonDecode(response.body);
      if (decoded == null) return null;
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      throw ApiException(response.statusCode, 'Expected a JSON object from $path');
    }

    String message = 'Request failed (${response.statusCode})';
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['error'] != null) {
        message = decoded['error'].toString();
      }
    } catch (_) {
      // keep default message
    }
    throw ApiException(response.statusCode, message);
  }
}

/// Shared singleton used by every repository.
final apiClient = ApiClient();

class ApiException implements Exception {
  ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => message;
}
