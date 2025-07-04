 
import 'package:flutter/services.dart';

enum ValidationLevel { basic, strict, enterprise }

enum ValidationError {
  required,
  invalid,
  tooShort,
  tooLong,
  invalidFormat,
  duplicateFound,
  businessRuleViolation,
  securityThreat,
  invalidRange,
  futureDate,
  pastDate,
}

class ValidationResult {
  final bool isValid;
  final String? errorMessage;
  final ValidationError? errorType;
  final String? sanitizedValue;
  final double confidence;

  const ValidationResult({
    required this.isValid,
    this.errorMessage,
    this.errorType,
    this.sanitizedValue,
    this.confidence = 1.0,
  });

  factory ValidationResult.valid(String? sanitizedValue) {
    return ValidationResult(
      isValid: true,
      sanitizedValue: sanitizedValue,
      confidence: 1.0,
    );
  }

  factory ValidationResult.invalid(
    String message,
    ValidationError errorType, {
    double confidence = 1.0,
  }) {
    return ValidationResult(
      isValid: false,
      errorMessage: message,
      errorType: errorType,
      confidence: confidence,
    );
  }
}

class ValidationRule {
  final String field;
  final bool required;
  final int? minLength;
  final int? maxLength;
  final RegExp? pattern;
  final String? customMessage;
  final bool sanitize;
  final ValidationLevel level;
  final List<String> Function()? forbiddenValues;

  const ValidationRule({
    required this.field,
    this.required = false,
    this.minLength,
    this.maxLength,
    this.pattern,
    this.customMessage,
    this.sanitize = true,
    this.level = ValidationLevel.basic,
    this.forbiddenValues,
  });
}

class ValidationHelper {
  static final ValidationHelper _instance = ValidationHelper._internal();
  factory ValidationHelper() => _instance;
  ValidationHelper._internal();

  // Comprehensive validation patterns
  static final Map<String, RegExp> _patterns = {
    'email': RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'),
    'phone': RegExp(r'^\+?[\d\s\-\(\)]{7,20}$'),
    'invoiceNumber': RegExp(r'^[A-Z0-9\-]{3,20}$'),
    'clientName': RegExp(r'^[a-zA-Z\s\.\,\&]{2,100}$'),
    'companyName': RegExp(r'^[a-zA-Z0-9\s\.\,\&\-]{2,100}$'),
    'address': RegExp(r'^[a-zA-Z0-9\s\.\,\#\-\n]{5,500}$'),
    'amount': RegExp(r'^\d+(\.\d{1,2})?$'),
    'percentage': RegExp(r'^\d{1,2}(\.\d{1,2})?$'),
    'bankAccount': RegExp(r'^[A-Z0-9]{8,20}$'),
    'ifscCode': RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$'),
    'description': RegExp(r'^[a-zA-Z0-9\s\.\,\-\(\)]{1,500}$'),
    'notes': RegExp(r'^[a-zA-Z0-9\s\.\,\-\(\)\n]{0,1000}$'),
    'website': RegExp(r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$'),
  };

  // Security threat patterns
  static final List<RegExp> _threatPatterns = [
    RegExp(r'<script[^>]*>.*?<\/script>', caseSensitive: false),
    RegExp(r'javascript:', caseSensitive: false),
    RegExp(r'on\w+\s*=', caseSensitive: false),
    RegExp(r'(union|select|insert|delete|update|drop)\s+', caseSensitive: false),
    RegExp(r'[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]'), // Control characters
  ];

  // Common forbidden values
  static final Set<String> _commonForbiddenValues = {
    'admin', 'root', 'null', 'undefined', 'test', 'demo', 'sample',
    'example', 'temp', 'temporary', 'delete', 'remove', 'system',
  };

  // Pre-defined validation rules
  static final Map<String, ValidationRule> _standardRules = {
    'clientName': ValidationRule(
      field: 'clientName',
      required: true,
      minLength: 2,
      maxLength: 100,
      pattern: _patterns['clientName'],
      customMessage: 'Client name must be 2-100 characters with letters, spaces, and basic punctuation only',
    ),
    'companyName': ValidationRule(
      field: 'companyName',
      required: true,
      minLength: 2,
      maxLength: 100,
      pattern: _patterns['companyName'],
      customMessage: 'Company name must be 2-100 characters with letters, numbers, spaces, and basic punctuation only',
    ),
    'email': ValidationRule(
      field: 'email',
      required: false,
      pattern: _patterns['email'],
      customMessage: 'Please enter a valid email address',
      level: ValidationLevel.strict,
    ),
    'phone': ValidationRule(
      field: 'phone',
      required: false,
      pattern: _patterns['phone'],
      customMessage: 'Please enter a valid phone number',
    ),
    'address': ValidationRule(
      field: 'address',
      required: false,
      minLength: 5,
      maxLength: 500,
      pattern: _patterns['address'],
      customMessage: 'Address must be 5-500 characters',
    ),
    'invoiceNumber': ValidationRule(
      field: 'invoiceNumber',
      required: true,
      minLength: 3,
      maxLength: 20,
      pattern: _patterns['invoiceNumber'],
      customMessage: 'Invoice number must be 3-20 characters with letters, numbers, and hyphens only',
      forbiddenValues: () => _commonForbiddenValues.toList(),
    ),
    'amount': ValidationRule(
      field: 'amount',
      required: true,
      pattern: _patterns['amount'],
      customMessage: 'Please enter a valid amount (e.g., 100.50)',
    ),
    'percentage': ValidationRule(
      field: 'percentage',
      required: false,
      pattern: _patterns['percentage'],
      customMessage: 'Please enter a valid percentage (0-99.99)',
    ),
    'description': ValidationRule(
      field: 'description',
      required: true,
      minLength: 1,
      maxLength: 500,
      pattern: _patterns['description'],
      customMessage: 'Description must be 1-500 characters',
    ),
    'notes': ValidationRule(
      field: 'notes',
      required: false,
      maxLength: 1000,
      pattern: _patterns['notes'],
      customMessage: 'Notes must be less than 1000 characters',
    ),
    'bankAccount': ValidationRule(
      field: 'bankAccount',
      required: false,
      minLength: 8,
      maxLength: 20,
      pattern: _patterns['bankAccount'],
      customMessage: 'Bank account must be 8-20 characters with letters and numbers only',
    ),
    'ifscCode': ValidationRule(
      field: 'ifscCode',
      required: false,
      pattern: _patterns['ifscCode'],
      customMessage: 'IFSC code must be in format: ABCD0123456',
    ),
    'website': ValidationRule(
      field: 'website',
      required: false,
      pattern: _patterns['website'],
      customMessage: 'Please enter a valid website URL',
    ),
  };

  // Main validation method
  ValidationResult validate(String? value, String fieldName, {ValidationRule? customRule}) {
    final rule = customRule ?? _standardRules[fieldName];
    if (rule == null) {
      return ValidationResult.invalid(
        'No validation rule found for field: $fieldName',
        ValidationError.invalid,
      );
    }

    // Check for required fields
    if (rule.required && (value == null || value.trim().isEmpty)) {
      return ValidationResult.invalid(
        rule.customMessage ?? '${rule.field} is required',
        ValidationError.required,
      );
    }

    // Skip validation for optional empty fields
    if (!rule.required && (value == null || value.trim().isEmpty)) {
      return ValidationResult.valid(null);
    }

    final trimmedValue = value!.trim();

    // Security validation
    final securityResult = _validateSecurity(trimmedValue, rule);
    if (!securityResult.isValid) return securityResult;

    // Length validation
    final lengthResult = _validateLength(trimmedValue, rule);
    if (!lengthResult.isValid) return lengthResult;

    // Pattern validation
    final patternResult = _validatePattern(trimmedValue, rule);
    if (!patternResult.isValid) return patternResult;

    // Business rules validation
    final businessResult = _validateBusinessRules(trimmedValue, rule);
    if (!businessResult.isValid) return businessResult;

    // Sanitize the value
    final sanitizedValue = rule.sanitize ? sanitize(trimmedValue, fieldName) : trimmedValue;

    return ValidationResult.valid(sanitizedValue);
  }

  ValidationResult _validateSecurity(String value, ValidationRule rule) {
    // Check for security threats
    for (final pattern in _threatPatterns) {
      if (pattern.hasMatch(value)) {
        return ValidationResult.invalid(
          'Input contains potentially dangerous content',
          ValidationError.securityThreat,
          confidence: 0.9,
        );
      }
    }

    // Check for suspicious patterns based on field type
    if (rule.field == 'email' && value.contains('..')) {
      return ValidationResult.invalid(
        'Email contains invalid consecutive dots',
        ValidationError.invalidFormat,
      );
    }

    if (rule.field == 'amount' && value.startsWith('0') && value.length > 1 && !value.startsWith('0.')) {
      return ValidationResult.invalid(
        'Amount cannot start with zero unless it\'s a decimal',
        ValidationError.invalidFormat,
      );
    }

    return ValidationResult.valid(null);
  }

  ValidationResult _validateLength(String value, ValidationRule rule) {
    if (rule.minLength != null && value.length < rule.minLength!) {
      return ValidationResult.invalid(
        rule.customMessage ?? '${rule.field} must be at least ${rule.minLength} characters',
        ValidationError.tooShort,
      );
    }

    if (rule.maxLength != null && value.length > rule.maxLength!) {
      return ValidationResult.invalid(
        rule.customMessage ?? '${rule.field} must be no more than ${rule.maxLength} characters',
        ValidationError.tooLong,
      );
    }

    return ValidationResult.valid(null);
  }

  ValidationResult _validatePattern(String value, ValidationRule rule) {
    if (rule.pattern != null && !rule.pattern!.hasMatch(value)) {
      return ValidationResult.invalid(
        rule.customMessage ?? '${rule.field} format is invalid',
        ValidationError.invalidFormat,
      );
    }

    return ValidationResult.valid(null);
  }

  ValidationResult _validateBusinessRules(String value, ValidationRule rule) {
    // Check forbidden values
    if (rule.forbiddenValues != null) {
      final forbidden = rule.forbiddenValues!();
      if (forbidden.any((f) => f.toLowerCase() == value.toLowerCase())) {
        return ValidationResult.invalid(
          '${rule.field} cannot be "$value" - please choose a different value',
          ValidationError.businessRuleViolation,
        );
      }
    }

    // Field-specific business rules
    switch (rule.field) {
      case 'amount':
        final amount = double.tryParse(value);
        if (amount != null) {
          if (amount < 0) {
            return ValidationResult.invalid(
              'Amount cannot be negative',
              ValidationError.invalidRange,
            );
          }
          if (amount > 999999999.99) {
            return ValidationResult.invalid(
              'Amount is too large (maximum: 999,999,999.99)',
              ValidationError.invalidRange,
            );
          }
          if (amount == 0) {
            return ValidationResult.invalid(
              'Amount must be greater than zero',
              ValidationError.invalidRange,
            );
          }
        }
        break;

      case 'percentage':
        final percentage = double.tryParse(value);
        if (percentage != null) {
          if (percentage < 0 || percentage > 99.99) {
            return ValidationResult.invalid(
              'Percentage must be between 0 and 99.99',
              ValidationError.invalidRange,
            );
          }
        }
        break;

      case 'email':
        // Additional email validations
        if (value.split('@').length != 2) {
          return ValidationResult.invalid(
            'Email must contain exactly one @ symbol',
            ValidationError.invalidFormat,
          );
        }
        final domain = value.split('@')[1];
        if (domain.split('.').length < 2) {
          return ValidationResult.invalid(
            'Email domain must contain at least one dot',
            ValidationError.invalidFormat,
          );
        }
        break;

      case 'phone':
        // Remove formatting for length check
        final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
        if (digitsOnly.length < 7 || digitsOnly.length > 15) {
          return ValidationResult.invalid(
            'Phone number must contain 7-15 digits',
            ValidationError.invalidFormat,
          );
        }
        break;
    }

    return ValidationResult.valid(null);
  }

  // Advanced sanitization
  String sanitize(String value, String fieldName) {
    var sanitized = value.trim();

    // Remove control characters
    sanitized = sanitized.replaceAll(RegExp(r'[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]'), '');

    // Field-specific sanitization
    switch (fieldName) {
      case 'email':
        sanitized = sanitized.toLowerCase();
        break;

      case 'phone':
        // Normalize phone number format
        sanitized = sanitized.replaceAll(RegExp(r'[^\d\+\-\(\)\s]'), '');
        break;

      case 'amount':
        // Remove currency symbols and extra spaces
        sanitized = sanitized.replaceAll(RegExp(r'[^\d\.]'), '');
        break;

      case 'invoiceNumber':
        sanitized = sanitized.toUpperCase();
        break;

      case 'clientName':
      case 'companyName':
        // Normalize whitespace and capitalize properly
        sanitized = sanitized.split(' ')
            .where((word) => word.isNotEmpty)
            .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
            .join(' ');
        break;

      case 'website':
        sanitized = sanitized.toLowerCase();
        if (!sanitized.startsWith('http://') && !sanitized.startsWith('https://')) {
          sanitized = 'https://$sanitized';
        }
        break;

      case 'description':
      case 'notes':
        // Clean up excessive whitespace
        sanitized = sanitized.replaceAll(RegExp(r'\s+'), ' ');
        break;

      case 'address':
        // Normalize address formatting
        sanitized = sanitized.replaceAll(RegExp(r'\n+'), '\n')
                             .replaceAll(RegExp(r' +'), ' ');
        break;
    }

    return sanitized;
  }

  // Date validation
  ValidationResult validateDate(DateTime? date, String fieldName, {
    bool allowPast = true,
    bool allowFuture = true,
    DateTime? minDate,
    DateTime? maxDate,
  }) {
    if (date == null) {
      return ValidationResult.invalid(
        '$fieldName is required',
        ValidationError.required,
      );
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (!allowPast && dateOnly.isBefore(today)) {
      return ValidationResult.invalid(
        '$fieldName cannot be in the past',
        ValidationError.pastDate,
      );
    }

    if (!allowFuture && dateOnly.isAfter(today)) {
      return ValidationResult.invalid(
        '$fieldName cannot be in the future',
        ValidationError.futureDate,
      );
    }

    if (minDate != null && date.isBefore(minDate)) {
      return ValidationResult.invalid(
        '$fieldName must be after ${_formatDate(minDate)}',
        ValidationError.invalidRange,
      );
    }

    if (maxDate != null && date.isAfter(maxDate)) {
      return ValidationResult.invalid(
        '$fieldName must be before ${_formatDate(maxDate)}',
        ValidationError.invalidRange,
      );
    }

    return ValidationResult.valid(null);
  }

  // Batch validation for forms
  Map<String, ValidationResult> validateForm(Map<String, String?> formData, {
    Map<String, ValidationRule>? customRules,
  }) {
    final results = <String, ValidationResult>{};
    
    for (final entry in formData.entries) {
      final fieldName = entry.key;
      final value = entry.value;
      final customRule = customRules?[fieldName];
      
      results[fieldName] = validate(value, fieldName, customRule: customRule);
    }

    return results;
  }

  // Check for duplicate values across a list
  ValidationResult validateUnique(String? value, String fieldName, List<String> existingValues) {
    if (value == null || value.trim().isEmpty) {
      return ValidationResult.valid(null);
    }

    final sanitizedValue = sanitize(value, fieldName);
    final isDuplicate = existingValues.any((existing) => 
        sanitize(existing, fieldName).toLowerCase() == sanitizedValue.toLowerCase());

    if (isDuplicate) {
      return ValidationResult.invalid(
        '$fieldName "$value" already exists',
        ValidationError.duplicateFound,
      );
    }

    return ValidationResult.valid(sanitizedValue);
  }

  // Input formatters for real-time validation
  List<TextInputFormatter> getInputFormatters(String fieldName) {
    switch (fieldName) {
      case 'amount':
        return [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          LengthLimitingTextInputFormatter(12),
        ];

      case 'percentage':
        return [
          FilteringTextInputFormatter.allow(RegExp(r'^\d{0,2}\.?\d{0,2}')),
          LengthLimitingTextInputFormatter(5),
        ];

      case 'phone':
        return [
          FilteringTextInputFormatter.allow(RegExp(r'[\d\+\-\(\)\s]')),
          LengthLimitingTextInputFormatter(20),
        ];

      case 'invoiceNumber':
        return [
          FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9\-]')),
          LengthLimitingTextInputFormatter(20),
          UpperCaseTextFormatter(),
        ];

      case 'clientName':
      case 'companyName':
        return [
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s\.\,\&]')),
          LengthLimitingTextInputFormatter(100),
        ];

      case 'email':
        return [
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@\.\-_]')),
          LengthLimitingTextInputFormatter(254),
          LowerCaseTextFormatter(),
        ];

      case 'description':
        return [
          LengthLimitingTextInputFormatter(500),
        ];

      case 'notes':
        return [
          LengthLimitingTextInputFormatter(1000),
        ];

      case 'address':
        return [
          LengthLimitingTextInputFormatter(500),
        ];

      default:
        return [LengthLimitingTextInputFormatter(255)];
    }
  }

  // Utility methods
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  bool isValidEmail(String email) {
    return validate(email, 'email').isValid;
  }

  bool isValidPhone(String phone) {
    return validate(phone, 'phone').isValid;
  }

  bool isValidAmount(String amount) {
    return validate(amount, 'amount').isValid;
  }

  String formatPhoneNumber(String phone) {
    final digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length == 10) {
      return '(${digitsOnly.substring(0, 3)}) ${digitsOnly.substring(3, 6)}-${digitsOnly.substring(6)}';
    }
    return phone;
  }

  String formatAmount(String amount) {
    final value = double.tryParse(amount);
    if (value != null) {
      return value.toStringAsFixed(2);
    }
    return amount;
  }
}

// Custom text input formatters
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class LowerCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toLowerCase(),
      selection: newValue.selection,
    );
  }
}

// Extension for easy validation in forms
extension ValidationHelperExtension on String? {
  ValidationResult validateAs(String fieldName) {
    return ValidationHelper().validate(this, fieldName);
  }

  String? get sanitized {
    if (this == null) return null;
    return ValidationHelper().sanitize(this!, 'general');
  }
} 