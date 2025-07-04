import 'package:flutter/foundation.dart';

/// Build configuration for different environments
class BuildConfig {
  /// Current app version
  static const String appVersion = '1.0.0';
  
  /// Build number
  static const String buildNumber = '1';
  
  /// App name
  static const String appName = 'Invoice App';
  
  /// Package name
  static const String packageName = 'com.example.invoice_app';
  
  /// Minimum supported SDK version
  static const String minSdkVersion = '21';
  
  /// Target SDK version
  static const String targetSdkVersion = '34';
  
  /// Is this a debug build?
  static bool get isDebug => kDebugMode;
  
  /// Is this a release build?
  static bool get isRelease => kReleaseMode;
  
  /// Is this a profile build?
  static bool get isProfile => kProfileMode;
  
  /// Environment type
  static BuildEnvironment get environment {
    if (kDebugMode) return BuildEnvironment.debug;
    if (kProfileMode) return BuildEnvironment.profile;
    return BuildEnvironment.release;
  }
  
  /// Database version for migrations
  static const int databaseVersion = 1;
  
  /// Features enabled in this build
  static const Set<String> enabledFeatures = {
    'pdf_export',
    'csv_export',
    'client_management',
    'offline_support',
    'data_validation',
    'theme_support',
    'responsive_layout',
  };
  
  /// Check if a feature is enabled
  static bool isFeatureEnabled(String feature) {
    return enabledFeatures.contains(feature);
  }
  
  /// Production optimizations
  static ProductionConfig get production => ProductionConfig();
}

/// Different build environments
enum BuildEnvironment {
  debug,
  profile,
  release,
}

/// Production-specific configuration
class ProductionConfig {
  /// Enable crash reporting
  bool get enableCrashReporting => BuildConfig.isRelease;
  
  /// Enable analytics
  bool get enableAnalytics => false; // Disabled for privacy
  
  /// Enable performance monitoring
  bool get enablePerformanceMonitoring => BuildConfig.isRelease;
  
  /// Minimum log level
  LogLevel get minLogLevel => BuildConfig.isDebug ? LogLevel.debug : LogLevel.warning;
  
  /// Enable debug prints
  bool get enableDebugPrints => BuildConfig.isDebug;
  
  /// Enable assertion checks
  bool get enableAssertions => BuildConfig.isDebug;
  
  /// Maximum cache size (in MB)
  int get maxCacheSize => 50;
  
  /// Cache expiry duration
  Duration get cacheExpiry => const Duration(hours: 24);
  
  /// Enable data compression
  bool get enableDataCompression => BuildConfig.isRelease;
  
  /// Enable image optimization
  bool get enableImageOptimization => BuildConfig.isRelease;
  
  /// Background sync interval
  Duration get backgroundSyncInterval => const Duration(minutes: 15);
  
  /// Maximum file size for exports (MB)
  int get maxExportFileSize => 10;
  
  /// Maximum number of invoices to keep in memory
  int get maxInMemoryInvoices => 100;
  
  /// Auto-save interval
  Duration get autoSaveInterval => const Duration(seconds: 30);
  
  /// Network timeout
  Duration get networkTimeout => const Duration(seconds: 30);
  
  /// Retry attempts for failed operations
  int get maxRetryAttempts => 3;
  
  /// Enable data validation
  bool get enableDataValidation => true;
  
  /// Enable input sanitization
  bool get enableInputSanitization => true;
  
  /// Default theme mode
  String get defaultThemeMode => 'system';
  
  /// Supported locales
  List<String> get supportedLocales => ['en'];
  
  /// Enable backup/restore
  bool get enableBackupRestore => true;
  
  /// Backup retention period
  Duration get backupRetentionPeriod => const Duration(days: 30);
  
  /// Maximum number of backups to keep
  int get maxBackupCount => 5;
}

/// Log levels for production
enum LogLevel {
  debug,
  info,
  warning,
  error,
}

/// Performance configuration
class PerformanceConfig {
  /// Enable widget rebuild tracking
  static bool get enableRebuildTracking => BuildConfig.isDebug;
  
  /// Enable memory usage tracking
  static bool get enableMemoryTracking => !BuildConfig.isDebug;
  
  /// Enable frame rate monitoring
  static bool get enableFrameRateMonitoring => BuildConfig.isProfile;
  
  /// Maximum widget tree depth
  static const int maxWidgetTreeDepth = 50;
  
  /// Lazy loading threshold
  static const int lazyLoadingThreshold = 20;
  
  /// Image cache size (MB)
  static const int imageCacheSize = 20;
  
  /// Enable RepaintBoundary optimization
  static bool get enableRepaintBoundaryOptimization => !BuildConfig.isDebug;
  
  /// Enable widget caching
  static bool get enableWidgetCaching => BuildConfig.isRelease;
  
  /// Animation duration multiplier (reduce in production)
  static double get animationDurationMultiplier => BuildConfig.isDebug ? 1.0 : 0.7;
}

/// Security configuration for builds
class BuildSecurityConfig {
  /// Enable code obfuscation
  static bool get enableCodeObfuscation => BuildConfig.isRelease;
  
  /// Enable certificate pinning
  static bool get enableCertificatePinning => BuildConfig.isRelease;
  
  /// Enable root detection
  static bool get enableRootDetection => BuildConfig.isRelease;
  
  /// Enable debug mode detection
  static bool get enableDebugModeDetection => BuildConfig.isRelease;
  
  /// Enable anti-tampering
  static bool get enableAntiTampering => BuildConfig.isRelease;
  
  /// Allowed file types for data import
  static const Set<String> allowedImportTypes = {
    'application/json',
    'text/csv',
  };
  
  /// Maximum import file size (MB)
  static const int maxImportFileSize = 5;
  
  /// Enable data encryption at rest
  static bool get enableDataEncryption => BuildConfig.isRelease;
  
  /// Enable secure communication
  static bool get enableSecureCommunication => true;
}

/// Feature flags for conditional functionality
class FeatureFlags {
  /// Export functionality
  static bool get enableExport => BuildConfig.isFeatureEnabled('pdf_export');
  
  /// CSV export
  static bool get enableCsvExport => BuildConfig.isFeatureEnabled('csv_export');
  
  /// Client management
  static bool get enableClientManagement => BuildConfig.isFeatureEnabled('client_management');
  
  /// Offline support
  static bool get enableOfflineSupport => BuildConfig.isFeatureEnabled('offline_support');
  
  /// Data validation
  static bool get enableDataValidation => BuildConfig.isFeatureEnabled('data_validation');
  
  /// Theme support
  static bool get enableThemeSupport => BuildConfig.isFeatureEnabled('theme_support');
  
  /// Responsive layout
  static bool get enableResponsiveLayout => BuildConfig.isFeatureEnabled('responsive_layout');
  
  /// Advanced features (disabled in initial release)
  static bool get enableAdvancedFeatures => false;
  
  /// Beta features (disabled in production)
  static bool get enableBetaFeatures => BuildConfig.isDebug;
  
  /// Experimental features (debug only)
  static bool get enableExperimentalFeatures => BuildConfig.isDebug;
} 