/// Course model representing available courses
class CourseModel {
  final String id;
  final String code;
  final String name;
  final String? description;
  final int credits;
  final int capacity;
  final int enrolledCount;
  final String? instructor;
  final String? schedule;
  final String? semester;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CourseModel({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.credits,
    required this.capacity,
    this.enrolledCount = 0,
    this.instructor,
    this.schedule,
    this.semester,
    this.createdAt,
    this.updatedAt,
  });

  /// Get available slots
  int get availableSlots => capacity - enrolledCount;

  /// Check if course is full
  bool get isFull => availableSlots <= 0;

  /// Create from JSON
  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      credits: json['credits'] ?? 0,
      capacity: json['capacity'] ?? 0,
      enrolledCount: json['enrolledCount'] ?? 0,
      instructor: json['instructor'],
      schedule: json['schedule'],
      semester: json['semester'],
      createdAt: _parseTimestamp(json['createdAt']),
      updatedAt: _parseTimestamp(json['updatedAt']),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'credits': credits,
      'capacity': capacity,
      'enrolledCount': enrolledCount,
      'instructor': instructor,
      'schedule': schedule,
      'semester': semester,
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
  CourseModel copyWith({
    String? id,
    String? code,
    String? name,
    String? description,
    int? credits,
    int? capacity,
    int? enrolledCount,
    String? instructor,
    String? schedule,
    String? semester,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CourseModel(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      credits: credits ?? this.credits,
      capacity: capacity ?? this.capacity,
      enrolledCount: enrolledCount ?? this.enrolledCount,
      instructor: instructor ?? this.instructor,
      schedule: schedule ?? this.schedule,
      semester: semester ?? this.semester,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
