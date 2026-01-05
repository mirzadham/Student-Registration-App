import 'package:firebase_auth/firebase_auth.dart';
import '../../core/errors/app_exception.dart';
import '../services/secure_storage_service.dart';

/// Authentication repository handling Firebase Auth operations
class AuthRepository {
  final FirebaseAuth _auth;
  final SecureStorageService _secureStorage;

  AuthRepository({FirebaseAuth? auth, SecureStorageService? secureStorage})
    : _auth = auth ?? FirebaseAuth.instance,
      _secureStorage = secureStorage ?? SecureStorageService();

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  /// Get current user ID
  String? get userId => currentUser?.uid;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Register a new user with email and password
  Future<User> registerWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw AuthException('Registration failed. Please try again.');
      }

      // Save user ID to secure storage
      await _secureStorage.saveUserId(credential.user!.uid);

      return credential.user!;
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        parseFirebaseAuthError(e.code),
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(
        'An unexpected error occurred during registration.',
        originalError: e,
      );
    }
  }

  /// Sign in with email and password
  Future<User> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw AuthException('Sign in failed. Please try again.');
      }

      // Save user ID to secure storage
      await _secureStorage.saveUserId(credential.user!.uid);

      return credential.user!;
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        parseFirebaseAuthError(e.code),
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(
        'An unexpected error occurred during sign in.',
        originalError: e,
      );
    }
  }

  /// Sign in anonymously
  Future<User> signInAnonymously() async {
    try {
      final credential = await _auth.signInAnonymously();

      if (credential.user == null) {
        throw AuthException('Anonymous sign in failed. Please try again.');
      }

      // Save user ID to secure storage
      await _secureStorage.saveUserId(credential.user!.uid);

      return credential.user!;
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        parseFirebaseAuthError(e.code),
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(
        'An unexpected error occurred during anonymous sign in.',
        originalError: e,
      );
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _secureStorage.clearSession();
    } catch (e) {
      throw AuthException(
        'Sign out failed. Please try again.',
        originalError: e,
      );
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        parseFirebaseAuthError(e.code),
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw AuthException(
        'Failed to send password reset email.',
        originalError: e,
      );
    }
  }

  /// Get current user's ID token
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    try {
      return await currentUser?.getIdToken(forceRefresh);
    } catch (e) {
      return null;
    }
  }

  /// Reload current user data
  Future<void> reloadUser() async {
    await currentUser?.reload();
  }
}
