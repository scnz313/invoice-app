import 'package:flutter/material.dart';
import '../../models/invoice.dart';
import '../../utils/currency_helper.dart';

class InvoiceCard extends StatelessWidget {
  final Invoice invoice;
  final bool isSelected;
  final bool isSelectionMode;
  final ValueChanged<bool?>? onSelect;
  final VoidCallback? onTap;
  final Color statusColor;
  final IconData statusIcon;
  final String statusText;
  final String dueDateText;

  const InvoiceCard({
    Key? key,
    required this.invoice,
    required this.isSelected,
    required this.isSelectionMode,
    this.onSelect,
    this.onTap,
    required this.statusColor,
    required this.statusIcon,
    required this.statusText,
    required this.dueDateText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: isSelectionMode
            ? Checkbox(
                value: isSelected,
                onChanged: onSelect,
              )
            : CircleAvatar(
                backgroundColor: statusColor.withAlpha((255 * 0.1).round()),
                child: Icon(statusIcon, color: statusColor),
              ),
        title: Text(
          invoice.invoiceNumber,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(invoice.client.name),
            Text(
              'Due: $dueDateText',
              style: TextStyle(
                color: invoice.isOverdue
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              CurrencyHelper.formatInvoiceAmount(invoice.total),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withAlpha((255 * 0.1).round()),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}