import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/client.dart';

class ClientProvider with ChangeNotifier {
  List<Client> _clients = [];
  bool _isLoading = false;

  List<Client> get clients => List.unmodifiable(_clients);
  bool get isLoading => _isLoading;

  static const String _storageKey = 'clients';

  // Load clients from local storage
  Future<void> loadClients() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final clientsJson = prefs.getString(_storageKey);
      
      if (clientsJson != null) {
        final List<dynamic> clientsList = json.decode(clientsJson);
        _clients = clientsList.map((json) => Client.fromJson(json)).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading clients: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save clients to local storage
  Future<void> _saveClients() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final clientsJson = json.encode(_clients.map((client) => client.toJson()).toList());
      await prefs.setString(_storageKey, clientsJson);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving clients: $e');
      }
    }
  }

  // Add a new client
  Future<void> addClient(Client client) async {
    _clients.add(client);
    notifyListeners();
    await _saveClients();
  }

  // Update an existing client
  Future<void> updateClient(Client updatedClient) async {
    final index = _clients.indexWhere((client) => client.id == updatedClient.id);
    if (index != -1) {
      _clients[index] = updatedClient;
      notifyListeners();
      await _saveClients();
    }
  }

  // Delete a client
  Future<void> deleteClient(String clientId) async {
    _clients.removeWhere((client) => client.id == clientId);
    notifyListeners();
    await _saveClients();
  }

  // Get client by ID
  Client? getClientById(String id) {
    try {
      return _clients.firstWhere((client) => client.id == id);
    } catch (e) {
      return null;
    }
  }

  // Search clients by name or email
  List<Client> searchClients(String query) {
    if (query.isEmpty) return clients;
    
    final lowerQuery = query.toLowerCase();
    return _clients.where((client) =>
      client.name.toLowerCase().contains(lowerQuery) ||
      client.email.toLowerCase().contains(lowerQuery)
    ).toList();
  }

  // Get clients count
  int get clientsCount => _clients.length;

  // Clear all clients (for testing purposes)
  Future<void> clearAllClients() async {
    _clients.clear();
    notifyListeners();
    await _saveClients();
  }


} 