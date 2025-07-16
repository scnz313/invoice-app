import 'package:flutter/material.dart';
import '../../models/customer_loyalty.dart';

class LoyaltyRulesList extends StatelessWidget {
  final List<LoyaltyRule> rules;

  const LoyaltyRulesList({Key? key, required this.rules}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (rules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rule, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text('No rules yet', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Text('Loyalty rules will appear here', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rules.length,
      itemBuilder: (context, index) {
        final rule = rules[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.withOpacity(0.1),
              child: Icon(Icons.rule, color: Colors.blue),
            ),
            title: Text(rule.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rule.description),
                Text('Points/Rupee: ${rule.pointsPerRupee}'),
                if (rule.minimumPurchase > 0) Text('Min Purchase: ₹${rule.minimumPurchase}'),
                if (rule.maximumPoints > 0) Text('Max Points: ${rule.maximumPoints}'),
                if (rule.validFrom != null && rule.validUntil != null)
                  Text('Valid: ${rule.validFrom!.toLocal().toString().split(' ')[0]} - ${rule.validUntil!.toLocal().toString().split(' ')[0]}'),
              ],
            ),
            trailing: rule.isActive
                ? Icon(Icons.check_circle, color: Colors.green)
                : Icon(Icons.cancel, color: Colors.red),
          ),
        );
      },
    );
  }
}