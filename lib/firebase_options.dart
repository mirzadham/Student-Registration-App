import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default Firebase configuration options for the current platform.
///
/// IMPORTANT: Replace these placeholder values with your actual Firebase
/// configuration from the Firebase Console.
///
/// To get your configuration:
/// 1. Go to Firebase Console > Project Settings
/// 2. Under "Your apps", select your platform (Web, Android, iOS)
/// 3. Copy the configuration values
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  /// Web configuration

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDDj9pT2PQHyQB6KmNujLQ7F9P3ttBA6Cg',
    appId: '1:175260464912:web:52dd7059552e0bf72d5795',
    messagingSenderId: '175260464912',
    projectId: 'student-registration-app-69d19',
    authDomain: 'student-registration-app-69d19.firebaseapp.com',
    storageBucket: 'student-registration-app-69d19.firebasestorage.app',
    measurementId: 'G-BEPRXKQ47Y',
  );

  /// TODO: Replace with your actual Firebase Web configuration

  /// Android configuration

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDEBiyis3x-Y0685rrrAv1WLMD3nHkJLpE',
    appId: '1:175260464912:android:72bde3135190b9ad2d5795',
    messagingSenderId: '175260464912',
    projectId: 'student-registration-app-69d19',
    storageBucket: 'student-registration-app-69d19.firebasestorage.app',
  );

  /// TODO: Replace with your actual Firebase Android configuration

  /// iOS configuration
  /// TODO: Replace with your actual Firebase iOS configuration
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: '1:175260464912:ios:YOUR_IOS_APP_ID',
    messagingSenderId: '175260464912',
    projectId: 'student-registration-app-69d19',
    storageBucket: 'student-registration-app-69d19.firebasestorage.app',
    iosBundleId: 'com.studentapp.studentRegistrationApp',
  );
}