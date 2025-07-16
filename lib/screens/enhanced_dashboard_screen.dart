import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../models/business_category.dart';
import '../theme/app_theme.dart';
import 'category_specific_screens.dart';

class EnhancedDashboardScreen extends StatefulWidget {
  const EnhancedDashboardScreen({super.key});

  @override
  State<EnhancedDashboardScreen> createState() => _EnhancedDashboardScreenState();
}

class _EnhancedDashboardScreenState extends State<EnhancedDashboardScreen> {
  late BusinessCategory _selectedCategory;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBusinessCategory();
  }

  Future<void> _loadBusinessCategory() async {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    _selectedCategory = await settingsProvider.getBusinessCategory();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.ghost,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.rausch),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.ghost,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(),
            const SizedBox(height: 24),
            _buildQuickStats(),
            const SizedBox(height: 24),
            _buildCategorySpecificMetrics(),
            const SizedBox(height: 24),
            _buildRecentActivity(),
            const SizedBox(height: 24),
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        '${_selectedCategory.displayName} Dashboard',
        style: AppTheme.headline4.copyWith(color: AppTheme.snow),
      ),
      backgroundColor: _getCategoryColor(),
      foregroundColor: AppTheme.snow,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () {
            // Handle notifications
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            // Navigate to settings
          },
        ),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _selectedCategory.icon,
                  size: 32,
                  color: _getCategoryColor(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back!',
                        style: AppTheme.headline4,
                      ),
                      Text(
                        'Your ${_selectedCategory.displayName} is doing great',
                        style: AppTheme.body2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTodayStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem('Today\'s Sales', '\$2,450', Icons.trending_up),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatItem('Orders', '12', Icons.shopping_cart),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatItem('Customers', '8', Icons.people),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getCategoryColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: _getCategoryColor(), size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTheme.headline4.copyWith(
              fontSize: 18,
              color: _getCategoryColor(),
            ),
          ),
          Text(
            label,
            style: AppTheme.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Stats',
              style: AppTheme.headline4,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildQuickStatCard(
                    'Total Sales',
                    '\$45,230',
                    '+12%',
                    Icons.attach_money,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickStatCard(
                    'Products',
                    '156',
                    '+5%',
                    Icons.inventory,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuickStatCard(
                    'Customers',
                    '89',
                    '+8%',
                    Icons.people,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickStatCard(
                    'Invoices',
                    '234',
                    '+15%',
                    Icons.receipt,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatCard(String title, String value, String change, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const Spacer(),
              Text(
                change,
                style: AppTheme.caption.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTheme.headline4.copyWith(
              fontSize: 20,
              color: color,
            ),
          ),
          Text(
            title,
            style: AppTheme.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySpecificMetrics() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_selectedCategory.displayName} Metrics',
              style: AppTheme.headline4,
            ),
            const SizedBox(height: 16),
            _buildCategorySpecificContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySpecificContent() {
    switch (_selectedCategory) {
      case BusinessCategory.jewelryStore:
        return _buildJewelryMetrics();
      case BusinessCategory.restaurantCafe:
        return _buildRestaurantMetrics();
      case BusinessCategory.clothingStore:
        return _buildClothingMetrics();
      case BusinessCategory.electronicsStore:
        return _buildElectronicsMetrics();
      case BusinessCategory.hardwareStore:
        return _buildHardwareMetrics();
      case BusinessCategory.bakery:
        return _buildBakeryMetrics();
      case BusinessCategory.stationeryStore:
        return _buildStationeryMetrics();
      case BusinessCategory.groceryStore:
        return _buildGroceryMetrics();
      default:
        return _buildGenericMetrics();
    }
  }

  Widget _buildJewelryMetrics() {
    return Column(
      children: [
        _buildMetricRow('Gemstone Sales', '23', Icons.diamond),
        _buildMetricRow('Warranty Claims', '2', Icons.security),
        _buildMetricRow('Appraisals', '8', Icons.assessment),
        _buildMetricRow('Precious Metal Stock', 'High', Icons.monetization_on),
      ],
    );
  }

  Widget _buildRestaurantMetrics() {
    return Column(
      children: [
        _buildMetricRow('Table Turnover', '4.2x', Icons.table_restaurant),
        _buildMetricRow('Popular Dish', 'Pasta', Icons.restaurant_menu),
        _buildMetricRow('Peak Hours', '6-8 PM', Icons.schedule),
        _buildMetricRow('Server Performance', 'Excellent', Icons.person),
      ],
    );
  }

  Widget _buildClothingMetrics() {
    return Column(
      children: [
        _buildMetricRow('Popular Size', 'M', Icons.straighten),
        _buildMetricRow('Top Color', 'Blue', Icons.palette),
        _buildMetricRow('Brand Sales', 'Nike', Icons.branding_watermark),
        _buildMetricRow('Seasonal Trend', 'Spring', Icons.wb_sunny),
      ],
    );
  }

  Widget _buildElectronicsMetrics() {
    return Column(
      children: [
        _buildMetricRow('Warranty Claims', '3', Icons.security),
        _buildMetricRow('Tech Support', '5 requests', Icons.support_agent),
        _buildMetricRow('Installations', '2 pending', Icons.build),
        _buildMetricRow('Trade-ins', '8', Icons.swap_horiz),
      ],
    );
  }

  Widget _buildHardwareMetrics() {
    return Column(
      children: [
        _buildMetricRow('Active Projects', '12', Icons.construction),
        _buildMetricRow('Contractor Accounts', '8', Icons.person),
        _buildMetricRow('Tool Rentals', '5', Icons.handyman),
        _buildMetricRow('Bulk Orders', '3', Icons.shopping_cart),
      ],
    );
  }

  Widget _buildBakeryMetrics() {
    return Column(
      children: [
        _buildMetricRow('Production Schedule', 'On track', Icons.schedule),
        _buildMetricRow('Custom Orders', '6', Icons.cake),
        _buildMetricRow('Allergen Alerts', '2', Icons.warning),
        _buildMetricRow('Dietary Options', '8 types', Icons.restaurant),
      ],
    );
  }

  Widget _buildStationeryMetrics() {
    return Column(
      children: [
        _buildMetricRow('School Supplies', '45 items', Icons.school),
        _buildMetricRow('Office Supplies', '23 items', Icons.business),
        _buildMetricRow('Bulk Orders', '4', Icons.shopping_cart),
        _buildMetricRow('Seasonal Items', '12', Icons.calendar_today),
      ],
    );
  }

  Widget _buildGroceryMetrics() {
    return Column(
      children: [
        _buildMetricRow('Fresh Produce', 'In stock', Icons.local_florist),
        _buildMetricRow('Dairy Products', 'Low stock', Icons.local_drink),
        _buildMetricRow('Loyalty Members', '156', Icons.card_membership),
        _buildMetricRow('Expiry Alerts', '3', Icons.warning),
      ],
    );
  }

  Widget _buildGenericMetrics() {
    return Column(
      children: [
        _buildMetricRow('Sales Performance', 'Good', Icons.trending_up),
        _buildMetricRow('Inventory Status', 'Optimal', Icons.inventory),
        _buildMetricRow('Customer Satisfaction', '4.5/5', Icons.star),
        _buildMetricRow('Revenue Growth', '+8%', Icons.attach_money),
      ],
    );
  }

  Widget _buildMetricRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: _getCategoryColor(), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: AppTheme.body2),
          ),
          Text(
            value,
            style: AppTheme.body2.copyWith(
              fontWeight: FontWeight.w600,
              color: _getCategoryColor(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity',
                  style: AppTheme.headline4,
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to full activity log
                  },
                  child: Text('View All', style: AppTheme.body2.copyWith(color: _getCategoryColor())),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildActivityItem('New invoice created', '2 minutes ago', Icons.receipt),
            _buildActivityItem('Customer registered', '15 minutes ago', Icons.person_add),
            _buildActivityItem('Product restocked', '1 hour ago', Icons.inventory),
            _buildActivityItem('Payment received', '2 hours ago', Icons.payment),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String title, String time, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getCategoryColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: _getCategoryColor(), size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.body2),
                Text(time, style: AppTheme.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: AppTheme.headline4,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Create Invoice',
                    Icons.add,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategorySpecificInvoiceCreationScreen(
                            category: _selectedCategory,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    'Add Customer',
                    Icons.person_add,
                    () {
                      // Navigate to add customer
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Manage Inventory',
                    Icons.inventory,
                    () {
                      // Navigate to inventory
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    'View Reports',
                    Icons.analytics,
                    () {
                      // Navigate to reports
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: _getCategoryColor(),
        foregroundColor: AppTheme.snow,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTheme.body2.copyWith(
              color: AppTheme.snow,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor() {
    switch (_selectedCategory) {
      case BusinessCategory.jewelryStore:
        return AppTheme.rausch;
      case BusinessCategory.restaurantCafe:
        return AppTheme.babu;
      case BusinessCategory.clothingStore:
        return AppTheme.arches;
      case BusinessCategory.electronicsStore:
        return Colors.indigo;
      case BusinessCategory.hardwareStore:
        return Colors.orange;
      case BusinessCategory.bakery:
        return Colors.brown;
      case BusinessCategory.stationeryStore:
        return Colors.teal;
      case BusinessCategory.groceryStore:
        return Colors.green;
      default:
        return AppTheme.rausch;
    }
  }
}