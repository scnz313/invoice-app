import 'package:json_annotation/json_annotation.dart';

part 'invoice_item.g.dart';

@JsonSerializable()
class InvoiceItem {
  final String description;
  final int quantity;
  final double price;

  InvoiceItem({
    required this.description,
    required this.quantity,
    required this.price,
  });

  // Calculate total for this item
  double get total => quantity * price;

  // JSON serialization
  factory InvoiceItem.fromJson(Map<String, dynamic> json) => _$InvoiceItemFromJson(json);
  Map<String, dynamic> toJson() => _$InvoiceItemToJson(this);

  // CopyWith method for updating item data
  InvoiceItem copyWith({
    String? description,
    int? quantity,
    double? price,
  }) {
    return InvoiceItem(
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }

  @override
  String toString() {
    return 'InvoiceItem(description: $description, quantity: $quantity, price: $price, total: $total)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InvoiceItem &&
        other.description == description &&
        other.quantity == quantity &&
        other.price == price;
  }

  @override
  int get hashCode => description.hashCode ^ quantity.hashCode ^ price.hashCode;
} 