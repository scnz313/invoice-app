import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/enhanced_invoice_provider.dart';
import '../providers/client_provider.dart';
import '../models/invoice.dart';
import '../models/client.dart';
import '../models/invoice_item.dart';
import '../utils/currency_helper.dart';
import 'package:uuid/uuid.dart';

class InvoiceFormScreen extends StatefulWidget {
  final Invoice? invoice;

  const InvoiceFormScreen({super.key, this.invoice});

  @override
  State<InvoiceFormScreen> createState() => _InvoiceFormScreenState();
}

class _InvoiceFormScreenState extends State<InvoiceFormScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  
  // Animation controllers
  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;

  // Form controllers
  final _invoiceNumberController = TextEditingController();
  final _taxController = TextEditingController();
  final _discountController = TextEditingController();
  final _notesController = TextEditingController();

  // State variables
  Client? _selectedClient;
  DateTime _selectedDate = DateTime.now();
  DateTime _selectedDueDate = DateTime.now().add(const Duration(days: 30));
  InvoiceStatus _selectedStatus = InvoiceStatus.draft;
  List<InvoiceItem> _items = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeForm();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fadeAnimationController.forward();
    });
  }

  void _initializeAnimations() {
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  void _initializeForm() {
    if (widget.invoice != null) {
      final invoice = widget.invoice!;
      _invoiceNumberController.text = invoice.invoiceNumber;
      _selectedClient = invoice.client;
      _selectedDate = invoice.createdDate;
      _selectedDueDate = invoice.dueDate;
      _selectedStatus = invoice.status;
      _taxController.text = invoice.taxPercentage.toString();
      _discountController.text = invoice.discountAmount.toString();
      _notesController.text = invoice.notes;
      _items = List.from(invoice.items);
    } else {
      final now = DateTime.now();
      _invoiceNumberController.text = 'INV-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(8)}';
      _taxController.text = '18.0'; // Default GST rate
      _discountController.text = '0';
      _selectedClient = null; // Ensure no client is pre-selected for new invoices
    }
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    _scrollController.dispose();
    _invoiceNumberController.dispose();
    _taxController.dispose();
    _discountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          widget.invoice != null ? 'Edit Invoice' : 'Create Invoice',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          if (widget.invoice != null)
            IconButton(
              icon: Icon(Icons.delete_outline, color: colorScheme.error),
              onPressed: _showDeleteDialog,
              tooltip: 'Delete Invoice',
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeroSection(),
                const SizedBox(height: 24),
                _buildBasicInfoSection(),
                const SizedBox(height: 20),
                _buildClientSection(),
                const SizedBox(height: 20),
                _buildDatesSection(),
                const SizedBox(height: 20),
                _buildItemsSection(),
                const SizedBox(height: 20),
                _buildTotalSection(),
                const SizedBox(height: 20),
                _buildNotesSection(),
                const SizedBox(height: 100), // Space for FAB
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildHeroSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      elevation: 0,
      color: colorScheme.primaryContainer.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.invoice != null ? Icons.edit_document : Icons.receipt_long,
                size: 32,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.invoice != null ? 'Edit Invoice' : 'Create New Invoice',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.invoice != null 
                  ? 'Update invoice details and save changes'
                  : 'Fill in the details to create a professional invoice',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return _buildSection(
      title: 'Invoice Details',
      icon: Icons.receipt_long,
      children: [
        _buildTextField(
          controller: _invoiceNumberController,
          label: 'Invoice Number',
          icon: Icons.numbers,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter invoice number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildDropdown<InvoiceStatus>(
          value: _selectedStatus,
          label: 'Invoice Status',
          icon: Icons.flag_outlined,
          items: InvoiceStatus.values.map((status) {
            return DropdownMenuItem(
              value: status,
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Text(_getStatusText(status)),
                ],
              ),
            );
          }).toList(),
          onChanged: (status) {
            setState(() {
              _selectedStatus = status!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildClientSection() {
    return _buildSection(
      title: 'Client Information',
      icon: Icons.person_outline,
      children: [
        Consumer<ClientProvider>(
          builder: (context, clientProvider, child) {
            if (clientProvider.clients.isEmpty) {
              return _buildEmptyClientState();
            }
            
            return _buildDropdown<Client>(
              value: _isClientInList(clientProvider.clients, _selectedClient) ? _selectedClient : null,
              label: 'Select Client',
              icon: Icons.person,
              hint: 'Choose a client for this invoice',
              items: clientProvider.clients.map((client) {
                return DropdownMenuItem(
                  value: client,
                  child: Text(
                    client.email.isNotEmpty ? '${client.name} • ${client.email}' : client.name,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (client) {
                setState(() {
                  _selectedClient = client;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a client';
                }
                return null;
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyClientState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.person_add_outlined,
            size: 32,
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(height: 12),
          Text(
            'No clients found',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add a client first to create an invoice',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/add-client');
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Client'),
          ),
        ],
      ),
    );
  }

  Widget _buildDatesSection() {
    return _buildSection(
      title: 'Dates',
      icon: Icons.calendar_today_outlined,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                label: 'Invoice Date',
                date: _selectedDate,
                icon: Icons.event_outlined,
                onDateSelected: (date) {
                  setState(() {
                    _selectedDate = date;
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDateField(
                label: 'Due Date',
                date: _selectedDueDate,
                icon: Icons.schedule_outlined,
                onDateSelected: (date) {
                  setState(() {
                    _selectedDueDate = date;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildItemsSection() {
    return _buildSection(
      title: 'Invoice Items',
      icon: Icons.shopping_cart_outlined,
      children: [
        if (_items.isNotEmpty) ...[
          ..._items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return _buildItemCard(item, index);
          }),
          const SizedBox(height: 16),
        ],
        _buildAddItemButton(),
      ],
    );
  }

  Widget _buildItemCard(InvoiceItem item, int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.description,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                PopupMenuButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 20, color: colorScheme.primary),
                          const SizedBox(width: 12),
                          const Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 20, color: colorScheme.error),
                          const SizedBox(width: 12),
                          const Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editItem(index);
                    } else if (value == 'delete') {
                      _removeItem(index);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Flexible(
                  child: Text(
                    'Qty: ${item.quantity}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Price: ${CurrencyHelper.formatInvoiceAmount(item.price)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Total: ${CurrencyHelper.formatInvoiceAmount(item.total)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddItemButton() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return OutlinedButton.icon(
      onPressed: _addItem,
      icon: const Icon(Icons.add),
      label: const Text('Add Item'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: BorderSide(
          color: colorScheme.primary.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildTotalSection() {
    final subtotal = _calculateSubtotal();
    final taxPercentage = double.tryParse(_taxController.text) ?? 0;
    final taxAmount = subtotal * (taxPercentage / 100);
    final discountAmount = double.tryParse(_discountController.text) ?? 0;
    final total = subtotal + taxAmount - discountAmount;

    return _buildSection(
      title: 'Invoice Summary',
      icon: Icons.calculate_outlined,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _taxController,
                label: 'Tax (%)',
                icon: Icons.percent,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
                ],
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _discountController,
                label: 'Discount',
                icon: Icons.discount_outlined,
                prefixText: '${CurrencyHelper.currencySymbol} ',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
                ],
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildSummaryCard(subtotal, taxPercentage, taxAmount, discountAmount, total),
      ],
    );
  }

  Widget _buildSummaryCard(double subtotal, double taxPercentage, double taxAmount, double discountAmount, double total) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      elevation: 0,
      color: colorScheme.primaryContainer.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSummaryRow('Subtotal', CurrencyHelper.formatInvoiceAmount(subtotal)),
            if (taxPercentage > 0) ...[
              const SizedBox(height: 12),
              _buildSummaryRow('Tax (${taxPercentage.toStringAsFixed(1)}%)', CurrencyHelper.formatInvoiceAmount(taxAmount)),
            ],
            if (discountAmount > 0) ...[
              const SizedBox(height: 12),
              _buildSummaryRow('Discount', '-${CurrencyHelper.formatInvoiceAmount(discountAmount)}'),
            ],
            const Divider(height: 24),
            _buildSummaryRow(
              'Total Amount',
              CurrencyHelper.formatInvoiceAmount(total),
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String amount, {bool isTotal = false}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? colorScheme.onSurface : colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        Text(
          amount,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isTotal ? colorScheme.primary : colorScheme.onSurface,
            fontSize: isTotal ? 18 : null,
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return _buildSection(
      title: 'Additional Notes',
      icon: Icons.note_outlined,
      children: [
        _buildTextField(
          controller: _notesController,
          label: 'Notes (Optional)',
          icon: Icons.description_outlined,
          hint: 'Add any additional notes or terms',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int? maxLines,
    void Function(String)? onChanged,
    String? prefixText,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        prefixText: prefixText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
      ),
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines ?? 1,
      onChanged: onChanged,
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required String label,
    required IconData icon,
    String? hint,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
    String? Function(T?)? validator,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
      ),
      items: items,
      onChanged: onChanged,
      validator: validator,
      isExpanded: true,
      borderRadius: BorderRadius.circular(12),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime date,
    required IconData icon,
    required void Function(DateTime) onDateSelected,
  }) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (selectedDate != null) {
          onDateSelected(selectedDate);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
        ),
        child: Text(
          '${date.day}/${date.month}/${date.year}',
          style: theme.textTheme.bodyLarge,
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _isLoading ? null : _saveInvoice,
      icon: _isLoading 
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.save),
      label: Text(widget.invoice != null ? 'Update' : 'Save'),
    );
  }

  // Helper methods
  double _calculateSubtotal() {
    return _items.fold(0, (sum, item) => sum + item.total);
  }

  bool _isClientInList(List<Client> clients, Client? selectedClient) {
    if (selectedClient == null) return false;
    return clients.any((client) => client.id == selectedClient.id);
  }

  String _getStatusText(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return 'Draft';
      case InvoiceStatus.sent:
        return 'Sent';
      case InvoiceStatus.paid:
        return 'Paid';
      case InvoiceStatus.overdue:
        return 'Overdue';
    }
  }

  Color _getStatusColor(InvoiceStatus status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case InvoiceStatus.draft:
        return colorScheme.outline;
      case InvoiceStatus.sent:
        return Colors.blue;
      case InvoiceStatus.paid:
        return Colors.green;
      case InvoiceStatus.overdue:
        return colorScheme.error;
    }
  }

  void _addItem() {
    _showItemDialog();
  }

  void _editItem(int index) {
    _showItemDialog(item: _items[index], index: index);
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _showItemDialog({InvoiceItem? item, int? index}) {
    final descriptionController = TextEditingController(text: item?.description ?? '');
    final quantityController = TextEditingController(text: item?.quantity.toString() ?? '1');
    final priceController = TextEditingController(text: item?.price.toString() ?? '');
    final formKey = GlobalKey<FormState>();
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      item != null ? Icons.edit : Icons.add,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      item != null ? 'Edit Item' : 'Add New Item',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.description_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: quantityController,
                        decoration: const InputDecoration(
                          labelText: 'Quantity',
                          prefixIcon: Icon(Icons.inventory_2_outlined),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Invalid number';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: priceController,
                        decoration: InputDecoration(
                          labelText: 'Price',
                          prefixIcon: const Icon(Icons.currency_rupee),
                          prefixText: '${CurrencyHelper.currencySymbol} ',
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Invalid number';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            final newItem = InvoiceItem(
                              description: descriptionController.text,
                              quantity: double.parse(quantityController.text).toInt(),
                              price: double.parse(priceController.text),
                            );

                            setState(() {
                              if (index != null) {
                                _items[index] = newItem;
                              } else {
                                _items.add(newItem);
                              }
                            });

                            Navigator.of(context).pop();
                          }
                        },
                        child: Text(item != null ? 'Update' : 'Add'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog() {
    final invoiceProvider = Provider.of<EnhancedInvoiceProvider>(context, listen: false);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Invoice'),
        content: const Text('Are you sure you want to delete this invoice? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await invoiceProvider.deleteInvoice(widget.invoice!.id);
                if (!mounted) return;
                navigator.pop();
                messenger.showSnackBar(
                  const SnackBar(content: Text('Invoice deleted successfully')),
                );
              } catch (e) {
                if (!mounted) return;
                messenger.showSnackBar(
                  SnackBar(content: Text('Error deleting invoice: $e')),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveInvoice() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    final messenger = ScaffoldMessenger.of(context);

    if (_selectedClient == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Please select a client')),
      );
      return;
    }

    if (_items.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Please add at least one item')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final invoiceProvider = Provider.of<EnhancedInvoiceProvider>(context, listen: false);
    final navigator = Navigator.of(context);

    try {
      final taxPercentage = double.tryParse(_taxController.text) ?? 0;
      final discountAmount = double.tryParse(_discountController.text) ?? 0;

      final invoice = Invoice(
        id: widget.invoice?.id ?? const Uuid().v4(),
        invoiceNumber: _invoiceNumberController.text,
        client: _selectedClient!,
        items: _items,
        taxPercentage: taxPercentage,
        discountAmount: discountAmount,
        status: _selectedStatus,
        createdDate: _selectedDate,
        dueDate: _selectedDueDate,
        notes: _notesController.text,
      );

      if (widget.invoice != null) {
        await invoiceProvider.updateInvoice(invoice);
      } else {
        await invoiceProvider.addInvoice(invoice);
      }

      if (!mounted) return;
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            widget.invoice != null
                ? 'Invoice updated successfully'
                : 'Invoice created successfully',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Error saving invoice: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
