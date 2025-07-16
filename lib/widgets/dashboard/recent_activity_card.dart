import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class RecentActivityCard extends StatelessWidget {
  const RecentActivityCard({Key? key}) : super(key: key);

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ) ?? const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: AppTheme.spacing16),
            ...List.generate(3, (index) => _buildActivityItem(context, index)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, int index) {
    final activities = [
      {'icon': Icons.receipt_long, 'title': 'Invoice #1234 created', 'subtitle': '2 hours ago'},
      {'icon': Icons.person_add, 'title': 'New customer added', 'subtitle': '3 hours ago'},
      {'icon': Icons.inventory_2, 'title': 'Product restocked', 'subtitle': '5 hours ago'},
    ];
    final activity = activities[index];
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.foggy.withOpacity(0.1),
            child: Icon(activity['icon'] as IconData, color: AppTheme.foggy, size: 20),
          ),
          const SizedBox(width: AppTheme.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'] as String,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  activity['subtitle'] as String,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.foggy),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}