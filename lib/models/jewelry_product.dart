import 'package:flutter/material.dart';

enum JewelryType {
  rings,
  necklaces,
  earrings,
  bracelets,
  watches,
  pendants,
  anklets,
  weddingBands,
  diamondJewelry,
  goldJewelry,
  silverJewelry,
  platinumJewelry,
}

enum MetalType {
  gold,
  silver,
  platinum,
  whiteGold,
  roseGold,
  palladium,
  titanium,
  stainlessSteel,
}

enum GemstoneType {
  diamond,
  ruby,
  emerald,
  sapphire,
  pearl,
  opal,
  amethyst,
  garnet,
  topaz,
  aquamarine,
  citrine,
  peridot,
  tanzanite,
  other,
}

enum CertificationType {
  gia,
  igi,
  sgl,
  bgi,
  local,
  none,
}

enum WarrantyType {
  manufacturer,
  store,
  extended,
  lifetime,
  none,
}

class JewelryProduct {
  final String id;
  final String name;
  final String description;
  final JewelryType type;
  final MetalType metalType;
  final double metalPurity; // Karat for gold, percentage for others
  final double weight; // in grams
  final double makingCharges;
  final double stoneWeight; // in carats
  final GemstoneType? gemstoneType;
  final String? gemstoneColor;
  final String? gemstoneClarity;
  final String? gemstoneCut;
  final CertificationType? certificationType;
  final String? certificationNumber;
  final String? hallmarkNumber;
  final double costPrice;
  final double sellingPrice;
  final double markupPercentage;
  final int stockQuantity;
  final int reorderPoint;
  final String? brand;
  final String? collection;
  final String? designNumber;
  final String? serialNumber;
  final WarrantyType warrantyType;
  final int warrantyPeriod; // in months
  final String? warrantyTerms;
  final bool isCustomDesign;
  final bool isLayawayEligible;
  final double layawayPercentage;
  final int layawayPeriod; // in months
  final bool isInsuranceEligible;
  final String? insuranceDetails;
  final List<String> images;
  final List<String> tags;
  final String? supplierId;
  final String? supplierName;
  final DateTime? manufacturingDate;
  final DateTime? purchaseDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  JewelryProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.metalType,
    required this.metalPurity,
    required this.weight,
    required this.makingCharges,
    this.stoneWeight = 0,
    this.gemstoneType,
    this.gemstoneColor,
    this.gemstoneClarity,
    this.gemstoneCut,
    this.certificationType,
    this.certificationNumber,
    this.hallmarkNumber,
    required this.costPrice,
    required this.sellingPrice,
    required this.markupPercentage,
    required this.stockQuantity,
    required this.reorderPoint,
    this.brand,
    this.collection,
    this.designNumber,
    this.serialNumber,
    required this.warrantyType,
    required this.warrantyPeriod,
    this.warrantyTerms,
    this.isCustomDesign = false,
    this.isLayawayEligible = false,
    this.layawayPercentage = 0,
    this.layawayPeriod = 0,
    this.isInsuranceEligible = false,
    this.insuranceDetails,
    this.images = const [],
    this.tags = const [],
    this.supplierId,
    this.supplierName,
    this.manufacturingDate,
    this.purchaseDate,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  // Calculate total value including making charges
  double get totalValue => costPrice + makingCharges;

  // Calculate profit margin
  double get profitMargin => ((sellingPrice - totalValue) / sellingPrice) * 100;

  // Calculate profit amount
  double get profitAmount => sellingPrice - totalValue;

  // Check if low stock
  bool get isLowStock => stockQuantity <= reorderPoint;

  // Check if out of stock
  bool get isOutOfStock => stockQuantity == 0;

  // Get metal purity display text
  String get metalPurityDisplay {
    switch (metalType) {
      case MetalType.gold:
        return '${metalPurity}K';
      case MetalType.silver:
      case MetalType.platinum:
      case MetalType.whiteGold:
      case MetalType.roseGold:
      case MetalType.palladium:
        return '${metalPurity}%';
      case MetalType.titanium:
      case MetalType.stainlessSteel:
        return 'Pure';
    }
  }

  // Get warranty display text
  String get warrantyDisplay {
    switch (warrantyType) {
      case WarrantyType.manufacturer:
        return 'Manufacturer Warranty';
      case WarrantyType.store:
        return 'Store Warranty';
      case WarrantyType.extended:
        return 'Extended Warranty';
      case WarrantyType.lifetime:
        return 'Lifetime Warranty';
      case WarrantyType.none:
        return 'No Warranty';
    }
  }

  // Get certification display text
  String get certificationDisplay {
    if (certificationType == null) return 'No Certification';
    
    switch (certificationType!) {
      case CertificationType.gia:
        return 'GIA Certified';
      case CertificationType.igi:
        return 'IGI Certified';
      case CertificationType.sgl:
        return 'SGL Certified';
      case CertificationType.bgi:
        return 'BGI Certified';
      case CertificationType.local:
        return 'Locally Certified';
      case CertificationType.none:
        return 'No Certification';
    }
  }

  // Get layaway display text
  String get layawayDisplay {
    if (!isLayawayEligible) return 'Not Available';
    return '${layawayPercentage}% down, ${layawayPeriod} months';
  }

  // Get insurance display text
  String get insuranceDisplay {
    if (!isInsuranceEligible) return 'Not Available';
    return 'Eligible';
  }

  // Create copy with updated values
  JewelryProduct copyWith({
    String? id,
    String? name,
    String? description,
    JewelryType? type,
    MetalType? metalType,
    double? metalPurity,
    double? weight,
    double? makingCharges,
    double? stoneWeight,
    GemstoneType? gemstoneType,
    String? gemstoneColor,
    String? gemstoneClarity,
    String? gemstoneCut,
    CertificationType? certificationType,
    String? certificationNumber,
    String? hallmarkNumber,
    double? costPrice,
    double? sellingPrice,
    double? markupPercentage,
    int? stockQuantity,
    int? reorderPoint,
    String? brand,
    String? collection,
    String? designNumber,
    String? serialNumber,
    WarrantyType? warrantyType,
    int? warrantyPeriod,
    String? warrantyTerms,
    bool? isCustomDesign,
    bool? isLayawayEligible,
    double? layawayPercentage,
    int? layawayPeriod,
    bool? isInsuranceEligible,
    String? insuranceDetails,
    List<String>? images,
    List<String>? tags,
    String? supplierId,
    String? supplierName,
    DateTime? manufacturingDate,
    DateTime? purchaseDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return JewelryProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      metalType: metalType ?? this.metalType,
      metalPurity: metalPurity ?? this.metalPurity,
      weight: weight ?? this.weight,
      makingCharges: makingCharges ?? this.makingCharges,
      stoneWeight: stoneWeight ?? this.stoneWeight,
      gemstoneType: gemstoneType ?? this.gemstoneType,
      gemstoneColor: gemstoneColor ?? this.gemstoneColor,
      gemstoneClarity: gemstoneClarity ?? this.gemstoneClarity,
      gemstoneCut: gemstoneCut ?? this.gemstoneCut,
      certificationType: certificationType ?? this.certificationType,
      certificationNumber: certificationNumber ?? this.certificationNumber,
      hallmarkNumber: hallmarkNumber ?? this.hallmarkNumber,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      markupPercentage: markupPercentage ?? this.markupPercentage,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      reorderPoint: reorderPoint ?? this.reorderPoint,
      brand: brand ?? this.brand,
      collection: collection ?? this.collection,
      designNumber: designNumber ?? this.designNumber,
      serialNumber: serialNumber ?? this.serialNumber,
      warrantyType: warrantyType ?? this.warrantyType,
      warrantyPeriod: warrantyPeriod ?? this.warrantyPeriod,
      warrantyTerms: warrantyTerms ?? this.warrantyTerms,
      isCustomDesign: isCustomDesign ?? this.isCustomDesign,
      isLayawayEligible: isLayawayEligible ?? this.isLayawayEligible,
      layawayPercentage: layawayPercentage ?? this.layawayPercentage,
      layawayPeriod: layawayPeriod ?? this.layawayPeriod,
      isInsuranceEligible: isInsuranceEligible ?? this.isInsuranceEligible,
      insuranceDetails: insuranceDetails ?? this.insuranceDetails,
      images: images ?? this.images,
      tags: tags ?? this.tags,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      manufacturingDate: manufacturingDate ?? this.manufacturingDate,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'metalType': metalType.name,
      'metalPurity': metalPurity,
      'weight': weight,
      'makingCharges': makingCharges,
      'stoneWeight': stoneWeight,
      'gemstoneType': gemstoneType?.name,
      'gemstoneColor': gemstoneColor,
      'gemstoneClarity': gemstoneClarity,
      'gemstoneCut': gemstoneCut,
      'certificationType': certificationType?.name,
      'certificationNumber': certificationNumber,
      'hallmarkNumber': hallmarkNumber,
      'costPrice': costPrice,
      'sellingPrice': sellingPrice,
      'markupPercentage': markupPercentage,
      'stockQuantity': stockQuantity,
      'reorderPoint': reorderPoint,
      'brand': brand,
      'collection': collection,
      'designNumber': designNumber,
      'serialNumber': serialNumber,
      'warrantyType': warrantyType.name,
      'warrantyPeriod': warrantyPeriod,
      'warrantyTerms': warrantyTerms,
      'isCustomDesign': isCustomDesign,
      'isLayawayEligible': isLayawayEligible,
      'layawayPercentage': layawayPercentage,
      'layawayPeriod': layawayPeriod,
      'isInsuranceEligible': isInsuranceEligible,
      'insuranceDetails': insuranceDetails,
      'images': images,
      'tags': tags,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'manufacturingDate': manufacturingDate?.toIso8601String(),
      'purchaseDate': purchaseDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  // Create from JSON
  factory JewelryProduct.fromJson(Map<String, dynamic> json) {
    return JewelryProduct(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: JewelryType.values.firstWhere((e) => e.name == json['type']),
      metalType: MetalType.values.firstWhere((e) => e.name == json['metalType']),
      metalPurity: json['metalPurity'].toDouble(),
      weight: json['weight'].toDouble(),
      makingCharges: json['makingCharges'].toDouble(),
      stoneWeight: json['stoneWeight']?.toDouble() ?? 0,
      gemstoneType: json['gemstoneType'] != null 
          ? GemstoneType.values.firstWhere((e) => e.name == json['gemstoneType'])
          : null,
      gemstoneColor: json['gemstoneColor'],
      gemstoneClarity: json['gemstoneClarity'],
      gemstoneCut: json['gemstoneCut'],
      certificationType: json['certificationType'] != null
          ? CertificationType.values.firstWhere((e) => e.name == json['certificationType'])
          : null,
      certificationNumber: json['certificationNumber'],
      hallmarkNumber: json['hallmarkNumber'],
      costPrice: json['costPrice'].toDouble(),
      sellingPrice: json['sellingPrice'].toDouble(),
      markupPercentage: json['markupPercentage'].toDouble(),
      stockQuantity: json['stockQuantity'],
      reorderPoint: json['reorderPoint'],
      brand: json['brand'],
      collection: json['collection'],
      designNumber: json['designNumber'],
      serialNumber: json['serialNumber'],
      warrantyType: WarrantyType.values.firstWhere((e) => e.name == json['warrantyType']),
      warrantyPeriod: json['warrantyPeriod'],
      warrantyTerms: json['warrantyTerms'],
      isCustomDesign: json['isCustomDesign'] ?? false,
      isLayawayEligible: json['isLayawayEligible'] ?? false,
      layawayPercentage: json['layawayPercentage']?.toDouble() ?? 0,
      layawayPeriod: json['layawayPeriod'] ?? 0,
      isInsuranceEligible: json['isInsuranceEligible'] ?? false,
      insuranceDetails: json['insuranceDetails'],
      images: List<String>.from(json['images'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      supplierId: json['supplierId'],
      supplierName: json['supplierName'],
      manufacturingDate: json['manufacturingDate'] != null 
          ? DateTime.parse(json['manufacturingDate'])
          : null,
      purchaseDate: json['purchaseDate'] != null 
          ? DateTime.parse(json['purchaseDate'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isActive: json['isActive'] ?? true,
    );
  }
}

// Extension for display names
extension JewelryTypeExtension on JewelryType {
  String get displayName {
    switch (this) {
      case JewelryType.rings:
        return 'Rings';
      case JewelryType.necklaces:
        return 'Necklaces';
      case JewelryType.earrings:
        return 'Earrings';
      case JewelryType.bracelets:
        return 'Bracelets';
      case JewelryType.watches:
        return 'Watches';
      case JewelryType.pendants:
        return 'Pendants';
      case JewelryType.anklets:
        return 'Anklets';
      case JewelryType.weddingBands:
        return 'Wedding Bands';
      case JewelryType.diamondJewelry:
        return 'Diamond Jewelry';
      case JewelryType.goldJewelry:
        return 'Gold Jewelry';
      case JewelryType.silverJewelry:
        return 'Silver Jewelry';
      case JewelryType.platinumJewelry:
        return 'Platinum Jewelry';
    }
  }

  IconData get icon {
    switch (this) {
      case JewelryType.rings:
        return Icons.circle;
      case JewelryType.necklaces:
        return Icons.favorite;
      case JewelryType.earrings:
        return Icons.radio_button_checked;
      case JewelryType.bracelets:
        return Icons.circle_outlined;
      case JewelryType.watches:
        return Icons.watch;
      case JewelryType.pendants:
        return Icons.favorite_border;
      case JewelryType.anklets:
        return Icons.circle_outlined;
      case JewelryType.weddingBands:
        return Icons.favorite;
      case JewelryType.diamondJewelry:
        return Icons.diamond;
      case JewelryType.goldJewelry:
        return Icons.star;
      case JewelryType.silverJewelry:
        return Icons.star_border;
      case JewelryType.platinumJewelry:
        return Icons.star_half;
    }
  }
}

extension MetalTypeExtension on MetalType {
  String get displayName {
    switch (this) {
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
      case MetalType.palladium:
        return 'Palladium';
      case MetalType.titanium:
        return 'Titanium';
      case MetalType.stainlessSteel:
        return 'Stainless Steel';
    }
  }

  Color get color {
    switch (this) {
      case MetalType.gold:
        return Colors.amber;
      case MetalType.silver:
        return Colors.grey;
      case MetalType.platinum:
        return Colors.blueGrey;
      case MetalType.whiteGold:
        return Colors.white;
      case MetalType.roseGold:
        return Colors.pink;
      case MetalType.palladium:
        return Colors.grey;
      case MetalType.titanium:
        return Colors.grey;
      case MetalType.stainlessSteel:
        return Colors.grey;
    }
  }
}

extension GemstoneTypeExtension on GemstoneType {
  String get displayName {
    switch (this) {
      case GemstoneType.diamond:
        return 'Diamond';
      case GemstoneType.ruby:
        return 'Ruby';
      case GemstoneType.emerald:
        return 'Emerald';
      case GemstoneType.sapphire:
        return 'Sapphire';
      case GemstoneType.pearl:
        return 'Pearl';
      case GemstoneType.opal:
        return 'Opal';
      case GemstoneType.amethyst:
        return 'Amethyst';
      case GemstoneType.garnet:
        return 'Garnet';
      case GemstoneType.topaz:
        return 'Topaz';
      case GemstoneType.aquamarine:
        return 'Aquamarine';
      case GemstoneType.citrine:
        return 'Citrine';
      case GemstoneType.peridot:
        return 'Peridot';
      case GemstoneType.tanzanite:
        return 'Tanzanite';
      case GemstoneType.other:
        return 'Other';
    }
  }

  Color get color {
    switch (this) {
      case GemstoneType.diamond:
        return Colors.white;
      case GemstoneType.ruby:
        return Colors.red;
      case GemstoneType.emerald:
        return Colors.green;
      case GemstoneType.sapphire:
        return Colors.blue;
      case GemstoneType.pearl:
        return Colors.white;
      case GemstoneType.opal:
        return Colors.orange;
      case GemstoneType.amethyst:
        return Colors.purple;
      case GemstoneType.garnet:
        return Colors.red;
      case GemstoneType.topaz:
        return Colors.yellow;
      case GemstoneType.aquamarine:
        return Colors.cyan;
      case GemstoneType.citrine:
        return Colors.orange;
      case GemstoneType.peridot:
        return Colors.green;
      case GemstoneType.tanzanite:
        return Colors.blue;
      case GemstoneType.other:
        return Colors.grey;
    }
  }
}