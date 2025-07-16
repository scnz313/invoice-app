import 'package:flutter/material.dart';
import '../models/grocery_product.dart';
import '../services/inventory_service.dart';
import '../utils/logger.dart';
import '../theme/app_theme.dart';

class InventoryManagementScreen extends StatefulWidget {
  const InventoryManagementScreen({super.key});

  @override
  State<InventoryManagementScreen> createState() => _InventoryManagementScreenState();
}

class _InventoryManagementScreenState extends State<InventoryManagementScreen>
    with TickerProviderStateMixin {
  final InventoryService _inventoryService = InventoryService();
  
  late TabController _tabController;
  bool _isLoading = true;
  
  List<GroceryProduct> _allProducts = [];
  List<GroceryProduct> _filteredProducts = [];
  GroceryCategory? _selectedCategory;
  String _searchQuery = '';
  
  // Alert counts
  int _lowStockCount = 0;
  int _outOfStockCount = 0;
  int _expiringCount = 0;
  int _expiredCount = 0;
  int _overstockedCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _initializeData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);
    
    try {
      await _inventoryService.initialize();
      await _loadData();
      setState(() => _isLoading = false);
    } catch (e) {
      Logger.error('Failed to initialize inventory screen', 'InventoryManagementScreen', e);
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadData() async {
    _allProducts = await _inventoryService.getAllProducts();
    _filteredProducts = List.from(_allProducts);
    
    // Calculate alert counts
    _lowStockCount = _allProducts.where((p) => p.isLowStock).length;
    _outOfStockCount = _allProducts.where((p) => p.isOutOfStock).length;
    _expiringCount = _allProducts.where((p) => p.isExpiringSoon).length;
    _expiredCount = _allProducts.where((p) => p.isExpired).length;
    _overstockedCount = _allProducts.where((p) => p.isOverstocked).length;
    
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Inventory Management',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _addProduct,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: 'All (${_allProducts.length})'),
            Tab(text: 'Alerts (${_lowStockCount + _outOfStockCount + _expiringCount})'),
            Tab(text: 'Categories'),
            Tab(text: 'Expiring (${_expiringCount + _expiredCount})'),
            Tab(text: 'Reports'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAllProductsTab(),
                _buildAlertsTab(),
                _buildCategoriesTab(),
                _buildExpiringTab(),
                _buildReportsTab(),
              ],
            ),
    );
  }

  Widget _buildAllProductsTab() {
    return Column(
      children: [
        _buildSearchAndFilter(),
        Expanded(
          child: _filteredProducts.isEmpty
              ? _buildEmptyState()
              : _buildProductsList(_filteredProducts),
        ),
      ],
    );
  }

  Widget _buildAlertsTab() {
    final alertProducts = _allProducts.where((product) {
      return product.stockAlertType != null;
    }).toList();

    return Column(
      children: [
        _buildAlertsSummary(),
        Expanded(
          child: alertProducts.isEmpty
              ? _buildNoAlertsState()
              : _buildProductsList(alertProducts),
        ),
      ],
    );
  }

  Widget _buildCategoriesTab() {
    return Column(
      children: [
        _buildCategoryFilter(),
        Expanded(
          child: _selectedCategory != null
              ? _buildCategoryProducts()
              : _buildCategoryGrid(),
        ),
      ],
    );
  }

  Widget _buildExpiringTab() {
    final expiringProducts = _allProducts.where((product) {
      return product.isExpiringSoon || product.isExpired;
    }).toList();

    return Column(
      children: [
        _buildExpirySummary(),
        Expanded(
          child: expiringProducts.isEmpty
              ? _buildNoExpiryState()
              : _buildExpiryList(expiringProducts),
        ),
      ],
    );
  }

  Widget _buildReportsTab() {
    return FutureBuilder<InventoryReport>(
      future: _inventoryService.generateInventoryReport(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading report: ${snapshot.error}'),
          );
        }
        
        final report = snapshot.data!;
        return _buildInventoryReport(report);
      },
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search products...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: _filterProducts,
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', null),
                ...GroceryCategory.values.map((category) => 
                  _buildFilterChip(category.displayName, category),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, GroceryCategory? category) {
    final isSelected = _selectedCategory == category;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? category : null;
            _filterProducts(_searchQuery);
          });
        },
        backgroundColor: Colors.grey[200],
        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
        checkmarkColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildAlertsSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildAlertCard(
                  'Low Stock',
                  _lowStockCount,
                  Colors.orange,
                  Icons.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAlertCard(
                  'Out of Stock',
                  _outOfStockCount,
                  Colors.red,
                  Icons.remove_shopping_cart,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildAlertCard(
                  'Expiring Soon',
                  _expiringCount,
                  Colors.yellow,
                  Icons.schedule,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAlertCard(
                  'Overstocked',
                  _overstockedCount,
                  Colors.blue,
                  Icons.inventory_2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(String title, int count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text(
            'Select Category:',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<GroceryCategory>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              hint: const Text('All Categories'),
              items: [
                const DropdownMenuItem<GroceryCategory>(
                  value: null,
                  child: Text('All Categories'),
                ),
                ...GroceryCategory.values.map((category) {
                  final count = _allProducts.where((p) => p.category == category).length;
                  return DropdownMenuItem(
                    value: category,
                    child: Text('${category.displayName} ($count)'),
                  );
                }),
              ],
              onChanged: (category) {
                setState(() {
                  _selectedCategory = category;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: GroceryCategory.values.length,
      itemBuilder: (context, index) {
        final category = GroceryCategory.values[index];
        final products = _allProducts.where((p) => p.category == category).toList();
        final count = products.length;
        
        return _buildCategoryCard(category, count, products);
      },
    );
  }

  Widget _buildCategoryCard(GroceryCategory category, int count, List<GroceryProduct> products) {
    final lowStockCount = products.where((p) => p.isLowStock).length;
    final outOfStockCount = products.where((p) => p.isOutOfStock).length;
    
    return Card(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedCategory = category;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: category.color.withOpacity(0.2),
                child: Icon(
                  category.icon,
                  color: category.color,
                  size: 30,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                category.displayName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '$count products',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              if (lowStockCount > 0 || outOfStockCount > 0) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (lowStockCount > 0) ...[
                      Icon(Icons.warning, color: Colors.orange, size: 16),
                      Text(
                        ' $lowStockCount',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    if (outOfStockCount > 0) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.remove_shopping_cart, color: Colors.red, size: 16),
                      Text(
                        ' $outOfStockCount',
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryProducts() {
    final products = _allProducts.where((p) => p.category == _selectedCategory).toList();
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _selectedCategory!.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                _selectedCategory!.icon,
                color: _selectedCategory!.color,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedCategory!.displayName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: _selectedCategory!.color,
                      ),
                    ),
                    Text(
                      '${products.length} products',
                      style: TextStyle(
                        color: _selectedCategory!.color.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _selectedCategory = null;
                  });
                },
              ),
                ],
              ),
            ),
          Expanded(
            child: _buildProductsList(products),
          ),
        ],
      );
    }

  Widget _buildExpirySummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildExpiryCard(
              'Expiring Soon',
              _expiringCount,
              Colors.yellow,
              Icons.schedule,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildExpiryCard(
              'Expired',
              _expiredCount,
              Colors.red,
              Icons.block,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiryCard(String title, int count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiryList(List<GroceryProduct> products) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildExpiryItem(product);
      },
    );
  }

  Widget _buildExpiryItem(GroceryProduct product) {
    final daysUntilExpiry = product.expiryDate?.difference(DateTime.now()).inDays ?? 0;
    final isExpired = product.isExpired;
    final color = isExpired ? Colors.red : Colors.orange;
    final icon = isExpired ? Icons.block : Icons.schedule;
    final text = isExpired ? 'Expired' : 'Expires in $daysUntilExpiry days';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(
          product.displayName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.category.displayName),
            Text(
              'Stock: ${product.currentStock} ${product.unitType.shortName}',
              style: TextStyle(
                color: product.isLowStock ? Colors.orange : Colors.grey[600],
                fontWeight: product.isLowStock ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => _editProduct(product),
        ),
      ),
    );
  }

  Widget _buildInventoryReport(InventoryReport report) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildReportCard(report),
          const SizedBox(height: 16),
          _buildCategoryValueChart(report.categoryValues),
          const SizedBox(height: 16),
          _buildAlertSummary(report),
        ],
      ),
    );
  }

  Widget _buildReportCard(InventoryReport report) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.assessment, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Inventory Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  'Generated: ${_formatDate(report.generatedAt)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildReportStat(
                    'Total Products',
                    report.totalProducts.toString(),
                    Icons.inventory,
                    AppTheme.primaryColor,
                  ),
                ),
                Expanded(
                  child: _buildReportStat(
                    'Total Value',
                    '₹${report.totalValue.toStringAsFixed(2)}',
                    Icons.attach_money,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildReportStat(
                    'Alert %',
                    '${report.alertPercentage.toStringAsFixed(1)}%',
                    Icons.warning,
                    report.hasAlerts ? Colors.orange : Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildReportStat(
                    'Low Stock',
                    report.lowStockCount.toString(),
                    Icons.warning,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryValueChart(Map<GroceryCategory, double> categoryValues) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Inventory Value by Category',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...categoryValues.entries.map((entry) {
              final category = entry.key;
              final value = entry.value;
              final percentage = categoryValues.values.reduce((a, b) => a + b) > 0
                  ? (value / categoryValues.values.reduce((a, b) => a + b)) * 100
                  : 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      category.icon,
                      color: category.color,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        category.displayName,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Text(
                      '₹${value.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${percentage.toStringAsFixed(1)}%)',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertSummary(InventoryReport report) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Alert Summary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildAlertRow('Low Stock', report.lowStockCount, Colors.orange),
            _buildAlertRow('Out of Stock', report.outOfStockCount, Colors.red),
            _buildAlertRow('Expiring Soon', report.expiringCount, Colors.yellow),
            _buildAlertRow('Expired', report.expiredCount, Colors.red),
            _buildAlertRow('Overstocked', report.overstockedCount, Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertRow(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label),
          ),
          Text(
            count.toString(),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList(List<GroceryProduct> products) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(GroceryProduct product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: product.category.color.withOpacity(0.2),
          child: Icon(
            product.category.icon,
            color: product.category.color,
          ),
        ),
        title: Text(
          product.displayName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.category.displayName),
            Row(
              children: [
                Text(
                  'Stock: ${product.currentStock} ${product.unitType.shortName}',
                  style: TextStyle(
                    color: product.isLowStock ? Colors.orange : Colors.grey[600],
                    fontWeight: product.isLowStock ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
                const Spacer(),
                Text(
                  '₹${product.unitPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            if (product.stockAlertType != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    product.stockAlertType!.icon,
                    color: product.stockAlertType!.color,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    product.stockAlertType!.displayName,
                    style: TextStyle(
                      color: product.stockAlertType!.color,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'stock',
              child: Row(
                children: [
                  Icon(Icons.inventory),
                  SizedBox(width: 8),
                  Text('Update Stock'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _editProduct(product);
                break;
              case 'stock':
                _updateStock(product);
                break;
              case 'delete':
                _deleteProduct(product);
                break;
            }
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No products found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add products to start managing your inventory',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoAlertsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            size: 80,
            color: Colors.green[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No alerts',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.green[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'All products are in good condition',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoExpiryState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.schedule,
            size: 80,
            color: Colors.green[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No expiry alerts',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.green[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'All products are within expiry dates',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  // Event handlers
  void _filterProducts(String query) {
    setState(() {
      _searchQuery = query;
      _filteredProducts = _allProducts.where((product) {
        final matchesSearch = query.isEmpty ||
            product.name.toLowerCase().contains(query.toLowerCase()) ||
            product.brand?.toLowerCase().contains(query.toLowerCase()) == true ||
            product.barcode?.contains(query) == true;
        
        final matchesCategory = _selectedCategory == null ||
            product.category == _selectedCategory;
        
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  void _addProduct() {
    // TODO: Navigate to add product screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add product functionality coming soon')),
    );
  }

  void _editProduct(GroceryProduct product) {
    // TODO: Navigate to edit product screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit product functionality coming soon')),
    );
  }

  void _updateStock(GroceryProduct product) {
    // TODO: Show stock update dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Update stock functionality coming soon')),
    );
  }

  void _deleteProduct(GroceryProduct product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete ${product.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _inventoryService.deleteProduct(product.id);
                await _loadData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Product deleted successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to delete product: $e')),
                );
              }
            },
            child: const Text('Delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    await _loadData();
    setState(() => _isLoading = false);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}