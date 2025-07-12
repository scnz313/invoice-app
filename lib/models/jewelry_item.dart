import 'package:json_annotation/json_annotation.dart';

part 'jewelry_item.g.dart';

enum MetalType {
  gold,
  silver,
  platinum,
  whitegold,
  rosegold,
  copper,
  brass,
  other,
}

enum GoldPurity {
  k14('14K', 14),
  k18('18K', 18),
  k22('22K', 22),
  k24('24K', 24);

  const GoldPurity(this.display, this.karat);
  final String display;
  final int karat;
}

enum SilverPurity {
  silver925('925', 92.5),
  silver999('999', 99.9);

  const SilverPurity(this.display, this.purity);
  final String display;
  final double purity;
}

enum JewelryCategory {
  rings,
  earrings,
  necklace,
  bracelet,
  chain,
  pendant,
  bangles,
  anklet,
  nosering,
  coins,
  bars,
  other,
}

@JsonSerializable()
class Stone {
  final String name;
  final int quantity;
  final double weight; // in carats
  final double price;
  final String? quality;
  final String? color;
  final String? cut;

  Stone({
    required this.name,
    required this.quantity,
    required this.weight,
    required this.price,
    this.quality,
    this.color,
    this.cut,
  });

  double get totalValue => quantity * price;

  factory Stone.fromJson(Map<String, dynamic> json) => _$StoneFromJson(json);
  Map<String, dynamic> toJson() => _$StoneToJson(this);
}

@JsonSerializable()
class JewelryItem {
  final String id;
  final String name;
  final String description;
  final JewelryCategory category;
  final MetalType metalType;
  final GoldPurity? goldPurity;
  final SilverPurity? silverPurity;
  final double metalWeight; // in grams
  final double metalRate; // per gram
  final double makingCharges; // per gram or fixed amount
  final bool isMakingChargesPerGram;
  final List<Stone> stones;
  final int quantity;
  final double wastagePercentage;
  final String? hsnCode;
  final String? hallmarkNumber;
  final double gstPercentage;
  final double discount;
  final String? designCode;
  final String? imageUrl;
  final String? notes;

  JewelryItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.metalType,
    this.goldPurity,
    this.silverPurity,
    required this.metalWeight,
    required this.metalRate,
    required this.makingCharges,
    this.isMakingChargesPerGram = true,
    this.stones = const [],
    required this.quantity,
    this.wastagePercentage = 0.0,
    this.hsnCode,
    this.hallmarkNumber,
    this.gstPercentage = 3.0,
    this.discount = 0.0,
    this.designCode,
    this.imageUrl,
    this.notes,
  });

  // Calculate metal value with wastage
  double get metalValueWithWastage {
    final wastageAmount = (metalWeight * wastagePercentage / 100);
    return (metalWeight + wastageAmount) * metalRate;
  }

  // Calculate total making charges
  double get totalMakingCharges {
    if (isMakingChargesPerGram) {
      return metalWeight * makingCharges;
    } else {
      return makingCharges;
    }
  }

  // Calculate total stone value
  double get totalStoneValue {
    return stones.fold(0.0, (sum, stone) => sum + stone.totalValue);
  }

  // Calculate subtotal (metal + making + stones)
  double get subtotal {
    return metalValueWithWastage + totalMakingCharges + totalStoneValue;
  }

  // Calculate discount amount
  double get discountAmount {
    return subtotal * (discount / 100);
  }

  // Calculate amount after discount
  double get amountAfterDiscount {
    return subtotal - discountAmount;
  }

  // Calculate GST amount
  double get gstAmount {
    return amountAfterDiscount * (gstPercentage / 100);
  }

  // Calculate total amount per piece
  double get totalAmountPerPiece {
    return amountAfterDiscount + gstAmount;
  }

  // Calculate total amount for all quantities
  double get totalAmount {
    return totalAmountPerPiece * quantity;
  }

  // Get metal purity display
  String get metalPurityDisplay {
    switch (metalType) {
      case MetalType.gold:
      case MetalType.whitegold:
      case MetalType.rosegold:
        return goldPurity?.display ?? 'Not specified';
      case MetalType.silver:
        return silverPurity?.display ?? 'Not specified';
      case MetalType.platinum:
        return '950';
      default:
        return 'N/A';
    }
  }

  // Get category display name
  String get categoryDisplay {
    switch (category) {
      case JewelryCategory.rings:
        return 'Rings';
      case JewelryCategory.earrings:
        return 'Earrings';
      case JewelryCategory.necklace:
        return 'Necklace';
      case JewelryCategory.bracelet:
        return 'Bracelet';
      case JewelryCategory.chain:
        return 'Chain';
      case JewelryCategory.pendant:
        return 'Pendant';
      case JewelryCategory.bangles:
        return 'Bangles';
      case JewelryCategory.anklet:
        return 'Anklet';
      case JewelryCategory.nosering:
        return 'Nose Ring';
      case JewelryCategory.coins:
        return 'Coins';
      case JewelryCategory.bars:
        return 'Bars';
      case JewelryCategory.other:
        return 'Other';
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
      case MetalType.whitegold:
        return 'White Gold';
      case MetalType.rosegold:
        return 'Rose Gold';
      case MetalType.copper:
        return 'Copper';
      case MetalType.brass:
        return 'Brass';
      case MetalType.other:
        return 'Other';
    }
  }

  factory JewelryItem.fromJson(Map<String, dynamic> json) => _$JewelryItemFromJson(json);
  Map<String, dynamic> toJson() => _$JewelryItemToJson(this);

  JewelryItem copyWith({
    String? name,
    String? description,
    JewelryCategory? category,
    MetalType? metalType,
    GoldPurity? goldPurity,
    SilverPurity? silverPurity,
    double? metalWeight,
    double? metalRate,
    double? makingCharges,
    bool? isMakingChargesPerGram,
    List<Stone>? stones,
    int? quantity,
    double? wastagePercentage,
    String? hsnCode,
    String? hallmarkNumber,
    double? gstPercentage,
    double? discount,
    String? designCode,
    String? imageUrl,
    String? notes,
  }) {
    return JewelryItem(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      metalType: metalType ?? this.metalType,
      goldPurity: goldPurity ?? this.goldPurity,
      silverPurity: silverPurity ?? this.silverPurity,
      metalWeight: metalWeight ?? this.metalWeight,
      metalRate: metalRate ?? this.metalRate,
      makingCharges: makingCharges ?? this.makingCharges,
      isMakingChargesPerGram: isMakingChargesPerGram ?? this.isMakingChargesPerGram,
      stones: stones ?? this.stones,
      quantity: quantity ?? this.quantity,
      wastagePercentage: wastagePercentage ?? this.wastagePercentage,
      hsnCode: hsnCode ?? this.hsnCode,
      hallmarkNumber: hallmarkNumber ?? this.hallmarkNumber,
      gstPercentage: gstPercentage ?? this.gstPercentage,
      discount: discount ?? this.discount,
      designCode: designCode ?? this.designCode,
      imageUrl: imageUrl ?? this.imageUrl,
      notes: notes ?? this.notes,
    );
  }
}