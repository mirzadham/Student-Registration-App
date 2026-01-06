import 'package:flutter/foundation.dart';
import '../../data/models/course_model.dart';
import '../../data/models/enrollment_model.dart';
import '../../data/repositories/course_repository.dart';
import '../../core/errors/app_exception.dart';

/// Enrollment state
enum EnrollmentState { initial, loading, loaded, enrolling, dropping, error }

/// Enrollment ViewModel for courses and enrollments
class EnrollmentViewModel extends ChangeNotifier {
  final CourseRepository _courseRepository;

  EnrollmentState _state = EnrollmentState.initial;
  List<CourseModel> _courses = [];
  List<EnrollmentModel> _enrollments = [];
  String? _errorMessage;
  bool _isLoading = false;

  EnrollmentViewModel({CourseRepository? courseRepository})
    : _courseRepository = courseRepository ?? CourseRepository();

  // Getters
  EnrollmentState get state => _state;
  List<CourseModel> get courses => _courses;
  List<EnrollmentModel> get enrollments => _enrollments;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  /// Get enrolled course IDs
  Set<String> get enrolledCourseIds =>
      _enrollments.where((e) => e.isActive).map((e) => e.courseId).toSet();

  /// Check if enrolled in a course
  bool isEnrolledIn(String courseId) => enrolledCourseIds.contains(courseId);

  /// Get enrollment for a course
  EnrollmentModel? getEnrollmentFor(String courseId) {
    try {
      return _enrollments.firstWhere(
        (e) => e.courseId == courseId && e.isActive,
      );
    } catch (_) {
      return null;
    }
  }

  /// Load all courses
  Future<void> loadCourses() async {
    _setLoading(true);
    _clearError();

    try {
      _courses = await _courseRepository.getCourses();
      _state = EnrollmentState.loaded;
      _setLoading(false);
    } on NetworkException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Failed to load courses.');
    }
  }

  /// Load student's enrollments
  Future<void> loadEnrollments(String studentId) async {
    _setLoading(true);
    _clearError();

    try {
      _enrollments = await _courseRepository.getStudentEnrollments(studentId);
      _state = EnrollmentState.loaded;
      _setLoading(false);
    } on NetworkException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Failed to load enrollments.');
    }
  }

  /// Load both courses and enrollments
  Future<void> loadAll(String studentId) async {
    _setLoading(true);
    _clearError();

    try {
      // Load in parallel
      final results = await Future.wait([
        _courseRepository.getCourses(),
        _courseRepository.getStudentEnrollments(studentId),
      ]);

      _courses = results[0] as List<CourseModel>;
      _enrollments = results[1] as List<EnrollmentModel>;
      _state = EnrollmentState.loaded;
      _setLoading(false);
    } on NetworkException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Failed to load data.');
    }
  }

  /// Enroll in a course
  Future<bool> enrollInCourse(String courseId) async {
    _state = EnrollmentState.enrolling;
    _clearError();
    notifyListeners();

    try {
      // Get the actual enrollment ID from the server response
      final enrollmentId = await _courseRepository.enrollInCourse(courseId);

      // Find the course and create a local enrollment with the real ID
      final course = _courses.firstWhere((c) => c.id == courseId);
      final enrollment = EnrollmentModel(
        id: enrollmentId, // Use the actual enrollment ID from the server
        studentId: '',
        courseId: courseId,
        courseName: course.name,
        courseCode: course.code,
        status: EnrollmentStatus.enrolled,
        enrolledAt: DateTime.now(),
      );
      _enrollments.add(enrollment);

      // Update course enrolled count locally
      final courseIndex = _courses.indexWhere((c) => c.id == courseId);
      if (courseIndex >= 0) {
        _courses[courseIndex] = _courses[courseIndex].copyWith(
          enrolledCount: _courses[courseIndex].enrolledCount + 1,
        );
      }

      _state = EnrollmentState.loaded;
      notifyListeners();
      return true;
    } on NetworkException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Failed to enroll in course.');
      return false;
    }
  }

  /// Drop a course
  Future<bool> dropCourse(String courseId) async {
    final enrollment = getEnrollmentFor(courseId);
    if (enrollment == null) {
      _setError('Enrollment not found.');
      return false;
    }

    _state = EnrollmentState.dropping;
    _clearError();
    notifyListeners();

    try {
      await _courseRepository.dropCourse(enrollment.id);

      // Remove enrollment locally
      _enrollments.removeWhere((e) => e.id == enrollment.id);

      // Update course enrolled count locally
      final courseIndex = _courses.indexWhere((c) => c.id == courseId);
      if (courseIndex >= 0) {
        _courses[courseIndex] = _courses[courseIndex].copyWith(
          enrolledCount: (_courses[courseIndex].enrolledCount - 1).clamp(
            0,
            9999,
          ),
        );
      }

      _state = EnrollmentState.loaded;
      notifyListeners();
      return true;
    } on NetworkException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Failed to drop course.');
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) {
      _state = EnrollmentState.loading;
    }
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _state = EnrollmentState.error;
    _isLoading = false;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  /// Clear error state
  void clearError() {
    _errorMessage = null;
    _state = EnrollmentState.loaded;
    notifyListeners();
  }

  /// Reset state
  void reset() {
    _state = EnrollmentState.initial;
    _courses = [];
    _enrollments = [];
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
