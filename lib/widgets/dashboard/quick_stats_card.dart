import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class QuickStatsCard extends StatelessWidget {
  const QuickStatsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radius16),
      ),
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStat(context, 'Total Sales', ' 23,000', Icons.attach_money, AppTheme.rausch),
            _buildStat(context, 'Orders', '120', Icons.shopping_cart, AppTheme.babu),
            _buildStat(context, 'Customers', '80', Icons.people, AppTheme.hof),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(BuildContext context, String label, String value, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: AppTheme.spacing8),
        Text(
          value,
          style: Theme.of(context).textTheme.headline6?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ) ?? TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: AppTheme.spacing4),
        Text(
          label,
          style: Theme.of(context).textTheme.caption?.copyWith(
                color: AppTheme.foggy,
              ) ?? TextStyle(color: AppTheme.foggy, fontSize: 12),
        ),
      ],
    );
  }
}