import 'dart:async';
import 'package:flutter/material.dart';
import '../models/grocery_product.dart';
import '../models/customer_loyalty.dart';
import '../utils/logger.dart';

class InventoryService {
  static final InventoryService _instance = InventoryService._internal();
  factory InventoryService() => _instance;
  InventoryService._internal();

  // Stream controllers for real-time updates
  final StreamController<List<GroceryProduct>> _stockAlertsController = 
      StreamController<List<GroceryProduct>>.broadcast();
  final StreamController<List<GroceryProduct>> _expiryAlertsController = 
      StreamController<List<GroceryProduct>>.broadcast();
  final StreamController<Map<GroceryCategory, int>> _categoryStockController = 
      StreamController<Map<GroceryCategory, int>>.broadcast();

  // Mock database for demonstration
  final Map<String, GroceryProduct> _products = {};
  final Map<String, List<InventoryTransaction>> _transactions = {};

  // Alert thresholds
  static const int _lowStockThreshold = 10;
  static const int _expiryWarningDays = 7;
  static const int _overstockThreshold = 200;

  // Initialize with sample data
  Future<void> initialize() async {
    try {
      await _loadSampleData();
      _startPeriodicChecks();
      Logger.info('Inventory service initialized', 'InventoryService');
    } catch (e) {
      Logger.error('Failed to initialize inventory service', 'InventoryService', e);
      rethrow;
    }
  }

  // Load sample inventory data
  Future<void> _loadSampleData() async {
    final sampleProducts = [
      GroceryProduct(
        id: '1',
        name: 'Amul Milk',
        barcode: '8901234567890',
        category: GroceryCategory.dairyEggs,
        subcategory: 'Milk',
        brand: 'Amul',
        description: 'Fresh full cream milk',
        unitPrice: 60.0,
        costPrice: 45.0,
        unitType: UnitType.liters,
        currentStock: 5.0, // Low stock
        reorderPoint: 10.0,
        maxStock: 100.0,
        expiryDate: DateTime.now().add(const Duration(days: 3)), // Expiring soon
        batchNumber: 'BATCH001',
        supplierName: 'Amul Dairy',
        supplierContact: '+91-1234567890',
        isPerishable: true,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      GroceryProduct(
        id: '2',
        name: 'Nestle Maggi',
        barcode: '4001234567890',
        category: GroceryCategory.pantryStaples,
        subcategory: 'Instant Noodles',
        brand: 'Nestle',
        description: '2-minute instant noodles',
        unitPrice: 14.0,
        costPrice: 10.0,
        unitType: UnitType.packs,
        currentStock: 250.0, // Overstocked
        reorderPoint: 50.0,
        maxStock: 200.0,
        expiryDate: DateTime.now().add(const Duration(days: 365)),
        batchNumber: 'BATCH002',
        supplierName: 'Nestle India',
        supplierContact: '+91-9876543210',
        isPerishable: false,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      GroceryProduct(
        id: '3',
        name: 'Cadbury Dairy Milk',
        barcode: '5001234567890',
        category: GroceryCategory.snacksConfectionery,
        subcategory: 'Chocolate',
        brand: 'Cadbury',
        description: 'Milk chocolate bar',
        unitPrice: 55.0,
        costPrice: 40.0,
        unitType: UnitType.pieces,
        currentStock: 0.0, // Out of stock
        reorderPoint: 20.0,
        maxStock: 200.0,
        expiryDate: DateTime.now().add(const Duration(days: 180)),
        batchNumber: 'BATCH003',
        supplierName: 'Mondelez India',
        supplierContact: '+91-1122334455',
        isPerishable: false,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      GroceryProduct(
        id: '4',
        name: 'Fresh Tomatoes',
        barcode: '1234567890123',
        category: GroceryCategory.freshProduce,
        subcategory: 'Vegetables',
        brand: null,
        description: 'Fresh red tomatoes',
        unitPrice: 40.0,
        costPrice: 25.0,
        unitType: UnitType.kg,
        currentStock: 15.0,
        reorderPoint: 5.0,
        maxStock: 50.0,
        expiryDate: DateTime.now().add(const Duration(days: 5)), // Expiring soon
        batchNumber: 'BATCH004',
        supplierName: 'Local Farmer',
        supplierContact: '+91-5555555555',
        isPerishable: true,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      GroceryProduct(
        id: '5',
        name: 'Britannia Bread',
        barcode: '9876543210987',
        category: GroceryCategory.bakeryBread,
        subcategory: 'Bread',
        brand: 'Britannia',
        description: 'Fresh white bread',
        unitPrice: 35.0,
        costPrice: 25.0,
        unitType: UnitType.pieces,
        currentStock: 25.0,
        reorderPoint: 10.0,
        maxStock: 100.0,
        expiryDate: DateTime.now().add(const Duration(days: 2)), // Expiring soon
        batchNumber: 'BATCH005',
        supplierName: 'Britannia Industries',
        supplierContact: '+91-4444444444',
        isPerishable: true,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    for (final product in sampleProducts) {
      _products[product.id] = product;
      _transactions[product.id] = [];
    }
  }

  // Start periodic checks for alerts
  void _startPeriodicChecks() {
    Timer.periodic(const Duration(minutes: 30), (timer) {
      _checkStockAlerts();
      _checkExpiryAlerts();
      _updateCategoryStock();
    });
  }

  // Get all products
  Future<List<GroceryProduct>> getAllProducts() async {
    return _products.values.toList();
  }

  // Get product by ID
  Future<GroceryProduct?> getProductById(String id) async {
    return _products[id];
  }

  // Get product by barcode
  Future<GroceryProduct?> getProductByBarcode(String barcode) async {
    try {
      return _products.values.firstWhere(
        (product) => product.barcode == barcode,
        orElse: () => throw Exception('Product not found'),
      );
    } catch (e) {
      return null;
    }
  }

  // Add new product
  Future<void> addProduct(GroceryProduct product) async {
    try {
      _products[product.id] = product;
      _transactions[product.id] = [];
      _checkStockAlerts();
      Logger.info('Product added: ${product.name}', 'InventoryService');
    } catch (e) {
      Logger.error('Failed to add product', 'InventoryService', e);
      rethrow;
    }
  }

  // Update product
  Future<void> updateProduct(GroceryProduct product) async {
    try {
      _products[product.id] = product;
      _checkStockAlerts();
      _checkExpiryAlerts();
      Logger.info('Product updated: ${product.name}', 'InventoryService');
    } catch (e) {
      Logger.error('Failed to update product', 'InventoryService', e);
      rethrow;
    }
  }

  // Delete product
  Future<void> deleteProduct(String id) async {
    try {
      _products.remove(id);
      _transactions.remove(id);
      _checkStockAlerts();
      Logger.info('Product deleted: $id', 'InventoryService');
    } catch (e) {
      Logger.error('Failed to delete product', 'InventoryService', e);
      rethrow;
    }
  }

  // Update stock levels
  Future<void> updateStock(String productId, double quantity, InventoryTransactionType type, {String? invoiceId, String? notes}) async {
    try {
      final product = _products[productId];
      if (product == null) throw Exception('Product not found');

      double newStock = product.currentStock;
      switch (type) {
        case InventoryTransactionType.sale:
          newStock -= quantity;
          break;
        case InventoryTransactionType.purchase:
          newStock += quantity;
          break;
        case InventoryTransactionType.adjustment:
          newStock = quantity;
          break;
        case InventoryTransactionType.return:
          newStock += quantity;
          break;
        case InventoryTransactionType.damage:
          newStock -= quantity;
          break;
      }

      if (newStock < 0) {
        throw Exception('Insufficient stock');
      }

      final updatedProduct = product.copyWith(
        currentStock: newStock,
        updatedAt: DateTime.now(),
      );

      _products[productId] = updatedProduct;

      // Record transaction
      final transaction = InventoryTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: productId,
        type: type,
        quantity: quantity,
        previousStock: product.currentStock,
        newStock: newStock,
        invoiceId: invoiceId,
        notes: notes,
        createdAt: DateTime.now(),
      );

      _transactions[productId]?.add(transaction);

      _checkStockAlerts();
      Logger.info('Stock updated for ${product.name}: $quantity', 'InventoryService');
    } catch (e) {
      Logger.error('Failed to update stock', 'InventoryService', e);
      rethrow;
    }
  }

  // Check stock availability
  Future<bool> checkStockAvailability(String productId, double quantity) async {
    final product = _products[productId];
    if (product == null) return false;
    return product.currentStock >= quantity;
  }

  // Get low stock products
  Future<List<GroceryProduct>> getLowStockProducts() async {
    return _products.values.where((product) => product.isLowStock).toList();
  }

  // Get out of stock products
  Future<List<GroceryProduct>> getOutOfStockProducts() async {
    return _products.values.where((product) => product.isOutOfStock).toList();
  }

  // Get expiring products
  Future<List<GroceryProduct>> getExpiringProducts({int days = 7}) async {
    final cutoffDate = DateTime.now().add(Duration(days: days));
    return _products.values.where((product) {
      if (product.expiryDate == null) return false;
      return product.expiryDate!.isBefore(cutoffDate) && !product.isExpired;
    }).toList();
  }

  // Get expired products
  Future<List<GroceryProduct>> getExpiredProducts() async {
    return _products.values.where((product) => product.isExpired).toList();
  }

  // Get overstocked products
  Future<List<GroceryProduct>> getOverstockedProducts() async {
    return _products.values.where((product) => product.isOverstocked).toList();
  }

  // Get products by category
  Future<List<GroceryProduct>> getProductsByCategory(GroceryCategory category) async {
    return _products.values.where((product) => product.category == category).toList();
  }

  // Get products by supplier
  Future<List<GroceryProduct>> getProductsBySupplier(String supplierName) async {
    return _products.values.where((product) => product.supplierName == supplierName).toList();
  }

  // Search products
  Future<List<GroceryProduct>> searchProducts(String query) async {
    final lowercaseQuery = query.toLowerCase();
    return _products.values.where((product) {
      return product.name.toLowerCase().contains(lowercaseQuery) ||
             product.brand?.toLowerCase().contains(lowercaseQuery) == true ||
             product.description?.toLowerCase().contains(lowercaseQuery) == true ||
             product.barcode?.contains(lowercaseQuery) == true;
    }).toList();
  }

  // Get inventory transactions
  Future<List<InventoryTransaction>> getProductTransactions(String productId) async {
    return _transactions[productId] ?? [];
  }

  // Get inventory value
  Future<double> getInventoryValue() async {
    double totalValue = 0;
    for (final product in _products.values) {
      totalValue += product.currentStock * product.costPrice;
    }
    return totalValue;
  }

  // Get inventory value by category
  Future<Map<GroceryCategory, double>> getInventoryValueByCategory() async {
    final Map<GroceryCategory, double> categoryValues = {};
    
    for (final category in GroceryCategory.values) {
      final products = await getProductsByCategory(category);
      double categoryValue = 0;
      for (final product in products) {
        categoryValue += product.currentStock * product.costPrice;
      }
      categoryValues[category] = categoryValue;
    }
    
    return categoryValues;
  }

  // Check stock alerts
  void _checkStockAlerts() {
    final alertProducts = <GroceryProduct>[];
    
    for (final product in _products.values) {
      if (product.stockAlertType != null) {
        alertProducts.add(product);
      }
    }
    
    _stockAlertsController.add(alertProducts);
  }

  // Check expiry alerts
  void _checkExpiryAlerts() {
    final expiringProducts = getExpiringProducts().then((products) {
      _expiryAlertsController.add(products);
    });
  }

  // Update category stock counts
  void _updateCategoryStock() {
    final categoryCounts = <GroceryCategory, int>{};
    
    for (final category in GroceryCategory.values) {
      final products = _products.values.where((p) => p.category == category);
      categoryCounts[category] = products.length;
    }
    
    _categoryStockController.add(categoryCounts);
  }

  // Streams for real-time updates
  Stream<List<GroceryProduct>> get stockAlertsStream => _stockAlertsController.stream;
  Stream<List<GroceryProduct>> get expiryAlertsStream => _expiryAlertsController.stream;
  Stream<Map<GroceryCategory, int>> get categoryStockStream => _categoryStockController.stream;

  // Generate inventory reports
  Future<InventoryReport> generateInventoryReport() async {
    final totalProducts = _products.length;
    final lowStockCount = (await getLowStockProducts()).length;
    final outOfStockCount = (await getOutOfStockProducts()).length;
    final expiringCount = (await getExpiringProducts()).length;
    final expiredCount = (await getExpiredProducts()).length;
    final overstockedCount = (await getOverstockedProducts()).length;
    final totalValue = await getInventoryValue();
    final categoryValues = await getInventoryValueByCategory();

    return InventoryReport(
      totalProducts: totalProducts,
      lowStockCount: lowStockCount,
      outOfStockCount: outOfStockCount,
      expiringCount: expiringCount,
      expiredCount: expiredCount,
      overstockedCount: overstockedCount,
      totalValue: totalValue,
      categoryValues: categoryValues,
      generatedAt: DateTime.now(),
    );
  }

  // Dispose resources
  void dispose() {
    _stockAlertsController.close();
    _expiryAlertsController.close();
    _categoryStockController.close();
  }
}

// Inventory transaction types
enum InventoryTransactionType {
  sale,
  purchase,
  adjustment,
  return,
  damage,
}

// Inventory transaction model
class InventoryTransaction {
  final String id;
  final String productId;
  final InventoryTransactionType type;
  final double quantity;
  final double previousStock;
  final double newStock;
  final String? invoiceId;
  final String? notes;
  final DateTime createdAt;

  const InventoryTransaction({
    required this.id,
    required this.productId,
    required this.type,
    required this.quantity,
    required this.previousStock,
    required this.newStock,
    this.invoiceId,
    this.notes,
    required this.createdAt,
  });
}

// Inventory report model
class InventoryReport {
  final int totalProducts;
  final int lowStockCount;
  final int outOfStockCount;
  final int expiringCount;
  final int expiredCount;
  final int overstockedCount;
  final double totalValue;
  final Map<GroceryCategory, double> categoryValues;
  final DateTime generatedAt;

  const InventoryReport({
    required this.totalProducts,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.expiringCount,
    required this.expiredCount,
    required this.overstockedCount,
    required this.totalValue,
    required this.categoryValues,
    required this.generatedAt,
  });

  double get alertPercentage {
    if (totalProducts == 0) return 0;
    return ((lowStockCount + outOfStockCount + expiringCount + expiredCount) / totalProducts) * 100;
  }

  bool get hasAlerts => alertPercentage > 0;
}

// Extension for transaction type
extension InventoryTransactionTypeExtension on InventoryTransactionType {
  String get displayName {
    switch (this) {
      case InventoryTransactionType.sale:
        return 'Sale';
      case InventoryTransactionType.purchase:
        return 'Purchase';
      case InventoryTransactionType.adjustment:
        return 'Adjustment';
      case InventoryTransactionType.return:
        return 'Return';
      case InventoryTransactionType.damage:
        return 'Damage';
    }
  }

  Color get color {
    switch (this) {
      case InventoryTransactionType.sale:
        return Colors.red;
      case InventoryTransactionType.purchase:
        return Colors.green;
      case InventoryTransactionType.adjustment:
        return Colors.blue;
      case InventoryTransactionType.return:
        return Colors.orange;
      case InventoryTransactionType.damage:
        return Colors.red;
    }
  }

  IconData get icon {
    switch (this) {
      case InventoryTransactionType.sale:
        return Icons.remove_shopping_cart;
      case InventoryTransactionType.purchase:
        return Icons.add_shopping_cart;
      case InventoryTransactionType.adjustment:
        return Icons.edit;
      case InventoryTransactionType.return:
        return Icons.undo;
      case InventoryTransactionType.damage:
        return Icons.block;
    }
  }
}