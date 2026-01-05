import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

/// AES-256-CBC Encryption Helper
/// Encrypts sensitive data on client-side before sending to backend
/// Decrypts data received from backend
class EncryptionHelper {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static encrypt.Key? _key;
  static encrypt.IV? _iv;

  /// Initialize encryption with a stored or generated key
  static Future<void> initialize() async {
    String? storedKey = await _secureStorage.read(
      key: AppConstants.encryptionKeyStorageKey,
    );

    if (storedKey == null) {
      // Generate a new 256-bit key
      final key = encrypt.Key.fromSecureRandom(32);
      storedKey = base64Encode(key.bytes);
      await _secureStorage.write(
        key: AppConstants.encryptionKeyStorageKey,
        value: storedKey,
      );
    }

    _key = encrypt.Key(base64Decode(storedKey));
    // Use a fixed IV for consistent encryption (in production, consider per-field IV)
    _iv = encrypt.IV.fromLength(16);
  }

  /// Get the encrypter instance
  static encrypt.Encrypter _getEncrypter() {
    if (_key == null) {
      throw StateError('EncryptionHelper not initialized. Call initialize() first.');
    }
    return encrypt.Encrypter(
      encrypt.AES(_key!, mode: encrypt.AESMode.cbc),
    );
  }

  /// Encrypt a plaintext string
  /// Returns base64 encoded ciphertext
  static String encryptData(String plainText) {
    if (plainText.isEmpty) return '';
    
    final encrypter = _getEncrypter();
    final encrypted = encrypter.encrypt(plainText, iv: _iv);
    return encrypted.base64;
  }

  /// Decrypt a base64 encoded ciphertext
  /// Returns the original plaintext
  static String decryptData(String cipherText) {
    if (cipherText.isEmpty) return '';
    
    try {
      final encrypter = _getEncrypter();
      final decrypted = encrypter.decrypt64(cipherText, iv: _iv);
      return decrypted;
    } catch (e) {
      // Return empty string if decryption fails (might be unencrypted data)
      return '';
    }
  }

  /// Check if encryption is initialized
  static bool get isInitialized => _key != null;

  /// Encrypt multiple fields in a map
  static Map<String, dynamic> encryptFields(
    Map<String, dynamic> data,
    List<String> fieldsToEncrypt,
  ) {
    final encryptedData = Map<String, dynamic>.from(data);
    
    for (final field in fieldsToEncrypt) {
      if (encryptedData.containsKey(field) && encryptedData[field] != null) {
        final value = encryptedData[field];
        if (value is String && value.isNotEmpty) {
          encryptedData[field] = encryptData(value);
        }
      }
    }
    
    return encryptedData;
  }

  /// Decrypt multiple fields in a map
  static Map<String, dynamic> decryptFields(
    Map<String, dynamic> data,
    List<String> fieldsToDecrypt,
  ) {
    final decryptedData = Map<String, dynamic>.from(data);
    
    for (final field in fieldsToDecrypt) {
      if (decryptedData.containsKey(field) && decryptedData[field] != null) {
        final value = decryptedData[field];
        if (value is String && value.isNotEmpty) {
          decryptedData[field] = decryptData(value);
        }
      }
    }
    
    return decryptedData;
  }
}
