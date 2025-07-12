import 'package:flutter/material.dart';
import '../models/invoice.dart';
import '../models/invoice_item.dart';
import '../utils/currency_helper.dart';

class JewelryDashboard extends StatelessWidget {
  final List<Invoice> invoices;
  final List<Client> clients;

  const JewelryDashboard({
    super.key,
    required this.invoices,
    required this.clients,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 24),
          _buildOverviewCards(context),
          const SizedBox(height: 24),
          _buildJewelryTypeAnalytics(context),
          const SizedBox(height: 24),
          _buildMetalTypeAnalytics(context),
          const SizedBox(height: 24),
          _buildStoneAnalytics(context),
          const SizedBox(height: 24),
          _buildExchangeAnalytics(context),
          const SizedBox(height: 24),
          _buildPaymentAnalytics(context),
          const SizedBox(height: 24),
          _buildRecentTransactions(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      elevation: 0,
      color: colorScheme.primaryContainer.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.dashboard_outlined,
                size: 32,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jewelry Shop Dashboard',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Comprehensive analytics for your jewelry business',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards(BuildContext context) {
    final totalSales = _calculateTotalSales();
    final totalInvoices = invoices.length;
    final totalClients = clients.length;
    final averageOrderValue = totalInvoices > 0 ? totalSales / totalInvoices : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
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
            _buildOverviewCard(
              context,
              'Total Sales',
              CurrencyHelper.formatInvoiceAmount(totalSales),
              Icons.attach_money,
              Colors.green,
            ),
            _buildOverviewCard(
              context,
              'Total Invoices',
              totalInvoices.toString(),
              Icons.receipt_long,
              Colors.blue,
            ),
            _buildOverviewCard(
              context,
              'Total Clients',
              totalClients.toString(),
              Icons.people,
              Colors.orange,
            ),
            _buildOverviewCard(
              context,
              'Avg Order Value',
              CurrencyHelper.formatInvoiceAmount(averageOrderValue),
              Icons.trending_up,
              Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOverviewCard(BuildContext context, String title, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Icon(Icons.trending_up, color: color, size: 16),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJewelryTypeAnalytics(BuildContext context) {
    final jewelryTypeStats = _calculateJewelryTypeStats();
    
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.category_outlined, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Sales by Jewelry Type',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...jewelryTypeStats.entries.map((entry) {
              final type = entry.key;
              final stats = entry.value;
              final percentage = _calculateTotalSales() > 0 ? (stats['sales'] / _calculateTotalSales()) * 100 : 0.0;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            type,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            stats['count'].toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            CurrencyHelper.formatInvoiceAmount(stats['sales']),
                            textAlign: TextAlign.end,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMetalTypeAnalytics(BuildContext context) {
    final metalTypeStats = _calculateMetalTypeStats();
    
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.metal_outlined, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Sales by Metal Type',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...metalTypeStats.entries.map((entry) {
              final type = entry.key;
              final stats = entry.value;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        type,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        stats['count'].toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        CurrencyHelper.formatInvoiceAmount(stats['sales']),
                        textAlign: TextAlign.end,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStoneAnalytics(BuildContext context) {
    final stoneStats = _calculateStoneStats();
    
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.diamond, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Stone Analytics',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStoneStatCard(
                    context,
                    'Items with Stones',
                    stoneStats['withStones'].toString(),
                    Icons.gem,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStoneStatCard(
                    context,
                    'Items without Stones',
                    stoneStats['withoutStones'].toString(),
                    Icons.circle_outlined,
                    Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (stoneStats['stoneTypes'].isNotEmpty) ...[
              Text(
                'Popular Stone Types',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...stoneStats['stoneTypes'].entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(entry.key),
                      ),
                      Text(
                        '${entry.value} items',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStoneStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
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
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildExchangeAnalytics(BuildContext context) {
    final exchangeStats = _calculateExchangeStats();
    
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.swap_horiz_outlined, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Exchange Analytics',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildExchangeStatCard(
                    context,
                    'Exchange Transactions',
                    exchangeStats['exchangeCount'].toString(),
                    Icons.swap_horiz,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildExchangeStatCard(
                    context,
                    'Total Exchange Value',
                    CurrencyHelper.formatInvoiceAmount(exchangeStats['totalExchangeValue']),
                    Icons.currency_exchange,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (exchangeStats['exchangePercentage'] > 0)
              Text(
                '${exchangeStats['exchangePercentage'].toStringAsFixed(1)}% of transactions involve exchanges',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExchangeStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
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
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentAnalytics(BuildContext context) {
    final paymentStats = _calculatePaymentStats();
    
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.payment_outlined, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Payment Analytics',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...paymentStats.entries.map((entry) {
              final method = entry.key;
              final stats = entry.value;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        method,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        stats['count'].toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        CurrencyHelper.formatInvoiceAmount(stats['amount']),
                        textAlign: TextAlign.end,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildPaymentStatCard(
                    context,
                    'EMI Transactions',
                    paymentStats['emiCount'].toString(),
                    Icons.credit_card,
                    Colors.purple,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPaymentStatCard(
                    context,
                    'Avg EMI Amount',
                    CurrencyHelper.formatInvoiceAmount(paymentStats['avgEMIAmount']),
                    Icons.trending_up,
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
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
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(BuildContext context) {
    final recentInvoices = invoices.take(5).toList();
    
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Recent Transactions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (recentInvoices.isEmpty)
              Center(
                child: Text(
                  'No recent transactions',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              )
            else
              ...recentInvoices.map((invoice) => _buildTransactionItem(context, invoice)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, Invoice invoice) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getStatusColor(invoice.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.receipt_long,
              color: _getStatusColor(invoice.status),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invoice.invoiceNumber,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  invoice.client.name,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyHelper.formatInvoiceAmount(invoice.finalAmount),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getStatusColor(invoice.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  invoice.status.name.toUpperCase(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _getStatusColor(invoice.status),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper methods for calculations
  double _calculateTotalSales() {
    return invoices.fold(0.0, (sum, invoice) => sum + invoice.finalAmount);
  }

  Map<String, Map<String, dynamic>> _calculateJewelryTypeStats() {
    final stats = <String, Map<String, dynamic>>{};
    
    for (final invoice in invoices) {
      for (final item in invoice.items) {
        if (item.jewelryType != null) {
          final type = item.jewelryTypeDisplay;
          if (!stats.containsKey(type)) {
            stats[type] = {'count': 0, 'sales': 0.0};
          }
          stats[type]!['count'] = (stats[type]!['count'] as int) + item.quantity;
          stats[type]!['sales'] = (stats[type]!['sales'] as double) + item.total;
        }
      }
    }
    
    return stats;
  }

  Map<String, Map<String, dynamic>> _calculateMetalTypeStats() {
    final stats = <String, Map<String, dynamic>>{};
    
    for (final invoice in invoices) {
      for (final item in invoice.items) {
        if (item.metalType != null) {
          final type = item.metalTypeDisplay;
          if (!stats.containsKey(type)) {
            stats[type] = {'count': 0, 'sales': 0.0};
          }
          stats[type]!['count'] = (stats[type]!['count'] as int) + item.quantity;
          stats[type]!['sales'] = (stats[type]!['sales'] as double) + item.total;
        }
      }
    }
    
    return stats;
  }

  Map<String, dynamic> _calculateStoneStats() {
    int withStones = 0;
    int withoutStones = 0;
    final stoneTypes = <String, int>{};
    
    for (final invoice in invoices) {
      for (final item in invoice.items) {
        if (item.stoneDetails != null) {
          withStones += item.quantity;
          final stoneType = item.stoneTypeDisplay;
          stoneTypes[stoneType] = (stoneTypes[stoneType] ?? 0) + item.quantity;
        } else {
          withoutStones += item.quantity;
        }
      }
    }
    
    return {
      'withStones': withStones,
      'withoutStones': withoutStones,
      'stoneTypes': stoneTypes,
    };
  }

  Map<String, dynamic> _calculateExchangeStats() {
    int exchangeCount = 0;
    double totalExchangeValue = 0.0;
    
    for (final invoice in invoices) {
      if (invoice.isExchange) {
        exchangeCount++;
        totalExchangeValue += invoice.exchangeValue ?? 0.0;
      }
    }
    
    final exchangePercentage = invoices.isNotEmpty ? (exchangeCount / invoices.length) * 100 : 0.0;
    
    return {
      'exchangeCount': exchangeCount,
      'totalExchangeValue': totalExchangeValue,
      'exchangePercentage': exchangePercentage,
    };
  }

  Map<String, dynamic> _calculatePaymentStats() {
    final paymentMethods = <String, Map<String, dynamic>>{};
    int emiCount = 0;
    double totalEMIAmount = 0.0;
    
    for (final invoice in invoices) {
      if (invoice.paymentMethod != null) {
        final method = invoice.paymentMethodDisplay;
        if (!paymentMethods.containsKey(method)) {
          paymentMethods[method] = {'count': 0, 'amount': 0.0};
        }
        paymentMethods[method]!['count'] = (paymentMethods[method]!['count'] as int) + 1;
        paymentMethods[method]!['amount'] = (paymentMethods[method]!['amount'] as double) + invoice.finalAmount;
      }
      
      if (invoice.isEMI) {
        emiCount++;
        totalEMIAmount += invoice.emiAmount ?? 0.0;
      }
    }
    
    final avgEMIAmount = emiCount > 0 ? totalEMIAmount / emiCount : 0.0;
    
    return {
      ...paymentMethods,
      'emiCount': emiCount,
      'avgEMIAmount': avgEMIAmount,
    };
  }

  Color _getStatusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return Colors.grey;
      case InvoiceStatus.sent:
        return Colors.blue;
      case InvoiceStatus.paid:
        return Colors.green;
      case InvoiceStatus.overdue:
        return Colors.red;
      case InvoiceStatus.exchanged:
        return Colors.orange;
      case InvoiceStatus.returned:
        return Colors.purple;
    }
  }
}