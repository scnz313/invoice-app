import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/jewelry_invoice.dart';
import '../models/jewelry_item.dart';
import '../models/jewelry_client.dart';
import '../models/metal_rates.dart';
import '../models/invoice.dart';

class JewelryInvoiceProvider with ChangeNotifier {
  List<JewelryInvoice> _invoices = [];
  List<JewelryItem> _jewelryItems = [];
  bool _isLoading = false;
  String? _error;

  List<JewelryInvoice> get invoices => _invoices;
  List<JewelryItem> get jewelryItems => _jewelryItems;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get invoices by type
  List<JewelryInvoice> getInvoicesByType(InvoiceType type) {
    return _invoices.where((invoice) => invoice.type == type).toList();
  }

  // Get invoices by status
  List<JewelryInvoice> getInvoicesByStatus(InvoiceStatus status) {
    return _invoices.where((invoice) => invoice.status == status).toList();
  }

  // Get invoices by client
  List<JewelryInvoice> getInvoicesByClient(String clientId) {
    return _invoices.where((invoice) => invoice.client.id == clientId).toList();
  }

  // Get pending invoices
  List<JewelryInvoice> get pendingInvoices => _invoices.where((invoice) => !invoice.isFullyPaid).toList();

  // Get overdue invoices
  List<JewelryInvoice> get overdueInvoices => _invoices.where((invoice) => invoice.isOverdue).toList();

  // Get estimates
  List<JewelryInvoice> get estimates => getInvoicesByType(InvoiceType.estimate);

  // Get exchange invoices
  List<JewelryInvoice> get exchangeInvoices => getInvoicesByType(InvoiceType.exchange);

  // Calculate totals
  double get totalAmount => _invoices.fold(0.0, (sum, invoice) => sum + invoice.finalAmount);
  double get totalPaidAmount => _invoices.fold(0.0, (sum, invoice) => sum + invoice.totalPaidAmount);
  double get totalPendingAmount => _invoices.fold(0.0, (sum, invoice) => sum + invoice.pendingAmount);
  double get totalExchangeValue => _invoices.fold(0.0, (sum, invoice) => sum + invoice.totalExchangeValue);

  // Get total weight by metal type
  Map<MetalType, double> get totalWeightByMetal {
    final weights = <MetalType, double>{};
    for (final invoice in _invoices) {
      final invoiceWeights = invoice.totalWeightByMetal;
      for (final entry in invoiceWeights.entries) {
        weights[entry.key] = (weights[entry.key] ?? 0) + entry.value;
      }
    }
    return weights;
  }

  // Get monthly sales data
  Map<String, double> get monthlySales {
    final sales = <String, double>{};
    for (final invoice in _invoices) {
      final monthKey = '${invoice.createdDate.year}-${invoice.createdDate.month.toString().padLeft(2, '0')}';
      sales[monthKey] = (sales[monthKey] ?? 0) + invoice.finalAmount;
    }
    return sales;
  }

  // Get top selling items
  List<JewelryItem> get topSellingItems {
    final itemCounts = <String, int>{};
    for (final invoice in _invoices) {
      for (final item in invoice.items) {
        itemCounts[item.name] = (itemCounts[item.name] ?? 0) + item.quantity;
      }
    }
    
    final sortedItems = itemCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedItems.take(10).map((entry) {
      return _jewelryItems.firstWhere(
        (item) => item.name == entry.key,
        orElse: () => _jewelryItems.first,
      );
    }).toList();
  }

  // Load invoices from storage
  Future<void> loadInvoices() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final invoicesJson = prefs.getStringList('jewelry_invoices') ?? [];
      
      _invoices = invoicesJson.map((json) {
        final Map<String, dynamic> data = jsonDecode(json);
        return JewelryInvoice.fromJson(data);
      }).toList();

      // Sort by creation date (newest first)
      _invoices.sort((a, b) => b.createdDate.compareTo(a.createdDate));

      // Load jewelry items
      await loadJewelryItems();

    } catch (e) {
      _error = 'Failed to load invoices: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save invoices to storage
  Future<void> saveInvoices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final invoicesJson = _invoices.map((invoice) => jsonEncode(invoice.toJson())).toList();
      await prefs.setStringList('jewelry_invoices', invoicesJson);
    } catch (e) {
      _error = 'Failed to save invoices: ${e.toString()}';
      notifyListeners();
    }
  }

  // Load jewelry items from storage
  Future<void> loadJewelryItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final itemsJson = prefs.getStringList('jewelry_items') ?? [];
      
      _jewelryItems = itemsJson.map((json) {
        final Map<String, dynamic> data = jsonDecode(json);
        return JewelryItem.fromJson(data);
      }).toList();

    } catch (e) {
      _error = 'Failed to load jewelry items: ${e.toString()}';
    }
  }

  // Save jewelry items to storage
  Future<void> saveJewelryItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final itemsJson = _jewelryItems.map((item) => jsonEncode(item.toJson())).toList();
      await prefs.setStringList('jewelry_items', itemsJson);
    } catch (e) {
      _error = 'Failed to save jewelry items: ${e.toString()}';
      notifyListeners();
    }
  }

  // Add new invoice
  Future<void> addInvoice(JewelryInvoice invoice) async {
    try {
      _invoices.insert(0, invoice);
      
      // Add items to jewelry items if they don't exist
      for (final item in invoice.items) {
        if (!_jewelryItems.any((existing) => existing.id == item.id)) {
          _jewelryItems.add(item);
        }
      }
      
      await saveInvoices();
      await saveJewelryItems();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add invoice: ${e.toString()}';
      notifyListeners();
    }
  }

  // Update invoice
  Future<void> updateInvoice(JewelryInvoice invoice) async {
    try {
      final index = _invoices.indexWhere((i) => i.id == invoice.id);
      if (index != -1) {
        _invoices[index] = invoice;
        await saveInvoices();
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update invoice: ${e.toString()}';
      notifyListeners();
    }
  }

  // Delete invoice
  Future<void> deleteInvoice(String invoiceId) async {
    try {
      _invoices.removeWhere((invoice) => invoice.id == invoiceId);
      await saveInvoices();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete invoice: ${e.toString()}';
      notifyListeners();
    }
  }

  // Add payment to invoice
  Future<void> addPayment(String invoiceId, Payment payment) async {
    try {
      final index = _invoices.indexWhere((i) => i.id == invoiceId);
      if (index != -1) {
        final invoice = _invoices[index];
        final updatedPayments = List<Payment>.from(invoice.payments)..add(payment);
        
        // Update invoice status if fully paid
        InvoiceStatus newStatus = invoice.status;
        if (invoice.finalAmount <= invoice.totalPaidAmount + payment.amount) {
          newStatus = InvoiceStatus.paid;
        }
        
        final updatedInvoice = invoice.copyWith(
          payments: updatedPayments,
          status: newStatus,
        );
        
        _invoices[index] = updatedInvoice;
        await saveInvoices();
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to add payment: ${e.toString()}';
      notifyListeners();
    }
  }

  // Add exchange item to invoice
  Future<void> addExchangeItem(String invoiceId, ExchangeItem exchangeItem) async {
    try {
      final index = _invoices.indexWhere((i) => i.id == invoiceId);
      if (index != -1) {
        final invoice = _invoices[index];
        final updatedExchangeItems = List<ExchangeItem>.from(invoice.exchangeItems)..add(exchangeItem);
        
        final updatedInvoice = invoice.copyWith(exchangeItems: updatedExchangeItems);
        
        _invoices[index] = updatedInvoice;
        await saveInvoices();
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to add exchange item: ${e.toString()}';
      notifyListeners();
    }
  }

  // Convert estimate to invoice
  Future<void> convertEstimateToInvoice(String estimateId) async {
    try {
      final index = _invoices.indexWhere((i) => i.id == estimateId);
      if (index != -1) {
        final estimate = _invoices[index];
        if (estimate.type == InvoiceType.estimate) {
          final updatedInvoice = estimate.copyWith(
            type: InvoiceType.sale,
            status: InvoiceStatus.draft,
          );
          
          _invoices[index] = updatedInvoice;
          await saveInvoices();
          notifyListeners();
        }
      }
    } catch (e) {
      _error = 'Failed to convert estimate to invoice: ${e.toString()}';
      notifyListeners();
    }
  }

  // Search invoices
  List<JewelryInvoice> searchInvoices(String query) {
    if (query.isEmpty) return _invoices;
    
    final lowerQuery = query.toLowerCase();
    return _invoices.where((invoice) {
      return invoice.invoiceNumber.toLowerCase().contains(lowerQuery) ||
          invoice.client.name.toLowerCase().contains(lowerQuery) ||
          invoice.client.phone.contains(query) ||
          invoice.items.any((item) => item.name.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  // Get invoice by ID
  JewelryInvoice? getInvoiceById(String id) {
    try {
      return _invoices.firstWhere((invoice) => invoice.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get customer summary
  Map<String, dynamic> getCustomerSummary(String clientId) {
    final customerInvoices = getInvoicesByClient(clientId);
    final totalAmount = customerInvoices.fold(0.0, (sum, invoice) => sum + invoice.finalAmount);
    final totalPaid = customerInvoices.fold(0.0, (sum, invoice) => sum + invoice.totalPaidAmount);
    final totalPending = customerInvoices.fold(0.0, (sum, invoice) => sum + invoice.pendingAmount);
    
    return {
      'totalInvoices': customerInvoices.length,
      'totalAmount': totalAmount,
      'totalPaid': totalPaid,
      'totalPending': totalPending,
      'lastPurchaseDate': customerInvoices.isNotEmpty ? customerInvoices.first.createdDate : null,
    };
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh data
  Future<void> refresh() async {
    await loadInvoices();
  }
}