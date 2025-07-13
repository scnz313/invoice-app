import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/enhanced_invoice_provider.dart';
import '../providers/settings_provider.dart';
import '../models/enhanced_invoice.dart';
import '../models/business_category.dart';
import '../utils/theme.dart';
import '../utils/logger.dart';
import '../widgets/airbnb_card.dart';
import '../widgets/category_field_widget.dart';

class InvoiceCreationScreen extends StatefulWidget {
  final EnhancedInvoice? editingInvoice;

  const InvoiceCreationScreen({
    super.key,
    this.editingInvoice,
  });

  @override
  State<InvoiceCreationScreen> createState() => _InvoiceCreationScreenState();
}

class _InvoiceCreationScreenState extends State<InvoiceCreationScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _customerEmailController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _customerAddressController = TextEditingController();
  final _customerGstController = TextEditingController();
  final _notesController = TextEditingController();
  final _termsController = TextEditingController();

  Customer? _selectedCustomer;
  BusinessCategory? _selectedCategory;
  List<InvoiceItem> _items = [];
  List<CategorySpecificField> _categoryFields = [];
  Map<String, dynamic> _categoryFieldValues = {};
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  CustomerType _customerType = CustomerType.individual;
  PaymentMethod _paymentMethod = PaymentMethod.cash;

  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();

    _initializeForm();
  }

  void _initializeForm() {
    final settingsProvider = context.read<SettingsProvider>();
    _selectedCategory = settingsProvider.selectedBusinessCategory;

    if (widget.editingInvoice != null) {
      final invoice = widget.editingInvoice!;
      _selectedCustomer = invoice.customer;
      _selectedCategory = invoice.businessCategory;
      _items = List.from(invoice.items);
      _categoryFields = List.from(invoice.categoryFields);
      _dueDate = invoice.dueDate;
      _paymentMethod = invoice.paymentDetails.method;

      _customerNameController.text = invoice.customer.name;
      _customerEmailController.text = invoice.customer.email ?? '';
      _customerPhoneController.text = invoice.customer.phone ?? '';
      _customerAddressController.text = invoice.customer.address ?? '';
      _customerGstController.text = invoice.customer.gstNumber ?? '';
      _customerType = invoice.customer.type;
      _notesController.text = invoice.notes ?? '';
      _termsController.text = invoice.terms ?? '';

      // Initialize category field values
      for (var field in _categoryFields) {
        _categoryFieldValues[field.fieldName] = field.value;
      }
    } else {
      _selectedCategory = settingsProvider.selectedBusinessCategory;
      if (_selectedCategory != null) {
        _categoryFields = CategoryFieldDefinitions.getFieldsForCategory(_selectedCategory!);
        for (var field in _categoryFields) {
          _categoryFieldValues[field.fieldName] = field.value;
        }
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _customerNameController.dispose();
    _customerEmailController.dispose();
    _customerPhoneController.dispose();
    _customerAddressController.dispose();
    _customerGstController.dispose();
    _notesController.dispose();
    _termsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AirbnbTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.editingInvoice != null ? 'Edit Invoice' : 'Create Invoice',
          style: AirbnbTheme.headlineStyle.copyWith(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: AirbnbTheme.primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (widget.editingInvoice != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteInvoice,
            ),
        ],
      ),
      body: Consumer2<EnhancedInvoiceProvider, SettingsProvider>(
        builder: (context, invoiceProvider, settingsProvider, child) {
          return Form(
            key: _formKey,
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Customer Information
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildCustomerSection(),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Invoice Details
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildInvoiceDetailsSection(),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Category-Specific Fields
                      if (_selectedCategory != null)
                        SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: _buildCategoryFieldsSection(),
                          ),
                        ),

                      if (_selectedCategory != null) const SizedBox(height: 24),

                      // Invoice Items
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildItemsSection(invoiceProvider),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Additional Information
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildAdditionalInfoSection(),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Action Buttons
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildActionButtons(invoiceProvider),
                        ),
                      ),

                      const SizedBox(height: 100), // Bottom padding
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCustomerSection() {
    return AirbnbCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline,
                color: AirbnbTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Customer Information',
                style: AirbnbTheme.headlineStyle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _customerNameController,
                  decoration: const InputDecoration(
                    labelText: 'Customer Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Customer name is required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<CustomerType>(
                  value: _customerType,
                  decoration: const InputDecoration(
                    labelText: 'Customer Type',
                    border: OutlineInputBorder(),
                  ),
                  items: CustomerType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.name.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _customerType = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _customerEmailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _customerPhoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _customerAddressController,
            decoration: const InputDecoration(
              labelText: 'Address',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _customerGstController,
            decoration: const InputDecoration(
              labelText: 'GST Number',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceDetailsSection() {
    return AirbnbCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_long,
                color: AirbnbTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Invoice Details',
                style: AirbnbTheme.headlineStyle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<BusinessCategory>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Business Category *',
                    border: OutlineInputBorder(),
                  ),
                  items: BusinessCategory.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Row(
                        children: [
                          Icon(
                            category.icon,
                            color: category.color,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(category.displayName),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                      if (value != null) {
                        _categoryFields = CategoryFieldDefinitions.getFieldsForCategory(value);
                        _categoryFieldValues.clear();
                        for (var field in _categoryFields) {
                          _categoryFieldValues[field.fieldName] = field.value;
                        }
                      }
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Business category is required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: _selectDueDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Due Date',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      '${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',
                      style: AirbnbTheme.bodyStyle,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<PaymentMethod>(
            value: _paymentMethod,
            decoration: const InputDecoration(
              labelText: 'Payment Method',
              border: OutlineInputBorder(),
            ),
            items: PaymentMethod.values.map((method) {
              return DropdownMenuItem(
                value: method,
                child: Text(method.name.toUpperCase()),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _paymentMethod = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFieldsSection() {
    if (_categoryFields.isEmpty) return const SizedBox.shrink();

    return AirbnbCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _selectedCategory!.icon,
                color: _selectedCategory!.color,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                '${_selectedCategory!.displayName} Specific Fields',
                style: AirbnbTheme.headlineStyle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ..._categoryFields.map((field) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: CategoryFieldWidget(
              field: field,
              value: _categoryFieldValues[field.fieldName],
              onChanged: (value) {
                setState(() {
                  _categoryFieldValues[field.fieldName] = value;
                });
              },
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildItemsSection(EnhancedInvoiceProvider invoiceProvider) {
    return AirbnbCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    color: AirbnbTheme.primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Invoice Items',
                    style: AirbnbTheme.headlineStyle.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: _addItem,
                icon: const Icon(Icons.add),
                label: const Text('Add Item'),
                style: TextButton.styleFrom(
                  foregroundColor: AirbnbTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_items.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    color: Colors.grey[400],
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No items added',
                    style: AirbnbTheme.bodyStyle.copyWith(
                      color: AirbnbTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add items to your invoice',
                    style: AirbnbTheme.bodyStyle.copyWith(
                      color: AirbnbTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          else
            ..._items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return _buildItemCard(index, item);
            }),
          if (_items.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildTotalsSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildItemCard(int index, InvoiceItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.name,
                  style: AirbnbTheme.bodyStyle.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _removeItem(index),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Qty: ${item.quantity} ${item.unit}',
                  style: AirbnbTheme.bodyStyle.copyWith(
                    color: AirbnbTheme.textSecondary,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Price: ₹${item.unitPrice.toStringAsFixed(2)}',
                  style: AirbnbTheme.bodyStyle.copyWith(
                    color: AirbnbTheme.textSecondary,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Total: ₹${item.total.toStringAsFixed(2)}',
                  style: AirbnbTheme.bodyStyle.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AirbnbTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          if (item.description?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Text(
              item.description!,
              style: AirbnbTheme.bodyStyle.copyWith(
                color: AirbnbTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTotalsSection() {
    final invoiceProvider = context.read<EnhancedInvoiceProvider>();
    final totals = invoiceProvider.calculateTotals(_items);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AirbnbTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AirbnbTheme.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          _buildTotalRow('Subtotal', totals.subtotal),
          _buildTotalRow('Discount', totals.discountTotal),
          _buildTotalRow('Tax', totals.taxTotal),
          const Divider(),
          _buildTotalRow('Grand Total', totals.grandTotal, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AirbnbTheme.bodyStyle.copyWith(
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: AirbnbTheme.bodyStyle.copyWith(
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? AirbnbTheme.primaryColor : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoSection() {
    return AirbnbCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.note_outlined,
                color: AirbnbTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Additional Information',
                style: AirbnbTheme.headlineStyle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Notes',
              border: OutlineInputBorder(),
              hintText: 'Additional notes for the customer...',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _termsController,
            decoration: const InputDecoration(
              labelText: 'Terms & Conditions',
              border: OutlineInputBorder(),
              hintText: 'Payment terms and conditions...',
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(EnhancedInvoiceProvider invoiceProvider) {
    return Column(
      children: [
        if (_error != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Text(
              _error!,
              style: AirbnbTheme.bodyStyle.copyWith(
                color: Colors.red,
              ),
            ),
          ),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _saveAsDraft,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AirbnbTheme.primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Save as Draft',
                  style: AirbnbTheme.bodyStyle.copyWith(
                    color: AirbnbTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveInvoice,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AirbnbTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        widget.editingInvoice != null ? 'Update Invoice' : 'Create Invoice',
                        style: AirbnbTheme.bodyStyle.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _selectDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _addItem() {
    // TODO: Navigate to item creation screen
    // For now, add a sample item
    final invoiceProvider = context.read<EnhancedInvoiceProvider>();
    final newItem = invoiceProvider.createInvoiceItem(
      name: 'Sample Item',
      description: 'Sample description',
      quantity: 1,
      unit: 'piece',
      unitPrice: 100.0,
      category: _selectedCategory ?? BusinessCategory.jewelryStore,
    );
    setState(() {
      _items.add(newItem);
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  Future<void> _saveAsDraft() async {
    await _saveInvoice(isDraft: true);
  }

  Future<void> _saveInvoice({bool isDraft = false}) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_items.isEmpty) {
      setState(() {
        _error = 'Please add at least one item to the invoice';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final invoiceProvider = context.read<EnhancedInvoiceProvider>();
      
      // Create or update customer
      Customer customer;
      if (_selectedCustomer != null) {
        customer = _selectedCustomer!.copyWith(
          name: _customerNameController.text,
          email: _customerEmailController.text.isEmpty ? null : _customerEmailController.text,
          phone: _customerPhoneController.text.isEmpty ? null : _customerPhoneController.text,
          address: _customerAddressController.text.isEmpty ? null : _customerAddressController.text,
          gstNumber: _customerGstController.text.isEmpty ? null : _customerGstController.text,
          type: _customerType,
        );
        await invoiceProvider.updateCustomer(customer);
      } else {
        customer = invoiceProvider.createCustomer(
          name: _customerNameController.text,
          email: _customerEmailController.text.isEmpty ? null : _customerEmailController.text,
          phone: _customerPhoneController.text.isEmpty ? null : _customerPhoneController.text,
          address: _customerAddressController.text.isEmpty ? null : _customerAddressController.text,
          gstNumber: _customerGstController.text.isEmpty ? null : _customerGstController.text,
          type: _customerType,
        );
        await invoiceProvider.addCustomer(customer);
      }

      // Update category fields with values
      final updatedCategoryFields = _categoryFields.map((field) {
        return field.copyWith(value: _categoryFieldValues[field.fieldName]);
      }).toList();

      // Create invoice
      EnhancedInvoice invoice;
      if (widget.editingInvoice != null) {
        invoice = widget.editingInvoice!.copyWith(
          customer: customer,
          businessCategory: _selectedCategory!,
          dueDate: _dueDate,
          items: _items,
          categoryFields: updatedCategoryFields,
          totals: invoiceProvider.calculateTotals(_items),
          paymentDetails: PaymentDetails(
            method: _paymentMethod,
            status: isDraft ? PaymentStatus.pending : PaymentStatus.pending,
          ),
          status: isDraft ? InvoiceStatus.draft : InvoiceStatus.sent,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
          terms: _termsController.text.isEmpty ? null : _termsController.text,
        );
        await invoiceProvider.updateInvoice(invoice);
      } else {
        invoice = invoiceProvider.createDraftInvoice(
          category: _selectedCategory!,
          customer: customer,
          items: _items,
          categoryFields: updatedCategoryFields,
        );
        invoice = invoice.copyWith(
          dueDate: _dueDate,
          totals: invoiceProvider.calculateTotals(_items),
          paymentDetails: PaymentDetails(
            method: _paymentMethod,
            status: isDraft ? PaymentStatus.pending : PaymentStatus.pending,
          ),
          status: isDraft ? InvoiceStatus.draft : InvoiceStatus.sent,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
          terms: _termsController.text.isEmpty ? null : _termsController.text,
        );
        await invoiceProvider.addInvoice(invoice);
      }

      if (mounted) {
        Navigator.pop(context, invoice);
      }
    } catch (e) {
      Logger.error('Failed to save invoice', 'InvoiceCreationScreen', e);
      setState(() {
        _error = 'Failed to save invoice: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteInvoice() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Invoice'),
        content: const Text('Are you sure you want to delete this invoice? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.editingInvoice != null) {
      try {
        final invoiceProvider = context.read<EnhancedInvoiceProvider>();
        await invoiceProvider.deleteInvoice(widget.editingInvoice!.id);
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        Logger.error('Failed to delete invoice', 'InvoiceCreationScreen', e);
        setState(() {
          _error = 'Failed to delete invoice: $e';
        });
      }
    }
  }
}