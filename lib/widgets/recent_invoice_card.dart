import 'package:flutter/material.dart';
import '../models/enhanced_invoice.dart';
import '../utils/theme.dart';

class RecentInvoiceCard extends StatelessWidget {
  final EnhancedInvoice invoice;

  const RecentInvoiceCard({
    super.key,
    required this.invoice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invoice.invoiceNumber,
                        style: AirbnbTheme.bodyStyle.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        invoice.customer.name,
                        style: AirbnbTheme.bodyStyle.copyWith(
                          color: AirbnbTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(invoice.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Amount',
                      style: AirbnbTheme.bodyStyle.copyWith(
                        color: AirbnbTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '₹${invoice.totals.grandTotal.toStringAsFixed(2)}',
                      style: AirbnbTheme.headlineStyle.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AirbnbTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Date',
                      style: AirbnbTheme.bodyStyle.copyWith(
                        color: AirbnbTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(invoice.createdAt),
                      style: AirbnbTheme.bodyStyle.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (invoice.items.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AirbnbTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${invoice.items.length} item${invoice.items.length > 1 ? 's' : ''}',
                  style: AirbnbTheme.bodyStyle.copyWith(
                    fontSize: 12,
                    color: AirbnbTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(InvoiceStatus status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case InvoiceStatus.draft:
        color = Colors.grey;
        text = 'Draft';
        icon = Icons.edit_outlined;
        break;
      case InvoiceStatus.sent:
        color = Colors.blue;
        text = 'Sent';
        icon = Icons.send;
        break;
      case InvoiceStatus.paid:
        color = Colors.green;
        text = 'Paid';
        icon = Icons.check_circle;
        break;
      case InvoiceStatus.overdue:
        color = Colors.red;
        text = 'Overdue';
        icon = Icons.warning;
        break;
      case InvoiceStatus.cancelled:
        color = Colors.grey;
        text = 'Cancelled';
        icon = Icons.cancel;
        break;
      case InvoiceStatus.partiallyPaid:
        color = Colors.orange;
        text = 'Partial';
        icon = Icons.pending;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: AirbnbTheme.bodyStyle.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}