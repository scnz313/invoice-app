import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import 'client.dart';
import 'invoice_item.dart';

part 'invoice.g.dart';

enum InvoiceStatus {
  draft,
  sent,
  paid,
  overdue,
  exchanged,
  returned,
}

enum PaymentMethod {
  cash,
  card,
  upi,
  bankTransfer,
  cheque,
  exchange,
  emi,
  other,
}

@JsonSerializable()
class ExchangeDetails {
  final double oldItemWeight;
  final double oldItemValue;
  final String oldItemDescription;
  final double exchangeValue;
  final String exchangeNotes;

  ExchangeDetails({
    required this.oldItemWeight,
    required this.oldItemValue,
    required this.oldItemDescription,
    required this.exchangeValue,
    required this.exchangeNotes,
  });

  factory ExchangeDetails.fromJson(Map<String, dynamic> json) => _$ExchangeDetailsFromJson(json);
  Map<String, dynamic> toJson() => _$ExchangeDetailsToJson(this);

  ExchangeDetails copyWith({
    double? oldItemWeight,
    double? oldItemValue,
    String? oldItemDescription,
    double? exchangeValue,
    String? exchangeNotes,
  }) {
    return ExchangeDetails(
      oldItemWeight: oldItemWeight ?? this.oldItemWeight,
      oldItemValue: oldItemValue ?? this.oldItemValue,
      oldItemDescription: oldItemDescription ?? this.oldItemDescription,
      exchangeValue: exchangeValue ?? this.exchangeValue,
      exchangeNotes: exchangeNotes ?? this.exchangeNotes,
    );
  }
}

@JsonSerializable()
class Invoice {
  final String id;
  final String invoiceNumber;
  final Client client;
  final List<InvoiceItem> items;
  final DateTime createdDate;
  final DateTime dueDate;
  final double taxPercentage;
  final double discountAmount;
  final InvoiceStatus status;
  final String notes;
  
  // Jewelry shop specific fields
  final double? makingCharges;
  final double? wastageCharges;
  final double? exchangeValue;
  final ExchangeDetails? exchangeDetails;
  final PaymentMethod? paymentMethod;
  final String? paymentReference;
  final DateTime? paymentDate;
  final double? advanceAmount;
  final double? balanceAmount;
  final String? salesPerson;
  final String? warrantyDetails;
  final String? returnPolicy;
  final bool isExchange;
  final bool isEMI;
  final int? emiMonths;
  final double? emiAmount;

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.client,
    required this.items,
    required this.createdDate,
    required this.dueDate,
    this.taxPercentage = 0.0,
    this.discountAmount = 0.0,
    this.status = InvoiceStatus.draft,
    this.notes = '',
    this.makingCharges,
    this.wastageCharges,
    this.exchangeValue,
    this.exchangeDetails,
    this.paymentMethod,
    this.paymentReference,
    this.paymentDate,
    this.advanceAmount,
    this.balanceAmount,
    this.salesPerson,
    this.warrantyDetails,
    this.returnPolicy,
    this.isExchange = false,
    this.isEMI = false,
    this.emiMonths,
    this.emiAmount,
  });

  // Factory constructor for creating a new invoice with auto-generated ID and invoice number
  factory Invoice.create({
    required Client client,
    required List<InvoiceItem> items,
    required DateTime dueDate,
    double taxPercentage = 0.0,
    double discountAmount = 0.0,
    String notes = '',
    double? makingCharges,
    double? wastageCharges,
    double? exchangeValue,
    ExchangeDetails? exchangeDetails,
    PaymentMethod? paymentMethod,
    String? salesPerson,
    String? warrantyDetails,
    String? returnPolicy,
    bool isExchange = false,
    bool isEMI = false,
    int? emiMonths,
    double? emiAmount,
  }) {
    final now = DateTime.now();
    return Invoice(
      id: const Uuid().v4(),
      invoiceNumber: _generateInvoiceNumber(now),
      client: client,
      items: items,
      createdDate: now,
      dueDate: dueDate,
      taxPercentage: taxPercentage,
      discountAmount: discountAmount,
      notes: notes,
      makingCharges: makingCharges,
      wastageCharges: wastageCharges,
      exchangeValue: exchangeValue,
      exchangeDetails: exchangeDetails,
      paymentMethod: paymentMethod,
      salesPerson: salesPerson,
      warrantyDetails: warrantyDetails,
      returnPolicy: returnPolicy,
      isExchange: isExchange,
      isEMI: isEMI,
      emiMonths: emiMonths,
      emiAmount: emiAmount,
    );
  }

  static String _generateInvoiceNumber(DateTime date) {
    return 'INV-${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}-${date.millisecondsSinceEpoch.toString().substring(8)}';
  }

  // Calculate subtotal (sum of all items)
  double get subtotal => items.fold(0.0, (sum, item) => sum + item.total);

  // Calculate making charges
  double get totalMakingCharges => makingCharges ?? 0.0;

  // Calculate wastage charges
  double get totalWastageCharges => wastageCharges ?? 0.0;

  // Calculate subtotal with making and wastage charges
  double get subtotalWithCharges => subtotal + totalMakingCharges + totalWastageCharges;

  // Calculate tax amount
  double get taxAmount => subtotalWithCharges * (taxPercentage / 100);

  // Calculate total after tax and discount
  double get total => subtotalWithCharges + taxAmount - discountAmount;

  // Calculate final amount after exchange
  double get finalAmount => total - (exchangeValue ?? 0.0);

  // Calculate EMI amount if applicable
  double get monthlyEMIAmount {
    if (!isEMI || emiMonths == null || emiMonths! <= 0) return 0.0;
    return finalAmount / emiMonths!;
  }

  // Check if invoice is overdue
  bool get isOverdue => status != InvoiceStatus.paid && DateTime.now().isAfter(dueDate);

  // Check if payment is complete
  bool get isPaymentComplete => 
    status == InvoiceStatus.paid || 
    (advanceAmount != null && advanceAmount! >= finalAmount);

  // Get payment status text
  String get paymentStatusText {
    if (status == InvoiceStatus.paid) return 'Paid';
    if (advanceAmount != null && advanceAmount! > 0) {
      if (advanceAmount! >= finalAmount) return 'Paid';
      return 'Partial Payment (${advanceAmount!.toStringAsFixed(2)})';
    }
    return 'Pending';
  }

  // Get payment method display name
  String get paymentMethodDisplay {
    switch (paymentMethod) {
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
      default:
        return 'Not specified';
    }
  }

  // JSON serialization
  factory Invoice.fromJson(Map<String, dynamic> json) => _$InvoiceFromJson(json);
  Map<String, dynamic> toJson() => _$InvoiceToJson(this);

  // CopyWith method for updating invoice data
  Invoice copyWith({
    String? invoiceNumber,
    Client? client,
    List<InvoiceItem>? items,
    DateTime? dueDate,
    double? taxPercentage,
    double? discountAmount,
    InvoiceStatus? status,
    String? notes,
    double? makingCharges,
    double? wastageCharges,
    double? exchangeValue,
    ExchangeDetails? exchangeDetails,
    PaymentMethod? paymentMethod,
    String? paymentReference,
    DateTime? paymentDate,
    double? advanceAmount,
    double? balanceAmount,
    String? salesPerson,
    String? warrantyDetails,
    String? returnPolicy,
    bool? isExchange,
    bool? isEMI,
    int? emiMonths,
    double? emiAmount,
  }) {
    return Invoice(
      id: id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      client: client ?? this.client,
      items: items ?? this.items,
      createdDate: createdDate,
      dueDate: dueDate ?? this.dueDate,
      taxPercentage: taxPercentage ?? this.taxPercentage,
      discountAmount: discountAmount ?? this.discountAmount,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      makingCharges: makingCharges ?? this.makingCharges,
      wastageCharges: wastageCharges ?? this.wastageCharges,
      exchangeValue: exchangeValue ?? this.exchangeValue,
      exchangeDetails: exchangeDetails ?? this.exchangeDetails,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentReference: paymentReference ?? this.paymentReference,
      paymentDate: paymentDate ?? this.paymentDate,
      advanceAmount: advanceAmount ?? this.advanceAmount,
      balanceAmount: balanceAmount ?? this.balanceAmount,
      salesPerson: salesPerson ?? this.salesPerson,
      warrantyDetails: warrantyDetails ?? this.warrantyDetails,
      returnPolicy: returnPolicy ?? this.returnPolicy,
      isExchange: isExchange ?? this.isExchange,
      isEMI: isEMI ?? this.isEMI,
      emiMonths: emiMonths ?? this.emiMonths,
      emiAmount: emiAmount ?? this.emiAmount,
    );
  }

  @override
  String toString() {
    return 'Invoice(id: $id, number: $invoiceNumber, client: ${client.name}, total: $total, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Invoice && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 