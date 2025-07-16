import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/enhanced_invoice.dart';
import '../models/business_category.dart';
import '../utils/logger.dart';
import 'dart:convert';
import '../models/client.dart';

class DatabaseService {
  static Database? _database;
  static const String _databaseName = 'invoice_app.db';
  static const int _databaseVersion = 1;

  // Table names
  static const String tableInvoices = 'invoices';
  static const String tableCustomers = 'customers';
  static const String tableProducts = 'products';
  static const String tableInvoiceItems = 'invoice_items';
  static const String tableCategoryFields = 'category_fields';
  static const String tableBusinessSettings = 'business_settings';
  static const String tableClients = 'clients';

  // Singleton pattern
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create invoices table
    await db.execute('''
      CREATE TABLE $tableInvoices (
        id TEXT PRIMARY KEY,
        invoiceNumber TEXT NOT NULL,
        businessCategory TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        dueDate TEXT NOT NULL,
        status TEXT NOT NULL,
        clientId TEXT NOT NULL,
        subtotal REAL NOT NULL,
        discountTotal REAL NOT NULL,
        taxableAmount REAL NOT NULL,
        taxTotal REAL NOT NULL,
        grandTotal REAL NOT NULL,
        currency TEXT NOT NULL,
        paymentMethod TEXT NOT NULL,
        paymentStatus TEXT NOT NULL,
        paidDate TEXT,
        transactionId TEXT,
        notes TEXT,
        terms TEXT,
        metadata TEXT,
        FOREIGN KEY (clientId) REFERENCES $tableClients (id)
      )
    ''');

    // Create customers table
    await db.execute('''
      CREATE TABLE $tableCustomers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT,
        phone TEXT,
        address TEXT,
        gstNumber TEXT,
        type TEXT NOT NULL,
        categorySpecificData TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Create products table
    await db.execute('''
      CREATE TABLE $tableProducts (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        category TEXT NOT NULL,
        unit TEXT NOT NULL,
        unitPrice REAL NOT NULL,
        taxRate REAL NOT NULL,
        categoryFields TEXT,
        metadata TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Create invoice items table
    await db.execute('''
      CREATE TABLE $tableInvoiceItems (
        id TEXT PRIMARY KEY,
        invoiceId TEXT NOT NULL,
        productId TEXT,
        name TEXT NOT NULL,
        description TEXT,
        quantity REAL NOT NULL,
        unit TEXT NOT NULL,
        unitPrice REAL NOT NULL,
        discount REAL NOT NULL,
        taxRate REAL NOT NULL,
        categoryFields TEXT,
        metadata TEXT,
        FOREIGN KEY (invoiceId) REFERENCES $tableInvoices (id),
        FOREIGN KEY (productId) REFERENCES $tableProducts (id)
      )
    ''');

    // Create category fields table
    await db.execute('''
      CREATE TABLE $tableCategoryFields (
        id TEXT PRIMARY KEY,
        invoiceId TEXT,
        itemId TEXT,
        fieldName TEXT NOT NULL,
        fieldType TEXT NOT NULL,
        label TEXT NOT NULL,
        value TEXT,
        required INTEGER NOT NULL,
        options TEXT,
        validationRule TEXT,
        FOREIGN KEY (invoiceId) REFERENCES $tableInvoices (id),
        FOREIGN KEY (itemId) REFERENCES $tableInvoiceItems (id)
      )
    ''');

    // Create business settings table
    await db.execute('''
      CREATE TABLE $tableBusinessSettings (
        id TEXT PRIMARY KEY,
        businessName TEXT NOT NULL,
        ownerName TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        address TEXT,
        gstNumber TEXT,
        panNumber TEXT,
        businessCategory TEXT NOT NULL,
        logoPath TEXT,
        taxRate REAL NOT NULL,
        currency TEXT NOT NULL,
        invoicePrefix TEXT,
        terms TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Create clients table
    await db.execute('''
      CREATE TABLE $tableClients (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT,
        phone TEXT,
        address TEXT,
        gstNumber TEXT,
        type TEXT NOT NULL,
        categorySpecificData TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_invoices_client ON $tableInvoices(clientId)');
    await db.execute('CREATE INDEX idx_invoices_status ON $tableInvoices(status)');
    await db.execute('CREATE INDEX idx_invoices_date ON $tableInvoices(createdAt)');
    await db.execute('CREATE INDEX idx_clients_name ON $tableClients(name)');
    await db.execute('CREATE INDEX idx_products_category ON $tableProducts(category)');
    await db.execute('CREATE INDEX idx_invoice_items_invoice ON $tableInvoiceItems(invoiceId)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
    if (oldVersion < newVersion) {
      // Add migration logic here
    }
  }

  // Invoice operations
  Future<void> insertInvoice(EnhancedInvoice invoice) async {
    final db = await database;
    await db.transaction((txn) async {
      // Insert invoice
      await txn.insert(tableInvoices, {
        'id': invoice.id,
        'invoiceNumber': invoice.invoiceNumber,
        'businessCategory': invoice.businessCategory.name,
        'createdAt': invoice.createdAt.toIso8601String(),
        'dueDate': invoice.dueDate.toIso8601String(),
        'status': invoice.status.name,
        'clientId': invoice.customer.id,
        'subtotal': invoice.totals.subtotal,
        'discountTotal': invoice.totals.discountTotal,
        'taxableAmount': invoice.totals.taxableAmount,
        'taxTotal': invoice.totals.taxTotal,
        'grandTotal': invoice.totals.grandTotal,
        'currency': invoice.totals.currency,
        'notes': invoice.notes,
        'terms': invoice.terms,
        'metadata': invoice.metadata != null ? jsonEncode(invoice.metadata) : null,
      });

      // Insert invoice items
      for (var item in invoice.items) {
        await txn.insert(tableInvoiceItems, {
          'id': item.id,
          'invoiceId': invoice.id,
          'productId': null, // TODO: Link to product if exists
          'name': item.name,
          'description': item.description,
          'quantity': item.quantity,
          'unit': item.unit,
          'unitPrice': item.unitPrice,
          'discount': item.discount,
          'taxRate': item.taxRate,
          'categoryFields': jsonEncode(item.categoryFields.map((f) => f.toJson()).toList()),
          'metadata': item.metadata != null ? jsonEncode(item.metadata) : null,
        });
      }

      // Insert category fields
      for (var field in invoice.categoryFields) {
        await txn.insert(tableCategoryFields, {
          'id': '${invoice.id}_${field.fieldName}',
          'invoiceId': invoice.id,
          'itemId': null,
          'fieldName': field.fieldName,
          'fieldType': field.fieldType,
          'label': field.label,
          'value': field.value?.toString(),
          'required': field.required ? 1 : 0,
          'options': field.options != null ? jsonEncode(field.options) : null,
          'validationRule': field.validationRule,
        });
      }
    });
  }

  Future<List<EnhancedInvoice>> getAllInvoices() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableInvoices,
      orderBy: 'createdAt DESC',
    );

    return Future.wait(maps.map((map) => _mapToInvoice(map)).toList());
  }

  Future<EnhancedInvoice?> getInvoiceById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableInvoices,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return await _mapToInvoice(maps.first);
  }

  Future<void> updateInvoice(EnhancedInvoice invoice) async {
    final db = await database;
    await db.transaction((txn) async {
      // Update invoice
      await txn.update(
        tableInvoices,
        {
          'invoiceNumber': invoice.invoiceNumber,
          'businessCategory': invoice.businessCategory.name,
          'dueDate': invoice.dueDate.toIso8601String(),
          'status': invoice.status.name,
          'clientId': invoice.customer.id,
          'subtotal': invoice.totals.subtotal,
          'discountTotal': invoice.totals.discountTotal,
          'taxableAmount': invoice.totals.taxableAmount,
          'taxTotal': invoice.totals.taxTotal,
          'grandTotal': invoice.totals.grandTotal,
          'currency': invoice.totals.currency,
          'notes': invoice.notes,
          'terms': invoice.terms,
          'metadata': invoice.metadata != null ? jsonEncode(invoice.metadata) : null,
        },
        where: 'id = ?',
        whereArgs: [invoice.id],
      );

      // Delete existing items and fields
      await txn.delete(tableInvoiceItems, where: 'invoiceId = ?', whereArgs: [invoice.id]);
      await txn.delete(tableCategoryFields, where: 'invoiceId = ?', whereArgs: [invoice.id]);

      // Insert new items and fields
      for (var item in invoice.items) {
        await txn.insert(tableInvoiceItems, {
          'id': item.id,
          'invoiceId': invoice.id,
          'productId': null,
          'name': item.name,
          'description': item.description,
          'quantity': item.quantity,
          'unit': item.unit,
          'unitPrice': item.unitPrice,
          'discount': item.discount,
          'taxRate': item.taxRate,
          'categoryFields': jsonEncode(item.categoryFields.map((f) => f.toJson()).toList()),
          'metadata': item.metadata != null ? jsonEncode(item.metadata) : null,
        });
      }

      for (var field in invoice.categoryFields) {
        await txn.insert(tableCategoryFields, {
          'id': '${invoice.id}_${field.fieldName}',
          'invoiceId': invoice.id,
          'itemId': null,
          'fieldName': field.fieldName,
          'fieldType': field.fieldType,
          'label': field.label,
          'value': field.value?.toString(),
          'required': field.required ? 1 : 0,
          'options': field.options != null ? jsonEncode(field.options) : null,
          'validationRule': field.validationRule,
        });
      }
    });
  }

  Future<void> deleteInvoice(String id) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(tableInvoiceItems, where: 'invoiceId = ?', whereArgs: [id]);
      await txn.delete(tableCategoryFields, where: 'invoiceId = ?', whereArgs: [id]);
      await txn.delete(tableInvoices, where: 'id = ?', whereArgs: [id]);
    });
  }

  // Customer operations
  Future<void> insertCustomer(Customer customer) async {
    final db = await database;
    await db.insert(tableCustomers, {
      'id': customer.id,
      'name': customer.name,
      'email': customer.email,
      'phone': customer.phone,
      'address': customer.address,
      'gstNumber': customer.gstNumber,
      'type': customer.type.name,
      'categorySpecificData': customer.categorySpecificData != null 
          ? jsonEncode(customer.categorySpecificData) 
          : null,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Customer>> getAllCustomers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableCustomers,
      orderBy: 'name ASC',
    );

    return maps.map((map) => Customer(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      address: map['address'],
      gstNumber: map['gstNumber'],
      type: CustomerType.values.firstWhere((e) => e.name == map['type']),
      categorySpecificData: map['categorySpecificData'] != null 
          ? jsonDecode(map['categorySpecificData']) 
          : null,
    )).toList();
  }

  Future<Customer?> getCustomerById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableCustomers,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;

    final map = maps.first;
    return Customer(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      address: map['address'],
      gstNumber: map['gstNumber'],
      type: CustomerType.values.firstWhere((e) => e.name == map['type']),
      categorySpecificData: map['categorySpecificData'] != null 
          ? jsonDecode(map['categorySpecificData']) 
          : null,
    );
  }

  Future<void> updateCustomer(Customer customer) async {
    final db = await database;
    await db.update(
      tableCustomers,
      {
        'name': customer.name,
        'email': customer.email,
        'phone': customer.phone,
        'address': customer.address,
        'gstNumber': customer.gstNumber,
        'type': customer.type.name,
        'categorySpecificData': customer.categorySpecificData != null 
            ? jsonEncode(customer.categorySpecificData) 
            : null,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  Future<void> deleteCustomer(String id) async {
    final db = await database;
    await db.delete(tableCustomers, where: 'id = ?', whereArgs: [id]);
  }

  // Product operations
  Future<void> insertProduct(Product product) async {
    final db = await database;
    await db.insert(tableProducts, {
      'id': product.id,
      'name': product.name,
      'description': product.description,
      'category': product.category.name,
      'unit': product.unit,
      'unitPrice': product.unitPrice,
      'taxRate': product.taxRate,
      'categoryFields': jsonEncode(product.categoryFields.map((f) => f.toJson()).toList()),
      'metadata': product.metadata != null ? jsonEncode(product.metadata) : null,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableProducts,
      orderBy: 'name ASC',
    );

    return maps.map((map) => Product(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      category: BusinessCategory.values.firstWhere((e) => e.name == map['category']),
      unit: map['unit'],
      unitPrice: map['unitPrice'],
      taxRate: map['taxRate'],
      categoryFields: (jsonDecode(map['categoryFields']) as List)
          .map((f) => CategorySpecificField.fromJson(f))
          .toList(),
      metadata: map['metadata'] != null ? jsonDecode(map['metadata']) : null,
    )).toList();
  }

  Future<List<Product>> getProductsByCategory(BusinessCategory category) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableProducts,
      where: 'category = ?',
      whereArgs: [category.name],
      orderBy: 'name ASC',
    );

    return maps.map((map) => Product(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      category: BusinessCategory.values.firstWhere((e) => e.name == map['category']),
      unit: map['unit'],
      unitPrice: map['unitPrice'],
      taxRate: map['taxRate'],
      categoryFields: (jsonDecode(map['categoryFields']) as List)
          .map((f) => CategorySpecificField.fromJson(f))
          .toList(),
      metadata: map['metadata'] != null ? jsonDecode(map['metadata']) : null,
    )).toList();
  }

  // Business settings operations
  Future<void> saveBusinessSettings(BusinessSettings settings) async {
    final db = await database;
    await db.insert(
      tableBusinessSettings,
      {
        'id': settings.id,
        'businessName': settings.businessName,
        'ownerName': settings.ownerName,
        'phone': settings.phone,
        'email': settings.email,
        'address': settings.address,
        'gstNumber': settings.gstNumber,
        'panNumber': settings.panNumber,
        'businessCategory': settings.businessCategory.name,
        'logoPath': settings.logoPath,
        'taxRate': settings.taxRate,
        'currency': settings.currency,
        'invoicePrefix': settings.invoicePrefix,
        'terms': settings.terms,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<BusinessSettings?> getBusinessSettings() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableBusinessSettings);

    if (maps.isEmpty) return null;

    final map = maps.first;
    return BusinessSettings(
      id: map['id'],
      businessName: map['businessName'],
      ownerName: map['ownerName'],
      phone: map['phone'],
      email: map['email'],
      address: map['address'],
      gstNumber: map['gstNumber'],
      panNumber: map['panNumber'],
      businessCategory: BusinessCategory.values.firstWhere((e) => e.name == map['businessCategory']),
      logoPath: map['logoPath'],
      taxRate: map['taxRate'],
      currency: map['currency'],
      invoicePrefix: map['invoicePrefix'],
      terms: map['terms'],
    );
  }

  // Helper methods
  Future<EnhancedInvoice> _mapToInvoice(Map<String, dynamic> map) async {
    final client = await getClientById(map['clientId']);
    if (client == null) {
      throw Exception('Client not found: ${map['clientId']}');
    }

    final items = await _getInvoiceItems(map['id']);
    final categoryFields = await _getCategoryFields(map['id']);

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
      id: map['id'],
      invoiceNumber: map['invoiceNumber'],
      businessCategory: BusinessCategory.values.firstWhere(
        (e) => e.name == map['businessCategory'],
      ),
      createdAt: DateTime.parse(map['createdAt']),
      dueDate: DateTime.parse(map['dueDate']),
      status: InvoiceStatus.values.firstWhere((e) => e.name == map['status']),
      customer: customer,
      items: items,
      categoryFields: categoryFields,
      totals: InvoiceTotals(
        subtotal: map['subtotal'],
        discountTotal: map['discountTotal'],
        taxableAmount: map['taxableAmount'],
        taxTotal: map['taxTotal'],
        grandTotal: map['grandTotal'],
      ),
      notes: map['notes'],
      terms: map['terms'],
    );
  }

  Future<List<InvoiceItem>> _getInvoiceItems(String invoiceId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableInvoiceItems,
      where: 'invoiceId = ?',
      whereArgs: [invoiceId],
    );

    return maps.map((map) => InvoiceItem(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      quantity: map['quantity'],
      unit: map['unit'],
      unitPrice: map['unitPrice'],
      discount: map['discount'],
      taxRate: map['taxRate'],
      categoryFields: map['categoryFields'] != null 
          ? (jsonDecode(map['categoryFields']) as List)
              .map((f) => CategorySpecificField.fromJson(f))
              .toList()
          : [],
      metadata: map['metadata'] != null ? jsonDecode(map['metadata']) : null,
    )).toList();
  }

  Future<List<CategorySpecificField>> _getCategoryFields(String invoiceId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableCategoryFields,
      where: 'invoiceId = ? AND itemId IS NULL',
      whereArgs: [invoiceId],
    );

    return maps.map((map) => CategorySpecificField(
      fieldName: map['fieldName'],
      fieldType: map['fieldType'],
      label: map['label'],
      value: map['value'],
      required: map['required'] == 1,
      options: map['options'] != null ? List<String>.from(jsonDecode(map['options'])) : null,
      validationRule: map['validationRule'],
    )).toList();
  }

  Future<Client?> getClientById(String id) async {
    final db = await database;
    final result = await db.query(
      tableClients,
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (result.isEmpty) return null;
    
    return Client.fromJson(result.first);
  }

  Future<void> insertClient(Client client) async {
    final db = await database;
    await db.insert(tableClients, client.toJson());
  }

  Future<void> updateClient(Client client) async {
    final db = await database;
    await db.update(
      tableClients,
      client.toJson(),
      where: 'id = ?',
      whereArgs: [client.id],
    );
  }

  Future<void> deleteClient(String id) async {
    final db = await database;
    await db.delete(
      tableClients,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Client>> getAllClients() async {
    final db = await database;
    final result = await db.query(tableClients);
    return result.map((map) => Client.fromJson(map)).toList();
  }

  // Analytics and reporting
  Future<Map<String, dynamic>> getInvoiceStats() async {
    final db = await database;
    
    final totalInvoicesResult = await db.rawQuery('SELECT COUNT(*) FROM $tableInvoices');
    final totalInvoices = (totalInvoicesResult.isNotEmpty ? totalInvoicesResult.first['COUNT(*)'] as int? : null) ?? 0;
    
    final revenueResult = await db.rawQuery('SELECT SUM(grandTotal) FROM $tableInvoices WHERE status = "paid"');
    final totalRevenue = (revenueResult.isNotEmpty ? revenueResult.first['SUM(grandTotal)'] as double? : null) ?? 0.0;
    
    final pendingResult = await db.rawQuery('SELECT COUNT(*) FROM $tableInvoices WHERE status = "sent"');
    final pendingInvoices = (pendingResult.isNotEmpty ? pendingResult.first['COUNT(*)'] as int? : null) ?? 0;
    
    final overdueResult = await db.rawQuery('SELECT COUNT(*) FROM $tableInvoices WHERE status = "overdue"');
    final overdueInvoices = (overdueResult.isNotEmpty ? overdueResult.first['COUNT(*)'] as int? : null) ?? 0;

    return {
      'totalInvoices': totalInvoices,
      'totalRevenue': totalRevenue,
      'pendingInvoices': pendingInvoices,
      'overdueInvoices': overdueInvoices,
    };
  }

  Future<List<Map<String, dynamic>>> getMonthlyRevenue() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        strftime('%Y-%m', createdAt) as month,
        SUM(grandTotal) as revenue,
        COUNT(*) as invoiceCount
      FROM $tableInvoices 
      WHERE status = 'paid'
      GROUP BY strftime('%Y-%m', createdAt)
      ORDER BY month DESC
      LIMIT 12
    ''');
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}

// Additional models for database operations
class Product {
  final String id;
  final String name;
  final String? description;
  final BusinessCategory category;
  final String unit;
  final double unitPrice;
  final double taxRate;
  final List<CategorySpecificField> categoryFields;
  final Map<String, dynamic>? metadata;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.category,
    required this.unit,
    required this.unitPrice,
    required this.taxRate,
    required this.categoryFields,
    this.metadata,
  });
}

class BusinessSettings {
  final String id;
  final String businessName;
  final String ownerName;
  final String? phone;
  final String? email;
  final String? address;
  final String? gstNumber;
  final String? panNumber;
  final BusinessCategory businessCategory;
  final String? logoPath;
  final double taxRate;
  final String currency;
  final String? invoicePrefix;
  final String? terms;

  BusinessSettings({
    required this.id,
    required this.businessName,
    required this.ownerName,
    this.phone,
    this.email,
    this.address,
    this.gstNumber,
    this.panNumber,
    required this.businessCategory,
    this.logoPath,
    required this.taxRate,
    this.currency = 'INR',
    this.invoicePrefix,
    this.terms,
  });
}