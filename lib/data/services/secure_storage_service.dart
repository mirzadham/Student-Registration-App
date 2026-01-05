import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/app_constants.dart';

/// Secure storage service for sensitive data
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
          );

  /// Store a value securely
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Read a value from secure storage
  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  /// Delete a value from secure storage
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  /// Delete all stored values
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  /// Check if a key exists
  Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }

  // Convenience methods for common keys

  /// Store user token
  Future<void> saveUserToken(String token) async {
    await write(AppConstants.userTokenKey, token);
  }

  /// Get user token
  Future<String?> getUserToken() async {
    return await read(AppConstants.userTokenKey);
  }

  /// Store user ID
  Future<void> saveUserId(String userId) async {
    await write(AppConstants.userIdKey, userId);
  }

  /// Get user ID
  Future<String?> getUserId() async {
    return await read(AppConstants.userIdKey);
  }

  /// Clear user session data
  Future<void> clearSession() async {
    await delete(AppConstants.userTokenKey);
    await delete(AppConstants.userIdKey);
  }
}
