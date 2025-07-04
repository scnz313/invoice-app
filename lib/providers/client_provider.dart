import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/client.dart';
import '../utils/logger.dart';

class ClientProvider with ChangeNotifier {
  List<Client> _clients = [];
  bool _isLoading = false;

  List<Client> get clients => List.unmodifiable(_clients);
  bool get isLoading => _isLoading;

  static const String _storageKey = 'clients';

  // Load clients from local storage
  Future<void> loadClients() async {
    _isLoading = true;
    // Don't notify listeners here to avoid setState during build

    try {
      final prefs = await SharedPreferences.getInstance();
      final clientsJson = prefs.getString(_storageKey);
      
      if (clientsJson != null) {
        // attempt to decode
        dynamic decoded = json.decode(clientsJson);

        // ------------------------------------------------------------------
        // Data-migration:
        // Some older builds saved the list of clients as a **single JSON
        // string** instead of a JSON encoded list. That produces a String
        // when decoded – causing the type-cast error we saw.  Detect and
        // migrate that data on-the-fly to the new canonical format.
        // ------------------------------------------------------------------
        if (decoded is String) {
          // old format -> the decoded value is itself a stringified list
          try {
            decoded = json.decode(decoded);
            // Persist back in the correct (single-encoded) format so
            // we don't pay the cost next launch.
            await prefs.setString(_storageKey, json.encode(decoded));
          } catch (_) {
            decoded = [];
          }
        }

        // Another legacy path stored each element as a JSON string.
        if (decoded is List) {
          final List<dynamic> rawList = decoded;
          _clients = rawList.map((element) {
            // If the element is a string, decode once more.
            final map = element is String ? json.decode(element) : element;
            return Client.fromJson(map as Map<String, dynamic>);
          }).toList();
        }
      }
    } catch (e) {
      Logger.error('Error loading clients', 'ClientProvider', e);
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
      Logger.error('Error saving clients', 'ClientProvider', e);
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