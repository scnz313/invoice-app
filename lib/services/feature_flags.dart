import 'package:shared_preferences/shared_preferences.dart';

class FeatureFlags {
  static const String _darkModeKey = 'feature_dark_mode';
  static const String _advancedReportsKey = 'feature_advanced_reports';
  static const String _aiSuggestionsKey = 'feature_ai_suggestions';
  
  static FeatureFlags? _instance;
  static FeatureFlags get instance => _instance ??= FeatureFlags._();
  
  FeatureFlags._();
  
  late SharedPreferences _prefs;
  
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  // Dark Mode Feature
  bool get isDarkModeEnabled => _prefs.getBool(_darkModeKey) ?? true;
  Future<void> setDarkModeEnabled(bool enabled) async {
    await _prefs.setBool(_darkModeKey, enabled);
  }
  
  // Advanced Reports Feature
  bool get isAdvancedReportsEnabled => _prefs.getBool(_advancedReportsKey) ?? false;
  Future<void> setAdvancedReportsEnabled(bool enabled) async {
    await _prefs.setBool(_advancedReportsKey, enabled);
  }
  
  // AI Suggestions Feature (future)
  bool get isAiSuggestionsEnabled => _prefs.getBool(_aiSuggestionsKey) ?? false;
  Future<void> setAiSuggestionsEnabled(bool enabled) async {
    await _prefs.setBool(_aiSuggestionsKey, enabled);
  }
  
  // Get all feature flags as a map
  Map<String, bool> getAllFlags() {
    return {
      'Dark Mode': isDarkModeEnabled,
      'Advanced Reports': isAdvancedReportsEnabled,
      'AI Suggestions': isAiSuggestionsEnabled,
    };
  }
  
  // Reset all flags to default
  Future<void> resetToDefaults() async {
    await setDarkModeEnabled(true);
    await setAdvancedReportsEnabled(false);
    await setAiSuggestionsEnabled(false);
  }
} 