import 'package:flutter/material.dart';
import '../../models/customer_loyalty.dart';

class LoyaltyCustomersList extends StatelessWidget {
  final List<CustomerLoyalty> customers;

  const LoyaltyCustomersList({Key? key, required this.customers}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (customers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text('No customers yet', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Text('Add your first customer to get started', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final customer = customers[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: customer.tier.color.withOpacity(0.1),
              child: Icon(customer.tier.icon, color: customer.tier.color),
            ),
            title: Text('Customer #${customer.customerId}', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Points: ${customer.currentPoints}'),
                Text('Tier: ${customer.tier.displayName}'),
                Text('Last Purchase: ${customer.lastPurchaseDate?.toLocal().toString().split(' ')[0] ?? 'N/A'}'),
              ],
            ),
            trailing: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurfaceVariant),
            onTap: () {
              // TODO: Show customer details
            },
          ),
        );
      },
    );
  }
}