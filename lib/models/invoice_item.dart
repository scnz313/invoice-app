import 'package:json_annotation/json_annotation.dart';

part 'invoice_item.g.dart';

enum JewelryType {
  ring,
  necklace,
  bracelet,
  earrings,
  pendant,
  chain,
  bangles,
  anklet,
  other,
}

enum MetalType {
  gold,
  silver,
  platinum,
  whiteGold,
  roseGold,
  other,
}

enum StoneType {
  diamond,
  ruby,
  emerald,
  sapphire,
  pearl,
  other,
  none,
}

@JsonSerializable()
class StoneDetails {
  final StoneType type;
  final double weight; // in carats
  final String color;
  final String clarity;
  final String cut;
  final String certification;

  StoneDetails({
    required this.type,
    required this.weight,
    required this.color,
    required this.clarity,
    required this.cut,
    required this.certification,
  });

  factory StoneDetails.fromJson(Map<String, dynamic> json) => _$StoneDetailsFromJson(json);
  Map<String, dynamic> toJson() => _$StoneDetailsToJson(this);

  StoneDetails copyWith({
    StoneType? type,
    double? weight,
    String? color,
    String? clarity,
    String? cut,
    String? certification,
  }) {
    return StoneDetails(
      type: type ?? this.type,
      weight: weight ?? this.weight,
      color: color ?? this.color,
      clarity: clarity ?? this.clarity,
      cut: cut ?? this.cut,
      certification: certification ?? this.certification,
    );
  }
}

@JsonSerializable()
class InvoiceItem {
  final String description;
  final int quantity;
  final double price;
  
  // Jewelry-specific fields
  final JewelryType? jewelryType;
  final MetalType? metalType;
  final double? weight; // in grams
  final double? purity; // karat for gold, percentage for others
  final StoneDetails? stoneDetails;
  final String? hallmarks;
  final String? certification;
  final String? size; // for rings, bracelets, etc.
  final String? designCode;
  final String? brand;

  InvoiceItem({
    required this.description,
    required this.quantity,
    required this.price,
    this.jewelryType,
    this.metalType,
    this.weight,
    this.purity,
    this.stoneDetails,
    this.hallmarks,
    this.certification,
    this.size,
    this.designCode,
    this.brand,
  });

  // Calculate total for this item
  double get total => quantity * price;

  // Get jewelry type display name
  String get jewelryTypeDisplay {
    switch (jewelryType) {
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
      default:
        return 'N/A';
    }
  }

  // Get metal type display name
  String get metalTypeDisplay {
    switch (metalType) {
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
      default:
        return 'N/A';
    }
  }

  // Get stone type display name
  String get stoneTypeDisplay {
    if (stoneDetails == null) return 'N/A';
    switch (stoneDetails!.type) {
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
      default:
        return 'N/A';
    }
  }

  // Check if item has jewelry details
  bool get hasJewelryDetails => 
    jewelryType != null || 
    metalType != null || 
    weight != null || 
    purity != null || 
    stoneDetails != null;

  // JSON serialization
  factory InvoiceItem.fromJson(Map<String, dynamic> json) => _$InvoiceItemFromJson(json);
  Map<String, dynamic> toJson() => _$InvoiceItemToJson(this);

  // CopyWith method for updating item data
  InvoiceItem copyWith({
    String? description,
    int? quantity,
    double? price,
    JewelryType? jewelryType,
    MetalType? metalType,
    double? weight,
    double? purity,
    StoneDetails? stoneDetails,
    String? hallmarks,
    String? certification,
    String? size,
    String? designCode,
    String? brand,
  }) {
    return InvoiceItem(
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      jewelryType: jewelryType ?? this.jewelryType,
      metalType: metalType ?? this.metalType,
      weight: weight ?? this.weight,
      purity: purity ?? this.purity,
      stoneDetails: stoneDetails ?? this.stoneDetails,
      hallmarks: hallmarks ?? this.hallmarks,
      certification: certification ?? this.certification,
      size: size ?? this.size,
      designCode: designCode ?? this.designCode,
      brand: brand ?? this.brand,
    );
  }

  @override
  String toString() {
    return 'InvoiceItem(description: $description, quantity: $quantity, price: $price, total: $total, jewelryType: $jewelryTypeDisplay)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InvoiceItem &&
        other.description == description &&
        other.quantity == quantity &&
        other.price == price &&
        other.jewelryType == jewelryType &&
        other.metalType == metalType &&
        other.weight == weight &&
        other.purity == purity &&
        other.stoneDetails == stoneDetails;
  }

  @override
  int get hashCode => 
    description.hashCode ^ 
    quantity.hashCode ^ 
    price.hashCode ^ 
    jewelryType.hashCode ^ 
    metalType.hashCode ^ 
    weight.hashCode ^ 
    purity.hashCode ^ 
    stoneDetails.hashCode;
} 