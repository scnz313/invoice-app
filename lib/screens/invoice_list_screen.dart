import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/invoice_provider.dart';
import '../providers/settings_provider.dart';
import '../models/invoice.dart';
import '../services/pdf_service.dart';
import '../services/export_service.dart';
import '../utils/currency_helper.dart';
import 'invoice_form_screen.dart';

class InvoiceListScreen extends StatefulWidget {
  const InvoiceListScreen({super.key});

  @override
  State<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen> {
  String _searchQuery = '';
  InvoiceStatus? _filterStatus;
  bool _isSelectionMode = false;
  Set<String> _selectedInvoiceIds = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSelectionMode 
            ? Text('${_selectedInvoiceIds.length} selected')
            : const Text('Invoices'),
        centerTitle: true,
        leading: _isSelectionMode 
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _isSelectionMode = false;
                    _selectedInvoiceIds.clear();
                  });
                },
              )
            : null,
        actions: _isSelectionMode 
            ? [
                IconButton(
                  icon: const Icon(Icons.select_all),
                  onPressed: () => _selectAllInvoices(),
                ),
                IconButton(
                  icon: const Icon(Icons.file_download),
                  onPressed: _selectedInvoiceIds.isNotEmpty 
                      ? () => _showExportDialog()
                      : null,
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) => _handleBulkAction(value),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'mark_paid',
                      child: ListTile(
                        leading: Icon(Icons.check_circle_outline),
                        title: Text('Mark as Paid'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete_outline, color: Colors.red),
                        title: Text('Delete Selected', style: TextStyle(color: Colors.red)),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.file_download),
                  onPressed: () => _showExportDialog(),
                ),
                PopupMenuButton<InvoiceStatus?>(
                  icon: const Icon(Icons.filter_list),
                  onSelected: (status) {
                    setState(() {
                      _filterStatus = status;
                    });
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: null,
                      child: Text('All Invoices'),
                    ),
                    const PopupMenuItem(
                      value: InvoiceStatus.draft,
                      child: Text('Draft'),
                    ),
                    const PopupMenuItem(
                      value: InvoiceStatus.sent,
                      child: Text('Sent'),
                    ),
                    const PopupMenuItem(
                      value: InvoiceStatus.paid,
                      child: Text('Paid'),
                    ),
                    const PopupMenuItem(
                      value: InvoiceStatus.overdue,
                      child: Text('Overdue'),
                    ),
                  ],
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'select_mode') {
                      setState(() {
                        _isSelectionMode = true;
                      });
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'select_mode',
                      child: ListTile(
                        leading: Icon(Icons.checklist),
                        title: Text('Select Multiple'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search invoices...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: Consumer<InvoiceProvider>(
              builder: (context, invoiceProvider, child) {
                if (invoiceProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<Invoice> invoices = invoiceProvider.invoices;

                // Apply search filter
                if (_searchQuery.isNotEmpty) {
                  invoices = invoiceProvider.searchInvoices(_searchQuery);
                }

                // Apply status filter
                if (_filterStatus != null) {
                  invoices = invoices.where((invoice) => invoice.status == _filterStatus).toList();
                }

                if (invoices.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty || _filterStatus != null
                              ? 'No invoices found'
                              : 'No invoices yet',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isNotEmpty || _filterStatus != null
                              ? 'Try adjusting your search or filter'
                              : 'Create your first invoice to get started',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => invoiceProvider.loadInvoices(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: invoices.length,
                    itemBuilder: (context, index) {
                      final invoice = invoices[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: _isSelectionMode 
                              ? Checkbox(
                                  value: _selectedInvoiceIds.contains(invoice.id),
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == true) {
                                        _selectedInvoiceIds.add(invoice.id);
                                      } else {
                                        _selectedInvoiceIds.remove(invoice.id);
                                      }
                                    });
                                  },
                                )
                              : CircleAvatar(
                                  backgroundColor: _getStatusColor(invoice.status).withOpacity(0.1),
                                  child: Icon(
                                    _getStatusIcon(invoice.status),
                                    color: _getStatusColor(invoice.status),
                                  ),
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
                                'Due: ${_formatDate(invoice.dueDate)}',
                                style: TextStyle(
                                  color: invoice.isOverdue ? Colors.red : Colors.grey[600],
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
                                  color: _getStatusColor(invoice.status).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _getStatusText(invoice.status),
                                  style: TextStyle(
                                    color: _getStatusColor(invoice.status),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          onTap: _isSelectionMode 
                              ? () {
                                  setState(() {
                                    if (_selectedInvoiceIds.contains(invoice.id)) {
                                      _selectedInvoiceIds.remove(invoice.id);
                                    } else {
                                      _selectedInvoiceIds.add(invoice.id);
                                    }
                                  });
                                }
                              : () => _showInvoiceDetails(context, invoice),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToInvoiceForm(context),
        heroTag: "invoice_list_fab",
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToInvoiceForm(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const InvoiceFormScreen(),
      ),
    );
  }

  void _showInvoiceDetails(BuildContext context, Invoice invoice) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle Bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header Section
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.08),
                    Theme.of(context).colorScheme.secondary.withOpacity(0.04),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.receipt_long,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Invoice Details',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2D3748),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          invoice.invoiceNumber,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A202C),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: _getStatusColor(invoice.status),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: _getStatusColor(invoice.status).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      _getStatusText(invoice.status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Content Section
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Client Information Card
                    _buildInfoCard(
                      context,
                      'Client Information',
                      Icons.person_outline,
                      [
                        _buildDetailRow('Name', invoice.client.name, isImportant: true),
                        _buildDetailRow('Email', invoice.client.email),
                        if (invoice.client.phone.isNotEmpty)
                          _buildDetailRow('Phone', invoice.client.phone),
                        if (invoice.client.address.isNotEmpty)
                          _buildDetailRow('Address', invoice.client.address),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Invoice Details Card
                    _buildInfoCard(
                      context,
                      'Invoice Information',
                      Icons.description_outlined,
                      [
                        _buildDetailRow('Created', _formatDate(invoice.createdDate)),
                        _buildDetailRow('Due Date', _formatDate(invoice.dueDate)),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Financial Summary Card
                    _buildInfoCard(
                      context,
                      'Financial Summary',
                      Icons.account_balance_wallet_outlined,
                      [
                        _buildDetailRow('Subtotal', CurrencyHelper.formatInvoiceAmount(invoice.subtotal)),
                        if (invoice.taxPercentage > 0)
                          _buildDetailRow(
                            'Tax (${invoice.taxPercentage.toStringAsFixed(1)}%)',
                            CurrencyHelper.formatInvoiceAmount(invoice.taxAmount),
                          ),
                        if (invoice.discountAmount > 0)
                          _buildDetailRow(
                            'Discount', 
                            '-${CurrencyHelper.formatInvoiceAmount(invoice.discountAmount)}',
                          ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.secondary,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Amount',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                CurrencyHelper.formatInvoiceAmount(invoice.total),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Items Card
                    _buildInfoCard(
                      context,
                      'Items (${invoice.items.length})',
                      Icons.list_alt_outlined,
                      [
                        ...invoice.items.map((item) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE9ECEF), width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.description,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        color: Color(0xFF2D3748),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    CurrencyHelper.formatInvoiceAmount(item.total),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Qty: ${item.quantity}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Rate: ${CurrencyHelper.formatInvoiceAmount(item.price)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            
            // Action Buttons Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: const Color(0xFFE9ECEF), width: 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Primary Actions Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildPrimaryActionButton(
                          context,
                          icon: Icons.share_outlined,
                          label: 'Share PDF',
                          onPressed: () => _shareInvoice(invoice),
                          isPrimary: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildPrimaryActionButton(
                          context,
                          icon: Icons.print_outlined,
                          label: 'Print',
                          onPressed: () => _printInvoice(invoice),
                          isPrimary: false,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Secondary Actions Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildSecondaryActionButton(
                          context,
                          icon: Icons.edit_outlined,
                          label: 'Edit Invoice',
                          onPressed: () => _editInvoice(context, invoice),
                          color: const Color(0xFF3182CE),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSecondaryActionButton(
                          context,
                          icon: Icons.delete_outline,
                          label: 'Delete',
                          onPressed: () => _deleteInvoice(context, invoice),
                          color: const Color(0xFFE53E3E),
                        ),
                      ),
                    ],
                  ),
                  
                  // Mark as Paid Button (if applicable)
                  if (invoice.status != InvoiceStatus.paid) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: _buildStatusActionButton(
                        context,
                        icon: Icons.check_circle_outline,
                        label: 'Mark as Paid',
                        onPressed: () => _markAsPaid(context, invoice),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, IconData icon, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildPrimaryActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary 
              ? Theme.of(context).colorScheme.primary
              : Colors.white,
          foregroundColor: isPrimary 
              ? Colors.white 
              : Theme.of(context).colorScheme.primary,
          elevation: isPrimary ? 4 : 0,
          shadowColor: isPrimary 
              ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
              : null,
          side: isPrimary 
              ? null 
              : BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withOpacity(0.3), width: 1),
          backgroundColor: color.withOpacity(0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF38A169),
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: const Color(0xFF38A169).withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isImportant = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: isImportant ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _shareInvoice(Invoice invoice) async {
    try {
      final companySettings = Provider.of<SettingsProvider>(context, listen: false).companySettings;
      await PDFService.shareInvoicePdf(invoice, companySettings);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing invoice: $e')),
        );
      }
    }
  }

  void _printInvoice(Invoice invoice) async {
    try {
      final companySettings = Provider.of<SettingsProvider>(context, listen: false).companySettings;
      await PDFService.printInvoicePdf(invoice, companySettings);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error printing invoice: $e')),
        );
      }
    }
  }

  Future<void> _editInvoice(BuildContext context, Invoice invoice) async {
    Navigator.of(context).pop(); // Close the modal first
    
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InvoiceFormScreen(invoice: invoice),
      ),
    );
    
    if (result == true) {
      // Refresh the invoice list
      if (context.mounted) {
        Provider.of<InvoiceProvider>(context, listen: false).loadInvoices();
      }
    }
  }

  Future<void> _deleteInvoice(BuildContext context, Invoice invoice) async {
    Navigator.of(context).pop(); // Close the modal first
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Invoice'),
        content: Text('Are you sure you want to delete invoice ${invoice.invoiceNumber}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await Provider.of<InvoiceProvider>(context, listen: false)
            .deleteInvoice(invoice.id);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invoice deleted successfully!')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting invoice: $e')),
          );
        }
      }
    }
  }

  void _markAsPaid(BuildContext context, Invoice invoice) async {
    final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
    await invoiceProvider.markInvoiceAsPaid(invoice.id);
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invoice marked as paid')),
      );
    }
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
    }
  }

  IconData _getStatusIcon(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return Icons.edit;
      case InvoiceStatus.sent:
        return Icons.send;
      case InvoiceStatus.paid:
        return Icons.check_circle;
      case InvoiceStatus.overdue:
        return Icons.warning;
    }
  }

  String _getStatusText(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return 'DRAFT';
      case InvoiceStatus.sent:
        return 'SENT';
      case InvoiceStatus.paid:
        return 'PAID';
      case InvoiceStatus.overdue:
        return 'OVERDUE';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Selection and Bulk Operations
  void _selectAllInvoices() {
    final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
    final filteredInvoices = _getFilteredInvoices(invoiceProvider.invoices);
    setState(() {
      _selectedInvoiceIds = filteredInvoices.map((invoice) => invoice.id).toSet();
    });
  }

  void _handleBulkAction(String action) async {
    if (_selectedInvoiceIds.isEmpty) return;

    final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
    
    switch (action) {
      case 'mark_paid':
        await _bulkMarkAsPaid();
        break;
      case 'delete':
        await _bulkDelete();
        break;
    }
    
    setState(() {
      _isSelectionMode = false;
      _selectedInvoiceIds.clear();
    });
  }

  Future<void> _bulkMarkAsPaid() async {
    final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
    
    for (final invoiceId in _selectedInvoiceIds) {
      await invoiceProvider.markInvoiceAsPaid(invoiceId);
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_selectedInvoiceIds.length} invoices marked as paid')),
      );
    }
  }

  Future<void> _bulkDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Invoices'),
        content: Text('Are you sure you want to delete ${_selectedInvoiceIds.length} invoices? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
      
      for (final invoiceId in _selectedInvoiceIds) {
        await invoiceProvider.deleteInvoice(invoiceId);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_selectedInvoiceIds.length} invoices deleted')),
        );
      }
    }
  }

  // Export Dialog
  void _showExportDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle Bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.file_download,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Export Invoices',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _isSelectionMode 
                              ? '${_selectedInvoiceIds.length} invoices selected'
                              : 'Export all invoices',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Export Options
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildExportOption(
                      icon: Icons.table_view,
                      title: 'CSV File',
                      subtitle: 'Spreadsheet compatible format',
                      onTap: () => _exportInvoices(ExportFormat.csv),
                    ),
                    const SizedBox(height: 12),
                    _buildExportOption(
                      icon: Icons.code,
                      title: 'JSON File',
                      subtitle: 'Machine readable format',
                      onTap: () => _exportInvoices(ExportFormat.json),
                    ),
                    const SizedBox(height: 12),
                    _buildExportOption(
                      icon: Icons.insert_chart,
                      title: 'Excel File',
                      subtitle: 'Microsoft Excel format',
                      onTap: () => _exportInvoices(ExportFormat.excel),
                    ),
                    const SizedBox(height: 12),
                    _buildExportOption(
                      icon: Icons.picture_as_pdf,
                      title: 'PDF Report',
                      subtitle: 'Printable document format',
                      onTap: () => _exportInvoices(ExportFormat.pdf),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Future<void> _exportInvoices(ExportFormat format) async {
    Navigator.pop(context); // Close the export dialog
    
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Exporting invoices...'),
            ],
          ),
        ),
      );

      final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
      final allInvoices = invoiceProvider.invoices;
      
      // Get invoices to export
      final invoicesToExport = _isSelectionMode 
          ? allInvoices.where((invoice) => _selectedInvoiceIds.contains(invoice.id)).toList()
          : _getFilteredInvoices(allInvoices);

      final options = ExportOptions(
        format: format,
        scope: _isSelectionMode ? ExportScope.selected : ExportScope.filtered,
        statusFilter: _filterStatus != null ? [_filterStatus!] : null,
      );

      final result = await ExportService().exportInvoices(
        invoicesToExport,
        options,
        selectedIds: _isSelectionMode ? _selectedInvoiceIds.toList() : null,
      );

      // Hide loading indicator
      if (mounted) Navigator.pop(context);

      if (result.success) {
        // Show success message and offer to share
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Export Successful'),
            content: Text('${result.recordCount} invoices exported to ${result.fileName}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  // Share the file
                  await ExportService().shareExportFile(result.filePath);
                },
                child: const Text('Share'),
              ),
            ],
          ),
        );
      } else {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Export failed: ${result.errorMessage}')),
          );
        }
      }
    } catch (e) {
      // Hide loading indicator
      if (mounted) Navigator.pop(context);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export error: $e')),
        );
      }
    }
  }

  List<Invoice> _getFilteredInvoices(List<Invoice> invoices) {
    var filtered = invoices;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((invoice) =>
        invoice.invoiceNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        invoice.client.name.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    // Apply status filter
    if (_filterStatus != null) {
      filtered = filtered.where((invoice) => invoice.status == _filterStatus).toList();
    }

    return filtered;
  }
} 