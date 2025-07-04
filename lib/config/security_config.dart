import 'package:flutter/foundation.dart';

/// Security configuration for production deployment
class SecurityConfig {
  /// Disable debug features in production
  static bool get isDebugModeDisabled => !kDebugMode;
  
  /// Enable secure storage for sensitive data
  static bool get useSecureStorage => !kDebugMode;
  
  /// Maximum file size for exports (5MB)
  static const int maxExportFileSize = 5 * 1024 * 1024;
  
  /// Maximum number of invoices in a single export
  static const int maxExportInvoices = 1000;
  
  /// Data retention period (90 days for temporary files)
  static const Duration tempFileRetention = Duration(days: 90);
  
  /// Maximum retry attempts for network operations
  static const int maxRetryAttempts = 3;
  
  /// Timeout for network operations
  static const Duration networkTimeout = Duration(seconds: 30);
  
  /// Enable data validation
  static bool get enableDataValidation => true;
  
  /// Enable input sanitization
  static bool get enableInputSanitization => true;
  
  /// Allowed file types for export
  static const Set<String> allowedExportTypes = {
    'application/pdf',
    'text/csv',
    'application/json',
  };
  
  /// Maximum length for user inputs
  static const Map<String, int> maxInputLengths = {
    'clientName': 100,
    'companyName': 100,
    'email': 254,
    'phone': 20,
    'address': 500,
    'invoiceNumber': 20,
    'description': 500,
    'notes': 1000,
  };
  
  /// Forbidden input patterns (security threats)
  static final List<RegExp> forbiddenPatterns = [
    RegExp(r'<script[^>]*>.*?<\/script>', caseSensitive: false),
    RegExp(r'javascript:', caseSensitive: false),
    RegExp(r'on\w+\s*=', caseSensitive: false),
    RegExp(r'(union|select|insert|delete|update|drop)\s+', caseSensitive: false),
    RegExp(r'[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]'), // Control characters
  ];
  
  /// Check if input contains security threats
  static bool containsSecurityThreat(String input) {
    for (final pattern in forbiddenPatterns) {
      if (pattern.hasMatch(input)) {
        return true;
      }
    }
    return false;
  }
  
  /// Sanitize user input
  static String sanitizeInput(String input) {
    if (input.isEmpty) return input;
    
    // Remove control characters
    String sanitized = input.replaceAll(RegExp(r'[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]'), '');
    
    // Trim whitespace
    sanitized = sanitized.trim();
    
    // Remove potential XSS patterns
    sanitized = sanitized.replaceAll(RegExp(r'<[^>]*>'), '');
    
    return sanitized;
  }
  
  /// Validate file size
  static bool isValidFileSize(int sizeBytes) {
    return sizeBytes <= maxExportFileSize;
  }
  
  /// Validate export type
  static bool isAllowedExportType(String mimeType) {
    return allowedExportTypes.contains(mimeType);
  }
  
  /// Generate secure file name
  static String generateSecureFileName(String baseName, String extension) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final sanitized = baseName.replaceAll(RegExp(r'[^\w\-]'), '_');
    return '${sanitized}_$timestamp.$extension';
  }
  
  /// Check if data is within retention period
  static bool isWithinRetentionPeriod(DateTime createdDate) {
    final now = DateTime.now();
    final difference = now.difference(createdDate);
    return difference <= tempFileRetention;
  }
}

/// Data privacy configuration
class PrivacyConfig {
  /// Enable data encryption for sensitive fields
  static bool get enableDataEncryption => !kDebugMode;
  
  /// Fields that contain sensitive data
  static const Set<String> sensitiveFields = {
    'email',
    'phone',
    'address',
    'bankAccount',
    'taxNumber',
  };
  
  /// Check if field contains sensitive data
  static bool isSensitiveField(String fieldName) {
    return sensitiveFields.contains(fieldName);
  }
  
  /// Mask sensitive data for logging/display
  static String maskSensitiveData(String fieldName, String value) {
    if (!isSensitiveField(fieldName) || value.isEmpty) {
      return value;
    }
    
    switch (fieldName) {
      case 'email':
        final parts = value.split('@');
        if (parts.length == 2) {
          final username = parts[0];
          final domain = parts[1];
          final maskedUsername = username.length > 2 
              ? '${username[0]}${'*' * (username.length - 2)}${username[username.length - 1]}'
              : username;
          return '$maskedUsername@$domain';
        }
        break;
      case 'phone':
        if (value.length > 4) {
          return '${value.substring(0, 2)}${'*' * (value.length - 4)}${value.substring(value.length - 2)}';
        }
        break;
      case 'bankAccount':
        if (value.length > 4) {
          return '*' * (value.length - 4) + value.substring(value.length - 4);
        }
        break;
      default:
        if (value.length > 4) {
          return '${value.substring(0, 2)}${'*' * (value.length - 4)}${value.substring(value.length - 2)}';
        }
    }
    
    return '*' * value.length;
  }
}

/// File system security configuration
class FileSecurityConfig {
  /// Allowed file extensions for reading
  static const Set<String> allowedReadExtensions = {
    '.pdf',
    '.csv',
    '.json',
    '.txt',
  };
  
  /// Allowed file extensions for writing
  static const Set<String> allowedWriteExtensions = {
    '.pdf',
    '.csv',
    '.json',
  };
  
  /// Maximum file size for reading (10MB)
  static const int maxReadFileSize = 10 * 1024 * 1024;
  
  /// Check if file extension is allowed for reading
  static bool isAllowedReadExtension(String fileName) {
    final extension = fileName.toLowerCase().substring(fileName.lastIndexOf('.'));
    return allowedReadExtensions.contains(extension);
  }
  
  /// Check if file extension is allowed for writing
  static bool isAllowedWriteExtension(String fileName) {
    final extension = fileName.toLowerCase().substring(fileName.lastIndexOf('.'));
    return allowedWriteExtensions.contains(extension);
  }
  
  /// Validate file path for security
  static bool isSecureFilePath(String filePath) {
    // Prevent directory traversal attacks
    if (filePath.contains('..') || filePath.contains('~/') || filePath.startsWith('/')) {
      return false;
    }
    
    // Check for null bytes
    if (filePath.contains('\x00')) {
      return false;
    }
    
    return true;
  }
}

/// Network security configuration
class NetworkSecurityConfig {
  /// Enable certificate pinning in production
  static bool get enableCertificatePinning => !kDebugMode;
  
  /// Timeout for network requests
  static const Duration requestTimeout = Duration(seconds: 30);
  
  /// Maximum retry attempts
  static const int maxRetryAttempts = 3;
  
  /// Allowed domains for network requests (if any external APIs are added)
  static const Set<String> allowedDomains = {
    // Add allowed domains here if external APIs are used
  };
  
  /// Check if domain is allowed for network requests
  static bool isAllowedDomain(String url) {
    if (allowedDomains.isEmpty) return true;
    
    try {
      final uri = Uri.parse(url);
      return allowedDomains.contains(uri.host);
    } catch (e) {
      return false;
    }
  }
} 