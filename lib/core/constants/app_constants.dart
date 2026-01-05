/// API Base URLs
class ApiConstants {
  // Use this for Firebase emulator testing
  static const String emulatorBaseUrl = 'http://10.0.2.2:5001/student-registration-app-69d19/us-central1/api';
  
  // Use this for local web testing
  static const String localWebBaseUrl = 'http://localhost:5001/student-registration-app-69d19/us-central1/api';
  
  // Use this for production (update with your deployed function URL)
  static const String productionBaseUrl = 'https://us-central1-student-registration-app-69d19.cloudfunctions.net/api';
  
  // Toggle between emulator and production
  static const bool useEmulator = true;
  
  static String get baseUrl => useEmulator ? emulatorBaseUrl : productionBaseUrl;
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
