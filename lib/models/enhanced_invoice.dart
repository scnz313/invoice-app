import 'package:json_annotation/json_annotation.dart';
import 'business_category.dart';

part 'enhanced_invoice.g.dart';

@JsonSerializable()
class EnhancedInvoice {
  final String id;
  final String invoiceNumber;
  final BusinessCategory businessCategory;
  final DateTime createdAt;
  final DateTime dueDate;
  final InvoiceStatus status;
  final Customer customer;
  final List<InvoiceItem> items;
  final List<CategorySpecificField> categoryFields;
  final InvoiceTotals totals;
  final PaymentDetails paymentDetails;
  final String? notes;
  final String? terms;
  final Map<String, dynamic>? metadata;

  EnhancedInvoice({
    required this.id,
    required this.invoiceNumber,
    required this.businessCategory,
    required this.createdAt,
    required this.dueDate,
    required this.status,
    required this.customer,
    required this.items,
    required this.categoryFields,
    required this.totals,
    required this.paymentDetails,
    this.notes,
    this.terms,
    this.metadata,
  });

  factory EnhancedInvoice.fromJson(Map<String, dynamic> json) =>
      _$EnhancedInvoiceFromJson(json);

  Map<String, dynamic> toJson() => _$EnhancedInvoiceToJson(this);

  EnhancedInvoice copyWith({
    String? id,
    String? invoiceNumber,
    BusinessCategory? businessCategory,
    DateTime? createdAt,
    DateTime? dueDate,
    InvoiceStatus? status,
    Customer? customer,
    List<InvoiceItem>? items,
    List<CategorySpecificField>? categoryFields,
    InvoiceTotals? totals,
    PaymentDetails? paymentDetails,
    String? notes,
    String? terms,
    Map<String, dynamic>? metadata,
  }) {
    return EnhancedInvoice(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      businessCategory: businessCategory ?? this.businessCategory,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      customer: customer ?? this.customer,
      items: items ?? this.items,
      categoryFields: categoryFields ?? this.categoryFields,
      totals: totals ?? this.totals,
      paymentDetails: paymentDetails ?? this.paymentDetails,
      notes: notes ?? this.notes,
      terms: terms ?? this.terms,
      metadata: metadata ?? this.metadata,
    );
  }
}

@JsonSerializable()
class Customer {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final String? gstNumber;
  final CustomerType type;
  final Map<String, dynamic>? categorySpecificData;

  Customer({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.gstNumber,
    required this.type,
    this.categorySpecificData,
  });

  factory Customer.fromJson(Map<String, dynamic> json) =>
      _$CustomerFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerToJson(this);
}

@JsonSerializable()
class InvoiceItem {
  final String id;
  final String name;
  final String? description;
  final double quantity;
  final String unit;
  final double unitPrice;
  final double discount;
  final double taxRate;
  final List<CategorySpecificField> categoryFields;
  final Map<String, dynamic>? metadata;

  InvoiceItem({
    required this.id,
    required this.name,
    this.description,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    this.discount = 0.0,
    this.taxRate = 0.0,
    required this.categoryFields,
    this.metadata,
  });

  double get subtotal => quantity * unitPrice;
  double get discountAmount => subtotal * (discount / 100);
  double get taxableAmount => subtotal - discountAmount;
  double get taxAmount => taxableAmount * (taxRate / 100);
  double get total => taxableAmount + taxAmount;

  factory InvoiceItem.fromJson(Map<String, dynamic> json) =>
      _$InvoiceItemFromJson(json);

  Map<String, dynamic> toJson() => _$InvoiceItemToJson(this);
}

@JsonSerializable()
class CategorySpecificField {
  final String fieldName;
  final String fieldType;
  final String label;
  final dynamic value;
  final bool required;
  final List<String>? options;
  final String? validationRule;

  CategorySpecificField({
    required this.fieldName,
    required this.fieldType,
    required this.label,
    this.value,
    this.required = false,
    this.options,
    this.validationRule,
  });

  factory CategorySpecificField.fromJson(Map<String, dynamic> json) =>
      _$CategorySpecificFieldFromJson(json);

  Map<String, dynamic> toJson() => _$CategorySpecificFieldToJson(this);
}

@JsonSerializable()
class InvoiceTotals {
  final double subtotal;
  final double discountTotal;
  final double taxableAmount;
  final double taxTotal;
  final double grandTotal;
  final String currency;

  InvoiceTotals({
    required this.subtotal,
    required this.discountTotal,
    required this.taxableAmount,
    required this.taxTotal,
    required this.grandTotal,
    this.currency = 'INR',
  });

  factory InvoiceTotals.fromJson(Map<String, dynamic> json) =>
      _$InvoiceTotalsFromJson(json);

  Map<String, dynamic> toJson() => _$InvoiceTotalsToJson(this);
}

@JsonSerializable()
class PaymentDetails {
  final PaymentMethod method;
  final PaymentStatus status;
  final DateTime? paidDate;
  final String? transactionId;
  final String? notes;

  PaymentDetails({
    required this.method,
    required this.status,
    this.paidDate,
    this.transactionId,
    this.notes,
  });

  factory PaymentDetails.fromJson(Map<String, dynamic> json) =>
      _$PaymentDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentDetailsToJson(this);
}

enum InvoiceStatus {
  draft,
  sent,
  paid,
  overdue,
  cancelled,
}

enum CustomerType {
  individual,
  business,
  academic,
  corporate,
}

enum PaymentMethod {
  cash,
  card,
  upi,
  bankTransfer,
  cheque,
  digitalWallet,
}

enum PaymentStatus {
  pending,
  paid,
  partiallyPaid,
  failed,
  refunded,
}

// Category-specific field definitions
class CategoryFieldDefinitions {
  static List<CategorySpecificField> getJewelryFields() {
    return [
      CategorySpecificField(
        fieldName: 'metalType',
        fieldType: 'dropdown',
        label: 'Metal Type',
        required: true,
        options: ['Gold', 'Silver', 'Platinum'],
      ),
      CategorySpecificField(
        fieldName: 'karat',
        fieldType: 'number',
        label: 'Karat/Purity',
        required: true,
      ),
      CategorySpecificField(
        fieldName: 'weight',
        fieldType: 'number',
        label: 'Weight (grams)',
        required: true,
      ),
      CategorySpecificField(
        fieldName: 'makingCharges',
        fieldType: 'number',
        label: 'Making Charges',
        required: false,
      ),
      CategorySpecificField(
        fieldName: 'stoneDetails',
        fieldType: 'text',
        label: 'Stone Details',
        required: false,
      ),
      CategorySpecificField(
        fieldName: 'hallmarkNumber',
        fieldType: 'text',
        label: 'Hallmark Number',
        required: false,
      ),
    ];
  }

  static List<CategorySpecificField> getGroceryFields() {
    return [
      CategorySpecificField(
        fieldName: 'barcode',
        fieldType: 'text',
        label: 'Barcode',
        required: false,
      ),
      CategorySpecificField(
        fieldName: 'unitType',
        fieldType: 'dropdown',
        label: 'Unit Type',
        required: true,
        options: ['kg', 'grams', 'pieces', 'liters', 'packets'],
      ),
      CategorySpecificField(
        fieldName: 'expiryDate',
        fieldType: 'date',
        label: 'Expiry Date',
        required: false,
      ),
      CategorySpecificField(
        fieldName: 'batchNumber',
        fieldType: 'text',
        label: 'Batch Number',
        required: false,
      ),
      CategorySpecificField(
        fieldName: 'category',
        fieldType: 'dropdown',
        label: 'Category',
        required: true,
        options: ['Fruits', 'Vegetables', 'Dairy', 'Grains', 'Beverages', 'Snacks'],
      ),
    ];
  }

  static List<CategorySpecificField> getRestaurantFields() {
    return [
      CategorySpecificField(
        fieldName: 'tableNumber',
        fieldType: 'text',
        label: 'Table Number',
        required: false,
      ),
      CategorySpecificField(
        fieldName: 'orderType',
        fieldType: 'dropdown',
        label: 'Order Type',
        required: true,
        options: ['Dine-in', 'Takeaway', 'Delivery'],
      ),
      CategorySpecificField(
        fieldName: 'specialInstructions',
        fieldType: 'textarea',
        label: 'Special Instructions',
        required: false,
      ),
      CategorySpecificField(
        fieldName: 'kotNumber',
        fieldType: 'text',
        label: 'KOT Number',
        required: false,
      ),
    ];
  }

  static List<CategorySpecificField> getClothingFields() {
    return [
      CategorySpecificField(
        fieldName: 'size',
        fieldType: 'dropdown',
        label: 'Size',
        required: true,
        options: ['XS', 'S', 'M', 'L', 'XL', 'XXL', 'Custom'],
      ),
      CategorySpecificField(
        fieldName: 'color',
        fieldType: 'text',
        label: 'Color',
        required: true,
      ),
      CategorySpecificField(
        fieldName: 'brand',
        fieldType: 'text',
        label: 'Brand',
        required: false,
      ),
      CategorySpecificField(
        fieldName: 'season',
        fieldType: 'dropdown',
        label: 'Season/Collection',
        required: false,
        options: ['Spring', 'Summer', 'Autumn', 'Winter', 'All Season'],
      ),
      CategorySpecificField(
        fieldName: 'alterationCharges',
        fieldType: 'number',
        label: 'Alteration Charges',
        required: false,
      ),
    ];
  }

  static List<CategorySpecificField> getElectronicsFields() {
    return [
      CategorySpecificField(
        fieldName: 'modelNumber',
        fieldType: 'text',
        label: 'Model Number',
        required: true,
      ),
      CategorySpecificField(
        fieldName: 'serialNumber',
        fieldType: 'text',
        label: 'Serial Number',
        required: false,
      ),
      CategorySpecificField(
        fieldName: 'warrantyPeriod',
        fieldType: 'number',
        label: 'Warranty Period (months)',
        required: false,
      ),
      CategorySpecificField(
        fieldName: 'installationCharges',
        fieldType: 'number',
        label: 'Installation Charges',
        required: false,
      ),
      CategorySpecificField(
        fieldName: 'extendedWarranty',
        fieldType: 'boolean',
        label: 'Extended Warranty',
        required: false,
      ),
    ];
  }

  static List<CategorySpecificField> getHardwareFields() {
    return [
      CategorySpecificField(
        fieldName: 'specifications',
        fieldType: 'textarea',
        label: 'Specifications',
        required: false,
      ),
      CategorySpecificField(
        fieldName: 'material',
        fieldType: 'text',
        label: 'Material',
        required: false,
      ),
      CategorySpecificField(
        fieldName: 'grade',
        fieldType: 'dropdown',
        label: 'Grade',
        required: false,
        options: ['A', 'B', 'C', 'Premium', 'Standard'],
      ),
      CategorySpecificField(
        fieldName: 'bulkPricing',
        fieldType: 'boolean',
        label: 'Bulk Pricing Applied',
        required: false,
      ),
      CategorySpecificField(
        fieldName: 'deliveryCharges',
        fieldType: 'number',
        label: 'Delivery Charges',
        required: false,
      ),
    ];
  }

  static List<CategorySpecificField> getPharmacyFields() {
    return [
      CategorySpecificField(
        fieldName: 'medicineName',
        fieldType: 'text',
        label: 'Medicine Name',
        required: true,
      ),
      CategorySpecificField(
        fieldName: 'composition',
        fieldType: 'text',
        label: 'Composition',
        required: false,
      ),
      CategorySpecificField(
        fieldName: 'dosage',
        fieldType: 'text',
        label: 'Dosage',
        required: false,
      ),
      CategorySpecificField(
        fieldName: 'prescriptionNumber',
        fieldType: 'text',
        label: 'Prescription Number',
        required: false,
      ),
      CategorySpecificField(
        fieldName: 'doctorName',
        fieldType: 'text',
        label: 'Doctor Name',
        required: false,
      ),
      CategorySpecificField(
        fieldName: 'batchNumber',
        fieldType: 'text',
        label: 'Batch Number',
        required: false,
      ),
      CategorySpecificField(
        fieldName: 'expiryDate',
        fieldType: 'date',
        label: 'Expiry Date',
        required: false,
      ),
      CategorySpecificField(
        fieldName: 'isGeneric',
        fieldType: 'boolean',
        label: 'Generic Medicine',
        required: false,
      ),
    ];
  }

  static List<CategorySpecificField> getStationeryFields() {
    return [
      CategorySpecificField(
        fieldName: 'category',
        fieldType: 'dropdown',
        label: 'Category',
        required: true,
        options: ['Books', 'Office Supplies', 'Art Materials', 'Electronics'],
      ),
      CategorySpecificField(
        fieldName: 'customerType',
        fieldType: 'dropdown',
        label: 'Customer Type',
        required: true,
        options: ['Individual', 'Academic', 'Corporate'],
      ),
      CategorySpecificField(
        fieldName: 'bulkDiscount',
        fieldType: 'number',
        label: 'Bulk Discount (%)',
        required: false,
      ),
      CategorySpecificField(
        fieldName: 'giftWrapping',
        fieldType: 'boolean',
        label: 'Gift Wrapping',
        required: false,
      ),
      CategorySpecificField(
        fieldName: 'seasonalPricing',
        fieldType: 'boolean',
        label: 'Seasonal Pricing Applied',
        required: false,
      ),
    ];
  }

  static List<CategorySpecificField> getBeautySalonFields() {
    return [
      CategorySpecificField(
        fieldName: 'serviceType',
        fieldType: 'dropdown',
        label: 'Service Type',
        required: true,
        options: ['Haircut', 'Facial', 'Massage', 'Manicure', 'Pedicure', 'Hair Color'],
      ),
      CategorySpecificField(
        fieldName: 'stylistName',
        fieldType: 'text',
        label: 'Stylist/Therapist Name',
        required: false,
      ),
      CategorySpecificField(
        fieldName: 'serviceDuration',
        fieldType: 'number',
        label: 'Service Duration (minutes)',
        required: false,
      ),
      CategorySpecificField(
        fieldName: 'productsUsed',
        fieldType: 'textarea',
        label: 'Products Used',
        required: false,
      ),
      CategorySpecificField(
        fieldName: 'packageDeal',
        fieldType: 'boolean',
        label: 'Package Deal',
        required: false,
      ),
      CategorySpecificField(
        fieldName: 'membershipDiscount',
        fieldType: 'number',
        label: 'Membership Discount (%)',
        required: false,
      ),
    ];
  }

  static List<CategorySpecificField> getAutoPartsFields() {
    return [
      CategorySpecificField(
        fieldName: 'vehicleCompatibility',
        fieldType: 'text',
        label: 'Vehicle Compatibility',
        required: false,
      ),
      CategorySpecificField(
        fieldName: 'partNumber',
        fieldType: 'text',
        label: 'Part Number',
        required: true,
      ),
      CategorySpecificField(
        fieldName: 'oemType',
        fieldType: 'dropdown',
        label: 'OEM/Aftermarket',
        required: false,
        options: ['OEM', 'Aftermarket', 'Genuine'],
      ),
      CategorySpecificField(
        fieldName: 'warrantyPeriod',
        fieldType: 'number',
        label: 'Warranty Period (months)',
        required: false,
      ),
      CategorySpecificField(
        fieldName: 'installationCharges',
        fieldType: 'number',
        label: 'Installation Charges',
        required: false,
      ),
      CategorySpecificField(
        fieldName: 'coreExchangeValue',
        fieldType: 'number',
        label: 'Core Exchange Value',
        required: false,
      ),
    ];
  }

  static List<CategorySpecificField> getBakeryFields() {
    return [
      CategorySpecificField(
        fieldName: 'category',
        fieldType: 'dropdown',
        label: 'Category',
        required: true,
        options: ['Cakes', 'Pastries', 'Bread', 'Cookies', 'Custom'],
      ),
      CategorySpecificField(
        fieldName: 'customOrder',
        fieldType: 'boolean',
        label: 'Custom Order',
        required: false,
      ),
      CategorySpecificField(
        fieldName: 'deliveryDate',
        fieldType: 'date',
        label: 'Delivery Date',
        required: false,
      ),
      CategorySpecificField(
        fieldName: 'deliveryTime',
        fieldType: 'time',
        label: 'Delivery Time',
        required: false,
      ),
      CategorySpecificField(
        fieldName: 'dietaryInfo',
        fieldType: 'dropdown',
        label: 'Dietary Information',
        required: false,
        options: ['Regular', 'Sugar-free', 'Vegan', 'Gluten-free', 'Diabetic'],
      ),
      CategorySpecificField(
        fieldName: 'decorationCharges',
        fieldType: 'number',
        label: 'Decoration Charges',
        required: false,
      ),
    ];
  }

  static List<CategorySpecificField> getMobileRepairFields() {
    return [
      CategorySpecificField(
        fieldName: 'deviceModel',
        fieldType: 'text',
        label: 'Device Model',
        required: true,
      ),
      CategorySpecificField(
        fieldName: 'imei',
        fieldType: 'text',
        label: 'IMEI Number',
        required: false,
      ),
      CategorySpecificField(
        fieldName: 'problemDescription',
        fieldType: 'textarea',
        label: 'Problem Description',
        required: true,
      ),
      CategorySpecificField(
        fieldName: 'partsReplaced',
        fieldType: 'textarea',
        label: 'Parts Replaced',
        required: false,
      ),
      CategorySpecificField(
        fieldName: 'laborCharges',
        fieldType: 'number',
        label: 'Labor Charges',
        required: false,
      ),
      CategorySpecificField(
        fieldName: 'warrantyPeriod',
        fieldType: 'number',
        label: 'Warranty on Repair (months)',
        required: false,
      ),
      CategorySpecificField(
        fieldName: 'dataBackup',
        fieldType: 'boolean',
        label: 'Data Backup/Restore',
        required: false,
      ),
      CategorySpecificField(
        fieldName: 'pickupDelivery',
        fieldType: 'dropdown',
        label: 'Pickup/Delivery',
        required: false,
        options: ['Drop-off', 'Pickup', 'Both'],
      ),
    ];
  }

  static List<CategorySpecificField> getFieldsForCategory(BusinessCategory category) {
    switch (category) {
      case BusinessCategory.jewelryStore:
        return getJewelryFields();
      case BusinessCategory.groceryStore:
        return getGroceryFields();
      case BusinessCategory.restaurantCafe:
        return getRestaurantFields();
      case BusinessCategory.clothingStore:
        return getClothingFields();
      case BusinessCategory.electronicsStore:
        return getElectronicsFields();
      case BusinessCategory.hardwareStore:
        return getHardwareFields();
      case BusinessCategory.pharmacy:
        return getPharmacyFields();
      case BusinessCategory.stationeryStore:
        return getStationeryFields();
      case BusinessCategory.beautySalon:
        return getBeautySalonFields();
      case BusinessCategory.autoPartsStore:
        return getAutoPartsFields();
      case BusinessCategory.bakery:
        return getBakeryFields();
      case BusinessCategory.mobileRepairShop:
        return getMobileRepairFields();
    }
  }
}