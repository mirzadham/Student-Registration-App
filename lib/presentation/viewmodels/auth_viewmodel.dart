import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../data/repositories/auth_repository.dart';
import '../../core/errors/app_exception.dart';

/// Authentication state
enum AuthState { initial, loading, authenticated, unauthenticated, error }

/// Authentication ViewModel
class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthState _state = AuthState.initial;
  User? _user;
  String? _errorMessage;
  bool _isLoading = false;

  AuthViewModel({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository() {
    _init();
  }

  // Getters
  AuthState get state => _state;
  User? get user => _user;
  String? get userId => _user?.uid;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _state == AuthState.authenticated;

  /// Initialize and listen to auth state changes
  void _init() {
    _authRepository.authStateChanges.listen((user) {
      _user = user;
      _state = user != null
          ? AuthState.authenticated
          : AuthState.unauthenticated;
      notifyListeners();
    });
  }

  /// Register with email and password
  Future<bool> registerWithEmailPassword({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _user = await _authRepository.registerWithEmailPassword(
        email: email,
        password: password,
      );
      _state = AuthState.authenticated;
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Registration failed. Please try again.');
      return false;
    }
  }

  /// Sign in with email and password
  Future<bool> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _user = await _authRepository.signInWithEmailPassword(
        email: email,
        password: password,
      );
      _state = AuthState.authenticated;
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Sign in failed. Please try again.');
      return false;
    }
  }

  /// Sign in anonymously
  Future<bool> signInAnonymously() async {
    _setLoading(true);
    _clearError();

    try {
      _user = await _authRepository.signInAnonymously();
      _state = AuthState.authenticated;
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Anonymous sign in failed. Please try again.');
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _setLoading(true);
    _clearError();

    try {
      await _authRepository.signOut();
      _user = null;
      _state = AuthState.unauthenticated;
      _setLoading(false);
    } catch (e) {
      _setError('Sign out failed. Please try again.');
    }
  }

  /// Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _authRepository.sendPasswordResetEmail(email);
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Failed to send password reset email.');
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) {
      _state = AuthState.loading;
    }
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _state = AuthState.error;
    _isLoading = false;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  /// Clear any error state
  void clearError() {
    _errorMessage = null;
    if (_user != null) {
      _state = AuthState.authenticated;
    } else {
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }
}
