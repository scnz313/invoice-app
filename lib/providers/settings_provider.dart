import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/company_settings.dart';

class SettingsProvider with ChangeNotifier {
  CompanySettings _companySettings = CompanySettings.defaultSettings;
  bool _isLoading = false;

  CompanySettings get companySettings => _companySettings;
  bool get isLoading => _isLoading;

  static const String _storageKey = 'company_settings';

  // Load settings from local storage
  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_storageKey);
      
      if (settingsJson != null) {
        _companySettings = CompanySettings.fromJson(json.decode(settingsJson));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading settings: $e');
      }
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
      if (kDebugMode) {
        print('Error saving settings: $e');
      }
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
} 