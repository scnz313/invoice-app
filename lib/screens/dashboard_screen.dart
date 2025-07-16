import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/enhanced_invoice_provider.dart';
import '../providers/settings_provider.dart';
import '../models/enhanced_invoice.dart';
import '../models/business_category.dart';
import '../utils/theme.dart';
import '../utils/logger.dart';
import '../widgets/airbnb_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/recent_invoice_card.dart';
import '../widgets/quick_action_button.dart';
import 'grocery_invoice_creation_screen.dart';
import 'inventory_management_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AirbnbTheme.backgroundColor,
      body: Consumer2<EnhancedInvoiceProvider, SettingsProvider>(
        builder: (context, invoiceProvider, settingsProvider, child) {
          return CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                backgroundColor: AirbnbTheme.primaryColor,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  title: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'Dashboard',
                      style: AirbnbTheme.headlineStyle.copyWith(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AirbnbTheme.primaryColor,
                          AirbnbTheme.primaryColor.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                    onPressed: () {
                      // TODO: Implement notifications
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, color: Colors.white),
                    onPressed: () {
                      // TODO: Navigate to settings
                    },
                  ),
                ],
              ),

              // Dashboard Content
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Welcome Section
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildWelcomeSection(settingsProvider),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Statistics Cards
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildStatisticsSection(invoiceProvider),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Revenue Chart
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildRevenueChart(invoiceProvider),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Quick Actions
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildQuickActionsSection(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Recent Invoices
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildRecentInvoicesSection(invoiceProvider),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Business Insights
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildBusinessInsightsSection(invoiceProvider),
                      ),
                    ),

                    const SizedBox(height: 100), // Bottom padding
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWelcomeSection(SettingsProvider settingsProvider) {
    final businessCategory = settingsProvider.selectedBusinessCategory;
    final businessName = settingsProvider.businessName ?? 'Your Business';

    return AirbnbCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: businessCategory?.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  businessCategory?.icon ?? Icons.business,
                  color: businessCategory?.color ?? AirbnbTheme.primaryColor,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back!',
                      style: AirbnbTheme.bodyStyle.copyWith(
                        color: AirbnbTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      businessName,
                      style: AirbnbTheme.headlineStyle.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (businessCategory != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        businessCategory.displayName,
                        style: AirbnbTheme.bodyStyle.copyWith(
                          color: businessCategory.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Here\'s what\'s happening with your business today.',
            style: AirbnbTheme.bodyStyle.copyWith(
              color: AirbnbTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(EnhancedInvoiceProvider invoiceProvider) {
    return FutureBuilder<Map<String, dynamic>>(
      future: invoiceProvider.getInvoiceStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildStatisticsLoading();
        }

        if (snapshot.hasError) {
          return _buildStatisticsError();
        }

        final stats = snapshot.data ?? {};
        final totalInvoices = stats['totalInvoices'] ?? 0;
        final totalRevenue = stats['totalRevenue'] ?? 0.0;
        final pendingInvoices = stats['pendingInvoices'] ?? 0;
        final overdueInvoices = stats['overdueInvoices'] ?? 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistics',
              style: AirbnbTheme.headlineStyle.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                StatCard(
                  title: 'Total Invoices',
                  value: totalInvoices.toString(),
                  icon: Icons.receipt_long,
                  color: AirbnbTheme.primaryColor,
                  trend: '+12%',
                  trendUp: true,
                ),
                StatCard(
                  title: 'Total Revenue',
                  value: '₹${totalRevenue.toStringAsFixed(0)}',
                  icon: Icons.trending_up,
                  color: Colors.green,
                  trend: '+8%',
                  trendUp: true,
                ),
                StatCard(
                  title: 'Pending',
                  value: pendingInvoices.toString(),
                  icon: Icons.pending,
                  color: Colors.orange,
                  trend: '-5%',
                  trendUp: false,
                ),
                StatCard(
                  title: 'Overdue',
                  value: overdueInvoices.toString(),
                  icon: Icons.warning,
                  color: Colors.red,
                  trend: '+2%',
                  trendUp: false,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatisticsLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistics',
          style: AirbnbTheme.headlineStyle.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: List.generate(4, (index) => _buildStatCardSkeleton()),
        ),
      ],
    );
  }

  Widget _buildStatisticsError() {
    return AirbnbCard(
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load statistics',
            style: AirbnbTheme.bodyStyle.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              setState(() {});
            },
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCardSkeleton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: 60,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart(EnhancedInvoiceProvider invoiceProvider) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: invoiceProvider.getMonthlyRevenue(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildChartSkeleton();
        }

        if (snapshot.hasError || snapshot.data == null) {
          return _buildChartError();
        }

        final data = snapshot.data!;
        if (data.isEmpty) {
          return _buildEmptyChart();
        }

        return AirbnbCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Monthly Revenue',
                style: AirbnbTheme.headlineStyle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval: 1000,
                      verticalInterval: 1,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey[300],
                          strokeWidth: 1,
                        );
                      },
                      getDrawingVerticalLine: (value) {
                        return FlLine(
                          color: Colors.grey[300],
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: 1,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            if (value.toInt() >= 0 && value.toInt() < data.length) {
                              final month = data[value.toInt()]['month'] as String;
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Text(
                                  month.substring(5), // Show only month
                                  style: AirbnbTheme.bodyStyle.copyWith(
                                    fontSize: 12,
                                    color: AirbnbTheme.textSecondary,
                                  ),
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1000,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                '₹${value.toInt()}',
                                style: AirbnbTheme.bodyStyle.copyWith(
                                  fontSize: 12,
                                  color: AirbnbTheme.textSecondary,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    minX: 0,
                    maxX: (data.length - 1).toDouble(),
                    minY: 0,
                    maxY: data.fold<double>(0, (max, item) => 
                      (item['revenue'] as double) > max ? (item['revenue'] as double) : max
                    ) * 1.2,
                    lineBarsData: [
                      LineChartBarData(
                        spots: data.asMap().entries.map((entry) {
                          return FlSpot(entry.key.toDouble(), entry.value['revenue'] as double);
                        }).toList(),
                        isCurved: true,
                        gradient: LinearGradient(
                          colors: [
                            AirbnbTheme.primaryColor,
                            AirbnbTheme.primaryColor.withOpacity(0.5),
                          ],
                        ),
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: AirbnbTheme.primaryColor,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              AirbnbTheme.primaryColor.withOpacity(0.3),
                              AirbnbTheme.primaryColor.withOpacity(0.1),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChartSkeleton() {
    return AirbnbCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 150,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartError() {
    return AirbnbCard(
      child: Column(
        children: [
          Icon(
            Icons.bar_chart,
            color: Colors.grey[400],
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'No revenue data available',
            style: AirbnbTheme.bodyStyle.copyWith(
              color: AirbnbTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChart() {
    return AirbnbCard(
      child: Column(
        children: [
          Icon(
            Icons.bar_chart,
            color: Colors.grey[400],
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'No revenue data available',
            style: AirbnbTheme.bodyStyle.copyWith(
              color: AirbnbTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        final businessCategory = settingsProvider.selectedBusinessCategory;
        final isGroceryStore = businessCategory == BusinessCategory.groceryStore;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: AirbnbTheme.headlineStyle.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                QuickActionButton(
                  title: isGroceryStore ? 'Scan & Invoice' : 'New Invoice',
                  icon: isGroceryStore ? Icons.qr_code_scanner : Icons.add_circle_outline,
                  color: AirbnbTheme.primaryColor,
                  onTap: () {
                    if (isGroceryStore) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GroceryInvoiceCreationScreen(),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const InvoiceCreationScreen(),
                        ),
                      );
                    }
                  },
                ),
                QuickActionButton(
                  title: 'Add Customer',
                  icon: Icons.person_add_outlined,
                  color: Colors.green,
                  onTap: () {
                    // TODO: Navigate to customer creation
                  },
                ),
                QuickActionButton(
                  title: isGroceryStore ? 'Inventory' : 'Add Product',
                  icon: isGroceryStore ? Icons.inventory : Icons.inventory_2_outlined,
                  color: Colors.orange,
                  onTap: () {
                    if (isGroceryStore) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const InventoryManagementScreen(),
                        ),
                      );
                    } else {
                      // TODO: Navigate to product creation
                    }
                  },
                ),
                QuickActionButton(
                  title: 'View Reports',
                  icon: Icons.analytics_outlined,
                  color: Colors.purple,
                  onTap: () {
                    // TODO: Navigate to reports
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecentInvoicesSection(EnhancedInvoiceProvider invoiceProvider) {
    final recentInvoices = invoiceProvider.invoices.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Invoices',
              style: AirbnbTheme.headlineStyle.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to invoice list
              },
              child: Text(
                'View All',
                style: AirbnbTheme.bodyStyle.copyWith(
                  color: AirbnbTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (recentInvoices.isEmpty)
          AirbnbCard(
            child: Column(
              children: [
                Icon(
                  Icons.receipt_long,
                  color: Colors.grey[400],
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'No invoices yet',
                  style: AirbnbTheme.bodyStyle.copyWith(
                    color: AirbnbTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create your first invoice to get started',
                  style: AirbnbTheme.bodyStyle.copyWith(
                    color: AirbnbTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )
        else
          ...recentInvoices.map((invoice) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: RecentInvoiceCard(invoice: invoice),
          )),
      ],
    );
  }

  Widget _buildBusinessInsightsSection(EnhancedInvoiceProvider invoiceProvider) {
    return AirbnbCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Business Insights',
            style: AirbnbTheme.headlineStyle.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildInsightItem(
            icon: Icons.trending_up,
            title: 'Revenue Growth',
            description: 'Your revenue has increased by 15% this month',
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          _buildInsightItem(
            icon: Icons.people,
            title: 'Customer Growth',
            description: 'You\'ve added 8 new customers this week',
            color: AirbnbTheme.primaryColor,
          ),
          const SizedBox(height: 16),
          _buildInsightItem(
            icon: Icons.schedule,
            title: 'Payment Time',
            description: 'Average payment time is 12 days',
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AirbnbTheme.bodyStyle.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: AirbnbTheme.bodyStyle.copyWith(
                  color: AirbnbTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}