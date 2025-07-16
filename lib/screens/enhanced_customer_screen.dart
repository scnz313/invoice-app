import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../models/business_category.dart';
import '../models/customer_loyalty.dart';
import '../theme/app_theme.dart';

class EnhancedCustomerScreen extends StatefulWidget {
  const EnhancedCustomerScreen({super.key});

  @override
  State<EnhancedCustomerScreen> createState() => _EnhancedCustomerScreenState();
}

class _EnhancedCustomerScreenState extends State<EnhancedCustomerScreen> {
  late BusinessCategory _selectedCategory;
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedFilter = 'All';
  int _selectedTabIndex = 0;

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

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppTheme.ghost,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            _buildSearchAndFilter(),
            _buildTabBar(),
            Expanded(
              child: _buildTabContent(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddCustomerDialog(),
          backgroundColor: _getCategoryColor(),
          foregroundColor: AppTheme.snow,
          child: const Icon(Icons.person_add),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        '${_selectedCategory.displayName} Customers',
        style: AppTheme.headline4.copyWith(color: AppTheme.snow),
      ),
      backgroundColor: _getCategoryColor(),
      foregroundColor: AppTheme.snow,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.analytics),
          onPressed: () => _showCustomerAnalytics(),
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
              hintText: 'Search customers...',
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
        return ['All', 'VIP', 'Regular', 'New', 'High Value'];
      case BusinessCategory.restaurantCafe:
        return ['All', 'Regular', 'VIP', 'Takeaway', 'Dine-in'];
      case BusinessCategory.clothingStore:
        return ['All', 'Fashion Forward', 'Classic', 'Seasonal', 'Bulk Buyer'];
      case BusinessCategory.electronicsStore:
        return ['All', 'Tech Savvy', 'Business', 'Student', 'Gaming'];
      case BusinessCategory.hardwareStore:
        return ['All', 'Contractor', 'DIY', 'Professional', 'Bulk Buyer'];
      case BusinessCategory.bakery:
        return ['All', 'Regular', 'Custom Orders', 'Wholesale', 'Event Planner'];
      case BusinessCategory.stationeryStore:
        return ['All', 'Student', 'Teacher', 'Business', 'Artist'];
      case BusinessCategory.groceryStore:
        return ['All', 'Loyalty Member', 'Regular', 'Bulk Buyer', 'Organic'];
      default:
        return ['All', 'Regular', 'VIP', 'New'];
    }
  }

  Widget _buildTabBar() {
    return Container(
      color: AppTheme.snow,
      child: TabBar(
        labelColor: _getCategoryColor(),
        unselectedLabelColor: AppTheme.foggy,
        indicatorColor: _getCategoryColor(),
        tabs: const [
          Tab(text: 'All Customers'),
          Tab(text: 'Loyalty Program'),
          Tab(text: 'Analytics'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      children: [
        _buildCustomerList(),
        _buildLoyaltyProgram(),
        _buildCustomerAnalytics(),
      ],
    );
  }

  Widget _buildCustomerList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _getSampleCustomers().length,
      itemBuilder: (context, index) {
        final customer = _getSampleCustomers()[index];
        return _buildCustomerCard(customer);
      },
    );
  }

  Widget _buildCustomerCard(Map<String, dynamic> customer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getCategoryColor().withOpacity(0.1),
          child: Text(
            customer['name'][0].toUpperCase(),
            style: TextStyle(
              color: _getCategoryColor(),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          customer['name'],
          style: AppTheme.body1.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(customer['email'], style: AppTheme.body2),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  _getCustomerTypeIcon(customer['type']),
                  size: 16,
                  color: _getCategoryColor(),
                ),
                const SizedBox(width: 4),
                Text(
                  customer['type'],
                  style: AppTheme.caption.copyWith(
                    color: _getCategoryColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${customer['orders']} orders',
                  style: AppTheme.caption,
                ),
              ],
            ),
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
                  Text('View Details'),
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
              value: 'history',
              child: Row(
                children: [
                  Icon(Icons.history),
                  SizedBox(width: 8),
                  Text('Order History'),
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
          onSelected: (value) => _handleCustomerAction(value, customer),
        ),
        onTap: () => _showCustomerDetails(customer),
      ),
    );
  }

  IconData _getCustomerTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'vip':
        return Icons.star;
      case 'regular':
        return Icons.person;
      case 'new':
        return Icons.fiber_new;
      case 'loyalty member':
        return Icons.card_membership;
      case 'contractor':
        return Icons.build;
      case 'student':
        return Icons.school;
      case 'business':
        return Icons.business;
      default:
        return Icons.person;
    }
  }

  List<Map<String, dynamic>> _getSampleCustomers() {
    switch (_selectedCategory) {
      case BusinessCategory.jewelryStore:
        return [
          {
            'name': 'Sarah Johnson',
            'email': 'sarah.j@email.com',
            'type': 'VIP',
            'orders': 15,
            'totalSpent': 12500,
          },
          {
            'name': 'Michael Chen',
            'email': 'mchen@email.com',
            'type': 'Regular',
            'orders': 8,
            'totalSpent': 3200,
          },
        ];
      case BusinessCategory.restaurantCafe:
        return [
          {
            'name': 'Emma Davis',
            'email': 'emma.d@email.com',
            'type': 'Regular',
            'orders': 25,
            'totalSpent': 450,
          },
          {
            'name': 'David Wilson',
            'email': 'dwilson@email.com',
            'type': 'Takeaway',
            'orders': 12,
            'totalSpent': 180,
          },
        ];
      case BusinessCategory.clothingStore:
        return [
          {
            'name': 'Lisa Rodriguez',
            'email': 'lisa.r@email.com',
            'type': 'Fashion Forward',
            'orders': 18,
            'totalSpent': 1200,
          },
          {
            'name': 'James Brown',
            'email': 'jbrown@email.com',
            'type': 'Classic',
            'orders': 6,
            'totalSpent': 450,
          },
        ];
      case BusinessCategory.electronicsStore:
        return [
          {
            'name': 'Alex Thompson',
            'email': 'alex.t@email.com',
            'type': 'Tech Savvy',
            'orders': 10,
            'totalSpent': 3500,
          },
          {
            'name': 'Maria Garcia',
            'email': 'mgarcia@email.com',
            'type': 'Business',
            'orders': 5,
            'totalSpent': 2800,
          },
        ];
      case BusinessCategory.hardwareStore:
        return [
          {
            'name': 'Robert Miller',
            'email': 'rmiller@email.com',
            'type': 'Contractor',
            'orders': 22,
            'totalSpent': 1800,
          },
          {
            'name': 'Jennifer Lee',
            'email': 'jlee@email.com',
            'type': 'DIY',
            'orders': 8,
            'totalSpent': 320,
          },
        ];
      case BusinessCategory.bakery:
        return [
          {
            'name': 'Amanda White',
            'email': 'awhite@email.com',
            'type': 'Regular',
            'orders': 30,
            'totalSpent': 280,
          },
          {
            'name': 'Chris Taylor',
            'email': 'ctaylor@email.com',
            'type': 'Custom Orders',
            'orders': 5,
            'totalSpent': 150,
          },
        ];
      case BusinessCategory.stationeryStore:
        return [
          {
            'name': 'Rachel Green',
            'email': 'rgreen@email.com',
            'type': 'Student',
            'orders': 15,
            'totalSpent': 120,
          },
          {
            'name': 'Thomas Anderson',
            'email': 'tanderson@email.com',
            'type': 'Teacher',
            'orders': 12,
            'totalSpent': 200,
          },
        ];
      case BusinessCategory.groceryStore:
        return [
          {
            'name': 'Patricia Moore',
            'email': 'pmoore@email.com',
            'type': 'Loyalty Member',
            'orders': 45,
            'totalSpent': 850,
          },
          {
            'name': 'Kevin Martin',
            'email': 'kmartin@email.com',
            'type': 'Regular',
            'orders': 20,
            'totalSpent': 320,
          },
        ];
      default:
        return [
          {
            'name': 'John Doe',
            'email': 'john@email.com',
            'type': 'Regular',
            'orders': 5,
            'totalSpent': 250,
          },
        ];
    }
  }

  Widget _buildLoyaltyProgram() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildLoyaltyStats(),
          const SizedBox(height: 24),
          _buildLoyaltyTiers(),
          const SizedBox(height: 24),
          _buildLoyaltyRewards(),
        ],
      ),
    );
  }

  Widget _buildLoyaltyStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Loyalty Program Stats',
              style: AppTheme.headline4,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('Total Members', '156', Icons.people),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem('Active Members', '89', Icons.person),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem('Points Issued', '12,450', Icons.stars),
                ),
              ],
            ),
          ],
        ),
      ),
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

  Widget _buildLoyaltyTiers() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Loyalty Tiers',
              style: AppTheme.headline4,
            ),
            const SizedBox(height: 16),
            _buildTierCard('Bronze', '0-100 points', '5% discount', Icons.star_border),
            _buildTierCard('Silver', '101-500 points', '10% discount', Icons.star_half),
            _buildTierCard('Gold', '501-1000 points', '15% discount', Icons.star),
            _buildTierCard('Platinum', '1000+ points', '20% discount', Icons.stars),
          ],
        ),
      ),
    );
  }

  Widget _buildTierCard(String tier, String requirement, String benefit, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.ghost,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getCategoryColor().withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: _getCategoryColor(), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tier, style: AppTheme.body1.copyWith(fontWeight: FontWeight.w600)),
                Text(requirement, style: AppTheme.caption),
              ],
            ),
          ),
          Text(benefit, style: AppTheme.body2.copyWith(color: _getCategoryColor())),
        ],
      ),
    );
  }

  Widget _buildLoyaltyRewards() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available Rewards',
              style: AppTheme.headline4,
            ),
            const SizedBox(height: 16),
            _buildRewardCard('Free Item', '500 points', 'Get any item under \$25'),
            _buildRewardCard('Discount Voucher', '200 points', '20% off next purchase'),
            _buildRewardCard('Birthday Gift', '100 points', 'Special birthday offer'),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardCard(String reward, String points, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.ghost,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getCategoryColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.card_giftcard, color: _getCategoryColor(), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reward, style: AppTheme.body1.copyWith(fontWeight: FontWeight.w600)),
                Text(description, style: AppTheme.caption),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getCategoryColor(),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              points,
              style: AppTheme.caption.copyWith(color: AppTheme.snow),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerAnalytics() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildAnalyticsOverview(),
          const SizedBox(height: 24),
          _buildCustomerSegments(),
          const SizedBox(height: 24),
          _buildTopCustomers(),
        ],
      ),
    );
  }

  Widget _buildAnalyticsOverview() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer Analytics',
              style: AppTheme.headline4,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildAnalyticsCard('Total Customers', '234', '+12%', Icons.people),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildAnalyticsCard('New This Month', '18', '+8%', Icons.person_add),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildAnalyticsCard('Avg. Order Value', '\$45', '+5%', Icons.attach_money),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildAnalyticsCard('Retention Rate', '78%', '+3%', Icons.trending_up),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsCard(String title, String value, String change, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getCategoryColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getCategoryColor().withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _getCategoryColor(), size: 16),
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
              color: _getCategoryColor(),
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

  Widget _buildCustomerSegments() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer Segments',
              style: AppTheme.headline4,
            ),
            const SizedBox(height: 16),
            _buildSegmentItem('VIP Customers', '15%', 'High value, frequent buyers'),
            _buildSegmentItem('Regular Customers', '45%', 'Consistent, moderate spending'),
            _buildSegmentItem('Occasional Buyers', '30%', 'Infrequent, low spending'),
            _buildSegmentItem('New Customers', '10%', 'Recently acquired'),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentItem(String segment, String percentage, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(segment, style: AppTheme.body2.copyWith(fontWeight: FontWeight.w600)),
                Text(description, style: AppTheme.caption),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              percentage,
              style: AppTheme.body2.copyWith(
                color: _getCategoryColor(),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopCustomers() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Customers',
              style: AppTheme.headline4,
            ),
            const SizedBox(height: 16),
            _buildTopCustomerItem('Sarah Johnson', '\$12,500', '15 orders'),
            _buildTopCustomerItem('Michael Chen', '\$8,200', '12 orders'),
            _buildTopCustomerItem('Emma Davis', '\$6,800', '18 orders'),
            _buildTopCustomerItem('David Wilson', '\$5,400', '10 orders'),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCustomerItem(String name, String total, String orders) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: _getCategoryColor().withOpacity(0.1),
            child: Text(
              name[0],
              style: TextStyle(
                color: _getCategoryColor(),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTheme.body2.copyWith(fontWeight: FontWeight.w600)),
                Text(orders, style: AppTheme.caption),
              ],
            ),
          ),
          Text(
            total,
            style: AppTheme.body2.copyWith(
              color: _getCategoryColor(),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCustomerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add ${_selectedCategory.displayName} Customer'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
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
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Customer added successfully'),
                  backgroundColor: _getCategoryColor(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _getCategoryColor(),
              foregroundColor: AppTheme.snow,
            ),
            child: const Text('Add Customer'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySpecificFields() {
    switch (_selectedCategory) {
      case BusinessCategory.jewelryStore:
        return Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Preferred Metal Type',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Budget Range',
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
                labelText: 'Dietary Preferences',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Favorite Dishes',
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
                labelText: 'Preferred Size',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Style Preference',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _showCustomerDetails(Map<String, dynamic> customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(customer['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${customer['email']}'),
            const SizedBox(height: 8),
            Text('Type: ${customer['type']}'),
            const SizedBox(height: 8),
            Text('Orders: ${customer['orders']}'),
            const SizedBox(height: 8),
            Text('Total Spent: \$${customer['totalSpent']}'),
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

  void _handleCustomerAction(String action, Map<String, dynamic> customer) {
    switch (action) {
      case 'view':
        _showCustomerDetails(customer);
        break;
      case 'edit':
        // Handle edit
        break;
      case 'history':
        // Handle order history
        break;
      case 'delete':
        _showDeleteConfirmation(customer);
        break;
    }
  }

  void _showDeleteConfirmation(Map<String, dynamic> customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Customer'),
        content: Text('Are you sure you want to delete "${customer['name']}"?'),
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
                  content: Text('Customer deleted'),
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

  void _showCustomerAnalytics() {
    // Navigate to detailed analytics
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
              title: const Text('Export Customer Data'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.upload),
              title: const Text('Import Customers'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Customer Settings'),
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