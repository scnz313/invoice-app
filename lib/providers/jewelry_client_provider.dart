import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/jewelry_client.dart';

class JewelryClientProvider with ChangeNotifier {
  List<JewelryClient> _clients = [];
  bool _isLoading = false;
  String? _error;

  List<JewelryClient> get clients => _clients;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get clients by type
  List<JewelryClient> getClientsByType(CustomerType type) {
    return _clients.where((client) => client.customerType == type).toList();
  }

  // Get clients by status
  List<JewelryClient> getClientsByStatus(CustomerStatus status) {
    return _clients.where((client) => client.status == status).toList();
  }

  // Get active clients
  List<JewelryClient> get activeClients => _clients.where((client) => client.isActive).toList();

  // Get VIP clients
  List<JewelryClient> get vipClients => getClientsByType(CustomerType.vip);

  // Get wholesale clients
  List<JewelryClient> get wholesaleClients => getClientsByType(CustomerType.wholesale);

  // Get clients with credit limits
  List<JewelryClient> get clientsWithCredit => _clients.where((client) => client.hasCreditLimit).toList();

  // Get clients with outstanding amounts
  List<JewelryClient> get clientsWithOutstanding => _clients.where((client) => client.outstandingAmount > 0).toList();

  // Get clients exceeding credit limit
  List<JewelryClient> get clientsExceedingCredit => _clients.where((client) => !client.isWithinCreditLimit).toList();

  // Get clients with birthdays today
  List<JewelryClient> get birthdayClients => _clients.where((client) => client.isBirthdayToday).toList();

  // Get clients with anniversaries today
  List<JewelryClient> get anniversaryClients => _clients.where((client) => client.isAnniversaryToday).toList();

  // Get clients with special occasions today
  List<JewelryClient> get specialOccasionClients => _clients.where((client) => client.isSpecialOccasion).toList();

  // Get top clients by purchase amount
  List<JewelryClient> get topClients {
    final sortedClients = List<JewelryClient>.from(_clients);
    sortedClients.sort((a, b) => b.totalPurchaseAmount.compareTo(a.totalPurchaseAmount));
    return sortedClients.take(10).toList();
  }

  // Get loyalty statistics
  Map<String, int> get loyaltyStats {
    final stats = <String, int>{
      'Bronze': 0,
      'Silver': 0,
      'Gold': 0,
      'Platinum': 0,
    };

    for (final client in _clients) {
      stats[client.loyaltyTier] = (stats[client.loyaltyTier] ?? 0) + 1;
    }

    return stats;
  }

  // Get customer type statistics
  Map<CustomerType, int> get customerTypeStats {
    final stats = <CustomerType, int>{};
    for (final client in _clients) {
      stats[client.customerType] = (stats[client.customerType] ?? 0) + 1;
    }
    return stats;
  }

  // Calculate totals
  double get totalOutstanding => _clients.fold(0.0, (sum, client) => sum + client.outstandingAmount);
  double get totalCreditLimit => _clients.fold(0.0, (sum, client) => sum + client.creditLimit);
  double get totalPurchaseAmount => _clients.fold(0.0, (sum, client) => sum + client.totalPurchaseAmount);
  int get totalLoyaltyPoints => _clients.fold(0, (sum, client) => sum + client.loyaltyPoints);

  // Load clients from storage
  Future<void> loadClients() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final clientsJson = prefs.getStringList('jewelry_clients') ?? [];
      
      _clients = clientsJson.map((json) {
        final Map<String, dynamic> data = jsonDecode(json);
        return JewelryClient.fromJson(data);
      }).toList();

      // Sort by name
      _clients.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    } catch (e) {
      _error = 'Failed to load clients: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save clients to storage
  Future<void> saveClients() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final clientsJson = _clients.map((client) => jsonEncode(client.toJson())).toList();
      await prefs.setStringList('jewelry_clients', clientsJson);
    } catch (e) {
      _error = 'Failed to save clients: ${e.toString()}';
      notifyListeners();
    }
  }

  // Add new client
  Future<void> addClient(JewelryClient client) async {
    try {
      _clients.add(client);
      _clients.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      await saveClients();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add client: ${e.toString()}';
      notifyListeners();
    }
  }

  // Update client
  Future<void> updateClient(JewelryClient client) async {
    try {
      final index = _clients.indexWhere((c) => c.id == client.id);
      if (index != -1) {
        _clients[index] = client;
        _clients.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        await saveClients();
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update client: ${e.toString()}';
      notifyListeners();
    }
  }

  // Delete client
  Future<void> deleteClient(String clientId) async {
    try {
      _clients.removeWhere((client) => client.id == clientId);
      await saveClients();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete client: ${e.toString()}';
      notifyListeners();
    }
  }

  // Update client purchase history
  Future<void> updateClientPurchaseHistory(String clientId, PurchaseHistory purchase) async {
    try {
      final index = _clients.indexWhere((c) => c.id == clientId);
      if (index != -1) {
        final client = _clients[index];
        final updatedHistory = List<PurchaseHistory>.from(client.purchaseHistory)..add(purchase);
        
        // Update totals
        final updatedClient = client.copyWith(
          purchaseHistory: updatedHistory,
          totalPurchaseAmount: client.totalPurchaseAmount + purchase.amount,
          loyaltyPoints: client.loyaltyPoints + (purchase.amount ~/ 100), // 1 point per ₹100
        );
        
        _clients[index] = updatedClient;
        await saveClients();
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update purchase history: ${e.toString()}';
      notifyListeners();
    }
  }

  // Update client outstanding amount
  Future<void> updateClientOutstanding(String clientId, double amount) async {
    try {
      final index = _clients.indexWhere((c) => c.id == clientId);
      if (index != -1) {
        final client = _clients[index];
        final updatedClient = client.copyWith(outstandingAmount: amount);
        
        _clients[index] = updatedClient;
        await saveClients();
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update outstanding amount: ${e.toString()}';
      notifyListeners();
    }
  }

  // Add loyalty points
  Future<void> addLoyaltyPoints(String clientId, int points) async {
    try {
      final index = _clients.indexWhere((c) => c.id == clientId);
      if (index != -1) {
        final client = _clients[index];
        final updatedClient = client.copyWith(loyaltyPoints: client.loyaltyPoints + points);
        
        _clients[index] = updatedClient;
        await saveClients();
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to add loyalty points: ${e.toString()}';
      notifyListeners();
    }
  }

  // Redeem loyalty points
  Future<void> redeemLoyaltyPoints(String clientId, int points) async {
    try {
      final index = _clients.indexWhere((c) => c.id == clientId);
      if (index != -1) {
        final client = _clients[index];
        if (client.loyaltyPoints >= points) {
          final updatedClient = client.copyWith(loyaltyPoints: client.loyaltyPoints - points);
          
          _clients[index] = updatedClient;
          await saveClients();
          notifyListeners();
        } else {
          throw Exception('Insufficient loyalty points');
        }
      }
    } catch (e) {
      _error = 'Failed to redeem loyalty points: ${e.toString()}';
      notifyListeners();
    }
  }

  // Update client status
  Future<void> updateClientStatus(String clientId, CustomerStatus status) async {
    try {
      final index = _clients.indexWhere((c) => c.id == clientId);
      if (index != -1) {
        final client = _clients[index];
        final updatedClient = client.copyWith(status: status);
        
        _clients[index] = updatedClient;
        await saveClients();
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update client status: ${e.toString()}';
      notifyListeners();
    }
  }

  // Upgrade client to VIP
  Future<void> upgradeToVIP(String clientId) async {
    try {
      final index = _clients.indexWhere((c) => c.id == clientId);
      if (index != -1) {
        final client = _clients[index];
        final updatedClient = client.copyWith(
          customerType: CustomerType.vip,
          discountPercentage: 10.0, // VIP discount
        );
        
        _clients[index] = updatedClient;
        await saveClients();
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to upgrade client to VIP: ${e.toString()}';
      notifyListeners();
    }
  }

  // Search clients
  List<JewelryClient> searchClients(String query) {
    if (query.isEmpty) return _clients;
    
    final lowerQuery = query.toLowerCase();
    return _clients.where((client) {
      return client.name.toLowerCase().contains(lowerQuery) ||
          client.email.toLowerCase().contains(lowerQuery) ||
          client.phone.contains(query) ||
          client.alternatePhone?.contains(query) == true ||
          client.gstNumber?.toLowerCase().contains(lowerQuery) == true ||
          client.panNumber?.toLowerCase().contains(lowerQuery) == true;
    }).toList();
  }

  // Get client by ID
  JewelryClient? getClientById(String id) {
    try {
      return _clients.firstWhere((client) => client.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get client by phone
  JewelryClient? getClientByPhone(String phone) {
    try {
      return _clients.firstWhere((client) => 
        client.phone == phone || client.alternatePhone == phone
      );
    } catch (e) {
      return null;
    }
  }

  // Get client by email
  JewelryClient? getClientByEmail(String email) {
    try {
      return _clients.firstWhere((client) => 
        client.email.toLowerCase() == email.toLowerCase()
      );
    } catch (e) {
      return null;
    }
  }

  // Get clients by city
  List<JewelryClient> getClientsByCity(String city) {
    return _clients.where((client) => 
      client.addresses.any((address) => 
        address.city.toLowerCase() == city.toLowerCase()
      )
    ).toList();
  }

  // Get clients by state
  List<JewelryClient> getClientsByState(String state) {
    return _clients.where((client) => 
      client.addresses.any((address) => 
        address.state.toLowerCase() == state.toLowerCase()
      )
    ).toList();
  }

  // Get clients who haven't purchased recently
  List<JewelryClient> getInactiveClients({int days = 90}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return _clients.where((client) {
      final lastPurchase = client.lastPurchaseDate;
      return lastPurchase == null || lastPurchase.isBefore(cutoffDate);
    }).toList();
  }

  // Get clients with upcoming birthdays
  List<JewelryClient> getUpcomingBirthdays({int days = 30}) {
    final today = DateTime.now();
    final endDate = today.add(Duration(days: days));
    
    return _clients.where((client) {
      if (client.dateOfBirth == null) return false;
      
      final birthday = DateTime(today.year, client.dateOfBirth!.month, client.dateOfBirth!.day);
      if (birthday.isBefore(today)) {
        final nextBirthday = DateTime(today.year + 1, client.dateOfBirth!.month, client.dateOfBirth!.day);
        return nextBirthday.isBefore(endDate) || nextBirthday.isAtSameMomentAs(endDate);
      } else {
        return birthday.isBefore(endDate) || birthday.isAtSameMomentAs(endDate);
      }
    }).toList();
  }

  // Get clients with upcoming anniversaries
  List<JewelryClient> getUpcomingAnniversaries({int days = 30}) {
    final today = DateTime.now();
    final endDate = today.add(Duration(days: days));
    
    return _clients.where((client) {
      if (client.anniversaryDate == null) return false;
      
      final anniversary = DateTime(today.year, client.anniversaryDate!.month, client.anniversaryDate!.day);
      if (anniversary.isBefore(today)) {
        final nextAnniversary = DateTime(today.year + 1, client.anniversaryDate!.month, client.anniversaryDate!.day);
        return nextAnniversary.isBefore(endDate) || nextAnniversary.isAtSameMomentAs(endDate);
      } else {
        return anniversary.isBefore(endDate) || anniversary.isAtSameMomentAs(endDate);
      }
    }).toList();
  }

  // Generate client report
  Map<String, dynamic> generateClientReport() {
    final totalClients = _clients.length;
    final activeClients = this.activeClients.length;
    final vipClients = this.vipClients.length;
    final wholesaleClients = this.wholesaleClients.length;
    
    return {
      'totalClients': totalClients,
      'activeClients': activeClients,
      'vipClients': vipClients,
      'wholesaleClients': wholesaleClients,
      'totalOutstanding': totalOutstanding,
      'totalCreditLimit': totalCreditLimit,
      'totalPurchaseAmount': totalPurchaseAmount,
      'totalLoyaltyPoints': totalLoyaltyPoints,
      'loyaltyStats': loyaltyStats,
      'customerTypeStats': customerTypeStats,
      'birthdayClients': birthdayClients.length,
      'anniversaryClients': anniversaryClients.length,
      'clientsExceedingCredit': clientsExceedingCredit.length,
    };
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh data
  Future<void> refresh() async {
    await loadClients();
  }
}