import '../models/course_model.dart';
import '../models/enrollment_model.dart';
import '../services/api_service.dart';
import '../../core/errors/app_exception.dart';

/// Repository for course and enrollment operations
class CourseRepository {
  final ApiService _apiService;

  CourseRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  /// Get all available courses
  Future<List<CourseModel>> getCourses() async {
    try {
      final response = await _apiService.get('/courses');
      final coursesList = response['courses'] as List<dynamic>? ?? [];
      return coursesList
          .map((json) => CourseModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to fetch courses.', originalError: e);
    }
  }

  /// Get course by ID
  Future<CourseModel> getCourse(String courseId) async {
    try {
      final response = await _apiService.get('/courses/$courseId');
      return CourseModel.fromJson(response);
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        'Failed to fetch course details.',
        originalError: e,
      );
    }
  }

  /// Enroll in a course
  Future<String> enrollInCourse(String courseId) async {
    try {
      final response = await _apiService.post('/enrollments/enroll', {
        'courseId': courseId,
      });
      return response['enrollmentId'] as String? ?? '';
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to enroll in course.', originalError: e);
    }
  }

  /// Get student's enrollments
  Future<List<EnrollmentModel>> getStudentEnrollments(String studentId) async {
    try {
      final response = await _apiService.get('/enrollments/student/$studentId');
      final enrollmentsList = response['enrollments'] as List<dynamic>? ?? [];
      return enrollmentsList
          .map((json) => EnrollmentModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to fetch enrollments.', originalError: e);
    }
  }

  /// Drop a course (unenroll)
  Future<void> dropCourse(String enrollmentId) async {
    try {
      await _apiService.delete('/enrollments/$enrollmentId');
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to drop course.', originalError: e);
    }
  }
}
