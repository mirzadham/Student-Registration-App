/// Enrollment status enum
enum EnrollmentStatus {
  enrolled,
  dropped,
  completed;

  static EnrollmentStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'enrolled':
        return EnrollmentStatus.enrolled;
      case 'dropped':
        return EnrollmentStatus.dropped;
      case 'completed':
        return EnrollmentStatus.completed;
      default:
        return EnrollmentStatus.enrolled;
    }
  }

  String toJson() => name;
}

/// Enrollment model linking students to courses
class EnrollmentModel {
  final String id;
  final String studentId;
  final String courseId;
  final String? courseName;
  final String? courseCode;
  final EnrollmentStatus status;
  final DateTime? enrolledAt;
  final DateTime? droppedAt;
  final DateTime? completedAt;

  EnrollmentModel({
    required this.id,
    required this.studentId,
    required this.courseId,
    this.courseName,
    this.courseCode,
    this.status = EnrollmentStatus.enrolled,
    this.enrolledAt,
    this.droppedAt,
    this.completedAt,
  });

  /// Check if enrollment is active
  bool get isActive => status == EnrollmentStatus.enrolled;

  /// Create from JSON
  factory EnrollmentModel.fromJson(Map<String, dynamic> json) {
    return EnrollmentModel(
      id: json['id'] ?? '',
      studentId: json['studentId'] ?? '',
      courseId: json['courseId'] ?? '',
      courseName: json['courseName'],
      courseCode: json['courseCode'],
      status: EnrollmentStatus.fromString(json['status'] ?? 'enrolled'),
      enrolledAt: _parseTimestamp(json['enrolledAt'] ?? json['createdAt']),
      droppedAt: _parseTimestamp(json['droppedAt']),
      completedAt: _parseTimestamp(json['completedAt']),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'courseId': courseId,
      'courseName': courseName,
      'courseCode': courseCode,
      'status': status.toJson(),
    };
  }

  /// Parse Firestore timestamp
  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is Map && value['_seconds'] != null) {
      return DateTime.fromMillisecondsSinceEpoch(
        (value['_seconds'] as int) * 1000,
      );
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  /// Create a copy with updated fields
  EnrollmentModel copyWith({
    String? id,
    String? studentId,
    String? courseId,
    String? courseName,
    String? courseCode,
    EnrollmentStatus? status,
    DateTime? enrolledAt,
    DateTime? droppedAt,
    DateTime? completedAt,
  }) {
    return EnrollmentModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      courseCode: courseCode ?? this.courseCode,
      status: status ?? this.status,
      enrolledAt: enrolledAt ?? this.enrolledAt,
      droppedAt: droppedAt ?? this.droppedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
