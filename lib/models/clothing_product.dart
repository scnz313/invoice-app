import 'package:flutter/material.dart';

enum ClothingCategory {
  mensClothing,
  womensClothing,
  kidsClothing,
  accessories,
  shoes,
  bags,
  jewelry,
  watches,
  sunglasses,
  belts,
  scarves,
  hats,
}

enum SizeType {
  numeric, // 28, 30, 32, etc.
  alphabetic, // XS, S, M, L, XL, XXL
  shoe, // 6, 7, 8, 9, 10, etc.
  age, // 2Y, 4Y, 6Y, etc.
  custom, // Custom sizes
}

enum Season {
  spring,
  summer,
  autumn,
  winter,
  allSeason,
}

enum BrandTier {
  luxury,
  premium,
  midRange,
  budget,
  local,
}

enum MaterialType {
  cotton,
  polyester,
  wool,
  silk,
  linen,
  denim,
  leather,
  synthetic,
  blend,
  other,
}

class ClothingProduct {
  final String id;
  final String name;
  final String description;
  final ClothingCategory category;
  final String? brand;
  final BrandTier? brandTier;
  final String? collection;
  final Season season;
  final MaterialType materialType;
  final String? materialComposition;
  final double costPrice;
  final double sellingPrice;
  final double? discountedPrice;
  final double markupPercentage;
  final List<SizeVariant> sizeVariants;
  final List<ColorVariant> colorVariants;
  final int totalStockQuantity;
  final int reorderPoint;
  final String? sku;
  final String? barcode;
  final String? styleNumber;
  final String? modelNumber;
  final String? countryOfOrigin;
  final String? careInstructions;
  final bool isSustainable;
  final bool isEcoFriendly;
  final bool isHandmade;
  final bool isLimitedEdition;
  final bool isOnSale;
  final bool isNewArrival;
  final bool isBestSeller;
  final bool isTrending;
  final double? rating;
  final int? reviewCount;
  final List<String> images;
  final List<String> tags;
  final String? supplierId;
  final String? supplierName;
  final DateTime? manufacturingDate;
  final DateTime? arrivalDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  ClothingProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.brand,
    this.brandTier,
    this.collection,
    required this.season,
    required this.materialType,
    this.materialComposition,
    required this.costPrice,
    required this.sellingPrice,
    this.discountedPrice,
    required this.markupPercentage,
    required this.sizeVariants,
    required this.colorVariants,
    required this.totalStockQuantity,
    required this.reorderPoint,
    this.sku,
    this.barcode,
    this.styleNumber,
    this.modelNumber,
    this.countryOfOrigin,
    this.careInstructions,
    this.isSustainable = false,
    this.isEcoFriendly = false,
    this.isHandmade = false,
    this.isLimitedEdition = false,
    this.isOnSale = false,
    this.isNewArrival = false,
    this.isBestSeller = false,
    this.isTrending = false,
    this.rating,
    this.reviewCount,
    this.images = const [],
    this.tags = const [],
    this.supplierId,
    this.supplierName,
    this.manufacturingDate,
    this.arrivalDate,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  // Calculate discount percentage
  double? get discountPercentage {
    if (discountedPrice == null || discountedPrice! >= sellingPrice) return null;
    return ((sellingPrice - discountedPrice!) / sellingPrice) * 100;
  }

  // Get final price (discounted or original)
  double get finalPrice => discountedPrice ?? sellingPrice;

  // Check if item is on discount
  bool get isOnDiscount => discountedPrice != null && discountedPrice! < sellingPrice;

  // Calculate profit margin
  double get profitMargin => ((finalPrice - costPrice) / finalPrice) * 100;

  // Calculate profit amount
  double get profitAmount => finalPrice - costPrice;

  // Check if low stock
  bool get isLowStock => totalStockQuantity <= reorderPoint;

  // Check if out of stock
  bool get isOutOfStock => totalStockQuantity == 0;

  // Get available sizes
  List<String> get availableSizes {
    return sizeVariants
        .where((variant) => variant.stockQuantity > 0)
        .map((variant) => variant.size)
        .toList();
  }

  // Get available colors
  List<String> get availableColors {
    return colorVariants
        .where((variant) => variant.stockQuantity > 0)
        .map((variant) => variant.colorName)
        .toList();
  }

  // Get size variants with stock
  List<SizeVariant> get sizeVariantsWithStock {
    return sizeVariants.where((variant) => variant.stockQuantity > 0).toList();
  }

  // Get color variants with stock
  List<ColorVariant> get colorVariantsWithStock {
    return colorVariants.where((variant) => variant.stockQuantity > 0).toList();
  }

  // Get total value
  double get totalValue => costPrice * totalStockQuantity;

  // Get rating display
  String get ratingDisplay {
    if (rating == null) return 'No ratings';
    return '${rating!.toStringAsFixed(1)} (${reviewCount ?? 0} reviews)';
  }

  // Get brand tier display
  String get brandTierDisplay {
    if (brandTier == null) return 'Unknown';
    
    switch (brandTier!) {
      case BrandTier.luxury:
        return 'Luxury';
      case BrandTier.premium:
        return 'Premium';
      case BrandTier.midRange:
        return 'Mid-Range';
      case BrandTier.budget:
        return 'Budget';
      case BrandTier.local:
        return 'Local';
    }
  }

  // Get season display
  String get seasonDisplay {
    switch (season) {
      case Season.spring:
        return 'Spring';
      case Season.summer:
        return 'Summer';
      case Season.autumn:
        return 'Autumn';
      case Season.winter:
        return 'Winter';
      case Season.allSeason:
        return 'All Season';
    }
  }

  // Get material display
  String get materialDisplay {
    switch (materialType) {
      case MaterialType.cotton:
        return 'Cotton';
      case MaterialType.polyester:
        return 'Polyester';
      case MaterialType.wool:
        return 'Wool';
      case MaterialType.silk:
        return 'Silk';
      case MaterialType.linen:
        return 'Linen';
      case MaterialType.denim:
        return 'Denim';
      case MaterialType.leather:
        return 'Leather';
      case MaterialType.synthetic:
        return 'Synthetic';
      case MaterialType.blend:
        return 'Blend';
      case MaterialType.other:
        return 'Other';
    }
  }

  // Create copy with updated values
  ClothingProduct copyWith({
    String? id,
    String? name,
    String? description,
    ClothingCategory? category,
    String? brand,
    BrandTier? brandTier,
    String? collection,
    Season? season,
    MaterialType? materialType,
    String? materialComposition,
    double? costPrice,
    double? sellingPrice,
    double? discountedPrice,
    double? markupPercentage,
    List<SizeVariant>? sizeVariants,
    List<ColorVariant>? colorVariants,
    int? totalStockQuantity,
    int? reorderPoint,
    String? sku,
    String? barcode,
    String? styleNumber,
    String? modelNumber,
    String? countryOfOrigin,
    String? careInstructions,
    bool? isSustainable,
    bool? isEcoFriendly,
    bool? isHandmade,
    bool? isLimitedEdition,
    bool? isOnSale,
    bool? isNewArrival,
    bool? isBestSeller,
    bool? isTrending,
    double? rating,
    int? reviewCount,
    List<String>? images,
    List<String>? tags,
    String? supplierId,
    String? supplierName,
    DateTime? manufacturingDate,
    DateTime? arrivalDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return ClothingProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      brandTier: brandTier ?? this.brandTier,
      collection: collection ?? this.collection,
      season: season ?? this.season,
      materialType: materialType ?? this.materialType,
      materialComposition: materialComposition ?? this.materialComposition,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      markupPercentage: markupPercentage ?? this.markupPercentage,
      sizeVariants: sizeVariants ?? this.sizeVariants,
      colorVariants: colorVariants ?? this.colorVariants,
      totalStockQuantity: totalStockQuantity ?? this.totalStockQuantity,
      reorderPoint: reorderPoint ?? this.reorderPoint,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      styleNumber: styleNumber ?? this.styleNumber,
      modelNumber: modelNumber ?? this.modelNumber,
      countryOfOrigin: countryOfOrigin ?? this.countryOfOrigin,
      careInstructions: careInstructions ?? this.careInstructions,
      isSustainable: isSustainable ?? this.isSustainable,
      isEcoFriendly: isEcoFriendly ?? this.isEcoFriendly,
      isHandmade: isHandmade ?? this.isHandmade,
      isLimitedEdition: isLimitedEdition ?? this.isLimitedEdition,
      isOnSale: isOnSale ?? this.isOnSale,
      isNewArrival: isNewArrival ?? this.isNewArrival,
      isBestSeller: isBestSeller ?? this.isBestSeller,
      isTrending: isTrending ?? this.isTrending,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      images: images ?? this.images,
      tags: tags ?? this.tags,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      manufacturingDate: manufacturingDate ?? this.manufacturingDate,
      arrivalDate: arrivalDate ?? this.arrivalDate,
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
      'category': category.name,
      'brand': brand,
      'brandTier': brandTier?.name,
      'collection': collection,
      'season': season.name,
      'materialType': materialType.name,
      'materialComposition': materialComposition,
      'costPrice': costPrice,
      'sellingPrice': sellingPrice,
      'discountedPrice': discountedPrice,
      'markupPercentage': markupPercentage,
      'sizeVariants': sizeVariants.map((variant) => variant.toJson()).toList(),
      'colorVariants': colorVariants.map((variant) => variant.toJson()).toList(),
      'totalStockQuantity': totalStockQuantity,
      'reorderPoint': reorderPoint,
      'sku': sku,
      'barcode': barcode,
      'styleNumber': styleNumber,
      'modelNumber': modelNumber,
      'countryOfOrigin': countryOfOrigin,
      'careInstructions': careInstructions,
      'isSustainable': isSustainable,
      'isEcoFriendly': isEcoFriendly,
      'isHandmade': isHandmade,
      'isLimitedEdition': isLimitedEdition,
      'isOnSale': isOnSale,
      'isNewArrival': isNewArrival,
      'isBestSeller': isBestSeller,
      'isTrending': isTrending,
      'rating': rating,
      'reviewCount': reviewCount,
      'images': images,
      'tags': tags,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'manufacturingDate': manufacturingDate?.toIso8601String(),
      'arrivalDate': arrivalDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  // Create from JSON
  factory ClothingProduct.fromJson(Map<String, dynamic> json) {
    return ClothingProduct(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: ClothingCategory.values.firstWhere((e) => e.name == json['category']),
      brand: json['brand'],
      brandTier: json['brandTier'] != null 
          ? BrandTier.values.firstWhere((e) => e.name == json['brandTier'])
          : null,
      collection: json['collection'],
      season: Season.values.firstWhere((e) => e.name == json['season']),
      materialType: MaterialType.values.firstWhere((e) => e.name == json['materialType']),
      materialComposition: json['materialComposition'],
      costPrice: json['costPrice'].toDouble(),
      sellingPrice: json['sellingPrice'].toDouble(),
      discountedPrice: json['discountedPrice']?.toDouble(),
      markupPercentage: json['markupPercentage'].toDouble(),
      sizeVariants: (json['sizeVariants'] as List).map((variant) => SizeVariant.fromJson(variant)).toList(),
      colorVariants: (json['colorVariants'] as List).map((variant) => ColorVariant.fromJson(variant)).toList(),
      totalStockQuantity: json['totalStockQuantity'],
      reorderPoint: json['reorderPoint'],
      sku: json['sku'],
      barcode: json['barcode'],
      styleNumber: json['styleNumber'],
      modelNumber: json['modelNumber'],
      countryOfOrigin: json['countryOfOrigin'],
      careInstructions: json['careInstructions'],
      isSustainable: json['isSustainable'] ?? false,
      isEcoFriendly: json['isEcoFriendly'] ?? false,
      isHandmade: json['isHandmade'] ?? false,
      isLimitedEdition: json['isLimitedEdition'] ?? false,
      isOnSale: json['isOnSale'] ?? false,
      isNewArrival: json['isNewArrival'] ?? false,
      isBestSeller: json['isBestSeller'] ?? false,
      isTrending: json['isTrending'] ?? false,
      rating: json['rating']?.toDouble(),
      reviewCount: json['reviewCount'],
      images: List<String>.from(json['images'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      supplierId: json['supplierId'],
      supplierName: json['supplierName'],
      manufacturingDate: json['manufacturingDate'] != null 
          ? DateTime.parse(json['manufacturingDate'])
          : null,
      arrivalDate: json['arrivalDate'] != null 
          ? DateTime.parse(json['arrivalDate'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isActive: json['isActive'] ?? true,
    );
  }
}

class SizeVariant {
  final String id;
  final String size;
  final SizeType sizeType;
  final int stockQuantity;
  final double? priceAdjustment;
  final bool isAvailable;
  final String? notes;

  SizeVariant({
    required this.id,
    required this.size,
    required this.sizeType,
    required this.stockQuantity,
    this.priceAdjustment,
    this.isAvailable = true,
    this.notes,
  });

  // Check if out of stock
  bool get isOutOfStock => stockQuantity == 0;

  // Check if low stock
  bool get isLowStock => stockQuantity <= 5;

  // Create copy with updated values
  SizeVariant copyWith({
    String? id,
    String? size,
    SizeType? sizeType,
    int? stockQuantity,
    double? priceAdjustment,
    bool? isAvailable,
    String? notes,
  }) {
    return SizeVariant(
      id: id ?? this.id,
      size: size ?? this.size,
      sizeType: sizeType ?? this.sizeType,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      priceAdjustment: priceAdjustment ?? this.priceAdjustment,
      isAvailable: isAvailable ?? this.isAvailable,
      notes: notes ?? this.notes,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'size': size,
      'sizeType': sizeType.name,
      'stockQuantity': stockQuantity,
      'priceAdjustment': priceAdjustment,
      'isAvailable': isAvailable,
      'notes': notes,
    };
  }

  // Create from JSON
  factory SizeVariant.fromJson(Map<String, dynamic> json) {
    return SizeVariant(
      id: json['id'],
      size: json['size'],
      sizeType: SizeType.values.firstWhere((e) => e.name == json['sizeType']),
      stockQuantity: json['stockQuantity'],
      priceAdjustment: json['priceAdjustment']?.toDouble(),
      isAvailable: json['isAvailable'] ?? true,
      notes: json['notes'],
    );
  }
}

class ColorVariant {
  final String id;
  final String colorName;
  final Color colorValue;
  final int stockQuantity;
  final double? priceAdjustment;
  final bool isAvailable;
  final String? notes;
  final List<String> images;

  ColorVariant({
    required this.id,
    required this.colorName,
    required this.colorValue,
    required this.stockQuantity,
    this.priceAdjustment,
    this.isAvailable = true,
    this.notes,
    this.images = const [],
  });

  // Check if out of stock
  bool get isOutOfStock => stockQuantity == 0;

  // Check if low stock
  bool get isLowStock => stockQuantity <= 5;

  // Create copy with updated values
  ColorVariant copyWith({
    String? id,
    String? colorName,
    Color? colorValue,
    int? stockQuantity,
    double? priceAdjustment,
    bool? isAvailable,
    String? notes,
    List<String>? images,
  }) {
    return ColorVariant(
      id: id ?? this.id,
      colorName: colorName ?? this.colorName,
      colorValue: colorValue ?? this.colorValue,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      priceAdjustment: priceAdjustment ?? this.priceAdjustment,
      isAvailable: isAvailable ?? this.isAvailable,
      notes: notes ?? this.notes,
      images: images ?? this.images,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'colorName': colorName,
      'colorValue': colorValue.value,
      'stockQuantity': stockQuantity,
      'priceAdjustment': priceAdjustment,
      'isAvailable': isAvailable,
      'notes': notes,
      'images': images,
    };
  }

  // Create from JSON
  factory ColorVariant.fromJson(Map<String, dynamic> json) {
    return ColorVariant(
      id: json['id'],
      colorName: json['colorName'],
      colorValue: Color(json['colorValue']),
      stockQuantity: json['stockQuantity'],
      priceAdjustment: json['priceAdjustment']?.toDouble(),
      isAvailable: json['isAvailable'] ?? true,
      notes: json['notes'],
      images: List<String>.from(json['images'] ?? []),
    );
  }
}

// Extensions for display names
extension ClothingCategoryExtension on ClothingCategory {
  String get displayName {
    switch (this) {
      case ClothingCategory.mensClothing:
        return 'Men\'s Clothing';
      case ClothingCategory.womensClothing:
        return 'Women\'s Clothing';
      case ClothingCategory.kidsClothing:
        return 'Kids Clothing';
      case ClothingCategory.accessories:
        return 'Accessories';
      case ClothingCategory.shoes:
        return 'Shoes';
      case ClothingCategory.bags:
        return 'Bags';
      case ClothingCategory.jewelry:
        return 'Jewelry';
      case ClothingCategory.watches:
        return 'Watches';
      case ClothingCategory.sunglasses:
        return 'Sunglasses';
      case ClothingCategory.belts:
        return 'Belts';
      case ClothingCategory.scarves:
        return 'Scarves';
      case ClothingCategory.hats:
        return 'Hats';
    }
  }

  IconData get icon {
    switch (this) {
      case ClothingCategory.mensClothing:
        return Icons.man;
      case ClothingCategory.womensClothing:
        return Icons.woman;
      case ClothingCategory.kidsClothing:
        return Icons.child_care;
      case ClothingCategory.accessories:
        return Icons.style;
      case ClothingCategory.shoes:
        return Icons.sports_soccer;
      case ClothingCategory.bags:
        return Icons.work;
      case ClothingCategory.jewelry:
        return Icons.diamond;
      case ClothingCategory.watches:
        return Icons.watch;
      case ClothingCategory.sunglasses:
        return Icons.remove_red_eye;
      case ClothingCategory.belts:
        return Icons.circle;
      case ClothingCategory.scarves:
        return Icons.texture;
      case ClothingCategory.hats:
        return Icons.face;
    }
  }
}

extension SizeTypeExtension on SizeType {
  String get displayName {
    switch (this) {
      case SizeType.numeric:
        return 'Numeric';
      case SizeType.alphabetic:
        return 'Alphabetic';
      case SizeType.shoe:
        return 'Shoe Size';
      case SizeType.age:
        return 'Age';
      case SizeType.custom:
        return 'Custom';
    }
  }
}

extension SeasonExtension on Season {
  String get displayName {
    switch (this) {
      case Season.spring:
        return 'Spring';
      case Season.summer:
        return 'Summer';
      case Season.autumn:
        return 'Autumn';
      case Season.winter:
        return 'Winter';
      case Season.allSeason:
        return 'All Season';
    }
  }

  Color get color {
    switch (this) {
      case Season.spring:
        return Colors.pink;
      case Season.summer:
        return Colors.yellow;
      case Season.autumn:
        return Colors.orange;
      case Season.winter:
        return Colors.blue;
      case Season.allSeason:
        return Colors.grey;
    }
  }
}

extension BrandTierExtension on BrandTier {
  String get displayName {
    switch (this) {
      case BrandTier.luxury:
        return 'Luxury';
      case BrandTier.premium:
        return 'Premium';
      case BrandTier.midRange:
        return 'Mid-Range';
      case BrandTier.budget:
        return 'Budget';
      case BrandTier.local:
        return 'Local';
    }
  }

  Color get color {
    switch (this) {
      case BrandTier.luxury:
        return Colors.purple;
      case BrandTier.premium:
        return Colors.amber;
      case BrandTier.midRange:
        return Colors.blue;
      case BrandTier.budget:
        return Colors.green;
      case BrandTier.local:
        return Colors.orange;
    }
  }
}