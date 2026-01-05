import '../models/student_model.dart';
import '../services/api_service.dart';
import '../../core/errors/app_exception.dart';

/// Repository for student-related operations
class StudentRepository {
  final ApiService _apiService;

  StudentRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  /// Register a new student profile
  Future<void> registerStudent({
    required String uid,
    required StudentModel student,
  }) async {
    try {
      final data = student.toRegistrationJson(uid);
      await _apiService.post('/register', data);
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        'Failed to register student profile.',
        originalError: e,
      );
    }
  }

  /// Get student profile by ID
  Future<StudentModel> getStudent(String studentId) async {
    try {
      final response = await _apiService.get('/students/$studentId');
      return StudentModel.fromJson(response);
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        'Failed to fetch student profile.',
        originalError: e,
      );
    }
  }

  /// Update student profile
  Future<void> updateStudent({
    required String studentId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await _apiService.put('/students/$studentId', updates);
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        'Failed to update student profile.',
        originalError: e,
      );
    }
  }

  /// Update student model (encrypts sensitive fields automatically)
  Future<void> updateStudentModel({
    required String studentId,
    required StudentModel student,
  }) async {
    final updates = student.toJson();
    await updateStudent(studentId: studentId, updates: updates);
  }
}
