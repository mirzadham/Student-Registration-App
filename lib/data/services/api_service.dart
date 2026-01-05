import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';

/// HTTP API Service with Firebase token injection
class ApiService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Get the base URL based on platform
  String get baseUrl {
    // For web testing, use localhost
    // For Android emulator, use 10.0.2.2
    return ApiConstants.baseUrl;
  }

  /// Get current user's ID token
  Future<String?> _getIdToken() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return await user.getIdToken();
  }

  /// Build headers with authorization
  Future<Map<String, String>> _buildHeaders() async {
    final token = await _getIdToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Perform GET request
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final headers = await _buildHeaders();
      final response = await _client.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Perform POST request
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final headers = await _buildHeaders();
      final response = await _client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Perform PUT request
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final headers = await _buildHeaders();
      final response = await _client.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Perform DELETE request
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final headers = await _buildHeaders();
      final response = await _client.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle HTTP response
  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    final error = body['error'] ?? 'Unknown error';
    throw NetworkException(error.toString(), statusCode: response.statusCode);
  }

  /// Convert exceptions to app exceptions
  AppException _handleError(dynamic error) {
    if (error is NetworkException) {
      return error;
    }
    if (error is http.ClientException) {
      return NetworkException(
        'Network error. Please check your connection.',
        originalError: error,
      );
    }
    return NetworkException(
      'An unexpected error occurred.',
      originalError: error,
    );
  }

  /// Dispose the HTTP client
  void dispose() {
    _client.close();
  }
}
