import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/metal_rates.dart';
import '../models/jewelry_item.dart';

class MetalRatesProvider with ChangeNotifier {
  List<DailyMetalRates> _dailyRates = [];
  DailyMetalRates? _currentRates;
  bool _isLoading = false;
  String? _error;

  List<DailyMetalRates> get dailyRates => _dailyRates;
  DailyMetalRates? get currentRates => _currentRates;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get today's rates
  DailyMetalRates? get todaysRates {
    final today = DateTime.now();
    try {
      return _dailyRates.firstWhere((rates) => 
        rates.date.year == today.year &&
        rates.date.month == today.month &&
        rates.date.day == today.day
      );
    } catch (e) {
      return null;
    }
  }

  // Get latest rates
  DailyMetalRates? get latestRates {
    if (_dailyRates.isEmpty) return null;
    return _dailyRates.first;
  }

  // Get rates for a specific date
  DailyMetalRates? getRatesForDate(DateTime date) {
    try {
      return _dailyRates.firstWhere((rates) => 
        rates.date.year == date.year &&
        rates.date.month == date.month &&
        rates.date.day == date.day
      );
    } catch (e) {
      return null;
    }
  }

  // Get rate for specific metal and purity
  MetalRate? getCurrentRate(MetalType metalType, {GoldPurity? goldPurity, SilverPurity? silverPurity}) {
    final current = todaysRates ?? latestRates;
    if (current == null) return null;
    
    try {
      return current.getRateByMetal(metalType, goldPurity: goldPurity, silverPurity: silverPurity);
    } catch (e) {
      return null;
    }
  }

  // Get all gold rates for today
  List<MetalRate> get currentGoldRates {
    final current = todaysRates ?? latestRates;
    return current?.goldRates ?? [];
  }

  // Get all silver rates for today
  List<MetalRate> get currentSilverRates {
    final current = todaysRates ?? latestRates;
    return current?.silverRates ?? [];
  }

  // Get rate history for a specific metal
  List<MetalRate> getRateHistory(MetalType metalType, {GoldPurity? goldPurity, SilverPurity? silverPurity, int days = 30}) {
    final history = <MetalRate>[];
    final endDate = DateTime.now();
    
    for (int i = 0; i < days; i++) {
      final date = endDate.subtract(Duration(days: i));
      final dayRates = getRatesForDate(date);
      
      if (dayRates != null) {
        try {
          final rate = dayRates.getRateByMetal(metalType, goldPurity: goldPurity, silverPurity: silverPurity);
          history.add(rate);
        } catch (e) {
          // Rate not found for this day, skip
        }
      }
    }
    
    return history;
  }

  // Get price trend for a metal
  Map<String, dynamic> getPriceTrend(MetalType metalType, {GoldPurity? goldPurity, SilverPurity? silverPurity, int days = 7}) {
    final history = getRateHistory(metalType, goldPurity: goldPurity, silverPurity: silverPurity, days: days);
    
    if (history.length < 2) {
      return {
        'trend': 'stable',
        'change': 0.0,
        'changePercent': 0.0,
      };
    }
    
    final latest = history.first.sellingRate;
    final previous = history.last.sellingRate;
    final change = latest - previous;
    final changePercent = (change / previous) * 100;
    
    String trend = 'stable';
    if (change > 0) trend = 'up';
    if (change < 0) trend = 'down';
    
    return {
      'trend': trend,
      'change': change,
      'changePercent': changePercent,
    };
  }

  // Load rates from storage
  Future<void> loadRates() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final ratesJson = prefs.getStringList('metal_rates') ?? [];
      
      _dailyRates = ratesJson.map((json) {
        final Map<String, dynamic> data = jsonDecode(json);
        return DailyMetalRates.fromJson(data);
      }).toList();

      // Sort by date (newest first)
      _dailyRates.sort((a, b) => b.date.compareTo(a.date));

      // Set current rates
      _currentRates = latestRates;

      // Initialize with default rates if empty
      if (_dailyRates.isEmpty) {
        await _initializeDefaultRates();
      }

    } catch (e) {
      _error = 'Failed to load metal rates: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save rates to storage
  Future<void> saveRates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ratesJson = _dailyRates.map((rates) => jsonEncode(rates.toJson())).toList();
      await prefs.setStringList('metal_rates', ratesJson);
    } catch (e) {
      _error = 'Failed to save metal rates: ${e.toString()}';
      notifyListeners();
    }
  }

  // Initialize default rates
  Future<void> _initializeDefaultRates() async {
    final today = DateTime.now();
    final defaultRates = [
      MetalRate.create(
        date: today,
        metalType: MetalType.gold,
        goldPurity: GoldPurity.k24,
        buyingRate: 6200.0,
        sellingRate: 6300.0,
        makingChargePerGram: 500.0,
        wastagePercentage: 8.0,
        notes: 'Default 24K gold rate',
      ),
      MetalRate.create(
        date: today,
        metalType: MetalType.gold,
        goldPurity: GoldPurity.k22,
        buyingRate: 5700.0,
        sellingRate: 5800.0,
        makingChargePerGram: 450.0,
        wastagePercentage: 8.0,
        notes: 'Default 22K gold rate',
      ),
      MetalRate.create(
        date: today,
        metalType: MetalType.gold,
        goldPurity: GoldPurity.k18,
        buyingRate: 4700.0,
        sellingRate: 4800.0,
        makingChargePerGram: 400.0,
        wastagePercentage: 8.0,
        notes: 'Default 18K gold rate',
      ),
      MetalRate.create(
        date: today,
        metalType: MetalType.silver,
        silverPurity: SilverPurity.silver999,
        buyingRate: 75.0,
        sellingRate: 80.0,
        makingChargePerGram: 20.0,
        wastagePercentage: 5.0,
        notes: 'Default 999 silver rate',
      ),
      MetalRate.create(
        date: today,
        metalType: MetalType.silver,
        silverPurity: SilverPurity.silver925,
        buyingRate: 70.0,
        sellingRate: 75.0,
        makingChargePerGram: 18.0,
        wastagePercentage: 5.0,
        notes: 'Default 925 silver rate',
      ),
    ];

    final dailyRates = DailyMetalRates.create(
      date: today,
      rates: defaultRates,
    );

    await addDailyRates(dailyRates);
  }

  // Add daily rates
  Future<void> addDailyRates(DailyMetalRates dailyRates) async {
    try {
      // Remove existing rates for the same date
      _dailyRates.removeWhere((rates) => 
        rates.date.year == dailyRates.date.year &&
        rates.date.month == dailyRates.date.month &&
        rates.date.day == dailyRates.date.day
      );

      // Add new rates
      _dailyRates.insert(0, dailyRates);
      
      // Sort by date
      _dailyRates.sort((a, b) => b.date.compareTo(a.date));
      
      // Update current rates
      _currentRates = latestRates;
      
      await saveRates();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add daily rates: ${e.toString()}';
      notifyListeners();
    }
  }

  // Update daily rates
  Future<void> updateDailyRates(DailyMetalRates dailyRates) async {
    try {
      final index = _dailyRates.indexWhere((rates) => rates.id == dailyRates.id);
      if (index != -1) {
        _dailyRates[index] = dailyRates;
        
        // Update current rates if this is the latest
        if (index == 0) {
          _currentRates = dailyRates;
        }
        
        await saveRates();
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update daily rates: ${e.toString()}';
      notifyListeners();
    }
  }

  // Delete daily rates
  Future<void> deleteDailyRates(String ratesId) async {
    try {
      _dailyRates.removeWhere((rates) => rates.id == ratesId);
      
      // Update current rates
      _currentRates = latestRates;
      
      await saveRates();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete daily rates: ${e.toString()}';
      notifyListeners();
    }
  }

  // Add or update individual rate
  Future<void> addOrUpdateRate(MetalRate rate) async {
    try {
      final today = DateTime.now();
      final todayRates = todaysRates;
      
      if (todayRates == null) {
        // Create new daily rates for today
        final newDailyRates = DailyMetalRates.create(
          date: today,
          rates: [rate],
        );
        await addDailyRates(newDailyRates);
      } else {
        // Update existing daily rates
        final updatedRates = List<MetalRate>.from(todayRates.rates);
        
        // Find and replace existing rate or add new one
        final existingIndex = updatedRates.indexWhere((r) =>
          r.metalType == rate.metalType &&
          r.goldPurity == rate.goldPurity &&
          r.silverPurity == rate.silverPurity
        );
        
        if (existingIndex != -1) {
          updatedRates[existingIndex] = rate;
        } else {
          updatedRates.add(rate);
        }
        
        final updatedDailyRates = todayRates.copyWith(rates: updatedRates);
        await updateDailyRates(updatedDailyRates);
      }
    } catch (e) {
      _error = 'Failed to add/update rate: ${e.toString()}';
      notifyListeners();
    }
  }

  // Get default rates for new jewelry items
  Map<String, dynamic> getDefaultRatesForItem(MetalType metalType, {GoldPurity? goldPurity, SilverPurity? silverPurity}) {
    final rate = getCurrentRate(metalType, goldPurity: goldPurity, silverPurity: silverPurity);
    
    if (rate == null) {
      return {
        'metalRate': 0.0,
        'makingChargePerGram': 0.0,
        'wastagePercentage': 0.0,
      };
    }
    
    return {
      'metalRate': rate.sellingRate,
      'makingChargePerGram': rate.makingChargePerGram,
      'wastagePercentage': rate.wastagePercentage,
    };
  }

  // Search rates
  List<DailyMetalRates> searchRates(String query) {
    if (query.isEmpty) return _dailyRates;
    
    final lowerQuery = query.toLowerCase();
    return _dailyRates.where((dailyRates) {
      return dailyRates.rates.any((rate) =>
        rate.metalDisplay.toLowerCase().contains(lowerQuery) ||
        rate.notes?.toLowerCase().contains(lowerQuery) == true
      );
    }).toList();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh data
  Future<void> refresh() async {
    await loadRates();
  }
}