import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../providers/jewelry_invoice_provider.dart';
import '../providers/jewelry_client_provider.dart';
import '../providers/metal_rates_provider.dart';
import '../models/jewelry_invoice.dart';
import '../models/jewelry_client.dart';
import '../models/jewelry_item.dart';
import '../models/metal_rates.dart';
import '../models/client.dart';
import '../utils/currency_helper.dart';

class JewelryInvoiceFormScreen extends StatefulWidget {
  final JewelryInvoice? invoice;

  const JewelryInvoiceFormScreen({super.key, this.invoice});

  @override
  State<JewelryInvoiceFormScreen> createState() => _JewelryInvoiceFormScreenState();
}

class _JewelryInvoiceFormScreenState extends State<JewelryInvoiceFormScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  late TabController _tabController;
  
  // Form controllers
  final _invoiceNumberController = TextEditingController();
  final _notesController = TextEditingController();
  final _termsController = TextEditingController();
  final _advanceController = TextEditingController();
  final _roundOffController = TextEditingController();
  final _bankDetailsController = TextEditingController();
  final _transportDetailsController = TextEditingController();
  final _placeOfSupplyController = TextEditingController();

  // State variables
  JewelryClient? _selectedClient;
  DateTime _selectedDate = DateTime.now();
  DateTime _selectedDueDate = DateTime.now().add(const Duration(days: 30));
  DateTime? _selectedDeliveryDate;
  InvoiceType _selectedType = InvoiceType.sale;
  InvoiceStatus _selectedStatus = InvoiceStatus.draft;
  bool _isHallmarked = false;
  
  List<JewelryItem> _items = [];
  List<ExchangeItem> _exchangeItems = [];
  List<Payment> _payments = [];
  
  bool _isLoading = false;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.invoice != null) {
      final invoice = widget.invoice!;
      _invoiceNumberController.text = invoice.invoiceNumber;
      _selectedClient = JewelryClient(
        id: invoice.client.id,
        name: invoice.client.name,
        email: invoice.client.email,
        phone: invoice.client.phone,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _selectedDate = invoice.createdDate;
      _selectedDueDate = invoice.dueDate;
      _selectedDeliveryDate = invoice.deliveryDate;
      _selectedType = invoice.type;
      _selectedStatus = invoice.status;
      _isHallmarked = invoice.isHallmarked;
      _items = List.from(invoice.items);
      _exchangeItems = List.from(invoice.exchangeItems);
      _payments = List.from(invoice.payments);
      _notesController.text = invoice.notes;
      _termsController.text = invoice.terms ?? '';
      _advanceController.text = invoice.advanceAmount.toString();
      _roundOffController.text = invoice.roundOffAmount.toString();
      _bankDetailsController.text = invoice.bankDetails ?? '';
      _transportDetailsController.text = invoice.transportDetails ?? '';
      _placeOfSupplyController.text = invoice.placeOfSupply ?? '';
    } else {
      final now = DateTime.now();
      _invoiceNumberController.text = 'JEW-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(8)}';
      _advanceController.text = '0';
      _roundOffController.text = '0';
      _placeOfSupplyController.text = 'Gujarat';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    _invoiceNumberController.dispose();
    _notesController.dispose();
    _termsController.dispose();
    _advanceController.dispose();
    _roundOffController.dispose();
    _bankDetailsController.dispose();
    _transportDetailsController.dispose();
    _placeOfSupplyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.invoice != null ? 'Edit Jewelry Invoice' : 'Create Jewelry Invoice'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Basic Info'),
            Tab(text: 'Items'),
            Tab(text: 'Exchange'),
            Tab(text: 'Summary'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveInvoice,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildBasicInfoTab(),
            _buildItemsTab(),
            _buildExchangeTab(),
            _buildSummaryTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            'Invoice Details',
            [
              _buildTextField(
                controller: _invoiceNumberController,
                label: 'Invoice Number',
                validator: (value) => value?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              _buildDropdown<InvoiceType>(
                value: _selectedType,
                label: 'Invoice Type',
                items: InvoiceType.values.map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(_getTypeDisplay(type)),
                )).toList(),
                onChanged: (value) => setState(() => _selectedType = value!),
              ),
              const SizedBox(height: 16),
              _buildDropdown<InvoiceStatus>(
                value: _selectedStatus,
                label: 'Status',
                items: InvoiceStatus.values.map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(_getStatusDisplay(status)),
                )).toList(),
                onChanged: (value) => setState(() => _selectedStatus = value!),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Hallmarked Jewelry'),
                value: _isHallmarked,
                onChanged: (value) => setState(() => _isHallmarked = value),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Client Information',
            [
              Consumer<JewelryClientProvider>(
                builder: (context, clientProvider, child) {
                  return _buildDropdown<JewelryClient>(
                    value: _selectedClient,
                    label: 'Select Client',
                    items: clientProvider.clients.map((client) => DropdownMenuItem(
                      value: client,
                      child: Text('${client.name} (${client.customerTypeDisplay})'),
                    )).toList(),
                    onChanged: (value) => setState(() => _selectedClient = value),
                    validator: (value) => value == null ? 'Please select a client' : null,
                  );
                },
              ),
              if (_selectedClient != null) ...[
                const SizedBox(height: 16),
                _buildClientInfoCard(),
              ],
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Dates',
            [
              Row(
                children: [
                  Expanded(
                    child: _buildDateField(
                      label: 'Invoice Date',
                      date: _selectedDate,
                      onDateSelected: (date) => setState(() => _selectedDate = date),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDateField(
                      label: 'Due Date',
                      date: _selectedDueDate,
                      onDateSelected: (date) => setState(() => _selectedDueDate = date),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDateField(
                label: 'Delivery Date (Optional)',
                date: _selectedDeliveryDate,
                onDateSelected: (date) => setState(() => _selectedDeliveryDate = date),
                allowNull: true,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Additional Information',
            [
              _buildTextField(
                controller: _placeOfSupplyController,
                label: 'Place of Supply',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _bankDetailsController,
                label: 'Bank Details',
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _transportDetailsController,
                label: 'Transport Details',
                maxLines: 2,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemsTab() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _items.length,
            itemBuilder: (context, index) => _buildItemCard(_items[index], index),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _addJewelryItem,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Jewelry Item'),
                ),
              ),
              const SizedBox(width: 16),
              Consumer<MetalRatesProvider>(
                builder: (context, ratesProvider, child) {
                  return ElevatedButton.icon(
                    onPressed: () => _showMetalRatesDialog(ratesProvider),
                    icon: const Icon(Icons.monetization_on),
                    label: const Text('View Rates'),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExchangeTab() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _exchangeItems.length,
            itemBuilder: (context, index) => _buildExchangeItemCard(_exchangeItems[index], index),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey.shade300)),
          ),
          child: ElevatedButton.icon(
            onPressed: _addExchangeItem,
            icon: const Icon(Icons.swap_horiz),
            label: const Text('Add Exchange Item'),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            'Invoice Summary',
            [
              _buildSummaryCard(),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Payments',
            [
              ..._payments.map((payment) => _buildPaymentCard(payment)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _addPayment,
                icon: const Icon(Icons.payment),
                label: const Text('Add Payment'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Final Details',
            [
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _advanceController,
                      label: 'Advance Amount',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _roundOffController,
                      label: 'Round Off',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.-]'))],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _notesController,
                label: 'Notes',
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _termsController,
                label: 'Terms & Conditions',
                maxLines: 5,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required String label,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    String? Function(T?)? validator,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      items: items,
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required ValueChanged<DateTime> onDateSelected,
    bool allowNull = false,
  }) {
    return InkWell(
      onTap: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (selectedDate != null) {
          onDateSelected(selectedDate);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date != null ? DateFormat('dd/MM/yyyy').format(date) : 'Select Date',
              style: TextStyle(
                color: date != null ? Colors.black : Colors.grey,
              ),
            ),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Widget _buildClientInfoCard() {
    final client = _selectedClient!;
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              client.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text('${client.customerTypeDisplay} Customer'),
            Text('Phone: ${client.phone}'),
            Text('Email: ${client.email}'),
            if (client.hasCreditLimit) ...[
              const SizedBox(height: 4),
              Text('Credit Limit: ${CurrencyHelper.formatAmount(client.creditLimit)}'),
              Text('Outstanding: ${CurrencyHelper.formatAmount(client.outstandingAmount)}'),
            ],
            if (client.loyaltyPoints > 0) ...[
              const SizedBox(height: 4),
              Text('Loyalty Points: ${client.loyaltyPoints} (${client.loyaltyTier})'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(JewelryItem item, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editJewelryItem(index);
                    } else if (value == 'delete') {
                      _removeJewelryItem(index);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(item.description),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${item.metalTypeDisplay} ${item.metalPurityDisplay}'),
                      Text('Weight: ${item.metalWeight}g'),
                      Text('Quantity: ${item.quantity}'),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Rate: ${CurrencyHelper.formatAmount(item.metalRate)}/g'),
                      Text('Making: ${CurrencyHelper.formatAmount(item.makingCharges)}${item.isMakingChargesPerGram ? '/g' : ''}'),
                      Text(
                        'Total: ${CurrencyHelper.formatAmount(item.totalAmount)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (item.stones.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('Stones:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...item.stones.map((stone) => Text('${stone.name}: ${stone.quantity} pcs')),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExchangeItemCard(ExchangeItem item, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _removeExchangeItem(index),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.metalDisplay),
                      Text('Weight: ${item.weight}g'),
                      Text('Rate: ${CurrencyHelper.formatAmount(item.rate)}/g'),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Gross: ${CurrencyHelper.formatAmount(item.grossValue)}'),
                      Text('Deduction: ${item.deductionPercentage}%'),
                      Text(
                        'Net: ${CurrencyHelper.formatAmount(item.netValue)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard(Payment payment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.payment),
        title: Text(payment.methodDisplay),
        subtitle: Text(DateFormat('dd/MM/yyyy').format(payment.date)),
        trailing: Text(
          CurrencyHelper.formatAmount(payment.amount),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final subtotal = _items.fold(0.0, (sum, item) => sum + item.totalAmount);
    final exchangeValue = _exchangeItems.fold(0.0, (sum, item) => sum + item.netValue);
    final netAmount = subtotal - exchangeValue;
    final advanceAmount = double.tryParse(_advanceController.text) ?? 0.0;
    final roundOff = double.tryParse(_roundOffController.text) ?? 0.0;
    final finalAmount = netAmount + roundOff - advanceAmount;

    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSummaryRow('Subtotal', subtotal),
            _buildSummaryRow('Exchange Value', -exchangeValue),
            const Divider(),
            _buildSummaryRow('Net Amount', netAmount),
            _buildSummaryRow('Advance', -advanceAmount),
            _buildSummaryRow('Round Off', roundOff),
            const Divider(thickness: 2),
            _buildSummaryRow('Final Amount', finalAmount, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            CurrencyHelper.formatAmount(amount),
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: amount < 0 ? Colors.red : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  void _addJewelryItem() {
    showDialog(
      context: context,
      builder: (context) => JewelryItemDialog(
        onSave: (item) {
          setState(() {
            _items.add(item);
          });
        },
      ),
    );
  }

  void _editJewelryItem(int index) {
    showDialog(
      context: context,
      builder: (context) => JewelryItemDialog(
        item: _items[index],
        onSave: (item) {
          setState(() {
            _items[index] = item;
          });
        },
      ),
    );
  }

  void _removeJewelryItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _addExchangeItem() {
    showDialog(
      context: context,
      builder: (context) => ExchangeItemDialog(
        onSave: (item) {
          setState(() {
            _exchangeItems.add(item);
          });
        },
      ),
    );
  }

  void _removeExchangeItem(int index) {
    setState(() {
      _exchangeItems.removeAt(index);
    });
  }

  void _addPayment() {
    showDialog(
      context: context,
      builder: (context) => PaymentDialog(
        onSave: (payment) {
          setState(() {
            _payments.add(payment);
          });
        },
      ),
    );
  }

  void _showMetalRatesDialog(MetalRatesProvider ratesProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Current Metal Rates'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...ratesProvider.currentGoldRates.map((rate) => ListTile(
                title: Text(rate.metalDisplay),
                subtitle: Text('Buying: ${CurrencyHelper.formatAmount(rate.buyingRate)}/g'),
                trailing: Text('Selling: ${CurrencyHelper.formatAmount(rate.sellingRate)}/g'),
              )),
              ...ratesProvider.currentSilverRates.map((rate) => ListTile(
                title: Text(rate.metalDisplay),
                subtitle: Text('Buying: ${CurrencyHelper.formatAmount(rate.buyingRate)}/g'),
                trailing: Text('Selling: ${CurrencyHelper.formatAmount(rate.sellingRate)}/g'),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _saveInvoice() async {
    if (!_formKey.currentState!.validate()) return;
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

    setState(() {
      _isLoading = true;
    });

    try {
      final client = Client(
        id: _selectedClient!.id,
        name: _selectedClient!.name,
        email: _selectedClient!.email,
        address: _selectedClient!.addresses.isNotEmpty ? _selectedClient!.addresses.first.fullAddress : '',
        phone: _selectedClient!.phone,
      );

      final invoice = widget.invoice?.copyWith(
        invoiceNumber: _invoiceNumberController.text,
        client: client,
        items: _items,
        exchangeItems: _exchangeItems,
        dueDate: _selectedDueDate,
        deliveryDate: _selectedDeliveryDate,
        type: _selectedType,
        status: _selectedStatus,
        payments: _payments,
        advanceAmount: double.tryParse(_advanceController.text) ?? 0.0,
        roundOffAmount: double.tryParse(_roundOffController.text) ?? 0.0,
        notes: _notesController.text,
        terms: _termsController.text,
        isHallmarked: _isHallmarked,
        bankDetails: _bankDetailsController.text,
        transportDetails: _transportDetailsController.text,
        placeOfSupply: _placeOfSupplyController.text,
      ) ?? JewelryInvoice.create(
        client: client,
        items: _items,
        exchangeItems: _exchangeItems,
        dueDate: _selectedDueDate,
        deliveryDate: _selectedDeliveryDate,
        type: _selectedType,
        notes: _notesController.text,
        terms: _termsController.text,
        isHallmarked: _isHallmarked,
        bankDetails: _bankDetailsController.text,
        transportDetails: _transportDetailsController.text,
        placeOfSupply: _placeOfSupplyController.text,
      );

      final invoiceProvider = context.read<JewelryInvoiceProvider>();
      
      if (widget.invoice != null) {
        await invoiceProvider.updateInvoice(invoice);
      } else {
        await invoiceProvider.addInvoice(invoice);
      }

      Navigator.pop(context, invoice);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving invoice: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getTypeDisplay(InvoiceType type) {
    switch (type) {
      case InvoiceType.sale:
        return 'Sale';
      case InvoiceType.exchange:
        return 'Exchange';
      case InvoiceType.estimate:
        return 'Estimate';
      case InvoiceType.repair:
        return 'Repair';
      case InvoiceType.custom:
        return 'Custom Order';
    }
  }

  String _getStatusDisplay(InvoiceStatus status) {
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
}

// Dialog classes would be implemented here
class JewelryItemDialog extends StatefulWidget {
  final JewelryItem? item;
  final ValueChanged<JewelryItem> onSave;

  const JewelryItemDialog({super.key, this.item, required this.onSave});

  @override
  State<JewelryItemDialog> createState() => _JewelryItemDialogState();
}

class _JewelryItemDialogState extends State<JewelryItemDialog> {
  // Implementation would go here
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.item != null ? 'Edit Item' : 'Add Item'),
      content: const Text('Jewelry item dialog implementation'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            // Implementation would create and return the item
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class ExchangeItemDialog extends StatefulWidget {
  final ExchangeItem? item;
  final ValueChanged<ExchangeItem> onSave;

  const ExchangeItemDialog({super.key, this.item, required this.onSave});

  @override
  State<ExchangeItemDialog> createState() => _ExchangeItemDialogState();
}

class _ExchangeItemDialogState extends State<ExchangeItemDialog> {
  // Implementation would go here
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.item != null ? 'Edit Exchange Item' : 'Add Exchange Item'),
      content: const Text('Exchange item dialog implementation'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            // Implementation would create and return the item
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class PaymentDialog extends StatefulWidget {
  final Payment? payment;
  final ValueChanged<Payment> onSave;

  const PaymentDialog({super.key, this.payment, required this.onSave});

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  // Implementation would go here
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.payment != null ? 'Edit Payment' : 'Add Payment'),
      content: const Text('Payment dialog implementation'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            // Implementation would create and return the payment
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}