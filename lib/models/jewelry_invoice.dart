import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import 'client.dart';
import 'jewelry_item.dart';
import 'invoice.dart';

part 'jewelry_invoice.g.dart';

enum PaymentMethod {
  cash,
  card,
  upi,
  netbanking,
  cheque,
  goldExchange,
  partialPayment,
}

enum InvoiceType {
  sale,
  exchange,
  estimate,
  repair,
  custom,
}

@JsonSerializable()
class Payment {
  final String id;
  final double amount;
  final PaymentMethod method;
  final DateTime date;
  final String? referenceNumber;
  final String? notes;

  Payment({
    required this.id,
    required this.amount,
    required this.method,
    required this.date,
    this.referenceNumber,
    this.notes,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => _$PaymentFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentToJson(this);

  String get methodDisplay {
    switch (method) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.netbanking:
        return 'Net Banking';
      case PaymentMethod.cheque:
        return 'Cheque';
      case PaymentMethod.goldExchange:
        return 'Gold Exchange';
      case PaymentMethod.partialPayment:
        return 'Partial Payment';
    }
  }
}

@JsonSerializable()
class ExchangeItem {
  final String id;
  final String description;
  final MetalType metalType;
  final GoldPurity? goldPurity;
  final SilverPurity? silverPurity;
  final double weight;
  final double rate;
  final double deductionPercentage;
  final String? notes;

  ExchangeItem({
    required this.id,
    required this.description,
    required this.metalType,
    this.goldPurity,
    this.silverPurity,
    required this.weight,
    required this.rate,
    this.deductionPercentage = 0.0,
    this.notes,
  });

  double get grossValue => weight * rate;
  double get deductionAmount => grossValue * (deductionPercentage / 100);
  double get netValue => grossValue - deductionAmount;

  factory ExchangeItem.fromJson(Map<String, dynamic> json) => _$ExchangeItemFromJson(json);
  Map<String, dynamic> toJson() => _$ExchangeItemToJson(this);

  String get metalDisplay {
    switch (metalType) {
      case MetalType.gold:
        return 'Gold ${goldPurity?.display ?? ''}';
      case MetalType.silver:
        return 'Silver ${silverPurity?.display ?? ''}';
      default:
        return metalType.name;
    }
  }
}

@JsonSerializable()
class JewelryInvoice {
  final String id;
  final String invoiceNumber;
  final Client client;
  final List<JewelryItem> items;
  final List<ExchangeItem> exchangeItems;
  final DateTime createdDate;
  final DateTime dueDate;
  final DateTime? deliveryDate;
  final InvoiceType type;
  final InvoiceStatus status;
  final List<Payment> payments;
  final double advanceAmount;
  final double roundOffAmount;
  final String notes;
  final String? terms;
  final bool isHallmarked;
  final String? bankDetails;
  final String? transportDetails;
  final String? placeOfSupply;

  JewelryInvoice({
    required this.id,
    required this.invoiceNumber,
    required this.client,
    required this.items,
    this.exchangeItems = const [],
    required this.createdDate,
    required this.dueDate,
    this.deliveryDate,
    this.type = InvoiceType.sale,
    this.status = InvoiceStatus.draft,
    this.payments = const [],
    this.advanceAmount = 0.0,
    this.roundOffAmount = 0.0,
    this.notes = '',
    this.terms,
    this.isHallmarked = false,
    this.bankDetails,
    this.transportDetails,
    this.placeOfSupply,
  });

  factory JewelryInvoice.create({
    required Client client,
    required List<JewelryItem> items,
    required DateTime dueDate,
    List<ExchangeItem> exchangeItems = const [],
    DateTime? deliveryDate,
    InvoiceType type = InvoiceType.sale,
    String notes = '',
    String? terms,
    bool isHallmarked = false,
    String? bankDetails,
    String? transportDetails,
    String? placeOfSupply,
  }) {
    final now = DateTime.now();
    return JewelryInvoice(
      id: const Uuid().v4(),
      invoiceNumber: _generateInvoiceNumber(now),
      client: client,
      items: items,
      exchangeItems: exchangeItems,
      createdDate: now,
      dueDate: dueDate,
      deliveryDate: deliveryDate,
      type: type,
      notes: notes,
      terms: terms,
      isHallmarked: isHallmarked,
      bankDetails: bankDetails,
      transportDetails: transportDetails,
      placeOfSupply: placeOfSupply,
    );
  }

  static String _generateInvoiceNumber(DateTime date) {
    final prefix = 'JEW';
    return '$prefix-${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}-${date.millisecondsSinceEpoch.toString().substring(8)}';
  }

  // Calculate subtotal from all jewelry items
  double get subtotal => items.fold(0.0, (sum, item) => sum + item.totalAmount);

  // Calculate total exchange value
  double get totalExchangeValue => exchangeItems.fold(0.0, (sum, item) => sum + item.netValue);

  // Calculate total paid amount
  double get totalPaidAmount => payments.fold(0.0, (sum, payment) => sum + payment.amount);

  // Calculate net amount (subtotal - exchange value)
  double get netAmount => subtotal - totalExchangeValue;

  // Calculate final amount (net amount + round off - advance)
  double get finalAmount => netAmount + roundOffAmount - advanceAmount;

  // Calculate pending amount
  double get pendingAmount => finalAmount - totalPaidAmount;

  // Check if invoice is fully paid
  bool get isFullyPaid => pendingAmount <= 0.01; // Allow small floating point differences

  // Check if invoice is overdue
  bool get isOverdue => status != InvoiceStatus.paid && DateTime.now().isAfter(dueDate);

  // Get total weight by metal type
  Map<MetalType, double> get totalWeightByMetal {
    final weights = <MetalType, double>{};
    for (final item in items) {
      weights[item.metalType] = (weights[item.metalType] ?? 0) + (item.metalWeight * item.quantity);
    }
    return weights;
  }

  // Get total making charges
  double get totalMakingCharges => items.fold(0.0, (sum, item) => sum + item.totalMakingCharges);

  // Get total stone value
  double get totalStoneValue => items.fold(0.0, (sum, item) => sum + item.totalStoneValue);

  // Get total GST amount
  double get totalGSTAmount => items.fold(0.0, (sum, item) => sum + item.gstAmount);

  // Get invoice type display
  String get typeDisplay {
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

  // JSON serialization
  factory JewelryInvoice.fromJson(Map<String, dynamic> json) => _$JewelryInvoiceFromJson(json);
  Map<String, dynamic> toJson() => _$JewelryInvoiceToJson(this);

  // CopyWith method for updating invoice data
  JewelryInvoice copyWith({
    String? invoiceNumber,
    Client? client,
    List<JewelryItem>? items,
    List<ExchangeItem>? exchangeItems,
    DateTime? dueDate,
    DateTime? deliveryDate,
    InvoiceType? type,
    InvoiceStatus? status,
    List<Payment>? payments,
    double? advanceAmount,
    double? roundOffAmount,
    String? notes,
    String? terms,
    bool? isHallmarked,
    String? bankDetails,
    String? transportDetails,
    String? placeOfSupply,
  }) {
    return JewelryInvoice(
      id: id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      client: client ?? this.client,
      items: items ?? this.items,
      exchangeItems: exchangeItems ?? this.exchangeItems,
      createdDate: createdDate,
      dueDate: dueDate ?? this.dueDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      type: type ?? this.type,
      status: status ?? this.status,
      payments: payments ?? this.payments,
      advanceAmount: advanceAmount ?? this.advanceAmount,
      roundOffAmount: roundOffAmount ?? this.roundOffAmount,
      notes: notes ?? this.notes,
      terms: terms ?? this.terms,
      isHallmarked: isHallmarked ?? this.isHallmarked,
      bankDetails: bankDetails ?? this.bankDetails,
      transportDetails: transportDetails ?? this.transportDetails,
      placeOfSupply: placeOfSupply ?? this.placeOfSupply,
    );
  }

  @override
  String toString() {
    return 'JewelryInvoice(id: $id, number: $invoiceNumber, client: ${client.name}, total: $finalAmount, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is JewelryInvoice && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}