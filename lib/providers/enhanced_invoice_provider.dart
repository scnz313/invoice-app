import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/invoice.dart';
import '../models/client.dart';
import '../utils/validation_helper.dart';

enum LoadingState { idle, loading, success, error }

enum SyncStatus { synced, pending, failed, offline }

class InvoiceState {
  final List<Invoice> invoices;
  final LoadingState loadingState;
  final String? errorMessage;
  final List<Invoice> pendingInvoices; // For offline support
  final Map<String, SyncStatus> syncStatuses;
  final bool isOffline;

  const InvoiceState({
    this.invoices = const [],
    this.loadingState = LoadingState.idle,
    this.errorMessage,
    this.pendingInvoices = const [],
    this.syncStatuses = const {},
    this.isOffline = false,
  });

  InvoiceState copyWith({
    List<Invoice>? invoices,
    LoadingState? loadingState,
    String? errorMessage,
    List<Invoice>? pendingInvoices,
    Map<String, SyncStatus>? syncStatuses,
    bool? isOffline,
  }) {
    return InvoiceState(
      invoices: invoices ?? this.invoices,
      loadingState: loadingState ?? this.loadingState,
      errorMessage: errorMessage,
      pendingInvoices: pendingInvoices ?? this.pendingInvoices,
      syncStatuses: syncStatuses ?? this.syncStatuses,
      isOffline: isOffline ?? this.isOffline,
    );
  }

  bool get isLoading => loadingState == LoadingState.loading;
  bool get hasError => loadingState == LoadingState.error;
  bool get isSuccess => loadingState == LoadingState.success;
  bool get hasPendingSync => pendingInvoices.isNotEmpty;
}

class EnhancedInvoiceProvider extends ChangeNotifier {
  InvoiceState _state = const InvoiceState();
  final ValidationHelper _validator = ValidationHelper();
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  // Getters
  InvoiceState get state => _state;
  List<Invoice> get invoices => _state.invoices;
  LoadingState get loadingState => _state.loadingState;
  String? get errorMessage => _state.errorMessage;
  bool get isLoading => _state.isLoading;
  bool get hasError => _state.hasError;
  bool get isOffline => _state.isOffline;
  bool get hasPendingSync => _state.hasPendingSync;

  // Statistics
  int get totalInvoices => _state.invoices.length;
  double get totalAmount => _state.invoices.fold(0.0, (sum, invoice) => sum + invoice.total);
  double get paidAmount => _state.invoices
      .where((invoice) => invoice.status == InvoiceStatus.paid)
      .fold(0.0, (sum, invoice) => sum + invoice.total);
  double get pendingAmount => _state.invoices
      .where((invoice) => invoice.status != InvoiceStatus.paid)
      .fold(0.0, (sum, invoice) => sum + invoice.total);
  int get overdueCount => _state.invoices
      .where((invoice) => invoice.isOverdue)
      .length;

  // Filtered lists
  List<Invoice> get draftInvoices => _state.invoices
      .where((invoice) => invoice.status == InvoiceStatus.draft)
      .toList();
  
  List<Invoice> get sentInvoices => _state.invoices
      .where((invoice) => invoice.status == InvoiceStatus.sent)
      .toList();
  
  List<Invoice> get paidInvoices => _state.invoices
      .where((invoice) => invoice.status == InvoiceStatus.paid)
      .toList();
  
  List<Invoice> get overdueInvoices => _state.invoices
      .where((invoice) => invoice.isOverdue)
      .toList();

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
      
      // Set up connectivity monitoring
      _setupConnectivityMonitoring();
      
      // Load invoices
      await loadInvoices();
      
      // Sync pending changes if online
      if (!_state.isOffline) {
        await _syncPendingChanges();
      }
    } catch (e) {
      _updateState(_state.copyWith(
        loadingState: LoadingState.error,
        errorMessage: 'Failed to initialize: $e',
      ));
    }
  }

  void _setupConnectivityMonitoring() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      final isOffline = result == ConnectivityResult.none;
      if (isOffline != _state.isOffline) {
        _updateState(_state.copyWith(isOffline: isOffline));
        
        // Auto-sync when coming back online
        if (!isOffline && _state.hasPendingSync) {
          _syncPendingChanges();
        }
      }
    });
  }

  Future<void> loadInvoices() async {
    if (!_isInitialized) await initialize();
    
    try {
      _updateState(_state.copyWith(loadingState: LoadingState.loading));
      
      final invoicesJson = _prefs.getStringList('invoices') ?? [];
      final pendingJson = _prefs.getStringList('pending_invoices') ?? [];
      
      final invoices = invoicesJson
          .map((json) => Invoice.fromJson(jsonDecode(json)))
          .toList();
      
      final pendingInvoices = pendingJson
          .map((json) => Invoice.fromJson(jsonDecode(json)))
          .toList();
      
      // Load sync statuses
      final syncStatusesJson = _prefs.getString('sync_statuses') ?? '{}';
      final syncStatuses = Map<String, SyncStatus>.from(
        jsonDecode(syncStatusesJson).map((key, value) => 
          MapEntry(key, SyncStatus.values[value])
        )
      );
      
      _updateState(_state.copyWith(
        invoices: invoices,
        pendingInvoices: pendingInvoices,
        syncStatuses: syncStatuses,
        loadingState: LoadingState.success,
        errorMessage: null,
      ));
    } catch (e) {
      _updateState(_state.copyWith(
        loadingState: LoadingState.error,
        errorMessage: 'Failed to load invoices: $e',
      ));
      rethrow;
    }
  }

  Future<void> addInvoice(Invoice invoice, {bool optimistic = true}) async {
    try {
      // Validate invoice data
      final validationResult = _validateInvoice(invoice);
      if (!validationResult.isValid) {
        throw ValidationException(validationResult.errorMessage ?? 'Invalid invoice data');
      }

      if (optimistic) {
        // Optimistic update - add to UI immediately
        final updatedInvoices = [..._state.invoices, invoice];
        _updateState(_state.copyWith(invoices: updatedInvoices));
      }

      if (_state.isOffline) {
        // Add to pending queue for offline support
        await _addToPendingQueue(invoice, 'create');
      } else {
        // Save directly
        await _saveInvoice(invoice);
        _updateSyncStatus(invoice.id, SyncStatus.synced);
      }
    } catch (e) {
      if (optimistic) {
        // Revert optimistic update
        await loadInvoices();
      }
      
      _updateState(_state.copyWith(
        loadingState: LoadingState.error,
        errorMessage: 'Failed to add invoice: $e',
      ));
      rethrow;
    }
  }

  Future<void> updateInvoice(Invoice invoice, {bool optimistic = true}) async {
    try {
      // Validate invoice data
      final validationResult = _validateInvoice(invoice);
      if (!validationResult.isValid) {
        throw ValidationException(validationResult.errorMessage ?? 'Invalid invoice data');
      }

      if (optimistic) {
        // Optimistic update
        final updatedInvoices = _state.invoices.map((inv) => 
          inv.id == invoice.id ? invoice : inv
        ).toList();
        _updateState(_state.copyWith(invoices: updatedInvoices));
      }

      if (_state.isOffline) {
        await _addToPendingQueue(invoice, 'update');
      } else {
        await _saveInvoice(invoice);
        _updateSyncStatus(invoice.id, SyncStatus.synced);
      }
    } catch (e) {
      if (optimistic) {
        await loadInvoices();
      }
      
      _updateState(_state.copyWith(
        loadingState: LoadingState.error,
        errorMessage: 'Failed to update invoice: $e',
      ));
      rethrow;
    }
  }

  Future<void> deleteInvoice(String invoiceId, {bool optimistic = true}) async {
    try {
      Invoice? deletedInvoice;
      
      if (optimistic) {
        // Find and remove invoice optimistically
        deletedInvoice = _state.invoices.firstWhere((inv) => inv.id == invoiceId);
        final updatedInvoices = _state.invoices.where((inv) => inv.id != invoiceId).toList();
        _updateState(_state.copyWith(invoices: updatedInvoices));
      }

      if (_state.isOffline) {
        await _addToPendingQueue(deletedInvoice ?? Invoice.create(
          client: Client.empty(),
          items: [],
          dueDate: DateTime.now(),
        ), 'delete');
      } else {
        await _removeInvoice(invoiceId);
        _removeSyncStatus(invoiceId);
      }
    } catch (e) {
      if (optimistic) {
        await loadInvoices();
      }
      
      _updateState(_state.copyWith(
        loadingState: LoadingState.error,
        errorMessage: 'Failed to delete invoice: $e',
      ));
      rethrow;
    }
  }

  Future<void> updateInvoiceStatus(String invoiceId, InvoiceStatus status) async {
    try {
      final invoice = _state.invoices.firstWhere((inv) => inv.id == invoiceId);
      final updatedInvoice = invoice.copyWith(status: status);
      await updateInvoice(updatedInvoice);
    } catch (e) {
      _updateState(_state.copyWith(
        loadingState: LoadingState.error,
        errorMessage: 'Failed to update invoice status: $e',
      ));
      rethrow;
    }
  }

  Future<void> duplicateInvoice(String invoiceId) async {
    try {
      final originalInvoice = _state.invoices.firstWhere((inv) => inv.id == invoiceId);
      final duplicatedInvoice = Invoice.create(
        client: originalInvoice.client,
        items: originalInvoice.items,
        dueDate: DateTime.now().add(const Duration(days: 30)),
        taxPercentage: originalInvoice.taxPercentage,
        discountAmount: originalInvoice.discountAmount,
        notes: originalInvoice.notes,
      );
      
      await addInvoice(duplicatedInvoice);
    } catch (e) {
      _updateState(_state.copyWith(
        loadingState: LoadingState.error,
        errorMessage: 'Failed to duplicate invoice: $e',
      ));
      rethrow;
    }
  }

  // Search and filtering
  List<Invoice> searchInvoices(String query) {
    if (query.isEmpty) return _state.invoices;
    
    final lowercaseQuery = query.toLowerCase();
    return _state.invoices.where((invoice) =>
      invoice.invoiceNumber.toLowerCase().contains(lowercaseQuery) ||
      invoice.client.name.toLowerCase().contains(lowercaseQuery) ||
      invoice.client.email.toLowerCase().contains(lowercaseQuery) ||
      invoice.notes.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }

  List<Invoice> filterInvoicesByStatus(List<InvoiceStatus> statuses) {
    return _state.invoices.where((invoice) => statuses.contains(invoice.status)).toList();
  }

  List<Invoice> filterInvoicesByDateRange(DateTime startDate, DateTime endDate) {
    return _state.invoices.where((invoice) => 
      invoice.createdDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
      invoice.createdDate.isBefore(endDate.add(const Duration(days: 1)))
    ).toList();
  }

  List<Invoice> filterInvoicesByAmountRange(double minAmount, double maxAmount) {
    return _state.invoices.where((invoice) => 
      invoice.total >= minAmount && invoice.total <= maxAmount
    ).toList();
  }

  // Sorting
  List<Invoice> sortInvoices(InvoiceSortBy sortBy, {bool ascending = true}) {
    final sorted = [..._state.invoices];
    
    sorted.sort((a, b) {
      int comparison;
      switch (sortBy) {
        case InvoiceSortBy.invoiceNumber:
          comparison = a.invoiceNumber.compareTo(b.invoiceNumber);
          break;
        case InvoiceSortBy.clientName:
          comparison = a.client.name.compareTo(b.client.name);
          break;
        case InvoiceSortBy.amount:
          comparison = a.total.compareTo(b.total);
          break;
        case InvoiceSortBy.date:
          comparison = a.createdDate.compareTo(b.createdDate);
          break;
        case InvoiceSortBy.dueDate:
          comparison = a.dueDate.compareTo(b.dueDate);
          break;
        case InvoiceSortBy.status:
          comparison = a.status.index.compareTo(b.status.index);
          break;
      }
      return ascending ? comparison : -comparison;
    });
    
    return sorted;
  }

  // Bulk operations
  Future<void> bulkUpdateStatus(List<String> invoiceIds, InvoiceStatus status) async {
    try {
      _updateState(_state.copyWith(loadingState: LoadingState.loading));
      
      for (final id in invoiceIds) {
        await updateInvoiceStatus(id, status);
      }
      
      _updateState(_state.copyWith(loadingState: LoadingState.success));
    } catch (e) {
      _updateState(_state.copyWith(
        loadingState: LoadingState.error,
        errorMessage: 'Failed to bulk update invoices: $e',
      ));
      rethrow;
    }
  }

  Future<void> bulkDelete(List<String> invoiceIds) async {
    try {
      _updateState(_state.copyWith(loadingState: LoadingState.loading));
      
      for (final id in invoiceIds) {
        await deleteInvoice(id, optimistic: false);
      }
      
      await loadInvoices(); // Refresh the list
    } catch (e) {
      _updateState(_state.copyWith(
        loadingState: LoadingState.error,
        errorMessage: 'Failed to bulk delete invoices: $e',
      ));
      rethrow;
    }
  }

  // Export functionality
  Future<Map<String, dynamic>> exportData() async {
    try {
      return {
        'invoices': _state.invoices.map((inv) => inv.toJson()).toList(),
        'exportDate': DateTime.now().toIso8601String(),
        'version': '1.0',
      };
    } catch (e) {
      throw Exception('Failed to export data: $e');
    }
  }

  Future<void> importData(Map<String, dynamic> data) async {
    try {
      _updateState(_state.copyWith(loadingState: LoadingState.loading));
      
      final invoicesData = data['invoices'] as List;
      final importedInvoices = invoicesData
          .map((json) => Invoice.fromJson(json))
          .toList();
      
      // Validate imported data
      for (final invoice in importedInvoices) {
        final validationResult = _validateInvoice(invoice);
        if (!validationResult.isValid) {
          throw ValidationException(
            'Invalid invoice data for ${invoice.invoiceNumber}: ${validationResult.errorMessage}'
          );
        }
      }
      
      // Save imported invoices
      for (final invoice in importedInvoices) {
        await _saveInvoice(invoice);
      }
      
      await loadInvoices();
    } catch (e) {
      _updateState(_state.copyWith(
        loadingState: LoadingState.error,
        errorMessage: 'Failed to import data: $e',
      ));
      rethrow;
    }
  }

  // Offline support methods
  Future<void> _addToPendingQueue(Invoice invoice, String operation) async {
    final pendingItem = {
      'invoice': invoice.toJson(),
      'operation': operation,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    final pendingQueue = _prefs.getStringList('pending_queue') ?? [];
    pendingQueue.add(jsonEncode(pendingItem));
    await _prefs.setStringList('pending_queue', pendingQueue);
    
    final updatedPending = [..._state.pendingInvoices, invoice];
    _updateState(_state.copyWith(pendingInvoices: updatedPending));
    
    _updateSyncStatus(invoice.id, SyncStatus.pending);
  }

  Future<void> _syncPendingChanges() async {
    if (_state.isOffline) return;
    
    try {
      final pendingQueue = _prefs.getStringList('pending_queue') ?? [];
      
      for (final item in pendingQueue) {
        final pendingItem = jsonDecode(item);
        final invoice = Invoice.fromJson(pendingItem['invoice']);
        final operation = pendingItem['operation'];
        
        try {
          switch (operation) {
            case 'create':
            case 'update':
              await _saveInvoice(invoice);
              break;
            case 'delete':
              await _removeInvoice(invoice.id);
              break;
          }
          
          _updateSyncStatus(invoice.id, SyncStatus.synced);
        } catch (e) {
          _updateSyncStatus(invoice.id, SyncStatus.failed);
        }
      }
      
      // Clear pending queue
      await _prefs.remove('pending_queue');
      _updateState(_state.copyWith(pendingInvoices: []));
      
    } catch (e) {
      debugPrint('Failed to sync pending changes: $e');
    }
  }

  // Private helper methods
  void _updateState(InvoiceState newState) {
    _state = newState;
    notifyListeners();
  }

  ValidationResult _validateInvoice(Invoice invoice) {
    // Validate invoice number
    final invoiceNumberResult = _validator.validate(invoice.invoiceNumber, 'invoiceNumber');
    if (!invoiceNumberResult.isValid) return invoiceNumberResult;
    
    // Check for duplicate invoice numbers
    final existingNumbers = _state.invoices
        .where((inv) => inv.id != invoice.id)
        .map((inv) => inv.invoiceNumber)
        .toList();
    
    final duplicateResult = _validator.validateUnique(
      invoice.invoiceNumber, 
      'Invoice number', 
      existingNumbers
    );
    if (!duplicateResult.isValid) return duplicateResult;
    
    // Validate client data
    final clientNameResult = _validator.validate(invoice.client.name, 'clientName');
    if (!clientNameResult.isValid) return clientNameResult;
    
    if (invoice.client.email.isNotEmpty) {
      final emailResult = _validator.validate(invoice.client.email, 'email');
      if (!emailResult.isValid) return emailResult;
    }
    
    // Validate invoice items
    if (invoice.items.isEmpty) {
      return ValidationResult.invalid(
        'Invoice must have at least one item',
        ValidationError.businessRuleViolation,
      );
    }
    
    for (final item in invoice.items) {
      final descResult = _validator.validate(item.description, 'description');
      if (!descResult.isValid) return descResult;
      
      if (item.quantity <= 0) {
        return ValidationResult.invalid(
          'Item quantity must be greater than zero',
          ValidationError.invalidRange,
        );
      }
      
      if (item.price < 0) {
        return ValidationResult.invalid(
          'Item price cannot be negative',
          ValidationError.invalidRange,
        );
      }
    }
    
    // Validate dates
    final dateResult = _validator.validateDate(
      invoice.dueDate, 
      'Due date',
      allowPast: false,
    );
    if (!dateResult.isValid) return dateResult;
    
    return ValidationResult.valid(null);
  }

  Future<void> _saveInvoice(Invoice invoice) async {
    final invoices = [..._state.invoices];
    final existingIndex = invoices.indexWhere((inv) => inv.id == invoice.id);
    
    if (existingIndex != -1) {
      invoices[existingIndex] = invoice;
    } else {
      invoices.add(invoice);
    }
    
    final invoicesJson = invoices.map((inv) => jsonEncode(inv.toJson())).toList();
    await _prefs.setStringList('invoices', invoicesJson);
  }

  Future<void> _removeInvoice(String invoiceId) async {
    final invoices = _state.invoices.where((inv) => inv.id != invoiceId).toList();
    final invoicesJson = invoices.map((inv) => jsonEncode(inv.toJson())).toList();
    await _prefs.setStringList('invoices', invoicesJson);
  }

  void _updateSyncStatus(String invoiceId, SyncStatus status) {
    final updatedStatuses = {..._state.syncStatuses};
    updatedStatuses[invoiceId] = status;
    
    _updateState(_state.copyWith(syncStatuses: updatedStatuses));
    
    // Save to preferences
    final statusesJson = jsonEncode(updatedStatuses.map(
      (key, value) => MapEntry(key, value.index)
    ));
    _prefs.setString('sync_statuses', statusesJson);
  }

  void _removeSyncStatus(String invoiceId) {
    final updatedStatuses = {..._state.syncStatuses};
    updatedStatuses.remove(invoiceId);
    
    _updateState(_state.copyWith(syncStatuses: updatedStatuses));
    
    final statusesJson = jsonEncode(updatedStatuses.map(
      (key, value) => MapEntry(key, value.index)
    ));
    _prefs.setString('sync_statuses', statusesJson);
  }

  // Clear all data
  Future<void> clearAllInvoices() async {
    try {
      _updateState(_state.copyWith(loadingState: LoadingState.loading));
      
      await _prefs.remove('invoices');
      await _prefs.remove('pending_invoices');
      await _prefs.remove('pending_queue');
      await _prefs.remove('sync_statuses');
      
      _updateState(const InvoiceState(loadingState: LoadingState.success));
    } catch (e) {
      _updateState(_state.copyWith(
        loadingState: LoadingState.error,
        errorMessage: 'Failed to clear invoices: $e',
      ));
      rethrow;
    }
  }

  // Force refresh
  Future<void> refresh() async {
    await loadInvoices();
  }

  // Error handling
  void clearError() {
    _updateState(_state.copyWith(
      errorMessage: null,
      loadingState: LoadingState.idle,
    ));
  }
}

enum InvoiceSortBy {
  invoiceNumber,
  clientName,
  amount,
  date,
  dueDate,
  status,
}

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);
  
  @override
  String toString() => 'ValidationException: $message';
} 