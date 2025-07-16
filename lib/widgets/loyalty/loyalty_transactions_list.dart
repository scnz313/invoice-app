import 'package:flutter/material.dart';
import '../../models/customer_loyalty.dart';

class LoyaltyTransactionsList extends StatelessWidget {
  final List<LoyaltyTransaction> transactions;

  const LoyaltyTransactionsList({Key? key, required this.transactions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.swap_horiz, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text('No transactions yet', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Text('Loyalty transactions will appear here', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: tx.type == LoyaltyTransactionType.earn ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              child: Icon(
                tx.type == LoyaltyTransactionType.earn ? Icons.add : Icons.remove,
                color: tx.type == LoyaltyTransactionType.earn ? Colors.green : Colors.red,
              ),
            ),
            title: Text(tx.description, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Points: ${tx.points}'),
                Text('Invoice: ${tx.invoiceId ?? 'N/A'}'),
                Text('Date: ${tx.createdAt.toLocal().toString().split(' ')[0]}'),
              ],
            ),
            trailing: Text(
              tx.type == LoyaltyTransactionType.earn ? '+${tx.points}' : '-${tx.points}',
              style: TextStyle(
                color: tx.type == LoyaltyTransactionType.earn ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }
}