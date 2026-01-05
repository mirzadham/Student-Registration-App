import 'package:flutter/foundation.dart';
import '../../data/models/student_model.dart';
import '../../data/repositories/student_repository.dart';
import '../../core/errors/app_exception.dart';

/// Registration state
enum RegistrationState { initial, loading, success, error }

/// Registration ViewModel for student profile management
class RegistrationViewModel extends ChangeNotifier {
  final StudentRepository _studentRepository;

  RegistrationState _state = RegistrationState.initial;
  StudentModel? _student;
  String? _errorMessage;
  bool _isLoading = false;
  bool _isProfileComplete = false;

  RegistrationViewModel({StudentRepository? studentRepository})
    : _studentRepository = studentRepository ?? StudentRepository();

  // Getters
  RegistrationState get state => _state;
  StudentModel? get student => _student;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isProfileComplete => _isProfileComplete;

  /// Register student profile after Firebase Auth registration
  Future<bool> registerStudentProfile({
    required String uid,
    required String email,
    required String name,
    String? icNumber,
    String? phoneNumber,
    String? address,
    String? emergencyContact,
    String? dateOfBirth,
    String? program,
    int? enrollmentYear,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final studentModel = StudentModel(
        id: uid,
        email: email,
        name: name,
        icNumber: icNumber,
        phoneNumber: phoneNumber,
        address: address,
        emergencyContact: emergencyContact,
        dateOfBirth: dateOfBirth,
        program: program,
        enrollmentYear: enrollmentYear,
      );

      await _studentRepository.registerStudent(uid: uid, student: studentModel);

      _student = studentModel;
      _isProfileComplete = true;
      _state = RegistrationState.success;
      _setLoading(false);
      return true;
    } on NetworkException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Failed to register student profile.');
      return false;
    }
  }

  /// Load student profile
  Future<bool> loadStudentProfile(String studentId) async {
    _setLoading(true);
    _clearError();

    try {
      _student = await _studentRepository.getStudent(studentId);
      _isProfileComplete = true;
      _state = RegistrationState.success;
      _setLoading(false);
      return true;
    } on NetworkException catch (e) {
      // If student not found, profile is not complete
      if (e.statusCode == 404) {
        _isProfileComplete = false;
        _state = RegistrationState.initial;
        _setLoading(false);
        return false;
      }
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Failed to load student profile.');
      return false;
    }
  }

  /// Update student profile
  Future<bool> updateStudentProfile({
    required String studentId,
    String? name,
    String? icNumber,
    String? phoneNumber,
    String? address,
    String? emergencyContact,
    String? dateOfBirth,
    String? program,
    int? enrollmentYear,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedStudent = _student?.copyWith(
        name: name,
        icNumber: icNumber,
        phoneNumber: phoneNumber,
        address: address,
        emergencyContact: emergencyContact,
        dateOfBirth: dateOfBirth,
        program: program,
        enrollmentYear: enrollmentYear,
      );

      if (updatedStudent == null) {
        _setError('No student profile to update.');
        return false;
      }

      await _studentRepository.updateStudentModel(
        studentId: studentId,
        student: updatedStudent,
      );

      _student = updatedStudent;
      _state = RegistrationState.success;
      _setLoading(false);
      return true;
    } on NetworkException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Failed to update student profile.');
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) {
      _state = RegistrationState.loading;
    }
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _state = RegistrationState.error;
    _isLoading = false;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  /// Clear error state
  void clearError() {
    _errorMessage = null;
    _state = RegistrationState.initial;
    notifyListeners();
  }

  /// Reset state
  void reset() {
    _state = RegistrationState.initial;
    _student = null;
    _errorMessage = null;
    _isLoading = false;
    _isProfileComplete = false;
    notifyListeners();
  }
}
