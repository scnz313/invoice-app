import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/enhanced_invoice_provider.dart';
import '../models/business_category.dart';
import '../theme/app_theme.dart';
import 'enhanced_dashboard_screen.dart';
import 'enhanced_invoice_list_screen.dart';
import 'enhanced_customer_screen.dart';
import 'category_product_management_screen.dart';
import 'enhanced_settings_screen.dart';
import 'category_specific_screens.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  late BusinessCategory _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadBusinessCategory();
  }

  Future<void> _loadBusinessCategory() async {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    _selectedCategory = await settingsProvider.getBusinessCategory();
  }

  List<Widget> get _screens {
    return [
      const EnhancedDashboardScreen(),
      const EnhancedInvoiceListScreen(),
      const EnhancedCustomerScreen(),
      const CategoryProductManagementScreen(),
      _buildReportsScreen(),
      const EnhancedSettingsScreen(),
    ];
  }

  Widget _buildReportsScreen() {
    return CategorySpecificReportsScreen(category: _selectedCategory);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.snow,
        boxShadow: [
          BoxShadow(
            color: AppTheme.hof.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.dashboard, 'Dashboard'),
              _buildNavItem(1, Icons.receipt_long, 'Invoices'),
              _buildNavItem(2, Icons.people, 'Customers'),
              _buildNavItem(3, Icons.inventory_2, 'Products'),
              _buildNavItem(4, Icons.analytics, 'Reports'),
              _buildNavItem(5, Icons.settings, 'Settings'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppTheme.rausch : AppTheme.foggy,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTheme.body2.copyWith(
              fontSize: 12,
              color: isSelected ? AppTheme.rausch : AppTheme.foggy,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        _navigateToInvoiceCreation();
      },
      backgroundColor: AppTheme.rausch,
      foregroundColor: AppTheme.snow,
      icon: const Icon(Icons.add),
      label: Text(
        'New Invoice',
        style: AppTheme.button.copyWith(color: AppTheme.snow),
      ),
    );
  }

  void _navigateToInvoiceCreation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategorySpecificInvoiceCreationScreen(
          category: _selectedCategory,
        ),
      ),
    );
  }
}

class CategorySpecificReportsScreen extends StatelessWidget {
  final BusinessCategory category;

  const CategorySpecificReportsScreen({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    switch (category) {
      case BusinessCategory.groceryStore:
        return const GroceryReportsScreen();
      case BusinessCategory.jewelryStore:
        return JewelryReportsScreen(category: category);
      case BusinessCategory.restaurantCafe:
        return RestaurantReportsScreen(category: category);
      case BusinessCategory.clothingStore:
        return ClothingReportsScreen(category: category);
      case BusinessCategory.electronicsStore:
        return ElectronicsReportsScreen(category: category);
      case BusinessCategory.hardwareStore:
        return HardwareReportsScreen(category: category);
      case BusinessCategory.bakery:
        return BakeryReportsScreen(category: category);
      case BusinessCategory.stationeryStore:
        return StationeryReportsScreen(category: category);
      default:
        return GenericReportsScreen(category: category);
    }
  }
}

class CategorySpecificInvoiceCreationScreen extends StatelessWidget {
  final BusinessCategory category;

  const CategorySpecificInvoiceCreationScreen({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    switch (category) {
      case BusinessCategory.groceryStore:
        return const GroceryInvoiceCreationScreen();
      case BusinessCategory.jewelryStore:
        return JewelryInvoiceCreationScreen(category: category);
      case BusinessCategory.restaurantCafe:
        return RestaurantInvoiceCreationScreen(category: category);
      case BusinessCategory.clothingStore:
        return ClothingInvoiceCreationScreen(category: category);
      case BusinessCategory.electronicsStore:
        return ElectronicsInvoiceCreationScreen(category: category);
      case BusinessCategory.hardwareStore:
        return HardwareInvoiceCreationScreen(category: category);
      case BusinessCategory.bakery:
        return BakeryInvoiceCreationScreen(category: category);
      case BusinessCategory.stationeryStore:
        return StationeryInvoiceCreationScreen(category: category);
      default:
        return const InvoiceCreationScreen();
    }
  }
}