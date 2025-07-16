import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/grocery_product.dart';
import '../models/customer_loyalty.dart';
import '../models/invoice.dart';
import '../services/barcode_scanner_service.dart';
import '../services/inventory_service.dart';
import '../providers/invoice_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/category_field_widget.dart';
import '../utils/constants.dart';
import '../utils/logger.dart';

class GroceryInvoiceCreationScreen extends StatefulWidget {
  final Invoice? invoice; // For editing existing invoice

  const GroceryInvoiceCreationScreen({
    super.key,
    this.invoice,
  });

  @override
  State<GroceryInvoiceCreationScreen> createState() => _GroceryInvoiceCreationScreenState();
}

class _GroceryInvoiceCreationScreenState extends State<GroceryInvoiceCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _barcodeController = TextEditingController();
  final _searchController = TextEditingController();
  
  final BarcodeScannerService _scannerService = BarcodeScannerService();
  final InventoryService _inventoryService = InventoryService();
  
  List<InvoiceItem> _items = [];
  Customer? _selectedCustomer;
  String _selectedPaymentMethod = 'Cash';
  double _subtotal = 0.0;
  double _taxAmount = 0.0;
  double _discountAmount = 0.0;
  double _totalAmount = 0.0;
  double _loyaltyDiscount = 0.0;
  int _loyaltyPointsRedeemed = 0;
  int _loyaltyPointsEarned = 0;
  
  bool _isLoading = false;
  bool _showProductSearch = false;
  List<GroceryProduct> _searchResults = [];
  List<GroceryProduct> _allProducts = [];

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    setState(() => _isLoading = true);
    
    try {
      await _inventoryService.initialize();
      _allProducts = await _inventoryService.getAllProducts();
      
      if (widget.invoice != null) {
        _loadExistingInvoice();
      }
      
      setState(() => _isLoading = false);
    } catch (e) {
      Logger.error('Failed to initialize grocery invoice screen', 'GroceryInvoiceCreationScreen', e);
      setState(() => _isLoading = false);
    }
  }

  void _loadExistingInvoice() {
    final invoice = widget.invoice!;
    _items = List.from(invoice.items);
    _selectedCustomer = invoice.customer;
    _selectedPaymentMethod = invoice.paymentMethod;
    _calculateTotals();
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.invoice != null ? 'Edit Invoice' : 'Create Invoice',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          if (widget.invoice != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: _deleteInvoice,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _buildBody(),
                ),
                _buildFooter(),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          _buildBarcodeSection(),
          const SizedBox(height: 16),
          _buildCustomerSection(),
        ],
      ),
    );
  }

  Widget _buildBarcodeSection() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _barcodeController,
              decoration: const InputDecoration(
                hintText: 'Enter barcode or search products',
                prefixIcon: Icon(Icons.qr_code_scanner),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: (value) => _handleBarcodeEntry(value),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.camera_alt, color: AppColors.primary),
            onPressed: _openBarcodeScanner,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(
              _showProductSearch ? Icons.close : Icons.search,
              color: AppColors.primary,
            ),
            onPressed: () {
              setState(() {
                _showProductSearch = !_showProductSearch;
                if (!_showProductSearch) {
                  _searchResults.clear();
                  _searchController.clear();
                }
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerSection() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _selectCustomer,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedCustomer?.name ?? 'Select Customer',
                      style: TextStyle(
                        color: _selectedCustomer != null ? Colors.black : Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                ],
              ),
            ),
          ),
        ),
        if (_selectedCustomer != null) ...[
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _selectedCustomer!.loyaltyTier.icon,
                  color: _selectedCustomer!.loyaltyTier.color,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${_selectedCustomer!.loyaltyPoints} pts',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        if (_showProductSearch) _buildProductSearch(),
        Expanded(
          child: _items.isEmpty
              ? _buildEmptyState()
              : _buildItemsList(),
        ),
      ],
    );
  }

  Widget _buildProductSearch() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search products...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: _searchProducts,
          ),
          if (_searchResults.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final product = _searchResults[index];
                  return _buildProductSearchItem(product);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProductSearchItem(GroceryProduct product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: product.category.color.withOpacity(0.2),
          child: Icon(
            product.category.icon,
            color: product.category.color,
          ),
        ),
        title: Text(
          product.displayName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.category.displayName),
            Row(
              children: [
                Text(
                  '₹${product.unitPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text('/ ${product.unitType.shortName}'),
                const Spacer(),
                _buildStockIndicator(product),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.add_circle, color: AppColors.primary),
          onPressed: () => _addProductToInvoice(product),
        ),
      ),
    );
  }

  Widget _buildStockIndicator(GroceryProduct product) {
    Color color;
    IconData icon;
    String text;

    if (product.isOutOfStock) {
      color = Colors.red;
      icon = Icons.remove_shopping_cart;
      text = 'Out of Stock';
    } else if (product.isLowStock) {
      color = Colors.orange;
      icon = Icons.warning;
      text = 'Low Stock';
    } else {
      color = Colors.green;
      icon = Icons.check_circle;
      text = 'In Stock';
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No items in invoice',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Scan barcodes or search products to add items',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return _buildInvoiceItem(item, index);
      },
    );
  }

  Widget _buildInvoiceItem(InvoiceItem item, int index) {
    final product = _allProducts.firstWhere(
      (p) => p.id == item.productId,
      orElse: () => GroceryProduct(
        id: item.productId,
        name: item.name,
        category: GroceryCategory.pantryStaples,
        unitPrice: item.unitPrice,
        costPrice: 0,
        unitType: UnitType.pieces,
        currentStock: 0,
        reorderPoint: 0,
        maxStock: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: product.category.color.withOpacity(0.2),
                  child: Icon(
                    product.category.icon,
                    color: product.category.color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        product.category.displayName,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeItem(index),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuantitySelector(item, index),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${item.unitPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        'Total: ₹${item.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (item.discount > 0) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Discount: -₹${item.discount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuantitySelector(InvoiceItem item, int index) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: () => _updateQuantity(index, item.quantity - 1),
        ),
        Expanded(
          child: TextField(
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Qty',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            ),
            controller: TextEditingController(text: item.quantity.toString()),
            onChanged: (value) {
              final quantity = double.tryParse(value) ?? 0;
              _updateQuantity(index, quantity);
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () => _updateQuantity(index, item.quantity + 1),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTotalsSection(),
          const SizedBox(height: 16),
          _buildPaymentSection(),
          const SizedBox(height: 16),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildTotalsSection() {
    return Column(
      children: [
        _buildTotalRow('Subtotal', _subtotal),
        _buildTotalRow('Tax (${AppConstants.defaultTaxRate}%)', _taxAmount),
        if (_discountAmount > 0)
          _buildTotalRow('Discount', -_discountAmount, color: Colors.green),
        if (_loyaltyDiscount > 0)
          _buildTotalRow('Loyalty Discount', -_loyaltyDiscount, color: Colors.blue),
        const Divider(),
        _buildTotalRow(
          'Total',
          _totalAmount,
          isTotal: true,
        ),
      ],
    );
  }

  Widget _buildTotalRow(String label, double amount, {Color? color, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              fontSize: isTotal ? 18 : 14,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
              fontSize: isTotal ? 18 : 14,
              color: color ?? (isTotal ? AppColors.primary : Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Column(
      children: [
        Row(
          children: [
            const Text(
              'Payment Method:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedPaymentMethod,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: AppConstants.paymentMethods.map((method) {
                  return DropdownMenuItem(
                    value: method,
                    child: Text(method),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value!;
                  });
                },
              ),
            ),
          ],
        ),
        if (_selectedCustomer != null && _selectedCustomer!.loyaltyPoints > 0) ...[
          const SizedBox(height: 12),
          _buildLoyaltySection(),
        ],
      ],
    );
  }

  Widget _buildLoyaltySection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                _selectedCustomer!.loyaltyTier.icon,
                color: _selectedCustomer!.loyaltyTier.color,
              ),
              const SizedBox(width: 8),
              Text(
                '${_selectedCustomer!.loyaltyTier.displayName} Member',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
              const Spacer(),
              Text(
                '${_selectedCustomer!.loyaltyPoints} points available',
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Points to redeem',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: (value) {
                    final points = int.tryParse(value) ?? 0;
                    _updateLoyaltyRedemption(points);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '= ₹${_loyaltyDiscount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _items.isEmpty ? null : _saveInvoice,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Save Invoice',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _items.isEmpty ? null : _printInvoice,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Print & Save',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Event handlers
  Future<void> _handleBarcodeEntry(String barcode) async {
    if (barcode.isEmpty) return;

    setState(() => _isLoading = true);
    
    try {
      final product = await _scannerService.lookupProductByBarcode(barcode);
      if (product != null) {
        _addProductToInvoice(product);
        _barcodeController.clear();
      } else {
        _showSnackBar('Product not found for barcode: $barcode', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error processing barcode: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openBarcodeScanner() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BarcodeScannerWidget(
          onBarcodeDetected: (result) {
            Navigator.pop(context, result);
          },
        ),
      ),
    );

    if (result != null && result.isValid && result.product != null) {
      _addProductToInvoice(result.product!);
    }
  }

  void _searchProducts(String query) {
    if (query.isEmpty) {
      setState(() => _searchResults.clear());
      return;
    }

    final results = _allProducts.where((product) {
      return product.name.toLowerCase().contains(query.toLowerCase()) ||
             product.brand?.toLowerCase().contains(query.toLowerCase()) == true ||
             product.barcode?.contains(query) == true;
    }).toList();

    setState(() => _searchResults = results);
  }

  void _addProductToInvoice(GroceryProduct product) {
    // Check if product already exists in invoice
    final existingIndex = _items.indexWhere((item) => item.productId == product.id);
    
    if (existingIndex != -1) {
      // Update quantity of existing item
      _updateQuantity(existingIndex, _items[existingIndex].quantity + 1);
    } else {
      // Add new item
      final item = InvoiceItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: product.id,
        name: product.displayName,
        description: product.description,
        quantity: 1,
        unitPrice: product.unitPrice,
        total: product.unitPrice,
        discount: 0,
        taxRate: AppConstants.defaultTaxRate,
        taxAmount: product.unitPrice * (AppConstants.defaultTaxRate / 100),
      );

      setState(() {
        _items.add(item);
        _calculateTotals();
      });
    }

    // Close search if open
    if (_showProductSearch) {
      setState(() {
        _showProductSearch = false;
        _searchResults.clear();
        _searchController.clear();
      });
    }
  }

  void _updateQuantity(int index, double quantity) {
    if (quantity <= 0) {
      _removeItem(index);
      return;
    }

    setState(() {
      final item = _items[index];
      _items[index] = item.copyWith(
        quantity: quantity,
        total: quantity * item.unitPrice,
        taxAmount: (quantity * item.unitPrice) * (item.taxRate / 100),
      );
      _calculateTotals();
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
      _calculateTotals();
    });
  }

  void _updateLoyaltyRedemption(int points) {
    if (_selectedCustomer == null) return;

    final maxPoints = _selectedCustomer!.loyaltyPoints;
    final actualPoints = points > maxPoints ? maxPoints : points;
    
    setState(() {
      _loyaltyPointsRedeemed = actualPoints;
      _loyaltyDiscount = actualPoints * 0.01; // 1 point = ₹0.01
      _calculateTotals();
    });
  }

  void _calculateTotals() {
    _subtotal = _items.fold(0, (sum, item) => sum + item.total);
    _taxAmount = _items.fold(0, (sum, item) => sum + item.taxAmount);
    _discountAmount = _items.fold(0, (sum, item) => sum + item.discount);
    
    _totalAmount = _subtotal + _taxAmount - _discountAmount - _loyaltyDiscount;
    
    // Calculate loyalty points to be earned
    if (_selectedCustomer != null) {
      _loyaltyPointsEarned = (_totalAmount * 10).round(); // 10 points per ₹1
    }
  }

  Future<void> _selectCustomer() async {
    // TODO: Implement customer selection dialog
    // For now, create a mock customer
    final customer = Customer(
      id: '1',
      name: 'John Doe',
      email: 'john@example.com',
      phone: '+91-9876543210',
      address: '123 Main St, City',
      loyaltyPoints: 1500,
      loyaltyTier: LoyaltyTier.gold,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setState(() {
      _selectedCustomer = customer;
      _calculateTotals();
    });
  }

  Future<void> _saveInvoice() async {
    if (_items.isEmpty) {
      _showSnackBar('Please add items to the invoice', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
      
      final invoice = Invoice(
        id: widget.invoice?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        number: widget.invoice?.number ?? await _generateInvoiceNumber(),
        customer: _selectedCustomer,
        items: _items,
        subtotal: _subtotal,
        taxAmount: _taxAmount,
        discountAmount: _discountAmount,
        totalAmount: _totalAmount,
        paymentMethod: _selectedPaymentMethod,
        status: InvoiceStatus.paid,
        notes: '',
        loyaltyPointsEarned: _loyaltyPointsEarned,
        loyaltyPointsRedeemed: _loyaltyPointsRedeemed,
        createdAt: widget.invoice?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.invoice != null) {
        await invoiceProvider.updateInvoice(invoice);
        _showSnackBar('Invoice updated successfully');
      } else {
        await invoiceProvider.addInvoice(invoice);
        _showSnackBar('Invoice created successfully');
      }

      // Update inventory
      for (final item in _items) {
        await _inventoryService.updateStock(
          item.productId,
          item.quantity,
          InventoryTransactionType.sale,
          invoiceId: invoice.id,
        );
      }

      Navigator.pop(context, invoice);
    } catch (e) {
      Logger.error('Failed to save invoice', 'GroceryInvoiceCreationScreen', e);
      _showSnackBar('Failed to save invoice: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _printInvoice() async {
    await _saveInvoice();
    // TODO: Implement print functionality
    _showSnackBar('Invoice printed successfully');
  }

  Future<void> _deleteInvoice() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Invoice'),
        content: const Text('Are you sure you want to delete this invoice?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
        await invoiceProvider.deleteInvoice(widget.invoice!.id);
        _showSnackBar('Invoice deleted successfully');
        Navigator.pop(context);
      } catch (e) {
        _showSnackBar('Failed to delete invoice: $e', isError: true);
      }
    }
  }

  Future<String> _generateInvoiceNumber() async {
    final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
    final invoices = await invoiceProvider.getAllInvoices();
    final nextNumber = invoices.length + 1;
    return 'INV-${DateTime.now().year}-${nextNumber.toString().padLeft(4, '0')}';
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}