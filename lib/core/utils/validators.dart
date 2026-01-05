import 'package:email_validator/email_validator.dart';
import '../constants/app_constants.dart';

/// Input validators for form fields
class Validators {
  /// Validate email address
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!EmailValidator.validate(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < ValidationConstants.minPasswordLength) {
      return 'Password must be at least ${ValidationConstants.minPasswordLength} characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  /// Validate password confirmation
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Validate name field
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length > ValidationConstants.maxNameLength) {
      return 'Name is too long';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  /// Validate IC number (Malaysian format: YYMMDD-SS-NNNN)
  static String? validateIcNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'IC number is required';
    }
    // Remove dashes for validation
    final cleanValue = value.replaceAll('-', '');
    if (cleanValue.length != ValidationConstants.icNumberLength) {
      return 'IC number must be 12 digits';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(cleanValue)) {
      return 'IC number can only contain numbers';
    }
    return null;
  }

  /// Validate phone number
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    // Remove common formatting characters
    final cleanValue = value.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    if (cleanValue.length < ValidationConstants.phoneNumberMinLength ||
        cleanValue.length > ValidationConstants.phoneNumberMaxLength) {
      return 'Please enter a valid phone number';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(cleanValue)) {
      return 'Phone number can only contain numbers';
    }
    return null;
  }

  /// Validate required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate optional field with max length
  static String? validateOptionalMaxLength(String? value, int maxLength) {
    if (value != null && value.length > maxLength) {
      return 'This field is too long (max $maxLength characters)';
    }
    return null;
  }
}
