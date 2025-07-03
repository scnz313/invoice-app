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
  });

  // Factory constructor for creating a new invoice with auto-generated ID and invoice number
  factory Invoice.create({
    required Client client,
    required List<InvoiceItem> items,
    required DateTime dueDate,
    double taxPercentage = 0.0,
    double discountAmount = 0.0,
    String notes = '',
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
    );
  }

  static String _generateInvoiceNumber(DateTime date) {
    return 'INV-${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}-${date.millisecondsSinceEpoch.toString().substring(8)}';
  }

  // Calculate subtotal (sum of all items)
  double get subtotal => items.fold(0.0, (sum, item) => sum + item.total);

  // Calculate tax amount
  double get taxAmount => subtotal * (taxPercentage / 100);

  // Calculate total after tax and discount
  double get total => subtotal + taxAmount - discountAmount;

  // Check if invoice is overdue
  bool get isOverdue => status != InvoiceStatus.paid && DateTime.now().isAfter(dueDate);

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