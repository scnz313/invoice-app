import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/company_settings.dart';
import '../models/business_category.dart';
import '../utils/logger.dart';

class SettingsProvider with ChangeNotifier {
  CompanySettings _companySettings = CompanySettings.defaultSettings;
  bool _isLoading = false;
  bool _hasCompletedOnboarding = false;
  BusinessCategory? _selectedBusinessCategory;

  CompanySettings get companySettings => _companySettings;
  bool get isLoading => _isLoading;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  BusinessCategory? get selectedBusinessCategory => _selectedBusinessCategory;

  static const String _storageKey = 'company_settings';
  static const String _onboardingKey = 'onboarding_completed';
  static const String _businessCategoryKey = 'business_category';

  // Load settings from local storage
  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load company settings
      final settingsJson = prefs.getString(_storageKey);
      if (settingsJson != null) {
        _companySettings = CompanySettings.fromJson(json.decode(settingsJson));
      }
      
      // Load onboarding status
      _hasCompletedOnboarding = prefs.getBool(_onboardingKey) ?? false;
      
      // Load business category
      final categoryIndex = prefs.getInt(_businessCategoryKey);
      if (categoryIndex != null && categoryIndex < BusinessCategory.values.length) {
        _selectedBusinessCategory = BusinessCategory.values[categoryIndex];
      }
    } catch (e) {
      Logger.error('Error loading settings', 'SettingsProvider', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save settings to local storage
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = json.encode(_companySettings.toJson());
      await prefs.setString(_storageKey, settingsJson);
    } catch (e) {
      Logger.error('Error saving settings', 'SettingsProvider', e);
    }
  }

  // Mark onboarding as completed
  Future<void> completeOnboarding(BusinessCategory category) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingKey, true);
      await prefs.setInt(_businessCategoryKey, category.index);
      
      _hasCompletedOnboarding = true;
      _selectedBusinessCategory = category;
      notifyListeners();
    } catch (e) {
      Logger.error('Error completing onboarding', 'SettingsProvider', e);
    }
  }

  // Reset onboarding status
  Future<void> resetOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_onboardingKey);
      await prefs.remove(_businessCategoryKey);
      
      _hasCompletedOnboarding = false;
      _selectedBusinessCategory = null;
      notifyListeners();
    } catch (e) {
      Logger.error('Error resetting onboarding', 'SettingsProvider', e);
    }
  }

  // Update company settings
  Future<void> updateCompanySettings(CompanySettings settings) async {
    _companySettings = settings;
    notifyListeners();
    await _saveSettings();
  }

  // Reset to default settings
  Future<void> resetToDefaults() async {
    _companySettings = CompanySettings.defaultSettings;
    notifyListeners();
    await _saveSettings();
  }

  // Get business category
  Future<BusinessCategory> getBusinessCategory() async {
    if (_selectedBusinessCategory != null) {
      return _selectedBusinessCategory!;
    }
    
    // If not loaded, load from storage
    await loadSettings();
    return _selectedBusinessCategory ?? BusinessCategory.groceryStore; // default fallback
  }

  // Check if onboarding is complete - async version
  Future<bool> hasCompletedOnboardingAsync() async {
    if (_hasCompletedOnboarding) return true;
    await loadSettings();
    return _hasCompletedOnboarding;
  }
} 