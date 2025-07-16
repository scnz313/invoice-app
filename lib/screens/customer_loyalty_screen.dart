import 'package:flutter/material.dart';
import '../models/customer_loyalty.dart';
import '../utils/constants.dart';
import '../utils/logger.dart';
import '../widgets/loyalty/loyalty_summary_card.dart';
import '../widgets/loyalty/loyalty_customers_list.dart';
import '../widgets/loyalty/loyalty_transactions_list.dart';
import '../widgets/loyalty/loyalty_rules_list.dart';
import '../widgets/loyalty/loyalty_rewards_list.dart';

class CustomerLoyaltyScreen extends StatefulWidget {
  const CustomerLoyaltyScreen({super.key});

  @override
  State<CustomerLoyaltyScreen> createState() => _CustomerLoyaltyScreenState();
}

class _CustomerLoyaltyScreenState extends State<CustomerLoyaltyScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  
  List<CustomerLoyalty> _customers = [];
  List<LoyaltyTransaction> _transactions = [];
  List<LoyaltyRule> _rules = [];
  List<LoyaltyReward> _rewards = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadSampleData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSampleData() async {
    setState(() => _isLoading = true);
    
    // Simulate loading delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Load sample customers
    _customers = [
      CustomerLoyalty(
        id: '1',
        customerId: '1',
        currentPoints: 1500,
        totalPointsEarned: 2500,
        totalPointsRedeemed: 1000,
        tier: LoyaltyTier.gold,
        lastPurchaseDate: DateTime.now().subtract(const Duration(days: 2)),
        tierUpgradeDate: DateTime.now().subtract(const Duration(days: 30)),
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        updatedAt: DateTime.now(),
      ),
      CustomerLoyalty(
        id: '2',
        customerId: '2',
        currentPoints: 500,
        totalPointsEarned: 800,
        totalPointsRedeemed: 300,
        tier: LoyaltyTier.silver,
        lastPurchaseDate: DateTime.now().subtract(const Duration(days: 5)),
        tierUpgradeDate: DateTime.now().subtract(const Duration(days: 60)),
        createdAt: DateTime.now().subtract(const Duration(days: 120)),
        updatedAt: DateTime.now(),
      ),
      CustomerLoyalty(
        id: '3',
        customerId: '3',
        currentPoints: 50,
        totalPointsEarned: 100,
        totalPointsRedeemed: 50,
        tier: LoyaltyTier.bronze,
        lastPurchaseDate: DateTime.now().subtract(const Duration(days: 15)),
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
      CustomerLoyalty(
        id: '4',
        customerId: '4',
        currentPoints: 5000,
        totalPointsEarned: 8000,
        totalPointsRedeemed: 3000,
        tier: LoyaltyTier.platinum,
        lastPurchaseDate: DateTime.now().subtract(const Duration(hours: 2)),
        tierUpgradeDate: DateTime.now().subtract(const Duration(days: 15)),
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
        updatedAt: DateTime.now(),
      ),
      CustomerLoyalty(
        id: '5',
        customerId: '5',
        currentPoints: 12000,
        totalPointsEarned: 20000,
        totalPointsRedeemed: 8000,
        tier: LoyaltyTier.diamond,
        lastPurchaseDate: DateTime.now().subtract(const Duration(hours: 1)),
        tierUpgradeDate: DateTime.now().subtract(const Duration(days: 7)),
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        updatedAt: DateTime.now(),
      ),
    ];

    // Load sample transactions
    _transactions = [
      LoyaltyTransaction(
        id: '1',
        customerId: '1',
        type: LoyaltyTransactionType.earn,
        points: 150,
        description: 'Purchase of ₹1500',
        invoiceId: 'INV-001',
        purchaseAmount: 1500,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      LoyaltyTransaction(
        id: '2',
        customerId: '1',
        type: LoyaltyTransactionType.redeem,
        points: 100,
        description: 'Points redemption',
        invoiceId: 'INV-002',
        purchaseAmount: 1000,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      LoyaltyTransaction(
        id: '3',
        customerId: '2',
        type: LoyaltyTransactionType.earn,
        points: 80,
        description: 'Purchase of ₹800',
        invoiceId: 'INV-003',
        purchaseAmount: 800,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];

    // Load sample rules
    _rules = [
      LoyaltyRule(
        id: '1',
        name: 'Standard Earning',
        description: 'Earn 10 points per ₹1 spent',
        pointsPerRupee: 10,
        minimumPurchase: 0,
        maximumPoints: 10000,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        updatedAt: DateTime.now(),
      ),
      LoyaltyRule(
        id: '2',
        name: 'Weekend Bonus',
        description: '50% bonus points on weekends',
        pointsPerRupee: 15,
        minimumPurchase: 100,
        maximumPoints: 5000,
        isActive: true,
        validFrom: DateTime.now().subtract(const Duration(days: 30)),
        validUntil: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
    ];

    // Load sample rewards
    _rewards = [
      LoyaltyReward(
        id: '1',
        name: '₹10 Discount',
        description: 'Get ₹10 off on purchase of ₹100 or more',
        pointsRequired: 1000,
        discountAmount: 10,
        discountPercentage: 0,
        isPercentage: false,
        minimumPurchase: 100,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        updatedAt: DateTime.now(),
      ),
      LoyaltyReward(
        id: '2',
        name: '5% Discount',
        description: 'Get 5% off on your total purchase',
        pointsRequired: 500,
        discountAmount: 0,
        discountPercentage: 5,
        isPercentage: true,
        minimumPurchase: 50,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        updatedAt: DateTime.now(),
      ),
    ];

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Customer Loyalty',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _addCustomer,
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: _openSettings,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: 'Customers (${_customers.length})'),
            Tab(text: 'Transactions (${_transactions.length})'),
            Tab(text: 'Rules (${_rules.length})'),
            Tab(text: 'Rewards (${_rewards.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCustomersTab(),
                LoyaltyTransactionsList(transactions: _transactions),
                LoyaltyRulesList(rules: _rules),
                LoyaltyRewardsList(rewards: _rewards),
              ],
            ),
    );
  }

  Widget _buildCustomersTab() {
    final totalCustomers = _customers.length;
    final totalPoints = _customers.fold<int>(0, (sum, customer) => sum + customer.currentPoints);
    final totalValue = totalPoints * 0.01;
    final tierDistribution = <LoyaltyTier, int>{};
    for (final tier in LoyaltyTier.values) {
      tierDistribution[tier] = _customers.where((c) => c.tier == tier).length;
    }
    return Column(
      children: [
        LoyaltySummaryCard(
          totalCustomers: totalCustomers,
          totalPoints: totalPoints,
          totalValue: totalValue,
          tierDistribution: tierDistribution,
        ),
        Expanded(
          child: LoyaltyCustomersList(customers: _customers),
        ),
      ],
    );
  }

  Widget _buildLoyaltySummary() {
    final totalCustomers = _customers.length;
    final totalPoints = _customers.fold<int>(0, (sum, customer) => sum + customer.currentPoints);
    final totalValue = totalPoints * 0.01;
    
    final tierDistribution = <LoyaltyTier, int>{};
    for (final tier in LoyaltyTier.values) {
      tierDistribution[tier] = _customers.where((c) => c.tier == tier).length;
    }

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
                child: _buildSummaryCard(
                  'Total Customers',
                  totalCustomers.toString(),
                  Icons.people,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Total Points',
                  totalPoints.toString(),
                  Icons.stars,
                  Colors.amber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Total Value',
                  '₹${totalValue.toStringAsFixed(2)}',
                  Icons.attach_money,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTierDistribution(tierDistribution),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
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
              color: color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierDistribution(Map<LoyaltyTier, int> distribution) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tier Distribution',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: distribution.entries.map((entry) {
            final tier = entry.key;
            final count = entry.value;
            final percentage = _customers.isNotEmpty ? (count / _customers.length) * 100 : 0;
            
            return Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 4),
                child: Column(
                  children: [
                    Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: tier.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: tier.color.withOpacity(0.3)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(tier.icon, color: tier.color, size: 16),
                          const SizedBox(height: 2),
                          Text(
                            count.toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: tier.color,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 10,
                        color: tier.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCustomersList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _customers.length,
      itemBuilder: (context, index) {
        final customer = _customers[index];
        return _buildCustomerCard(customer);
      },
    );
  }

  Widget _buildCustomerCard(CustomerLoyalty customer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: customer.tier.color.withOpacity(0.2),
                  child: Icon(
                    customer.tier.icon,
                    color: customer.tier.color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customer ${customer.customerId}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        customer.tier.displayName,
                        style: TextStyle(
                          color: customer.tier.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
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
                      value: 'history',
                      child: Row(
                        children: [
                          Icon(Icons.history),
                          SizedBox(width: 8),
                          Text('Transaction History'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'adjust',
                      child: Row(
                        children: [
                          Icon(Icons.adjust),
                          SizedBox(width: 8),
                          Text('Adjust Points'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _editCustomer(customer);
                        break;
                      case 'history':
                        _viewTransactionHistory(customer);
                        break;
                      case 'adjust':
                        _adjustPoints(customer);
                        break;
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildCustomerStat(
                    'Current Points',
                    customer.currentPoints.toString(),
                    Icons.stars,
                    Colors.amber,
                  ),
                ),
                Expanded(
                  child: _buildCustomerStat(
                    'Points Value',
                    '₹${customer.pointsValue.toStringAsFixed(2)}',
                    Icons.attach_money,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildCustomerStat(
                    'Total Earned',
                    customer.totalPointsEarned.toString(),
                    Icons.trending_up,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildCustomerStat(
                    'Total Redeemed',
                    customer.totalPointsRedeemed.toString(),
                    Icons.trending_down,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildCustomerStat(
                    'Last Purchase',
                    _formatDate(customer.lastPurchaseDate),
                    Icons.schedule,
                    Colors.grey,
                  ),
                ),
                Expanded(
                  child: _buildCustomerStat(
                    'Tier Upgrade',
                    _formatDate(customer.tierUpgradeDate),
                    Icons.upgrade,
                    customer.tier.color,
                  ),
                ),
              ],
            ),
            if (customer.canRedeem) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Text(
                  'Can redeem up to ${customer.maxRedemptionAmount} points',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: color,
            fontSize: 12,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsTab() {
    return Column(
      children: [
        _buildTransactionFilters(),
        Expanded(
          child: _transactions.isEmpty
              ? _buildEmptyTransactionsState()
              : _buildTransactionsList(),
        ),
      ],
    );
  }

  Widget _buildTransactionFilters() {
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
            child: DropdownButtonFormField<LoyaltyTransactionType>(
              decoration: const InputDecoration(
                hintText: 'Filter by type',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All Types'),
                ),
                ...LoyaltyTransactionType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.displayName),
                  );
                }),
              ],
              onChanged: (value) {
                // TODO: Implement filtering
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search transactions...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                // TODO: Implement search
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _transactions.length,
      itemBuilder: (context, index) {
        final transaction = _transactions[index];
        return _buildTransactionCard(transaction);
      },
    );
  }

  Widget _buildTransactionCard(LoyaltyTransaction transaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: transaction.type.color.withOpacity(0.2),
          child: Icon(
            transaction.type.icon,
            color: transaction.type.color,
          ),
        ),
        title: Text(
          transaction.description ?? transaction.type.displayName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer ${transaction.customerId}'),
            Text(
              _formatDate(transaction.createdAt),
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${transaction.type == LoyaltyTransactionType.earn ? '+' : '-'}${transaction.points}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: transaction.type.color,
                fontSize: 16,
              ),
            ),
            if (transaction.purchaseAmount != null)
              Text(
                '₹${transaction.purchaseAmount!.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRulesTab() {
    return Column(
      children: [
        Container(
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
                'Loyalty Rules',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _addRule,
                icon: const Icon(Icons.add),
                label: const Text('Add Rule'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _rules.isEmpty
              ? _buildEmptyRulesState()
              : _buildRulesList(),
        ),
      ],
    );
  }

  Widget _buildRulesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _rules.length,
      itemBuilder: (context, index) {
        final rule = _rules[index];
        return _buildRuleCard(rule);
      },
    );
  }

  Widget _buildRuleCard(LoyaltyRule rule) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  rule.isActive ? Icons.check_circle : Icons.cancel,
                  color: rule.isActive ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    rule.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                PopupMenuButton(
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
                    PopupMenuItem(
                      value: 'toggle',
                      child: Row(
                        children: [
                          Icon(rule.isActive ? Icons.pause : Icons.play_arrow),
                          const SizedBox(width: 8),
                          Text(rule.isActive ? 'Deactivate' : 'Activate'),
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
                        _editRule(rule);
                        break;
                      case 'toggle':
                        _toggleRule(rule);
                        break;
                      case 'delete':
                        _deleteRule(rule);
                        break;
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              rule.description,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildRuleStat(
                    'Points/₹',
                    rule.pointsPerRupee.toString(),
                    Icons.stars,
                    Colors.amber,
                  ),
                ),
                Expanded(
                  child: _buildRuleStat(
                    'Min Purchase',
                    '₹${rule.minimumPurchase.toStringAsFixed(2)}',
                    Icons.attach_money,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildRuleStat(
                    'Max Points',
                    rule.maximumPoints.toString(),
                    Icons.trending_up,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            if (rule.validFrom != null || rule.validUntil != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (rule.validFrom != null) ...[
                    Expanded(
                      child: Text(
                        'From: ${_formatDate(rule.validFrom!)}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                  if (rule.validUntil != null) ...[
                    Expanded(
                      child: Text(
                        'Until: ${_formatDate(rule.validUntil!)}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRuleStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: color,
            fontSize: 12,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildRewardsTab() {
    return Column(
      children: [
        Container(
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
                'Loyalty Rewards',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _addReward,
                icon: const Icon(Icons.add),
                label: const Text('Add Reward'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _rewards.isEmpty
              ? _buildEmptyRewardsState()
              : _buildRewardsList(),
        ),
      ],
    );
  }

  Widget _buildRewardsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _rewards.length,
      itemBuilder: (context, index) {
        final reward = _rewards[index];
        return _buildRewardCard(reward);
      },
    );
  }

  Widget _buildRewardCard(LoyaltyReward reward) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  reward.isActive ? Icons.card_giftcard : Icons.cancel,
                  color: reward.isActive ? Colors.purple : Colors.red,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    reward.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                PopupMenuButton(
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
                    PopupMenuItem(
                      value: 'toggle',
                      child: Row(
                        children: [
                          Icon(reward.isActive ? Icons.pause : Icons.play_arrow),
                          const SizedBox(width: 8),
                          Text(reward.isActive ? 'Deactivate' : 'Activate'),
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
                        _editReward(reward);
                        break;
                      case 'toggle':
                        _toggleReward(reward);
                        break;
                      case 'delete':
                        _deleteReward(reward);
                        break;
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              reward.description,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildRewardStat(
                    'Points Required',
                    reward.pointsRequired.toString(),
                    Icons.stars,
                    Colors.amber,
                  ),
                ),
                Expanded(
                  child: _buildRewardStat(
                    'Discount',
                    reward.isPercentage 
                        ? '${reward.discountPercentage}%'
                        : '₹${reward.discountAmount.toStringAsFixed(2)}',
                    Icons.discount,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildRewardStat(
                    'Min Purchase',
                    '₹${reward.minimumPurchase.toStringAsFixed(2)}',
                    Icons.attach_money,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            if (reward.validFrom != null || reward.validUntil != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (reward.validFrom != null) ...[
                    Expanded(
                      child: Text(
                        'From: ${_formatDate(reward.validFrom!)}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                  if (reward.validUntil != null) ...[
                    Expanded(
                      child: Text(
                        'Until: ${_formatDate(reward.validUntil!)}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRewardStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: color,
            fontSize: 12,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  // Empty state widgets
  Widget _buildEmptyCustomersState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No customers yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add customers to start building your loyalty program',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTransactionsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Customer purchases will appear here',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyRulesState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rule,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No loyalty rules yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create rules to define how customers earn points',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyRewardsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.card_giftcard,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No loyalty rewards yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create rewards for customers to redeem their points',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  // Event handlers
  void _addCustomer() {
    // TODO: Implement add customer
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add customer functionality coming soon')),
    );
  }

  void _editCustomer(CustomerLoyalty customer) {
    // TODO: Implement edit customer
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit customer functionality coming soon')),
    );
  }

  void _viewTransactionHistory(CustomerLoyalty customer) {
    // TODO: Implement view transaction history
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaction history functionality coming soon')),
    );
  }

  void _adjustPoints(CustomerLoyalty customer) {
    // TODO: Implement adjust points
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Adjust points functionality coming soon')),
    );
  }

  void _openSettings() {
    // TODO: Implement settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings functionality coming soon')),
    );
  }

  void _addRule() {
    // TODO: Implement add rule
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add rule functionality coming soon')),
    );
  }

  void _editRule(LoyaltyRule rule) {
    // TODO: Implement edit rule
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit rule functionality coming soon')),
    );
  }

  void _toggleRule(LoyaltyRule rule) {
    // TODO: Implement toggle rule
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Toggle rule functionality coming soon')),
    );
  }

  void _deleteRule(LoyaltyRule rule) {
    // TODO: Implement delete rule
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Delete rule functionality coming soon')),
    );
  }

  void _addReward() {
    // TODO: Implement add reward
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add reward functionality coming soon')),
    );
  }

  void _editReward(LoyaltyReward reward) {
    // TODO: Implement edit reward
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit reward functionality coming soon')),
    );
  }

  void _toggleReward(LoyaltyReward reward) {
    // TODO: Implement toggle reward
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Toggle reward functionality coming soon')),
    );
  }

  void _deleteReward(LoyaltyReward reward) {
    // TODO: Implement delete reward
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Delete reward functionality coming soon')),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }
}