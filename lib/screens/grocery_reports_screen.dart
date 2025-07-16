import 'package:flutter/material.dart';
import '../utils/logger.dart';
import '../theme/app_theme.dart';

class GroceryReportsScreen extends StatefulWidget {
  const GroceryReportsScreen({super.key});

  @override
  State<GroceryReportsScreen> createState() => _GroceryReportsScreenState();
}

class _GroceryReportsScreenState extends State<GroceryReportsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  
  String _selectedPeriod = 'This Month';
  String _selectedCategory = 'All Categories';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadSampleData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSampleData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Grocery Reports',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: _exportReports,
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _shareReports,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Sales'),
            Tab(text: 'Inventory'),
            Tab(text: 'Customers'),
            Tab(text: 'Profit'),
            Tab(text: 'Expiry'),
            Tab(text: 'Suppliers'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFilters(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildSalesTab(),
                      _buildInventoryTab(),
                      _buildCustomersTab(),
                      _buildProfitTab(),
                      _buildExpiryTab(),
                      _buildSuppliersTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilters() {
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
            child: DropdownButtonFormField<String>(
              value: _selectedPeriod,
              decoration: const InputDecoration(
                labelText: 'Period',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: [
                'Today',
                'This Week',
                'This Month',
                'This Quarter',
                'This Year',
                'Last Month',
                'Last Year',
              ].map((period) {
                return DropdownMenuItem(
                  value: period,
                  child: Text(period),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedPeriod = value!);
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: [
                'All Categories',
                'Fruits & Vegetables',
                'Dairy & Eggs',
                'Meat & Fish',
                'Grains & Cereals',
                'Beverages',
                'Snacks',
                'Frozen Foods',
                'Personal Care',
                'Household',
                'Baby Care',
                'Pet Supplies',
              ].map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedCategory = value!);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSalesSummary(),
          const SizedBox(height: 16),
          _buildSalesChart(),
          const SizedBox(height: 16),
          _buildTopProducts(),
          const SizedBox(height: 16),
          _buildSalesByCategory(),
        ],
      ),
    );
  }

  Widget _buildSalesSummary() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Total Sales',
            '₹45,250',
            '+12.5%',
            Icons.attach_money,
            Colors.green,
            true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Orders',
            '156',
            '+8.2%',
            Icons.shopping_cart,
            Colors.blue,
            true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Avg Order',
            '₹290',
            '+4.1%',
            Icons.analytics,
            Colors.orange,
            true,
          ),
        ),
      ],
    );
  }

  Widget _buildSalesChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sales Trend',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'Chart Placeholder\nSales trend visualization',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProducts() {
    final topProducts = [
      {'name': 'Milk 1L', 'sales': 1250, 'quantity': 250},
      {'name': 'Bread', 'sales': 980, 'quantity': 196},
      {'name': 'Eggs (12)', 'sales': 840, 'quantity': 70},
      {'name': 'Bananas', 'sales': 720, 'quantity': 180},
      {'name': 'Rice 5kg', 'sales': 680, 'quantity': 34},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Selling Products',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ...topProducts.map((product) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        product['name'] as String,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '₹${product['sales']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${product['quantity']} units',
                        style: TextStyle(color: Colors.grey[600]),
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

  Widget _buildSalesByCategory() {
    final categories = [
      {'name': 'Fruits & Vegetables', 'sales': 12500, 'percentage': 27.6},
      {'name': 'Dairy & Eggs', 'sales': 9800, 'percentage': 21.7},
      {'name': 'Grains & Cereals', 'sales': 8200, 'percentage': 18.1},
      {'name': 'Beverages', 'sales': 6500, 'percentage': 14.4},
      {'name': 'Snacks', 'sales': 5200, 'percentage': 11.5},
      {'name': 'Others', 'sales': 3050, 'percentage': 6.7},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sales by Category',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ...categories.map((category) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            category['name'] as String,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '₹${category['sales']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ),
                        Text(
                          '${category['percentage']}%',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: (category['percentage'] as double) / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryColor,
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

  Widget _buildInventoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInventorySummary(),
          const SizedBox(height: 16),
          _buildLowStockAlert(),
          const SizedBox(height: 16),
          _buildInventoryValue(),
          const SizedBox(height: 16),
          _buildStockMovement(),
        ],
      ),
    );
  }

  Widget _buildInventorySummary() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Total Items',
            '1,245',
            'Active',
            Icons.inventory,
            Colors.blue,
            false,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Low Stock',
            '23',
            'Alert',
            Icons.warning,
            Colors.orange,
            false,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Out of Stock',
            '8',
            'Critical',
            Icons.error,
            Colors.red,
            false,
          ),
        ),
      ],
    );
  }

  Widget _buildLowStockAlert() {
    final lowStockItems = [
      {'name': 'Milk 1L', 'current': 5, 'min': 10, 'supplier': 'Dairy Farm'},
      {'name': 'Bread', 'current': 3, 'min': 8, 'supplier': 'Bakery Co'},
      {'name': 'Eggs (12)', 'current': 2, 'min': 5, 'supplier': 'Poultry Farm'},
      {'name': 'Tomatoes', 'current': 8, 'min': 15, 'supplier': 'Fresh Veg'},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Low Stock Alerts',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _reorderItems,
                  child: const Text('Reorder All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...lowStockItems.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        item['name'] as String,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${item['current']}/${item['min']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item['supplier'] as String,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_shopping_cart, size: 20),
                      onPressed: () => _reorderItem(item),
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

  Widget _buildInventoryValue() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Inventory Value',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        '₹125,000',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const Text('Total Value'),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        '₹45,000',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const Text('Average Cost'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockMovement() {
    final movements = [
      {'item': 'Milk 1L', 'type': 'In', 'quantity': 50, 'date': 'Today'},
      {'item': 'Bread', 'type': 'Out', 'quantity': 25, 'date': 'Today'},
      {'item': 'Eggs (12)', 'type': 'In', 'quantity': 30, 'date': 'Yesterday'},
      {'item': 'Tomatoes', 'type': 'Out', 'quantity': 15, 'date': 'Yesterday'},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Stock Movements',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ...movements.map((movement) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(
                      movement['type'] == 'In' ? Icons.arrow_downward : Icons.arrow_upward,
                      color: movement['type'] == 'In' ? Colors.green : Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        movement['item'] as String,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Text(
                      '${movement['type'] == 'In' ? '+' : '-'}${movement['quantity']}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: movement['type'] == 'In' ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      movement['date'] as String,
                      style: TextStyle(color: Colors.grey[600]),
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

  Widget _buildCustomersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildCustomerSummary(),
          const SizedBox(height: 16),
          _buildTopCustomers(),
          const SizedBox(height: 16),
          _buildCustomerSegments(),
        ],
      ),
    );
  }

  Widget _buildCustomerSummary() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Total Customers',
            '456',
            '+15',
            Icons.people,
            Colors.blue,
            true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'New This Month',
            '23',
            '+8',
            Icons.person_add,
            Colors.green,
            true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Avg Order Value',
            '₹320',
            '+5.2%',
            Icons.analytics,
            Colors.orange,
            true,
          ),
        ),
      ],
    );
  }

  Widget _buildTopCustomers() {
    final topCustomers = [
      {'name': 'John Doe', 'orders': 45, 'total': 12500, 'loyalty': 'Gold'},
      {'name': 'Jane Smith', 'orders': 38, 'total': 9800, 'loyalty': 'Silver'},
      {'name': 'Mike Johnson', 'orders': 32, 'total': 8200, 'loyalty': 'Gold'},
      {'name': 'Sarah Wilson', 'orders': 28, 'total': 7200, 'loyalty': 'Bronze'},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Customers',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ...topCustomers.map((customer) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                      child: Text(
                        (customer['name'] as String).substring(0, 1),
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer['name'] as String,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '${customer['orders']} orders',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${customer['total']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getLoyaltyColor(customer['loyalty'] as String).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            customer['loyalty'] as String,
                            style: TextStyle(
                              color: _getLoyaltyColor(customer['loyalty'] as String),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildCustomerSegments() {
    final segments = [
      {'segment': 'High Value', 'count': 45, 'percentage': 9.9, 'color': Colors.green},
      {'segment': 'Regular', 'count': 156, 'percentage': 34.2, 'color': Colors.blue},
      {'segment': 'Occasional', 'count': 234, 'percentage': 51.3, 'color': Colors.orange},
      {'segment': 'Inactive', 'count': 21, 'percentage': 4.6, 'color': Colors.grey},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer Segments',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ...segments.map((segment) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: segment['color'] as Color,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        segment['segment'] as String,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Text(
                      '${segment['count']}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${segment['percentage']}%',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
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

  Widget _buildProfitTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildProfitSummary(),
          const SizedBox(height: 16),
          _buildProfitMargin(),
          const SizedBox(height: 16),
          _buildTopProfitableProducts(),
        ],
      ),
    );
  }

  Widget _buildProfitSummary() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Gross Profit',
            '₹18,500',
            '+15.2%',
            Icons.trending_up,
            Colors.green,
            true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Profit Margin',
            '40.9%',
            '+2.1%',
            Icons.analytics,
            Colors.blue,
            true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Avg Cost',
            '₹175',
            '-1.2%',
            Icons.attach_money,
            Colors.orange,
            false,
          ),
        ),
      ],
    );
  }

  Widget _buildProfitMargin() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profit Margin by Category',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'Chart Placeholder\nProfit margin visualization',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProfitableProducts() {
    final products = [
      {'name': 'Organic Milk', 'margin': 65.2, 'profit': 3200},
      {'name': 'Fresh Bread', 'margin': 58.4, 'profit': 2800},
      {'name': 'Premium Eggs', 'margin': 52.1, 'profit': 2100},
      {'name': 'Organic Fruits', 'margin': 48.7, 'profit': 1800},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Most Profitable Products',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ...products.map((product) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        product['name'] as String,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${product['margin']}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '₹${product['profit']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
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

  Widget _buildExpiryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildExpirySummary(),
          const SizedBox(height: 16),
          _buildExpiringSoon(),
          const SizedBox(height: 16),
          _buildExpiredItems(),
        ],
      ),
    );
  }

  Widget _buildExpirySummary() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Expiring Soon',
            '15',
            '7 days',
            Icons.warning,
            Colors.orange,
            false,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Expired',
            '3',
            'Today',
            Icons.error,
            Colors.red,
            false,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Value at Risk',
            '₹2,500',
            'Alert',
            Icons.attach_money,
            Colors.red,
            false,
          ),
        ),
      ],
    );
  }

  Widget _buildExpiringSoon() {
    final expiringItems = [
      {'name': 'Milk 1L', 'expiry': '2 days', 'quantity': 25, 'value': 500},
      {'name': 'Yogurt', 'expiry': '3 days', 'quantity': 15, 'value': 300},
      {'name': 'Cheese', 'expiry': '5 days', 'quantity': 8, 'value': 400},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Expiring Soon (Next 7 Days)',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ...expiringItems.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        item['name'] as String,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item['expiry'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${item['quantity']} units',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '₹${item['value']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
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

  Widget _buildExpiredItems() {
    final expiredItems = [
      {'name': 'Bread', 'expired': '1 day ago', 'quantity': 5, 'value': 100},
      {'name': 'Eggs', 'expired': '2 days ago', 'quantity': 12, 'value': 120},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Expired Items',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ...expiredItems.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        item['name'] as String,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item['expired'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${item['quantity']} units',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '₹${item['value']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
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

  Widget _buildSuppliersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSupplierSummary(),
          const SizedBox(height: 16),
          _buildTopSuppliers(),
          const SizedBox(height: 16),
          _buildSupplierPerformance(),
        ],
      ),
    );
  }

  Widget _buildSupplierSummary() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Total Suppliers',
            '24',
            'Active',
            Icons.business,
            Colors.blue,
            false,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'This Month',
            '₹18,500',
            'Spent',
            Icons.attach_money,
            Colors.green,
            false,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Avg Rating',
            '4.2',
            'Stars',
            Icons.star,
            Colors.amber,
            false,
          ),
        ),
      ],
    );
  }

  Widget _buildTopSuppliers() {
    final suppliers = [
      {'name': 'Dairy Farm Co', 'spent': 5200, 'items': 45, 'rating': 4.5},
      {'name': 'Fresh Veg Ltd', 'spent': 3800, 'items': 32, 'rating': 4.2},
      {'name': 'Bakery Corner', 'spent': 2900, 'items': 28, 'rating': 4.0},
      {'name': 'Poultry Farm', 'spent': 2100, 'items': 15, 'rating': 4.3},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Suppliers',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ...suppliers.map((supplier) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        supplier['name'] as String,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '₹${supplier['spent']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${supplier['items']} items',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        Text(
                          '${supplier['rating']}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
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

  Widget _buildSupplierPerformance() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Supplier Performance',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'Chart Placeholder\nSupplier performance metrics',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, String subtitle, IconData icon, Color color, bool isPercentage) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
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
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: isPercentage ? Colors.green : Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getLoyaltyColor(String tier) {
    switch (tier.toLowerCase()) {
      case 'diamond':
        return Colors.purple;
      case 'platinum':
        return Colors.blue;
      case 'gold':
        return Colors.amber;
      case 'silver':
        return Colors.grey;
      case 'bronze':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _exportReports() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export functionality coming soon')),
    );
  }

  void _shareReports() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon')),
    );
  }

  void _reorderItems() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reorder functionality coming soon')),
    );
  }

  void _reorderItem(Map<String, dynamic> item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reorder ${item['name']} functionality coming soon')),
    );
  }
}