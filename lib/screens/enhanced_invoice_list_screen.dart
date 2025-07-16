import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../models/business_category.dart';
import '../theme/app_theme.dart';
import 'category_specific_screens.dart';
import '../screens/invoice_creation_screen.dart';

class EnhancedInvoiceListScreen extends StatefulWidget {
  const EnhancedInvoiceListScreen({super.key});

  @override
  State<EnhancedInvoiceListScreen> createState() => _EnhancedInvoiceListScreenState();
}

class _EnhancedInvoiceListScreenState extends State<EnhancedInvoiceListScreen> {
  late BusinessCategory _selectedCategory;
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedFilter = 'All';
  String _selectedStatus = 'All';
  String _selectedSortBy = 'Date';

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
          _buildQuickStats(),
          Expanded(
            child: _buildInvoiceList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToInvoiceCreation(),
        backgroundColor: _getCategoryColor(),
        foregroundColor: AppTheme.snow,
        icon: const Icon(Icons.add),
        label: const Text('New Invoice'),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        '${_selectedCategory.displayName} Invoices',
        style: AppTheme.headline4.copyWith(color: AppTheme.snow),
      ),
      backgroundColor: _getCategoryColor(),
      foregroundColor: AppTheme.snow,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () => _showAdvancedFilterDialog(),
        ),
        IconButton(
          icon: const Icon(Icons.sort),
          onPressed: () => _showSortDialog(),
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showMoreOptions(),
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
              hintText: 'Search invoices...',
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
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown('Status', _selectedStatus, _getStatusOptions(), (value) {
                  setState(() {
                    _selectedStatus = value;
                  });
                }),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFilterDropdown('Filter', _selectedFilter, _getCategorySpecificFilters(), (value) {
                  setState(() {
                    _selectedFilter = value;
                  });
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(String label, String value, List<String> options, Function(String) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.ghost,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getCategoryColor().withOpacity(0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: _getCategoryColor()),
          items: options.map((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(
                option,
                style: AppTheme.body2,
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
        ),
      ),
    );
  }

  List<String> _getStatusOptions() {
    return ['All', 'Paid', 'Pending', 'Overdue', 'Cancelled', 'Draft'];
  }

  List<String> _getCategorySpecificFilters() {
    switch (_selectedCategory) {
      case BusinessCategory.jewelryStore:
        return ['All', 'Rings', 'Necklaces', 'Earrings', 'Watches', 'High Value'];
      case BusinessCategory.restaurantCafe:
        return ['All', 'Dine-in', 'Takeaway', 'Delivery', 'Catering', 'Specials'];
      case BusinessCategory.clothingStore:
        return ['All', 'Tops', 'Bottoms', 'Dresses', 'Accessories', 'Seasonal'];
      case BusinessCategory.electronicsStore:
        return ['All', 'Phones', 'Laptops', 'Accessories', 'Warranty', 'Installation'];
      case BusinessCategory.hardwareStore:
        return ['All', 'Tools', 'Materials', 'Contractor', 'DIY', 'Bulk'];
      case BusinessCategory.bakery:
        return ['All', 'Breads', 'Cakes', 'Pastries', 'Custom', 'Wholesale'];
      case BusinessCategory.stationeryStore:
        return ['All', 'School', 'Office', 'Art', 'Bulk', 'Seasonal'];
      case BusinessCategory.groceryStore:
        return ['All', 'Fresh', 'Dairy', 'Pantry', 'Frozen', 'Organic'];
      default:
        return ['All', 'Category 1', 'Category 2', 'Category 3'];
    }
  }

  Widget _buildQuickStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard('Total Invoices', '156', Icons.receipt),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard('This Month', '23', Icons.calendar_today),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard('Pending', '8', Icons.pending),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard('Revenue', '\$12,450', Icons.attach_money),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.snow,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppTheme.hof.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: _getCategoryColor(), size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTheme.headline4.copyWith(
              fontSize: 16,
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

  Widget _buildInvoiceList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _getSampleInvoices().length,
      itemBuilder: (context, index) {
        final invoice = _getSampleInvoices()[index];
        return _buildInvoiceCard(invoice);
      },
    );
  }

  Widget _buildInvoiceCard(Map<String, dynamic> invoice) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: _getStatusColor(invoice['status']).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getStatusIcon(invoice['status']),
            color: _getStatusColor(invoice['status']),
            size: 30,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                'Invoice #${invoice['number']}',
                style: AppTheme.body1.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(invoice['status']),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                invoice['status'],
                style: AppTheme.caption.copyWith(
                  color: AppTheme.snow,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(invoice['customer'], style: AppTheme.body2),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  invoice['date'],
                  style: AppTheme.caption,
                ),
                const Spacer(),
                Text(
                  '\$${invoice['amount']}',
                  style: AppTheme.body2.copyWith(
                    color: _getCategoryColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (invoice['category'] != null) ...[
              const SizedBox(height: 4),
              Text(
                'Category: ${invoice['category']}',
                style: AppTheme.caption.copyWith(
                  color: _getCategoryColor(),
                ),
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility),
                  SizedBox(width: 8),
                  Text('View'),
                ],
              ),
            ),
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
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.share),
                  SizedBox(width: 8),
                  Text('Share'),
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
          onSelected: (value) => _handleInvoiceAction(value, invoice),
        ),
        onTap: () => _showInvoiceDetails(invoice),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'overdue':
        return Icons.warning;
      case 'cancelled':
        return Icons.cancel;
      case 'draft':
        return Icons.edit_note;
      default:
        return Icons.receipt;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'overdue':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      case 'draft':
        return Colors.blue;
      default:
        return _getCategoryColor();
    }
  }

  List<Map<String, dynamic>> _getSampleInvoices() {
    switch (_selectedCategory) {
      case BusinessCategory.jewelryStore:
        return [
          {
            'number': 'JWL-001',
            'customer': 'Sarah Johnson',
            'date': '2024-01-15',
            'amount': '2,500',
            'status': 'Paid',
            'category': 'Diamond Ring',
          },
          {
            'number': 'JWL-002',
            'customer': 'Michael Chen',
            'date': '2024-01-14',
            'amount': '450',
            'status': 'Pending',
            'category': 'Pearl Necklace',
          },
        ];
      case BusinessCategory.restaurantCafe:
        return [
          {
            'number': 'RES-001',
            'customer': 'Emma Davis',
            'date': '2024-01-15',
            'amount': '45',
            'status': 'Paid',
            'category': 'Dine-in',
          },
          {
            'number': 'RES-002',
            'customer': 'David Wilson',
            'date': '2024-01-14',
            'amount': '28',
            'status': 'Pending',
            'category': 'Takeaway',
          },
        ];
      case BusinessCategory.clothingStore:
        return [
          {
            'number': 'CLT-001',
            'customer': 'Lisa Rodriguez',
            'date': '2024-01-15',
            'amount': '89',
            'status': 'Paid',
            'category': 'Denim Jacket',
          },
          {
            'number': 'CLT-002',
            'customer': 'James Brown',
            'date': '2024-01-14',
            'amount': '65',
            'status': 'Pending',
            'category': 'Summer Dress',
          },
        ];
      case BusinessCategory.electronicsStore:
        return [
          {
            'number': 'ELC-001',
            'customer': 'Alex Thompson',
            'date': '2024-01-15',
            'amount': '1,199',
            'status': 'Paid',
            'category': 'iPhone 15 Pro',
          },
          {
            'number': 'ELC-002',
            'customer': 'Maria Garcia',
            'date': '2024-01-14',
            'amount': '1,299',
            'status': 'Pending',
            'category': 'MacBook Air',
          },
        ];
      case BusinessCategory.hardwareStore:
        return [
          {
            'number': 'HRD-001',
            'customer': 'Robert Miller',
            'date': '2024-01-15',
            'amount': '129',
            'status': 'Paid',
            'category': 'Cordless Drill',
          },
          {
            'number': 'HRD-002',
            'customer': 'Jennifer Lee',
            'date': '2024-01-14',
            'amount': '15',
            'status': 'Pending',
            'category': 'Paint Roller Set',
          },
        ];
      case BusinessCategory.bakery:
        return [
          {
            'number': 'BAK-001',
            'customer': 'Amanda White',
            'date': '2024-01-15',
            'amount': '6.50',
            'status': 'Paid',
            'category': 'Sourdough Bread',
          },
          {
            'number': 'BAK-002',
            'customer': 'Chris Taylor',
            'date': '2024-01-14',
            'amount': '28',
            'status': 'Pending',
            'category': 'Chocolate Cake',
          },
        ];
      case BusinessCategory.stationeryStore:
        return [
          {
            'number': 'STN-001',
            'customer': 'Rachel Green',
            'date': '2024-01-15',
            'amount': '12',
            'status': 'Paid',
            'category': 'Notebook Set',
          },
          {
            'number': 'STN-002',
            'customer': 'Thomas Anderson',
            'date': '2024-01-14',
            'amount': '18',
            'status': 'Pending',
            'category': 'Art Supplies Kit',
          },
        ];
      case BusinessCategory.groceryStore:
        return [
          {
            'number': 'GRC-001',
            'customer': 'Patricia Moore',
            'date': '2024-01-15',
            'amount': '45',
            'status': 'Paid',
            'category': 'Organic Bananas',
          },
          {
            'number': 'GRC-002',
            'customer': 'Kevin Martin',
            'date': '2024-01-14',
            'amount': '4.50',
            'status': 'Pending',
            'category': 'Whole Milk',
          },
        ];
      default:
        return [
          {
            'number': 'INV-001',
            'customer': 'John Doe',
            'date': '2024-01-15',
            'amount': '99',
            'status': 'Paid',
            'category': 'General',
          },
        ];
    }
  }

  void _navigateToInvoiceCreation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const InvoiceCreationScreen(),
      ),
    );
  }

  void _showInvoiceDetails(Map<String, dynamic> invoice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Invoice #${invoice['number']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: ${invoice['customer']}'),
            const SizedBox(height: 8),
            Text('Date: ${invoice['date']}'),
            const SizedBox(height: 8),
            Text('Amount: \$${invoice['amount']}'),
            const SizedBox(height: 8),
            Text('Status: ${invoice['status']}'),
            if (invoice['category'] != null) ...[
              const SizedBox(height: 8),
              Text('Category: ${invoice['category']}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle edit invoice
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _getCategoryColor(),
              foregroundColor: AppTheme.snow,
            ),
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  void _handleInvoiceAction(String action, Map<String, dynamic> invoice) {
    switch (action) {
      case 'view':
        _showInvoiceDetails(invoice);
        break;
      case 'edit':
        // Handle edit
        break;
      case 'duplicate':
        // Handle duplicate
        break;
      case 'share':
        // Handle share
        break;
      case 'delete':
        _showDeleteConfirmation(invoice);
        break;
    }
  }

  void _showDeleteConfirmation(Map<String, dynamic> invoice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Invoice'),
        content: Text('Are you sure you want to delete "Invoice #${invoice['number']}"?'),
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
                  content: Text('Invoice deleted'),
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

  void _showAdvancedFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Advanced Filters'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.date_range),
              title: const Text('Date Range'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Amount Range'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Customer Filter'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Category Filter'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort Invoices'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.sort_by_alpha),
              title: const Text('Invoice Number'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.date_range),
              title: const Text('Date'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Amount'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Customer'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.flag),
              title: const Text('Status'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('More Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Export Invoices'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.print),
              title: const Text('Print All'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Invoice Analytics'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Invoice Settings'),
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
        return AppTheme.rausch;
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