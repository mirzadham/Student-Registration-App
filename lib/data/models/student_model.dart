import '../../core/utils/encryption_helper.dart';

/// Student model with encrypted sensitive fields
class StudentModel {
  final String id;
  final String email;
  final String name;
  final String? icNumber; // Encrypted
  final String? phoneNumber; // Encrypted
  final String? address; // Encrypted
  final String? emergencyContact; // Encrypted
  final String? dateOfBirth;
  final String? program;
  final int? enrollmentYear;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Fields that should be encrypted
  static const List<String> encryptedFields = [
    'icNumber',
    'phoneNumber',
    'address',
    'emergencyContact',
  ];

  StudentModel({
    required this.id,
    required this.email,
    required this.name,
    this.icNumber,
    this.phoneNumber,
    this.address,
    this.emergencyContact,
    this.dateOfBirth,
    this.program,
    this.enrollmentYear,
    this.createdAt,
    this.updatedAt,
  });

  /// Create from JSON (decrypts sensitive fields)
  factory StudentModel.fromJson(Map<String, dynamic> json) {
    // Decrypt sensitive fields
    final decryptedData = EncryptionHelper.decryptFields(json, encryptedFields);

    return StudentModel(
      id: decryptedData['id'] ?? '',
      email: decryptedData['email'] ?? '',
      name: decryptedData['name'] ?? '',
      icNumber: decryptedData['icNumber'],
      phoneNumber: decryptedData['phoneNumber'],
      address: decryptedData['address'],
      emergencyContact: decryptedData['emergencyContact'],
      dateOfBirth: decryptedData['dateOfBirth'],
      program: decryptedData['program'],
      enrollmentYear: decryptedData['enrollmentYear'],
      createdAt: _parseTimestamp(decryptedData['createdAt']),
      updatedAt: _parseTimestamp(decryptedData['updatedAt']),
    );
  }

  /// Convert to JSON (encrypts sensitive fields)
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'email': email,
      'name': name,
      'icNumber': icNumber,
      'phoneNumber': phoneNumber,
      'address': address,
      'emergencyContact': emergencyContact,
      'dateOfBirth': dateOfBirth,
      'program': program,
      'enrollmentYear': enrollmentYear,
    };

    // Remove null values
    data.removeWhere((key, value) => value == null);

    // Encrypt sensitive fields
    return EncryptionHelper.encryptFields(data, encryptedFields);
  }

  /// Convert to JSON for registration (includes uid)
  Map<String, dynamic> toRegistrationJson(String uid) {
    final json = toJson();
    json['uid'] = uid;
    return json;
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
  StudentModel copyWith({
    String? id,
    String? email,
    String? name,
    String? icNumber,
    String? phoneNumber,
    String? address,
    String? emergencyContact,
    String? dateOfBirth,
    String? program,
    int? enrollmentYear,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudentModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      icNumber: icNumber ?? this.icNumber,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      program: program ?? this.program,
      enrollmentYear: enrollmentYear ?? this.enrollmentYear,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
