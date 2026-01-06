/// API Base URLs
class ApiConstants {
  // Use this for Firebase emulator testing (Android)
  static const String emulatorBaseUrl =
      'http://10.0.2.2:5001/student-registration-app-69d19/asia-southeast1/api';

  // Use this for local web testing
  static const String localWebBaseUrl =
      'http://localhost:5001/student-registration-app-69d19/asia-southeast1/api';

  // Production URL (deployed Cloud Functions in asia-southeast1)
  static const String productionBaseUrl =
      'https://asia-southeast1-student-registration-app-69d19.cloudfunctions.net/api';

  // Toggle between emulator and production - set to false to use deployed functions
  static const bool useEmulator = false;

  static String get baseUrl =>
      useEmulator ? emulatorBaseUrl : productionBaseUrl;
}

/// App-wide constants
class AppConstants {
  static const String appName = 'Student Registration';
  static const String appVersion = '1.0.0';

  // Secure storage keys
  static const String encryptionKeyStorageKey = 'encryption_key';
  static const String userTokenKey = 'user_token';
  static const String userIdKey = 'user_id';
}

/// Field validation constants
class ValidationConstants {
  static const int minPasswordLength = 8;
  static const int maxNameLength = 100;
  static const int icNumberLength = 12;
  static const int phoneNumberMinLength = 10;
  static const int phoneNumberMaxLength = 15;
}
