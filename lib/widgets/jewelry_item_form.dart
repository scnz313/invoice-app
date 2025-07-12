import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/invoice_item.dart';
import '../utils/currency_helper.dart';

class JewelryItemForm extends StatefulWidget {
  final InvoiceItem? item;
  final Function(InvoiceItem) onSave;
  final VoidCallback onCancel;

  const JewelryItemForm({
    super.key,
    this.item,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<JewelryItemForm> createState() => _JewelryItemFormState();
}

class _JewelryItemFormState extends State<JewelryItemForm> {
  final _formKey = GlobalKey<FormState>();
  
  // Basic fields
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  
  // Jewelry specific fields
  final _weightController = TextEditingController();
  final _purityController = TextEditingController();
  final _hallmarksController = TextEditingController();
  final _certificationController = TextEditingController();
  final _sizeController = TextEditingController();
  final _designCodeController = TextEditingController();
  final _brandController = TextEditingController();
  
  // Stone details
  final _stoneWeightController = TextEditingController();
  final _stoneColorController = TextEditingController();
  final _stoneClarityController = TextEditingController();
  final _stoneCutController = TextEditingController();
  final _stoneCertificationController = TextEditingController();
  
  // State variables
  JewelryType? _selectedJewelryType;
  MetalType? _selectedMetalType;
  StoneType? _selectedStoneType;
  bool _hasStones = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.item != null) {
      final item = widget.item!;
      _descriptionController.text = item.description;
      _quantityController.text = item.quantity.toString();
      _priceController.text = item.price.toString();
      _selectedJewelryType = item.jewelryType;
      _selectedMetalType = item.metalType;
      _weightController.text = item.weight?.toString() ?? '';
      _purityController.text = item.purity?.toString() ?? '';
      _hallmarksController.text = item.hallmarks ?? '';
      _certificationController.text = item.certification ?? '';
      _sizeController.text = item.size ?? '';
      _designCodeController.text = item.designCode ?? '';
      _brandController.text = item.brand ?? '';
      
      if (item.stoneDetails != null) {
        _hasStones = true;
        _selectedStoneType = item.stoneDetails!.type;
        _stoneWeightController.text = item.stoneDetails!.weight.toString();
        _stoneColorController.text = item.stoneDetails!.color;
        _stoneClarityController.text = item.stoneDetails!.clarity;
        _stoneCutController.text = item.stoneDetails!.cut;
        _stoneCertificationController.text = item.stoneDetails!.certification;
      }
    } else {
      _quantityController.text = '1';
      _priceController.text = '0';
      _selectedJewelryType = JewelryType.ring;
      _selectedMetalType = MetalType.gold;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _weightController.dispose();
    _purityController.dispose();
    _hallmarksController.dispose();
    _certificationController.dispose();
    _sizeController.dispose();
    _designCodeController.dispose();
    _brandController.dispose();
    _stoneWeightController.dispose();
    _stoneColorController.dispose();
    _stoneClarityController.dispose();
    _stoneCutController.dispose();
    _stoneCertificationController.dispose();
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
          widget.item != null ? 'Edit Jewelry Item' : 'Add Jewelry Item',
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
          TextButton(
            onPressed: _saveItem,
            child: Text(
              'Save',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildBasicInfoSection(),
              const SizedBox(height: 24),
              _buildJewelryDetailsSection(),
              const SizedBox(height: 24),
              _buildStoneDetailsSection(),
              const SizedBox(height: 24),
              _buildAdditionalDetailsSection(),
              const SizedBox(height: 100), // Space for bottom buttons
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomButtons(),
    );
  }

  Widget _buildBasicInfoSection() {
    return _buildSection(
      title: 'Basic Information',
      icon: Icons.info_outline,
      children: [
        _buildTextField(
          controller: _descriptionController,
          label: 'Item Description',
          icon: Icons.description_outlined,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter item description';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _quantityController,
                label: 'Quantity',
                icon: Icons.numbers,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter quantity';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Please enter a valid quantity';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _priceController,
                label: 'Price',
                icon: Icons.attach_money,
                prefixText: '${CurrencyHelper.currencySymbol} ',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter price';
                  }
                  if (double.tryParse(value) == null || double.parse(value) < 0) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildJewelryDetailsSection() {
    return _buildSection(
      title: 'Jewelry Details',
      icon: Icons.diamond_outlined,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDropdown<JewelryType>(
                value: _selectedJewelryType,
                label: 'Jewelry Type',
                icon: Icons.category_outlined,
                items: JewelryType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getJewelryTypeDisplay(type)),
                  );
                }).toList(),
                onChanged: (type) {
                  setState(() {
                    _selectedJewelryType = type;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select jewelry type';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDropdown<MetalType>(
                value: _selectedMetalType,
                label: 'Metal Type',
                icon: Icons.metal_outlined,
                items: MetalType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getMetalTypeDisplay(type)),
                  );
                }).toList(),
                onChanged: (type) {
                  setState(() {
                    _selectedMetalType = type;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select metal type';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _weightController,
                label: 'Weight (grams)',
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
                controller: _purityController,
                label: _getPurityLabel(),
                icon: Icons.percent,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _sizeController,
                label: 'Size',
                icon: Icons.straighten_outlined,
                hint: 'e.g., 18, 20, 22',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _designCodeController,
                label: 'Design Code',
                icon: Icons.qr_code_outlined,
                hint: 'e.g., RNG001',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _brandController,
          label: 'Brand',
          icon: Icons.branding_watermark_outlined,
          hint: 'e.g., Tanishq, Kalyan',
        ),
      ],
    );
  }

  Widget _buildStoneDetailsSection() {
    return _buildSection(
      title: 'Stone Details',
      icon: Icons.diamond,
      children: [
        SwitchListTile(
          title: const Text('Has Stones'),
          subtitle: const Text('Check if this jewelry has stones'),
          value: _hasStones,
          onChanged: (value) {
            setState(() {
              _hasStones = value;
              if (!value) {
                _selectedStoneType = null;
                _stoneWeightController.clear();
                _stoneColorController.clear();
                _stoneClarityController.clear();
                _stoneCutController.clear();
                _stoneCertificationController.clear();
              } else {
                _selectedStoneType = StoneType.diamond;
              }
            });
          },
        ),
        if (_hasStones) ...[
          const SizedBox(height: 16),
          _buildDropdown<StoneType>(
            value: _selectedStoneType,
            label: 'Stone Type',
            icon: Icons.gem_outlined,
            items: StoneType.values.where((type) => type != StoneType.none).map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(_getStoneTypeDisplay(type)),
              );
            }).toList(),
            onChanged: (type) {
              setState(() {
                _selectedStoneType = type;
              });
            },
            validator: (value) {
              if (_hasStones && value == null) {
                return 'Please select stone type';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _stoneWeightController,
                  label: 'Stone Weight (carats)',
                  icon: Icons.scale_outlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _stoneColorController,
                  label: 'Color',
                  icon: Icons.palette_outlined,
                  hint: 'e.g., D, E, F',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _stoneClarityController,
                  label: 'Clarity',
                  icon: Icons.visibility_outlined,
                  hint: 'e.g., VVS1, VS1',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _stoneCutController,
                  label: 'Cut',
                  icon: Icons.cut_outlined,
                  hint: 'e.g., Excellent, Very Good',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _stoneCertificationController,
            label: 'Certification',
            icon: Icons.verified_outlined,
            hint: 'e.g., GIA, IGI',
          ),
        ],
      ],
    );
  }

  Widget _buildAdditionalDetailsSection() {
    return _buildSection(
      title: 'Additional Details',
      icon: Icons.notes_outlined,
      children: [
        _buildTextField(
          controller: _hallmarksController,
          label: 'Hallmarks',
          icon: Icons.stamp_outlined,
          hint: 'e.g., BIS, 916',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _certificationController,
          label: 'Certification',
          icon: Icons.verified_outlined,
          hint: 'e.g., BIS Hallmark, ISO',
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

  Widget _buildBottomButtons() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: widget.onCancel,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _saveItem,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Save Item'),
            ),
          ),
        ],
      ),
    );
  }

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      final quantity = int.parse(_quantityController.text);
      final price = double.parse(_priceController.text);
      
      StoneDetails? stoneDetails;
      if (_hasStones && _selectedStoneType != null) {
        stoneDetails = StoneDetails(
          type: _selectedStoneType!,
          weight: double.tryParse(_stoneWeightController.text) ?? 0.0,
          color: _stoneColorController.text,
          clarity: _stoneClarityController.text,
          cut: _stoneCutController.text,
          certification: _stoneCertificationController.text,
        );
      }
      
      final item = InvoiceItem(
        description: _descriptionController.text,
        quantity: quantity,
        price: price,
        jewelryType: _selectedJewelryType,
        metalType: _selectedMetalType,
        weight: double.tryParse(_weightController.text),
        purity: double.tryParse(_purityController.text),
        stoneDetails: stoneDetails,
        hallmarks: _hallmarksController.text.isNotEmpty ? _hallmarksController.text : null,
        certification: _certificationController.text.isNotEmpty ? _certificationController.text : null,
        size: _sizeController.text.isNotEmpty ? _sizeController.text : null,
        designCode: _designCodeController.text.isNotEmpty ? _designCodeController.text : null,
        brand: _brandController.text.isNotEmpty ? _brandController.text : null,
      );
      
      widget.onSave(item);
    }
  }

  String _getJewelryTypeDisplay(JewelryType type) {
    switch (type) {
      case JewelryType.ring:
        return 'Ring';
      case JewelryType.necklace:
        return 'Necklace';
      case JewelryType.bracelet:
        return 'Bracelet';
      case JewelryType.earrings:
        return 'Earrings';
      case JewelryType.pendant:
        return 'Pendant';
      case JewelryType.chain:
        return 'Chain';
      case JewelryType.bangles:
        return 'Bangles';
      case JewelryType.anklet:
        return 'Anklet';
      case JewelryType.other:
        return 'Other';
    }
  }

  String _getMetalTypeDisplay(MetalType type) {
    switch (type) {
      case MetalType.gold:
        return 'Gold';
      case MetalType.silver:
        return 'Silver';
      case MetalType.platinum:
        return 'Platinum';
      case MetalType.whiteGold:
        return 'White Gold';
      case MetalType.roseGold:
        return 'Rose Gold';
      case MetalType.other:
        return 'Other';
    }
  }

  String _getStoneTypeDisplay(StoneType type) {
    switch (type) {
      case StoneType.diamond:
        return 'Diamond';
      case StoneType.ruby:
        return 'Ruby';
      case StoneType.emerald:
        return 'Emerald';
      case StoneType.sapphire:
        return 'Sapphire';
      case StoneType.pearl:
        return 'Pearl';
      case StoneType.other:
        return 'Other';
      case StoneType.none:
        return 'None';
    }
  }

  String _getPurityLabel() {
    switch (_selectedMetalType) {
      case MetalType.gold:
        return 'Karat (e.g., 22K, 18K)';
      case MetalType.silver:
        return 'Purity % (e.g., 92.5)';
      case MetalType.platinum:
        return 'Purity % (e.g., 95)';
      default:
        return 'Purity';
    }
  }
}