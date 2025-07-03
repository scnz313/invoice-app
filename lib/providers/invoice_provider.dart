import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/invoice.dart';

class InvoiceProvider with ChangeNotifier {
  List<Invoice> _invoices = [];
  bool _isLoading = false;

  List<Invoice> get invoices => List.unmodifiable(_invoices);
  bool get isLoading => _isLoading;

  static const String _storageKey = 'invoices';

  // Load invoices from local storage
  Future<void> loadInvoices() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final invoicesJson = prefs.getString(_storageKey);
      
      if (invoicesJson != null) {
        final List<dynamic> invoicesList = json.decode(invoicesJson);
        _invoices = invoicesList.map((json) => Invoice.fromJson(json)).toList();
        // Sort by creation date, newest first
        _invoices.sort((a, b) => b.createdDate.compareTo(a.createdDate));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading invoices: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save invoices to local storage
  Future<void> _saveInvoices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final invoicesJson = json.encode(_invoices.map((invoice) => invoice.toJson()).toList());
      await prefs.setString(_storageKey, invoicesJson);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving invoices: $e');
      }
    }
  }

  // Add a new invoice
  Future<void> addInvoice(Invoice invoice) async {
    _invoices.insert(0, invoice); // Add to beginning for newest first
    notifyListeners();
    await _saveInvoices();
  }

  // Update an existing invoice
  Future<void> updateInvoice(Invoice updatedInvoice) async {
    final index = _invoices.indexWhere((invoice) => invoice.id == updatedInvoice.id);
    if (index != -1) {
      _invoices[index] = updatedInvoice;
      notifyListeners();
      await _saveInvoices();
    }
  }

  // Delete an invoice
  Future<void> deleteInvoice(String invoiceId) async {
    _invoices.removeWhere((invoice) => invoice.id == invoiceId);
    notifyListeners();
    await _saveInvoices();
  }

  // Get invoice by ID
  Invoice? getInvoiceById(String id) {
    try {
      return _invoices.firstWhere((invoice) => invoice.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get invoices by status
  List<Invoice> getInvoicesByStatus(InvoiceStatus status) {
    return _invoices.where((invoice) => invoice.status == status).toList();
  }

  // Get overdue invoices
  List<Invoice> getOverdueInvoices() {
    return _invoices.where((invoice) => invoice.isOverdue).toList();
  }

  // Search invoices by invoice number or client name
  List<Invoice> searchInvoices(String query) {
    if (query.isEmpty) return invoices;
    
    final lowerQuery = query.toLowerCase();
    return _invoices.where((invoice) =>
      invoice.invoiceNumber.toLowerCase().contains(lowerQuery) ||
      invoice.client.name.toLowerCase().contains(lowerQuery)
    ).toList();
  }

  // Get total revenue (all paid invoices)
  double get totalRevenue {
    return _invoices
        .where((invoice) => invoice.status == InvoiceStatus.paid)
        .fold(0.0, (sum, invoice) => sum + invoice.total);
  }

  // Get pending amount (draft + sent invoices)
  double get pendingAmount {
    return _invoices
        .where((invoice) => 
          invoice.status == InvoiceStatus.draft || 
          invoice.status == InvoiceStatus.sent)
        .fold(0.0, (sum, invoice) => sum + invoice.total);
  }

  // Get overdue amount
  double get overdueAmount {
    return _invoices
        .where((invoice) => invoice.isOverdue)
        .fold(0.0, (sum, invoice) => sum + invoice.total);
  }

  // Get paid amount
  double get paidAmount {
    return _invoices
        .where((invoice) => invoice.status == InvoiceStatus.paid)
        .fold(0.0, (sum, invoice) => sum + invoice.total);
  }

  // Get invoices count by status
  int getInvoicesCountByStatus(InvoiceStatus status) {
    return _invoices.where((invoice) => invoice.status == status).length;
  }

  // Get total invoices count
  int get invoicesCount => _invoices.length;

  // Update invoice status
  Future<void> updateInvoiceStatus(String invoiceId, InvoiceStatus newStatus) async {
    final invoice = getInvoiceById(invoiceId);
    if (invoice != null) {
      final updatedInvoice = invoice.copyWith(status: newStatus);
      await updateInvoice(updatedInvoice);
    }
  }

  // Mark invoice as paid
  Future<void> markInvoiceAsPaid(String invoiceId) async {
    await updateInvoiceStatus(invoiceId, InvoiceStatus.paid);
  }

  // Mark invoice as sent
  Future<void> markInvoiceAsSent(String invoiceId) async {
    await updateInvoiceStatus(invoiceId, InvoiceStatus.sent);
  }

  // Clear all invoices (for testing purposes)
  Future<void> clearAllInvoices() async {
    _invoices.clear();
    notifyListeners();
    await _saveInvoices();
  }


} 