import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class QuickActionsCard extends StatelessWidget {
  const QuickActionsCard({Key? key}) : super(key: key);

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
            _buildAction(context, Icons.add, 'New Invoice', AppTheme.rausch),
            _buildAction(context, Icons.person_add, 'Add Customer', AppTheme.babu),
            _buildAction(context, Icons.inventory_2, 'Add Product', AppTheme.hof),
          ],
        ),
      ),
    );
  }

  Widget _buildAction(BuildContext context, IconData icon, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: AppTheme.spacing8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.foggy,
                fontWeight: FontWeight.w600,
              ) ?? TextStyle(color: AppTheme.foggy, fontSize: 12, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}