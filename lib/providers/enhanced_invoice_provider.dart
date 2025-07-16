import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/enhanced_invoice.dart';
import '../models/business_category.dart';
import '../models/client.dart';
import '../services/database_service.dart';
import '../utils/logger.dart';
import 'package:csv/csv.dart';

class EnhancedInvoiceProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final Uuid _uuid = const Uuid();

  List<EnhancedInvoice> _invoices = [];
  List<Client> _clients = [];
  List<Product> _products = [];
  BusinessSettings? _businessSettings;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<EnhancedInvoice> get invoices => _invoices;
  List<Client> get clients => _clients;
  List<Product> get products => _products;
  BusinessSettings? get businessSettings => _businessSettings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize the provider
  Future<void> initialize() async {
    try {
      _setLoading(true);
      await Future.wait([
        loadInvoices(),
        loadClients(),
        loadProducts(),
        loadBusinessSettings(),
      ]);
      _setError(null);
    } catch (e) {
      Logger.error('Failed to initialize EnhancedInvoiceProvider', 'EnhancedInvoiceProvider', e);
      _setError('Failed to initialize: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Invoice operations
  Future<void> loadInvoices() async {
    try {
      _invoices = await _databaseService.getAllInvoices();
      notifyListeners();
    } catch (e) {
      Logger.error('Failed to load invoices', 'EnhancedInvoiceProvider', e);
      rethrow;
    }
  }

  Future<void> addInvoice(EnhancedInvoice invoice) async {
    try {
      await _databaseService.insertInvoice(invoice);
      _invoices.insert(0, invoice);
      notifyListeners();
    } catch (e) {
      Logger.error('Failed to add invoice', 'EnhancedInvoiceProvider', e);
      rethrow;
    }
  }

  Future<void> updateInvoice(EnhancedInvoice invoice) async {
    try {
      await _databaseService.updateInvoice(invoice);
      final index = _invoices.indexWhere((i) => i.id == invoice.id);
      if (index != -1) {
        _invoices[index] = invoice;
        notifyListeners();
      }
    } catch (e) {
      Logger.error('Failed to update invoice', 'EnhancedInvoiceProvider', e);
      rethrow;
    }
  }

  Future<void> deleteInvoice(String id) async {
    try {
      await _databaseService.deleteInvoice(id);
      _invoices.removeWhere((invoice) => invoice.id == id);
      notifyListeners();
    } catch (e) {
      Logger.error('Failed to delete invoice', 'EnhancedInvoiceProvider', e);
      rethrow;
    }
  }

  Future<EnhancedInvoice?> getInvoiceById(String id) async {
    try {
      return await _databaseService.getInvoiceById(id);
    } catch (e) {
      Logger.error('Failed to get invoice by id', 'EnhancedInvoiceProvider', e);
      rethrow;
    }
  }

  // Client operations
  Future<void> loadClients() async {
    try {
      _clients = await _databaseService.getAllClients();
      notifyListeners();
    } catch (e) {
      Logger.error('Failed to load clients', 'EnhancedInvoiceProvider', e);
    }
  }

  Future<void> addClient(Client client) async {
    try {
      await _databaseService.insertClient(client);
      _clients.add(client);
      _clients.sort((a, b) => a.name.compareTo(b.name));
      notifyListeners();
    } catch (e) {
      Logger.error('Failed to add client', 'EnhancedInvoiceProvider', e);
    }
  }

  Future<void> updateClient(Client client) async {
    try {
      await _databaseService.updateClient(client);
      final index = _clients.indexWhere((c) => c.id == client.id);
      if (index != -1) {
        _clients[index] = client;
        _clients.sort((a, b) => a.name.compareTo(b.name));
        notifyListeners();
      }
    } catch (e) {
      Logger.error('Failed to update client', 'EnhancedInvoiceProvider', e);
    }
  }

  Future<void> deleteClient(String id) async {
    try {
      await _databaseService.deleteClient(id);
      _clients.removeWhere((client) => client.id == id);
      notifyListeners();
    } catch (e) {
      Logger.error('Failed to delete client', 'EnhancedInvoiceProvider', e);
    }
  }

  // Product operations
  Future<void> loadProducts() async {
    try {
      _products = await _databaseService.getAllProducts();
      notifyListeners();
    } catch (e) {
      Logger.error('Failed to load products', 'EnhancedInvoiceProvider', e);
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      await _databaseService.insertProduct(product);
      _products.add(product);
      _products.sort((a, b) => a.name.compareTo(b.name));
      notifyListeners();
    } catch (e) {
      Logger.error('Failed to add product', 'EnhancedInvoiceProvider', e);
      rethrow;
    }
  }

  List<Product> getProductsByCategory(BusinessCategory category) {
    return _products.where((product) => product.category == category).toList();
  }

  // Business settings operations
  Future<void> loadBusinessSettings() async {
    try {
      _businessSettings = await _databaseService.getBusinessSettings();
      notifyListeners();
    } catch (e) {
      Logger.error('Failed to load business settings', 'EnhancedInvoiceProvider', e);
      rethrow;
    }
  }

  Future<void> saveBusinessSettings(BusinessSettings settings) async {
    try {
      await _databaseService.saveBusinessSettings(settings);
      _businessSettings = settings;
      notifyListeners();
    } catch (e) {
      Logger.error('Failed to save business settings', 'EnhancedInvoiceProvider', e);
      rethrow;
    }
  }

  // Invoice creation helpers
  String generateInvoiceNumber() {
    final prefix = _businessSettings?.invoicePrefix ?? 'INV';
    final date = DateTime.now();
    final year = date.year.toString().substring(2);
    final month = date.month.toString().padLeft(2, '0');
    final count = _invoices.where((i) => 
      i.createdAt.year == date.year && i.createdAt.month == date.month
    ).length + 1;
    
    return '$prefix$year$month${count.toString().padLeft(3, '0')}';
  }

  EnhancedInvoice createDraftInvoice({
    required BusinessCategory category,
    required Client client,
    List<InvoiceItem>? items,
    List<CategorySpecificField>? categoryFields,
  }) {
    final now = DateTime.now();
    final dueDate = now.add(const Duration(days: 30));

    // Convert Client to Customer for EnhancedInvoice
    final customer = Customer(
      id: client.id,
      name: client.name,
      email: client.email,
      phone: client.phone,
      address: client.address,
      type: CustomerType.individual,
    );

    return EnhancedInvoice(
      id: _uuid.v4(),
      invoiceNumber: generateInvoiceNumber(),
      businessCategory: category,
      createdAt: now,
      dueDate: dueDate,
      status: InvoiceStatus.draft,
      customer: customer,
      items: items ?? [],
      categoryFields: categoryFields ?? CategoryFieldDefinitions.getFieldsForCategory(category),
      totals: InvoiceTotals(
        subtotal: 0.0,
        discountTotal: 0.0,
        taxableAmount: 0.0,
        taxTotal: 0.0,
        grandTotal: 0.0,
        currency: _businessSettings?.currency ?? 'INR',
      ),
    );
  }

  InvoiceItem createInvoiceItem({
    required String name,
    String? description,
    required double quantity,
    required String unit,
    required double unitPrice,
    double discount = 0.0,
    double? taxRate,
    required BusinessCategory category,
    Map<String, dynamic>? metadata,
  }) {
    return InvoiceItem(
      id: _uuid.v4(),
      name: name,
      description: description,
      quantity: quantity,
      unit: unit,
      unitPrice: unitPrice,
      discount: discount,
      taxRate: taxRate ?? category.defaultTaxRate,
      categoryFields: CategoryFieldDefinitions.getFieldsForCategory(category),
      metadata: metadata,
    );
  }

  Customer createCustomer({
    required String name,
    String? email,
    String? phone,
    String? address,
    String? gstNumber,
    CustomerType type = CustomerType.individual,
    Map<String, dynamic>? categorySpecificData,
  }) {
    return Customer(
      id: _uuid.v4(),
      name: name,
      email: email,
      phone: phone,
      address: address,
      gstNumber: gstNumber,
      type: type,
      categorySpecificData: categorySpecificData,
    );
  }

  Product createProduct({
    required String name,
    String? description,
    required BusinessCategory category,
    required String unit,
    required double unitPrice,
    double? taxRate,
    Map<String, dynamic>? metadata,
  }) {
    return Product(
      id: _uuid.v4(),
      name: name,
      description: description,
      category: category,
      unit: unit,
      unitPrice: unitPrice,
      taxRate: taxRate ?? category.defaultTaxRate,
      categoryFields: CategoryFieldDefinitions.getFieldsForCategory(category),
      metadata: metadata,
    );
  }

  // Calculation helpers
  InvoiceTotals calculateTotals(List<InvoiceItem> items) {
    double subtotal = 0;
    double taxTotal = 0;
    double discountTotal = 0;

    for (final item in items) {
      subtotal += item.unitPrice * item.quantity;
      taxTotal += item.taxAmount;
      discountTotal += item.discount;
    }

    final taxableAmount = subtotal - discountTotal;
    final grandTotal = taxableAmount + taxTotal;

    return InvoiceTotals(
      subtotal: subtotal,
      discountTotal: discountTotal,
      taxableAmount: taxableAmount,
      taxTotal: taxTotal,
      grandTotal: grandTotal,
    );
  }

  // Search and filter methods
  List<EnhancedInvoice> searchInvoices(String query) {
    if (query.isEmpty) return _invoices;
    
    final lowercaseQuery = query.toLowerCase();
    return _invoices.where((invoice) {
      return invoice.invoiceNumber.toLowerCase().contains(lowercaseQuery) ||
             invoice.customer.name.toLowerCase().contains(lowercaseQuery) ||
             invoice.customer.email?.toLowerCase().contains(lowercaseQuery) == true ||
             invoice.customer.phone?.contains(query) == true;
    }).toList();
  }

  List<EnhancedInvoice> filterInvoicesByStatus(InvoiceStatus status) {
    return _invoices.where((invoice) => invoice.status == status).toList();
  }

  List<EnhancedInvoice> filterInvoicesByDateRange(DateTime start, DateTime end) {
    return _invoices.where((invoice) {
      return invoice.createdAt.isAfter(start) && invoice.createdAt.isBefore(end);
    }).toList();
  }

  List<Client> searchClients(String query) {
    if (query.isEmpty) return _clients;
    
    final lowercaseQuery = query.toLowerCase();
    return _clients.where((client) {
      return client.name.toLowerCase().contains(lowercaseQuery) ||
             client.email?.toLowerCase().contains(lowercaseQuery) == true ||
             client.phone?.contains(query) == true;
    }).toList();
  }

  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _products;
    
    final lowercaseQuery = query.toLowerCase();
    return _products.where((product) {
      return product.name.toLowerCase().contains(lowercaseQuery) ||
             product.description?.toLowerCase().contains(lowercaseQuery) == true;
    }).toList();
  }

  // Analytics methods
  Future<Map<String, dynamic>> getInvoiceStats() async {
    try {
      return await _databaseService.getInvoiceStats();
    } catch (e) {
      Logger.error('Failed to get invoice stats', 'EnhancedInvoiceProvider', e);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getMonthlyRevenue() async {
    try {
      return await _databaseService.getMonthlyRevenue();
    } catch (e) {
      Logger.error('Failed to get monthly revenue', 'EnhancedInvoiceProvider', e);
      rethrow;
    }
  }

  // Category-specific methods
  List<CategorySpecificField> getCategoryFields(BusinessCategory category) {
    return CategoryFieldDefinitions.getFieldsForCategory(category);
  }

  double getCategoryTaxRate(BusinessCategory category) {
    return category.defaultTaxRate;
  }

  // Utility methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _setError(null);
  }

  // Export methods
  Future<String> exportInvoicesToCSV() async {
    try {
      final csvData = <List<String>>[];
      
      // Add header
      csvData.add([
        'Invoice Number',
        'Date',
        'Client',
        'Status',
        'Subtotal',
        'Tax',
        'Total',
      ]);

      // Add data
      for (var invoice in _invoices) {
        csvData.add([
          invoice.invoiceNumber,
          invoice.createdAt.toIso8601String(),
          invoice.customer.name,
          invoice.status.name,
          invoice.totals.subtotal.toString(),
          invoice.totals.taxTotal.toString(),
          invoice.totals.grandTotal.toString(),
        ]);
      }

      return const CsvConverter().convert(csvData);
    } catch (e) {
      Logger.error('Failed to export invoices to CSV', 'EnhancedInvoiceProvider', e);
      rethrow;
    }
  }

  Future<String> exportCustomersToCSV() async {
    try {
      final csvData = <List<String>>[];
      
      // Add header
      csvData.add([
        'Name',
        'Email',
        'Phone',
        'Address',
      ]);

      // Add data
      for (var customer in _clients) {
        csvData.add([
          customer.name,
          customer.email ?? '',
          customer.phone ?? '',
          customer.address ?? '',
        ]);
      }

      return const CsvConverter().convert(csvData);
    } catch (e) {
      Logger.error('Failed to export customers to CSV', 'EnhancedInvoiceProvider', e);
      rethrow;
    }
  }

  Future<String> exportClientsToCSV() async {
    try {
      final csvData = <List<dynamic>>[
        ['Name', 'Email', 'Phone', 'Address'],
      ];
      
      for (var client in _clients) {
        csvData.add([
          client.name,
          client.email,
          client.phone,
          client.address,
        ]);
      }
      
      return const ListToCsvConverter().convert(csvData);
    } catch (e) {
      Logger.error('Failed to export clients to CSV', 'EnhancedInvoiceProvider', e);
      return '';
    }
  }

  // Backup and restore
  Future<Map<String, dynamic>> exportData() async {
    try {
      return {
        'invoices': _invoices.map((i) => i.toJson()).toList(),
        'customers': _clients.map((c) => c.toJson()).toList(),
        'products': _products.map((p) => {
          'id': p.id,
          'name': p.name,
          'description': p.description,
          'category': p.category.name,
          'unit': p.unit,
          'unitPrice': p.unitPrice,
          'taxRate': p.taxRate,
          'categoryFields': p.categoryFields.map((f) => f.toJson()).toList(),
          'metadata': p.metadata,
        }).toList(),
        'businessSettings': _businessSettings != null ? {
          'id': _businessSettings!.id,
          'businessName': _businessSettings!.businessName,
          'ownerName': _businessSettings!.ownerName,
          'phone': _businessSettings!.phone,
          'email': _businessSettings!.email,
          'address': _businessSettings!.address,
          'gstNumber': _businessSettings!.gstNumber,
          'panNumber': _businessSettings!.panNumber,
          'businessCategory': _businessSettings!.businessCategory.name,
          'logoPath': _businessSettings!.logoPath,
          'taxRate': _businessSettings!.taxRate,
          'currency': _businessSettings!.currency,
          'invoicePrefix': _businessSettings!.invoicePrefix,
          'terms': _businessSettings!.terms,
        } : null,
        'exportDate': DateTime.now().toIso8601String(),
        'version': '1.0.0',
      };
    } catch (e) {
      Logger.error('Failed to export data', 'EnhancedInvoiceProvider', e);
      rethrow;
    }
  }

  Future<void> importData(Map<String, dynamic> data) async {
    try {
      _setLoading(true);
      
      // Clear existing data
      _invoices.clear();
      _clients.clear();
      _products.clear();
      
      // Import products
      if (data['products'] != null) {
        for (var productData in data['products']) {
          final product = Product(
            id: productData['id'],
            name: productData['name'],
            description: productData['description'],
            category: BusinessCategory.values.firstWhere((e) => e.name == productData['category']),
            unit: productData['unit'],
            unitPrice: productData['unitPrice'],
            taxRate: productData['taxRate'],
            categoryFields: (productData['categoryFields'] as List)
                .map((f) => CategorySpecificField.fromJson(f))
                .toList(),
            metadata: productData['metadata'],
          );
          await _databaseService.insertProduct(product);
          _products.add(product);
        }
      }
      
      // Import invoices
      if (data['invoices'] != null) {
        for (var invoiceData in data['invoices']) {
          final invoice = EnhancedInvoice.fromJson(invoiceData);
          await _databaseService.insertInvoice(invoice);
          _invoices.add(invoice);
        }
      }
      
      // Import business settings
      if (data['businessSettings'] != null) {
        final settingsData = data['businessSettings'];
        final settings = BusinessSettings(
          id: settingsData['id'],
          businessName: settingsData['businessName'],
          ownerName: settingsData['ownerName'],
          phone: settingsData['phone'],
          email: settingsData['email'],
          address: settingsData['address'],
          gstNumber: settingsData['gstNumber'],
          panNumber: settingsData['panNumber'],
          businessCategory: BusinessCategory.values.firstWhere((e) => e.name == settingsData['businessCategory']),
          logoPath: settingsData['logoPath'],
          taxRate: settingsData['taxRate'],
          currency: settingsData['currency'],
          invoicePrefix: settingsData['invoicePrefix'],
          terms: settingsData['terms'],
        );
        await _databaseService.saveBusinessSettings(settings);
        _businessSettings = settings;
      }
      
      // Import clients
      if (data['clients'] != null) {
        for (var clientData in data['clients']) {
          final client = Client.fromJson(clientData);
          await _databaseService.insertClient(client);
          _clients.add(client);
        }
      }
      
      // Import customers (legacy support)
      if (data['customers'] != null) {
        for (var customerData in data['customers']) {
          final customer = Customer.fromJson(customerData);
          await _databaseService.insertCustomer(customer);
          // Convert Customer to Client for internal use
          final client = Client(
            id: customer.id,
            name: customer.name,
            email: customer.email ?? '',
            phone: customer.phone ?? '',
            address: customer.address ?? '',
          );
          _clients.add(client);
        }
      }
      
      notifyListeners();
    } catch (e) {
      Logger.error('Failed to import data', 'EnhancedInvoiceProvider', e);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<EnhancedInvoice?> getLastInvoice() async {
    if (_invoices.isEmpty) return null;
    return _invoices.last;
  }
}

// Simple CSV converter
class CsvConverter {
  const CsvConverter();

  String convert(List<List<String>> data) {
    return data.map((row) {
      return row.map((cell) {
        // Escape quotes and wrap in quotes if contains comma or quote
        final escaped = cell.replaceAll('"', '""');
        if (escaped.contains(',') || escaped.contains('"') || escaped.contains('\n')) {
          return '"$escaped"';
        }
        return escaped;
      }).join(',');
    }).join('\n');
  }
} 