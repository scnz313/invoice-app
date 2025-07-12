import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/invoice.dart';
import '../models/client.dart';
import '../models/invoice_item.dart';
import '../utils/currency_helper.dart';
import 'jewelry_item_form.dart';

class JewelryInvoiceForm extends StatefulWidget {
  final Invoice? invoice;
  final Function(Invoice) onSave;
  final VoidCallback onCancel;

  const JewelryInvoiceForm({
    super.key,
    this.invoice,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<JewelryInvoiceForm> createState() => _JewelryInvoiceFormState();
}

class _JewelryInvoiceFormState extends State<JewelryInvoiceForm>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  
  // Animation controllers
  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;

  // Basic form controllers
  final _invoiceNumberController = TextEditingController();
  final _taxController = TextEditingController();
  final _discountController = TextEditingController();
  final _notesController = TextEditingController();
  
  // Jewelry specific controllers
  final _makingChargesController = TextEditingController();
  final _wastageChargesController = TextEditingController();
  final _exchangeValueController = TextEditingController();
  final _advanceAmountController = TextEditingController();
  final _salesPersonController = TextEditingController();
  final _warrantyDetailsController = TextEditingController();
  final _returnPolicyController = TextEditingController();
  
  // Exchange details controllers
  final _oldItemWeightController = TextEditingController();
  final _oldItemValueController = TextEditingController();
  final _oldItemDescriptionController = TextEditingController();
  final _exchangeNotesController = TextEditingController();

  // State variables
  Client? _selectedClient;
  DateTime _selectedDate = DateTime.now();
  DateTime _selectedDueDate = DateTime.now().add(const Duration(days: 30));
  InvoiceStatus _selectedStatus = InvoiceStatus.draft;
  PaymentMethod? _selectedPaymentMethod;
  List<InvoiceItem> _items = [];
  bool _isLoading = false;
  
  // Jewelry specific state
  bool _isExchange = false;
  bool _isEMI = false;
  int _emiMonths = 12;
  double? _emiAmount;

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
      
      // Jewelry specific fields
      _makingChargesController.text = invoice.makingCharges?.toString() ?? '';
      _wastageChargesController.text = invoice.wastageCharges?.toString() ?? '';
      _exchangeValueController.text = invoice.exchangeValue?.toString() ?? '';
      _advanceAmountController.text = invoice.advanceAmount?.toString() ?? '';
      _salesPersonController.text = invoice.salesPerson ?? '';
      _warrantyDetailsController.text = invoice.warrantyDetails ?? '';
      _returnPolicyController.text = invoice.returnPolicy ?? '';
      _selectedPaymentMethod = invoice.paymentMethod;
      _isExchange = invoice.isExchange;
      _isEMI = invoice.isEMI;
      _emiMonths = invoice.emiMonths ?? 12;
      _emiAmount = invoice.emiAmount;
      
      // Exchange details
      if (invoice.exchangeDetails != null) {
        _oldItemWeightController.text = invoice.exchangeDetails!.oldItemWeight.toString();
        _oldItemValueController.text = invoice.exchangeDetails!.oldItemValue.toString();
        _oldItemDescriptionController.text = invoice.exchangeDetails!.oldItemDescription;
        _exchangeNotesController.text = invoice.exchangeDetails!.exchangeNotes;
      }
    } else {
      final now = DateTime.now();
      _invoiceNumberController.text = 'INV-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(8)}';
      _taxController.text = '3.0'; // Default GST rate for jewelry
      _discountController.text = '0';
      _makingChargesController.text = '0';
      _wastageChargesController.text = '0';
      _exchangeValueController.text = '0';
      _advanceAmountController.text = '0';
      _selectedClient = null;
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
    _makingChargesController.dispose();
    _wastageChargesController.dispose();
    _exchangeValueController.dispose();
    _advanceAmountController.dispose();
    _salesPersonController.dispose();
    _warrantyDetailsController.dispose();
    _returnPolicyController.dispose();
    _oldItemWeightController.dispose();
    _oldItemValueController.dispose();
    _oldItemDescriptionController.dispose();
    _exchangeNotesController.dispose();
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
          widget.invoice != null ? 'Edit Jewelry Invoice' : 'Create Jewelry Invoice',
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
                _buildJewelryChargesSection(),
                const SizedBox(height: 20),
                _buildExchangeSection(),
                const SizedBox(height: 20),
                _buildPaymentSection(),
                const SizedBox(height: 20),
                _buildTotalSection(),
                const SizedBox(height: 20),
                _buildAdditionalDetailsSection(),
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
                widget.invoice != null ? Icons.edit_document : Icons.diamond_outlined,
                size: 32,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.invoice != null ? 'Edit Jewelry Invoice' : 'Create Jewelry Invoice',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.invoice != null 
                  ? 'Update jewelry invoice details and save changes'
                  : 'Fill in the details to create a professional jewelry invoice',
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
        // This would be populated from a client provider
        _buildTextField(
          controller: TextEditingController(text: _selectedClient?.name ?? ''),
          label: 'Client Name',
          icon: Icons.person,
          readOnly: true,
          onTap: () {
            // Navigate to client selection
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: TextEditingController(text: _selectedClient?.gstNumber ?? ''),
                label: 'GST Number',
                icon: Icons.receipt_long,
                hint: 'e.g., 22AAAAA0000A1Z5',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: TextEditingController(text: _selectedClient?.panNumber ?? ''),
                label: 'PAN Number',
                icon: Icons.credit_card,
                hint: 'e.g., ABCDE1234F',
              ),
            ),
          ],
        ),
      ],
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
      title: 'Jewelry Items',
      icon: Icons.diamond_outlined,
      children: [
        if (_items.isNotEmpty) ...[
          ..._items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return _buildJewelryItemCard(item, index);
          }),
          const SizedBox(height: 16),
        ],
        _buildAddItemButton(),
      ],
    );
  }

  Widget _buildJewelryItemCard(InvoiceItem item, int index) {
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.description,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (item.hasJewelryDetails) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${item.jewelryTypeDisplay} • ${item.metalTypeDisplay}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        if (item.weight != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Weight: ${item.weight}g • Purity: ${item.purity}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ],
                    ],
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
      label: const Text('Add Jewelry Item'),
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

  Widget _buildJewelryChargesSection() {
    return _buildSection(
      title: 'Jewelry Charges',
      icon: Icons.calculate_outlined,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _makingChargesController,
                label: 'Making Charges',
                icon: Icons.handyman_outlined,
                prefixText: '${CurrencyHelper.currencySymbol} ',
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
                controller: _wastageChargesController,
                label: 'Wastage Charges',
                icon: Icons.waste_outlined,
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
      ],
    );
  }

  Widget _buildExchangeSection() {
    return _buildSection(
      title: 'Exchange Details',
      icon: Icons.swap_horiz_outlined,
      children: [
        SwitchListTile(
          title: const Text('Is Exchange'),
          subtitle: const Text('Check if this is an exchange transaction'),
          value: _isExchange,
          onChanged: (value) {
            setState(() {
              _isExchange = value;
            });
          },
        ),
        if (_isExchange) ...[
          const SizedBox(height: 16),
          _buildTextField(
            controller: _exchangeValueController,
            label: 'Exchange Value',
            icon: Icons.currency_exchange,
            prefixText: '${CurrencyHelper.currencySymbol} ',
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
            ],
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _oldItemDescriptionController,
            label: 'Old Item Description',
            icon: Icons.description_outlined,
            hint: 'Describe the item being exchanged',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _oldItemWeightController,
                  label: 'Old Item Weight (g)',
                  icon: Icons.scale_outlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,3}$')),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _oldItemValueController,
                  label: 'Old Item Value',
                  icon: Icons.attach_money,
                  prefixText: '${CurrencyHelper.currencySymbol} ',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _exchangeNotesController,
            label: 'Exchange Notes',
            icon: Icons.notes_outlined,
            hint: 'Additional notes about the exchange',
            maxLines: 3,
          ),
        ],
      ],
    );
  }

  Widget _buildPaymentSection() {
    return _buildSection(
      title: 'Payment Details',
      icon: Icons.payment_outlined,
      children: [
        _buildDropdown<PaymentMethod>(
          value: _selectedPaymentMethod,
          label: 'Payment Method',
          icon: Icons.payment,
          items: PaymentMethod.values.map((method) {
            return DropdownMenuItem(
              value: method,
              child: Text(_getPaymentMethodDisplay(method)),
            );
          }).toList(),
          onChanged: (method) {
            setState(() {
              _selectedPaymentMethod = method;
            });
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _advanceAmountController,
                label: 'Advance Amount',
                icon: Icons.payments_outlined,
                prefixText: '${CurrencyHelper.currencySymbol} ',
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
                controller: _salesPersonController,
                label: 'Sales Person',
                icon: Icons.person_outline,
                hint: 'Name of sales person',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('EMI Payment'),
          subtitle: const Text('Check if this is an EMI transaction'),
          value: _isEMI,
          onChanged: (value) {
            setState(() {
              _isEMI = value;
              if (value) {
                _selectedPaymentMethod = PaymentMethod.emi;
              }
            });
          },
        ),
        if (_isEMI) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDropdown<int>(
                  value: _emiMonths,
                  label: 'EMI Months',
                  icon: Icons.calendar_month,
                  items: [3, 6, 9, 12, 18, 24, 36].map((months) {
                    return DropdownMenuItem(
                      value: months,
                      child: Text('$months months'),
                    );
                  }).toList(),
                  onChanged: (months) {
                    setState(() {
                      _emiMonths = months!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monthly EMI',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyHelper.formatInvoiceAmount(_calculateMonthlyEMI()),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildTotalSection() {
    final subtotal = _calculateSubtotal();
    final makingCharges = double.tryParse(_makingChargesController.text) ?? 0;
    final wastageCharges = double.tryParse(_wastageChargesController.text) ?? 0;
    final subtotalWithCharges = subtotal + makingCharges + wastageCharges;
    final taxPercentage = double.tryParse(_taxController.text) ?? 0;
    final taxAmount = subtotalWithCharges * (taxPercentage / 100);
    final discountAmount = double.tryParse(_discountController.text) ?? 0;
    final total = subtotalWithCharges + taxAmount - discountAmount;
    final exchangeValue = double.tryParse(_exchangeValueController.text) ?? 0;
    final finalAmount = total - exchangeValue;

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
        _buildSummaryCard(
          subtotal, 
          makingCharges, 
          wastageCharges, 
          subtotalWithCharges,
          taxPercentage, 
          taxAmount, 
          discountAmount, 
          total,
          exchangeValue,
          finalAmount
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    double subtotal,
    double makingCharges,
    double wastageCharges,
    double subtotalWithCharges,
    double taxPercentage,
    double taxAmount,
    double discountAmount,
    double total,
    double exchangeValue,
    double finalAmount,
  ) {
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
            _buildSummaryRow('Subtotal', subtotal),
            if (makingCharges > 0) _buildSummaryRow('Making Charges', makingCharges),
            if (wastageCharges > 0) _buildSummaryRow('Wastage Charges', wastageCharges),
            if (makingCharges > 0 || wastageCharges > 0) _buildSummaryRow('Subtotal with Charges', subtotalWithCharges),
            if (taxPercentage > 0) _buildSummaryRow('Tax (${taxPercentage}%)', taxAmount),
            if (discountAmount > 0) _buildSummaryRow('Discount', -discountAmount),
            const Divider(),
            _buildSummaryRow('Total', total, isTotal: true),
            if (exchangeValue > 0) ...[
              _buildSummaryRow('Exchange Value', -exchangeValue),
              const Divider(),
              _buildSummaryRow('Final Amount', finalAmount, isTotal: true),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
              color: colorScheme.onSurface,
            ),
          ),
          Text(
            CurrencyHelper.formatInvoiceAmount(amount),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? colorScheme.primary : colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalDetailsSection() {
    return _buildSection(
      title: 'Additional Details',
      icon: Icons.notes_outlined,
      children: [
        _buildTextField(
          controller: _warrantyDetailsController,
          label: 'Warranty Details',
          icon: Icons.verified_outlined,
          hint: 'e.g., Lifetime warranty, 1 year warranty',
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _returnPolicyController,
          label: 'Return Policy',
          icon: Icons.assignment_return_outlined,
          hint: 'e.g., 7 days return policy, exchange only',
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _notesController,
          label: 'Notes',
          icon: Icons.notes_outlined,
          hint: 'Additional notes or special instructions',
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
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
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
                    size: 20,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
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
    String? prefixText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    bool readOnly = false,
    int? maxLines,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefixText,
        prefixIcon: Icon(icon, color: colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        filled: true,
        fillColor: colorScheme.surface,
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      readOnly: readOnly,
      maxLines: maxLines ?? 1,
      onTap: onTap,
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    String? Function(T?)? validator,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        filled: true,
        fillColor: colorScheme.surface,
      ),
      items: items,
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime date,
    required IconData icon,
    required Function(DateTime) onDateSelected,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
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
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outline.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(12),
          color: colorScheme.surface,
        ),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    '${date.day}/${date.month}/${date.year}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.calendar_today, color: colorScheme.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return FloatingActionButton.extended(
      onPressed: _saveInvoice,
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      icon: const Icon(Icons.save),
      label: const Text('Save Invoice'),
    );
  }

  void _addItem() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JewelryItemForm(
          onSave: (item) {
            setState(() {
              _items.add(item);
            });
            Navigator.pop(context);
          },
          onCancel: () => Navigator.pop(context),
        ),
      ),
    );
  }

  void _editItem(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JewelryItemForm(
          item: _items[index],
          onSave: (item) {
            setState(() {
              _items[index] = item;
            });
            Navigator.pop(context);
          },
          onCancel: () => Navigator.pop(context),
        ),
      ),
    );
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _saveInvoice() {
    if (_formKey.currentState!.validate()) {
      if (_selectedClient == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a client')),
        );
        return;
      }
      
      if (_items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one item')),
        );
        return;
      }

      final makingCharges = double.tryParse(_makingChargesController.text) ?? 0;
      final wastageCharges = double.tryParse(_wastageChargesController.text) ?? 0;
      final exchangeValue = double.tryParse(_exchangeValueController.text) ?? 0;
      final advanceAmount = double.tryParse(_advanceAmountController.text) ?? 0;
      
      ExchangeDetails? exchangeDetails;
      if (_isExchange && _oldItemDescriptionController.text.isNotEmpty) {
        exchangeDetails = ExchangeDetails(
          oldItemWeight: double.tryParse(_oldItemWeightController.text) ?? 0,
          oldItemValue: double.tryParse(_oldItemValueController.text) ?? 0,
          oldItemDescription: _oldItemDescriptionController.text,
          exchangeValue: exchangeValue,
          exchangeNotes: _exchangeNotesController.text,
        );
      }

      final invoice = Invoice.create(
        client: _selectedClient!,
        items: _items,
        dueDate: _selectedDueDate,
        taxPercentage: double.tryParse(_taxController.text) ?? 0,
        discountAmount: double.tryParse(_discountController.text) ?? 0,
        notes: _notesController.text,
        makingCharges: makingCharges,
        wastageCharges: wastageCharges,
        exchangeValue: exchangeValue,
        exchangeDetails: exchangeDetails,
        paymentMethod: _selectedPaymentMethod,
        salesPerson: _salesPersonController.text.isNotEmpty ? _salesPersonController.text : null,
        warrantyDetails: _warrantyDetailsController.text.isNotEmpty ? _warrantyDetailsController.text : null,
        returnPolicy: _returnPolicyController.text.isNotEmpty ? _returnPolicyController.text : null,
        isExchange: _isExchange,
        isEMI: _isEMI,
        emiMonths: _isEMI ? _emiMonths : null,
        emiAmount: _isEMI ? _calculateMonthlyEMI() : null,
      ).copyWith(
        id: widget.invoice?.id ?? '',
        invoiceNumber: _invoiceNumberController.text,
        createdDate: _selectedDate,
        status: _selectedStatus,
        advanceAmount: advanceAmount,
        balanceAmount: _calculateFinalAmount() - advanceAmount,
      );

      widget.onSave(invoice);
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Invoice'),
        content: const Text('Are you sure you want to delete this invoice? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onCancel();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  double _calculateSubtotal() {
    return _items.fold(0.0, (sum, item) => sum + item.total);
  }

  double _calculateFinalAmount() {
    final subtotal = _calculateSubtotal();
    final makingCharges = double.tryParse(_makingChargesController.text) ?? 0;
    final wastageCharges = double.tryParse(_wastageChargesController.text) ?? 0;
    final subtotalWithCharges = subtotal + makingCharges + wastageCharges;
    final taxPercentage = double.tryParse(_taxController.text) ?? 0;
    final taxAmount = subtotalWithCharges * (taxPercentage / 100);
    final discountAmount = double.tryParse(_discountController.text) ?? 0;
    final total = subtotalWithCharges + taxAmount - discountAmount;
    final exchangeValue = double.tryParse(_exchangeValueController.text) ?? 0;
    return total - exchangeValue;
  }

  double _calculateMonthlyEMI() {
    final finalAmount = _calculateFinalAmount();
    if (_emiMonths <= 0) return 0;
    return finalAmount / _emiMonths;
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
      case InvoiceStatus.exchanged:
        return Colors.orange;
      case InvoiceStatus.returned:
        return Colors.purple;
    }
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
      case InvoiceStatus.exchanged:
        return 'Exchanged';
      case InvoiceStatus.returned:
        return 'Returned';
    }
  }

  String _getPaymentMethodDisplay(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.cheque:
        return 'Cheque';
      case PaymentMethod.exchange:
        return 'Exchange';
      case PaymentMethod.emi:
        return 'EMI';
      case PaymentMethod.other:
        return 'Other';
    }
  }
}