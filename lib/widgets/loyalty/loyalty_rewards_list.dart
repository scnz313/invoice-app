import 'package:flutter/material.dart';
import '../../models/customer_loyalty.dart';

class LoyaltyRewardsList extends StatelessWidget {
  final List<LoyaltyReward> rewards;

  const LoyaltyRewardsList({Key? key, required this.rewards}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (rewards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.card_giftcard, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text('No rewards yet', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Text('Loyalty rewards will appear here', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rewards.length,
      itemBuilder: (context, index) {
        final reward = rewards[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.purple.withOpacity(0.1),
              child: Icon(Icons.card_giftcard, color: Colors.purple),
            ),
            title: Text(reward.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reward.description),
                Text('Points Required: ${reward.pointsRequired}'),
                if (reward.isPercentage)
                  Text('Discount: ${reward.discountPercentage}%')
                else
                  Text('Discount: ₹${reward.discountAmount}'),
                if (reward.minimumPurchase > 0) Text('Min Purchase: ₹${reward.minimumPurchase}'),
              ],
            ),
            trailing: reward.isActive
                ? Icon(Icons.check_circle, color: Colors.green)
                : Icon(Icons.cancel, color: Colors.red),
          ),
        );
      },
    );
  }
}