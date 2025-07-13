import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../models/business_category.dart';
import '../models/jewelry_product.dart';
import '../models/restaurant_product.dart';
import '../models/clothing_product.dart';
import '../models/electronics_product.dart';
import '../models/hardware_product.dart';
import '../models/bakery_product.dart';
import '../models/stationery_product.dart';
import '../models/grocery_product.dart';
import '../theme/app_theme.dart';

class CategoryProductManagementScreen extends StatefulWidget {
  const CategoryProductManagementScreen({super.key});

  @override
  State<CategoryProductManagementScreen> createState() => _CategoryProductManagementScreenState();
}

class _CategoryProductManagementScreenState extends State<CategoryProductManagementScreen> {
  late BusinessCategory _selectedCategory;
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedFilter = 'All';

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
            valueColor: AlwaysStoppedAnimation<Color>(_getCategoryColor()),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.ghost,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: _buildProductList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProductDialog(),
        backgroundColor: _getCategoryColor(),
        foregroundColor: AppTheme.snow,
        child: const Icon(Icons.add),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        '${_selectedCategory.displayName} Products',
        style: AppTheme.headline4.copyWith(color: AppTheme.snow),
      ),
      backgroundColor: _getCategoryColor(),
      foregroundColor: AppTheme.snow,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.sort),
          onPressed: () => _showSortDialog(),
        ),
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () => _showFilterDialog(),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.snow,
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppTheme.ghost,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _buildFilterChips(),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFilterChips() {
    List<String> filters = _getCategorySpecificFilters();
    
    return filters.map((filter) {
      final isSelected = _selectedFilter == filter;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: FilterChip(
          label: Text(filter),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedFilter = selected ? filter : 'All';
            });
          },
          backgroundColor: AppTheme.ghost,
          selectedColor: _getCategoryColor().withOpacity(0.2),
          checkmarkColor: _getCategoryColor(),
        ),
      );
    }).toList();
  }

  List<String> _getCategorySpecificFilters() {
    switch (_selectedCategory) {
      case BusinessCategory.jewelryStore:
        return ['All', 'Rings', 'Necklaces', 'Earrings', 'Bracelets', 'Watches'];
      case BusinessCategory.restaurantCafe:
        return ['All', 'Appetizers', 'Main Course', 'Desserts', 'Beverages', 'Specials'];
      case BusinessCategory.clothingStore:
        return ['All', 'Tops', 'Bottoms', 'Dresses', 'Outerwear', 'Accessories'];
      case BusinessCategory.electronicsStore:
        return ['All', 'Phones', 'Laptops', 'Tablets', 'Accessories', 'Gaming'];
      case BusinessCategory.hardwareStore:
        return ['All', 'Tools', 'Materials', 'Plumbing', 'Electrical', 'Garden'];
      case BusinessCategory.bakery:
        return ['All', 'Breads', 'Cakes', 'Pastries', 'Cookies', 'Custom'];
      case BusinessCategory.stationeryStore:
        return ['All', 'School', 'Office', 'Art', 'Seasonal', 'Bulk'];
      case BusinessCategory.groceryStore:
        return ['All', 'Fresh Produce', 'Dairy', 'Meat', 'Pantry', 'Frozen'];
      default:
        return ['All', 'Category 1', 'Category 2', 'Category 3'];
    }
  }

  Widget _buildProductList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _getSampleProducts().length,
      itemBuilder: (context, index) {
        final product = _getSampleProducts()[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: _getCategoryColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getProductIcon(product['type']),
            color: _getCategoryColor(),
            size: 30,
          ),
        ),
        title: Text(
          product['name'],
          style: AppTheme.body1.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product['description'], style: AppTheme.body2),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '\$${product['price']}',
                  style: AppTheme.body2.copyWith(
                    color: _getCategoryColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Stock: ${product['stock']}',
                  style: AppTheme.caption,
                ),
              ],
            ),
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
              value: 'duplicate',
              child: Row(
                children: [
                  Icon(Icons.copy),
                  SizedBox(width: 8),
                  Text('Duplicate'),
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
          onSelected: (value) => _handleProductAction(value, product),
        ),
        onTap: () => _showProductDetails(product),
      ),
    );
  }

  IconData _getProductIcon(String type) {
    switch (type) {
      case 'jewelry':
        return Icons.diamond;
      case 'food':
        return Icons.restaurant;
      case 'clothing':
        return Icons.checkroom;
      case 'electronics':
        return Icons.devices;
      case 'hardware':
        return Icons.build;
      case 'bakery':
        return Icons.cake;
      case 'stationery':
        return Icons.edit;
      case 'grocery':
        return Icons.shopping_basket;
      default:
        return Icons.inventory;
    }
  }

  List<Map<String, dynamic>> _getSampleProducts() {
    switch (_selectedCategory) {
      case BusinessCategory.jewelryStore:
        return [
          {
            'name': 'Diamond Ring',
            'description': '18K Gold, 1.5 carat diamond',
            'price': '2,500',
            'stock': '5',
            'type': 'jewelry',
          },
          {
            'name': 'Pearl Necklace',
            'description': 'Freshwater pearls, 18 inches',
            'price': '450',
            'stock': '12',
            'type': 'jewelry',
          },
        ];
      case BusinessCategory.restaurantCafe:
        return [
          {
            'name': 'Margherita Pizza',
            'description': 'Fresh mozzarella, basil, tomato sauce',
            'price': '18',
            'stock': 'Available',
            'type': 'food',
          },
          {
            'name': 'Cappuccino',
            'description': 'Espresso with steamed milk foam',
            'price': '4.50',
            'stock': 'Available',
            'type': 'food',
          },
        ];
      case BusinessCategory.clothingStore:
        return [
          {
            'name': 'Denim Jacket',
            'description': 'Classic blue denim, size M',
            'price': '89',
            'stock': '8',
            'type': 'clothing',
          },
          {
            'name': 'Summer Dress',
            'description': 'Floral print, cotton blend',
            'price': '65',
            'stock': '15',
            'type': 'clothing',
          },
        ];
      case BusinessCategory.electronicsStore:
        return [
          {
            'name': 'iPhone 15 Pro',
            'description': '256GB, Titanium, 5G',
            'price': '1,199',
            'stock': '3',
            'type': 'electronics',
          },
          {
            'name': 'MacBook Air',
            'description': 'M2 chip, 13-inch, 512GB',
            'price': '1,299',
            'stock': '2',
            'type': 'electronics',
          },
        ];
      case BusinessCategory.hardwareStore:
        return [
          {
            'name': 'Cordless Drill',
            'description': '20V MAX, 1/2 inch chuck',
            'price': '129',
            'stock': '7',
            'type': 'hardware',
          },
          {
            'name': 'Paint Roller Set',
            'description': '9-inch roller with frame',
            'price': '15',
            'stock': '25',
            'type': 'hardware',
          },
        ];
      case BusinessCategory.bakery:
        return [
          {
            'name': 'Sourdough Bread',
            'description': 'Artisan sourdough, 1lb',
            'price': '6.50',
            'stock': '12',
            'type': 'bakery',
          },
          {
            'name': 'Chocolate Cake',
            'description': '8-inch round, chocolate ganache',
            'price': '28',
            'stock': '3',
            'type': 'bakery',
          },
        ];
      case BusinessCategory.stationeryStore:
        return [
          {
            'name': 'Notebook Set',
            'description': '5-pack, college ruled, 100 pages',
            'price': '12',
            'stock': '20',
            'type': 'stationery',
          },
          {
            'name': 'Art Supplies Kit',
            'description': 'Pencils, erasers, sharpeners',
            'price': '18',
            'stock': '15',
            'type': 'stationery',
          },
        ];
      case BusinessCategory.groceryStore:
        return [
          {
            'name': 'Organic Bananas',
            'description': 'Fresh organic bananas, 1lb',
            'price': '1.99',
            'stock': '50',
            'type': 'grocery',
          },
          {
            'name': 'Whole Milk',
            'description': 'Fresh whole milk, 1 gallon',
            'price': '4.50',
            'stock': '8',
            'type': 'grocery',
          },
        ];
      default:
        return [
          {
            'name': 'Sample Product',
            'description': 'Product description',
            'price': '99',
            'stock': '10',
            'type': 'generic',
          },
        ];
    }
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) => _buildAddProductDialog(),
    );
  }

  Widget _buildAddProductDialog() {
    return AlertDialog(
      title: Text('Add ${_selectedCategory.displayName} Product'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Product Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Price',
                border: OutlineInputBorder(),
                prefixText: '\$',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Stock Quantity',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildCategorySpecificFields(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Handle add product
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Product added successfully'),
                backgroundColor: _getCategoryColor(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _getCategoryColor(),
            foregroundColor: AppTheme.snow,
          ),
          child: const Text('Add Product'),
        ),
      ],
    );
  }

  Widget _buildCategorySpecificFields() {
    switch (_selectedCategory) {
      case BusinessCategory.jewelryStore:
        return Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Metal Type',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Gemstone Type',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        );
      case BusinessCategory.restaurantCafe:
        return Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Preparation Time',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        );
      case BusinessCategory.clothingStore:
        return Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Size',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Color',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _showProductDetails(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Description: ${product['description']}'),
            const SizedBox(height: 8),
            Text('Price: \$${product['price']}'),
            const SizedBox(height: 8),
            Text('Stock: ${product['stock']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleProductAction(String action, Map<String, dynamic> product) {
    switch (action) {
      case 'edit':
        // Handle edit
        break;
      case 'duplicate':
        // Handle duplicate
        break;
      case 'delete':
        _showDeleteConfirmation(product);
        break;
    }
  }

  void _showDeleteConfirmation(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Product deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort Products'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.sort_by_alpha),
              title: const Text('Name A-Z'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Price Low-High'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Price High-Low'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Stock Level'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Products'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('In Stock'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.warning),
              title: const Text('Low Stock'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Out of Stock'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
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