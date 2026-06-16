import 'dart:convert';
import 'dart:io';

import 'package:ev_connect_india/config/app_config.dart';
import 'package:ev_connect_india/services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  const ApiException({
    required this.message,
    this.statusCode,
    this.errors,
  });

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}

class ApiResponse<T> {
  final T? data;
  final String? error;
  final int? statusCode;
  final bool isSuccess;

  const ApiResponse({
    this.data,
    this.error,
    this.statusCode,
    required this.isSuccess,
  });
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final http.Client _client = http.Client();

  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';

  String? _baseUrl;
  String? _cachedToken;
  bool _isRefreshing = false;

  String get baseUrl => _baseUrl ?? AppConfig.baseUrl;

  void setBaseUrl(String url) {
    _baseUrl = url;
  }

  Map<String, String> get _defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-App-Version': AppConfig.appVersion,
        'X-Platform': Platform.isAndroid ? 'android' : 'ios',
      };

  Future<Map<String, String>> get _authHeaders async {
    final headers = Map<String, String>.from(_defaultHeaders);
    final token = await getToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<String?> getToken() async {
    if (_cachedToken != null) return _cachedToken;
    _cachedToken = await _secureStorage.read(key: _tokenKey);
    return _cachedToken;
  }

  Future<void> setToken(String token) async {
    _cachedToken = token;
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  Future<void> clearToken() async {
    _cachedToken = null;
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: _refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return _secureStorage.read(key: _refreshTokenKey);
  }

  Future<void> _refreshToken() async {
    if (_isRefreshing) return;
    _isRefreshing = true;

    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        throw const ApiException(message: 'No refresh token available');
      }

      final response = await _client.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: _defaultHeaders,
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        await setToken(data['token'] as String);
        if (data['refresh_token'] != null) {
          await saveRefreshToken(data['refresh_token'] as String);
        }
      } else if (response.statusCode == 401) {
        await AuthService().signOut();
        throw const ApiException(
          message: 'Session expired. Please login again.',
          statusCode: 401,
        );
      } else {
        throw ApiException(
          message: 'Token refresh failed',
          statusCode: response.statusCode,
        );
      }
    } finally {
      _isRefreshing = false;
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> _executeWithAuth(
    Future<http.Response> Function() request,
  ) async {
    try {
      final response = await request();

      if (response.statusCode == 401) {
        await _refreshToken();
        final retryResponse = await request();
        return _handleResponse(retryResponse);
      }

      return _handleResponse(response);
    } on SocketException {
      return const ApiResponse(
        error: 'No internet connection',
        isSuccess: false,
        statusCode: -1,
      );
    } on http.ClientException {
      return const ApiResponse(
        error: 'Connection timeout',
        isSuccess: false,
        statusCode: -1,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      return ApiResponse(
        error: 'Unexpected error: ${e.toString()}',
        isSuccess: false,
        statusCode: -1,
      );
    }
  }

  ApiResponse<Map<String, dynamic>> _handleResponse(http.Response response) {
    final body = response.body.isNotEmpty
        ? jsonDecode(response.body) as Map<String, dynamic>
        : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse(
        data: body['data'] as Map<String, dynamic>?,
        isSuccess: true,
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode == 422) {
      return ApiResponse(
        error: body['message'] as String? ?? 'Validation error',
        isSuccess: false,
        statusCode: response.statusCode,
      );
    }

    return ApiResponse(
      error: body['message'] as String? ?? 'Something went wrong',
      isSuccess: false,
      statusCode: response.statusCode,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> get(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    return _executeWithAuth(() async {
      final uri = Uri.parse('$baseUrl$endpoint').replace(
        queryParameters: queryParams,
      );
      final headers = await _authHeaders;
      return _client.get(uri, headers: headers);
    });
  }

  Future<ApiResponse<Map<String, dynamic>>> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    return _executeWithAuth(() async {
      final uri = Uri.parse('$baseUrl$endpoint');
      final headers = await _authHeaders;
      return _client.post(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
    });
  }

  Future<ApiResponse<Map<String, dynamic>>> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    return _executeWithAuth(() async {
      final uri = Uri.parse('$baseUrl$endpoint');
      final headers = await _authHeaders;
      return _client.put(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
    });
  }

  Future<ApiResponse<Map<String, dynamic>>> patch(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    return _executeWithAuth(() async {
      final uri = Uri.parse('$baseUrl$endpoint');
      final headers = await _authHeaders;
      return _client.patch(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
    });
  }

  Future<ApiResponse<Map<String, dynamic>>> delete(String endpoint) async {
    return _executeWithAuth(() async {
      final uri = Uri.parse('$baseUrl$endpoint');
      final headers = await _authHeaders;
      return _client.delete(uri, headers: headers);
    });
  }

  Future<ApiResponse<Map<String, dynamic>>> upload(
    String endpoint, {
    required String filePath,
    String fileKey = 'file',
    Map<String, String>? fields,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final request = http.MultipartRequest('POST', uri);

      final token = await getToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers.addAll(_defaultHeaders);

      if (fields != null) {
        request.fields.addAll(fields);
      }

      request.files.add(
        await http.MultipartFile.fromPath(fileKey, filePath),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } on SocketException {
      return const ApiResponse(
        error: 'No internet connection',
        isSuccess: false,
        statusCode: -1,
      );
    } catch (e) {
      return ApiResponse(
        error: 'Upload failed: ${e.toString()}',
        isSuccess: false,
        statusCode: -1,
      );
    }
  }

  void dispose() {
    _client.close();
  }
}
