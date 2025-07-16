import 'package:flutter/material.dart';

enum StationeryCategory {
  writingSupplies,
  paperProducts,
  artSupplies,
  officeSupplies,
  schoolSupplies,
  craftMaterials,
  deskAccessories,
  storageOrganizers,
  technologyAccessories,
  seasonalItems,
  bulkSupplies,
  specialtyItems,
}

enum PaperType {
  printer,
  notebook,
  construction,
  art,
  specialty,
  recycled,
  colored,
  textured,
}

enum WritingType {
  pen,
  pencil,
  marker,
  highlighter,
  crayon,
  chalk,
  paint,
  ink,
}

enum ArtMedium {
  watercolor,
  acrylic,
  oil,
  gouache,
  tempera,
  pastel,
  charcoal,
  graphite,
  ink,
  digital,
}

enum BulkPricingType {
  quantity,
  weight,
  volume,
  sets,
  packs,
}

class StationeryProduct {
  final String id;
  final String name;
  final String description;
  final StationeryCategory category;
  final String? brand;
  final String? model;
  final String? sku;
  final String? barcode;
  final double costPrice;
  final double sellingPrice;
  final double? discountedPrice;
  final double markupPercentage;
  final int stockQuantity;
  final int reorderPoint;
  final String? unit;
  final double? weight; // in grams
  final String? dimensions; // L x W x H
  final String? color;
  final String? material;
  final PaperType? paperType;
  final WritingType? writingType;
  final ArtMedium? artMedium;
  final List<String> features;
  final List<String> applications;
  final List<String> compatibleItems;
  final bool isRefillable;
  final bool isReusable;
  final bool isEcoFriendly;
  final bool isRecycled;
  final bool isNonToxic;
  final bool isWashable;
  final bool isEraseable;
  final bool isWaterproof;
  final bool isLightfast;
  final bool isAcidFree;
  final bool isArchival;
  final bool isBulkAvailable;
  final List<BulkPricing> bulkPricing;
  final bool isSeasonal;
  final DateTime? seasonalStartDate;
  final DateTime? seasonalEndDate;
  final bool isLimitedEdition;
  final bool isNewArrival;
  final bool isBestSeller;
  final bool isTrending;
  final bool isEducational;
  final String? ageGroup;
  final String? gradeLevel;
  final String? subject;
  final String? curriculum;
  final bool isWholesaleAvailable;
  final double? wholesalePrice;
  final int? wholesaleMinQuantity;
  final String? warrantyTerms;
  final int? warrantyPeriod; // in months
  final String? careInstructions;
  final String? safetyInstructions;
  final double? rating;
  final int? reviewCount;
  final List<String> images;
  final List<String> tags;
  final String? supplierId;
  final String? supplierName;
  final DateTime? manufacturingDate;
  final DateTime? purchaseDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  StationeryProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.brand,
    this.model,
    this.sku,
    this.barcode,
    required this.costPrice,
    required this.sellingPrice,
    this.discountedPrice,
    required this.markupPercentage,
    required this.stockQuantity,
    required this.reorderPoint,
    this.unit,
    this.weight,
    this.dimensions,
    this.color,
    this.material,
    this.paperType,
    this.writingType,
    this.artMedium,
    this.features = const [],
    this.applications = const [],
    this.compatibleItems = const [],
    this.isRefillable = false,
    this.isReusable = false,
    this.isEcoFriendly = false,
    this.isRecycled = false,
    this.isNonToxic = false,
    this.isWashable = false,
    this.isEraseable = false,
    this.isWaterproof = false,
    this.isLightfast = false,
    this.isAcidFree = false,
    this.isArchival = false,
    this.isBulkAvailable = false,
    this.bulkPricing = const [],
    this.isSeasonal = false,
    this.seasonalStartDate,
    this.seasonalEndDate,
    this.isLimitedEdition = false,
    this.isNewArrival = false,
    this.isBestSeller = false,
    this.isTrending = false,
    this.isEducational = false,
    this.ageGroup,
    this.gradeLevel,
    this.subject,
    this.curriculum,
    this.isWholesaleAvailable = false,
    this.wholesalePrice,
    this.wholesaleMinQuantity,
    this.warrantyTerms,
    this.warrantyPeriod,
    this.careInstructions,
    this.safetyInstructions,
    this.rating,
    this.reviewCount,
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
  bool get isLowStock => stockQuantity <= reorderPoint;

  // Check if out of stock
  bool get isOutOfStock => stockQuantity == 0;

  // Get total value
  double get totalValue => costPrice * stockQuantity;

  // Check if currently in season
  bool get isInSeason {
    if (!isSeasonal) return true;
    if (seasonalStartDate == null || seasonalEndDate == null) return true;
    final now = DateTime.now();
    return now.isAfter(seasonalStartDate!) && now.isBefore(seasonalEndDate!);
  }

  // Get paper type display
  String get paperTypeDisplay {
    if (paperType == null) return 'Not specified';
    switch (paperType!) {
      case PaperType.printer:
        return 'Printer Paper';
      case PaperType.notebook:
        return 'Notebook Paper';
      case PaperType.construction:
        return 'Construction Paper';
      case PaperType.art:
        return 'Art Paper';
      case PaperType.specialty:
        return 'Specialty Paper';
      case PaperType.recycled:
        return 'Recycled Paper';
      case PaperType.colored:
        return 'Colored Paper';
      case PaperType.textured:
        return 'Textured Paper';
    }
  }

  // Get writing type display
  String get writingTypeDisplay {
    if (writingType == null) return 'Not specified';
    switch (writingType!) {
      case WritingType.pen:
        return 'Pen';
      case WritingType.pencil:
        return 'Pencil';
      case WritingType.marker:
        return 'Marker';
      case WritingType.highlighter:
        return 'Highlighter';
      case WritingType.crayon:
        return 'Crayon';
      case WritingType.chalk:
        return 'Chalk';
      case WritingType.paint:
        return 'Paint';
      case WritingType.ink:
        return 'Ink';
    }
  }

  // Get art medium display
  String get artMediumDisplay {
    if (artMedium == null) return 'Not specified';
    switch (artMedium!) {
      case ArtMedium.watercolor:
        return 'Watercolor';
      case ArtMedium.acrylic:
        return 'Acrylic';
      case ArtMedium.oil:
        return 'Oil';
      case ArtMedium.gouache:
        return 'Gouache';
      case ArtMedium.tempera:
        return 'Tempera';
      case ArtMedium.pastel:
        return 'Pastel';
      case ArtMedium.charcoal:
        return 'Charcoal';
      case ArtMedium.graphite:
        return 'Graphite';
      case ArtMedium.ink:
        return 'Ink';
      case ArtMedium.digital:
        return 'Digital';
    }
  }

  // Get features display
  String get featuresDisplay {
    if (features.isEmpty) return 'No features listed';
    return features.join(', ');
  }

  // Get applications display
  String get applicationsDisplay {
    if (applications.isEmpty) return 'No applications listed';
    return applications.join(', ');
  }

  // Get compatible items display
  String get compatibleItemsDisplay {
    if (compatibleItems.isEmpty) return 'No compatible items';
    return compatibleItems.join(', ');
  }

  // Get wholesale display
  String get wholesaleDisplay {
    if (!isWholesaleAvailable) return 'Not available';
    if (wholesalePrice != null && wholesaleMinQuantity != null) {
      return '₹${wholesalePrice!.toStringAsFixed(2)} (min ${wholesaleMinQuantity})';
    }
    return 'Contact for pricing';
  }

  // Get warranty display
  String get warrantyDisplay {
    if (warrantyPeriod == null) return 'No warranty';
    return '${warrantyPeriod} months';
  }

  // Get rating display
  String get ratingDisplay {
    if (rating == null) return 'No ratings';
    return '${rating!.toStringAsFixed(1)} (${reviewCount ?? 0} reviews)';
  }

  // Get educational info display
  String get educationalInfoDisplay {
    if (!isEducational) return 'Not educational';
    final parts = <String>[];
    if (ageGroup != null) parts.add('Age: $ageGroup');
    if (gradeLevel != null) parts.add('Grade: $gradeLevel');
    if (subject != null) parts.add('Subject: $subject');
    if (curriculum != null) parts.add('Curriculum: $curriculum');
    return parts.isEmpty ? 'Educational' : parts.join(', ');
  }

  // Get special properties display
  String get specialPropertiesDisplay {
    final properties = <String>[];
    if (isRefillable) properties.add('Refillable');
    if (isReusable) properties.add('Reusable');
    if (isEcoFriendly) properties.add('Eco-Friendly');
    if (isRecycled) properties.add('Recycled');
    if (isNonToxic) properties.add('Non-Toxic');
    if (isWashable) properties.add('Washable');
    if (isEraseable) properties.add('Eraseable');
    if (isWaterproof) properties.add('Waterproof');
    if (isLightfast) properties.add('Lightfast');
    if (isAcidFree) properties.add('Acid-Free');
    if (isArchival) properties.add('Archival');
    return properties.isEmpty ? 'Standard' : properties.join(', ');
  }

  // Create copy with updated values
  StationeryProduct copyWith({
    String? id,
    String? name,
    String? description,
    StationeryCategory? category,
    String? brand,
    String? model,
    String? sku,
    String? barcode,
    double? costPrice,
    double? sellingPrice,
    double? discountedPrice,
    double? markupPercentage,
    int? stockQuantity,
    int? reorderPoint,
    String? unit,
    double? weight,
    String? dimensions,
    String? color,
    String? material,
    PaperType? paperType,
    WritingType? writingType,
    ArtMedium? artMedium,
    List<String>? features,
    List<String>? applications,
    List<String>? compatibleItems,
    bool? isRefillable,
    bool? isReusable,
    bool? isEcoFriendly,
    bool? isRecycled,
    bool? isNonToxic,
    bool? isWashable,
    bool? isEraseable,
    bool? isWaterproof,
    bool? isLightfast,
    bool? isAcidFree,
    bool? isArchival,
    bool? isBulkAvailable,
    List<BulkPricing>? bulkPricing,
    bool? isSeasonal,
    DateTime? seasonalStartDate,
    DateTime? seasonalEndDate,
    bool? isLimitedEdition,
    bool? isNewArrival,
    bool? isBestSeller,
    bool? isTrending,
    bool? isEducational,
    String? ageGroup,
    String? gradeLevel,
    String? subject,
    String? curriculum,
    bool? isWholesaleAvailable,
    double? wholesalePrice,
    int? wholesaleMinQuantity,
    String? warrantyTerms,
    int? warrantyPeriod,
    String? careInstructions,
    String? safetyInstructions,
    double? rating,
    int? reviewCount,
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
    return StationeryProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      markupPercentage: markupPercentage ?? this.markupPercentage,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      reorderPoint: reorderPoint ?? this.reorderPoint,
      unit: unit ?? this.unit,
      weight: weight ?? this.weight,
      dimensions: dimensions ?? this.dimensions,
      color: color ?? this.color,
      material: material ?? this.material,
      paperType: paperType ?? this.paperType,
      writingType: writingType ?? this.writingType,
      artMedium: artMedium ?? this.artMedium,
      features: features ?? this.features,
      applications: applications ?? this.applications,
      compatibleItems: compatibleItems ?? this.compatibleItems,
      isRefillable: isRefillable ?? this.isRefillable,
      isReusable: isReusable ?? this.isReusable,
      isEcoFriendly: isEcoFriendly ?? this.isEcoFriendly,
      isRecycled: isRecycled ?? this.isRecycled,
      isNonToxic: isNonToxic ?? this.isNonToxic,
      isWashable: isWashable ?? this.isWashable,
      isEraseable: isEraseable ?? this.isEraseable,
      isWaterproof: isWaterproof ?? this.isWaterproof,
      isLightfast: isLightfast ?? this.isLightfast,
      isAcidFree: isAcidFree ?? this.isAcidFree,
      isArchival: isArchival ?? this.isArchival,
      isBulkAvailable: isBulkAvailable ?? this.isBulkAvailable,
      bulkPricing: bulkPricing ?? this.bulkPricing,
      isSeasonal: isSeasonal ?? this.isSeasonal,
      seasonalStartDate: seasonalStartDate ?? this.seasonalStartDate,
      seasonalEndDate: seasonalEndDate ?? this.seasonalEndDate,
      isLimitedEdition: isLimitedEdition ?? this.isLimitedEdition,
      isNewArrival: isNewArrival ?? this.isNewArrival,
      isBestSeller: isBestSeller ?? this.isBestSeller,
      isTrending: isTrending ?? this.isTrending,
      isEducational: isEducational ?? this.isEducational,
      ageGroup: ageGroup ?? this.ageGroup,
      gradeLevel: gradeLevel ?? this.gradeLevel,
      subject: subject ?? this.subject,
      curriculum: curriculum ?? this.curriculum,
      isWholesaleAvailable: isWholesaleAvailable ?? this.isWholesaleAvailable,
      wholesalePrice: wholesalePrice ?? this.wholesalePrice,
      wholesaleMinQuantity: wholesaleMinQuantity ?? this.wholesaleMinQuantity,
      warrantyTerms: warrantyTerms ?? this.warrantyTerms,
      warrantyPeriod: warrantyPeriod ?? this.warrantyPeriod,
      careInstructions: careInstructions ?? this.careInstructions,
      safetyInstructions: safetyInstructions ?? this.safetyInstructions,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
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
      'category': category.name,
      'brand': brand,
      'model': model,
      'sku': sku,
      'barcode': barcode,
      'costPrice': costPrice,
      'sellingPrice': sellingPrice,
      'discountedPrice': discountedPrice,
      'markupPercentage': markupPercentage,
      'stockQuantity': stockQuantity,
      'reorderPoint': reorderPoint,
      'unit': unit,
      'weight': weight,
      'dimensions': dimensions,
      'color': color,
      'material': material,
      'paperType': paperType?.name,
      'writingType': writingType?.name,
      'artMedium': artMedium?.name,
      'features': features,
      'applications': applications,
      'compatibleItems': compatibleItems,
      'isRefillable': isRefillable,
      'isReusable': isReusable,
      'isEcoFriendly': isEcoFriendly,
      'isRecycled': isRecycled,
      'isNonToxic': isNonToxic,
      'isWashable': isWashable,
      'isEraseable': isEraseable,
      'isWaterproof': isWaterproof,
      'isLightfast': isLightfast,
      'isAcidFree': isAcidFree,
      'isArchival': isArchival,
      'isBulkAvailable': isBulkAvailable,
      'bulkPricing': bulkPricing.map((pricing) => pricing.toJson()).toList(),
      'isSeasonal': isSeasonal,
      'seasonalStartDate': seasonalStartDate?.toIso8601String(),
      'seasonalEndDate': seasonalEndDate?.toIso8601String(),
      'isLimitedEdition': isLimitedEdition,
      'isNewArrival': isNewArrival,
      'isBestSeller': isBestSeller,
      'isTrending': isTrending,
      'isEducational': isEducational,
      'ageGroup': ageGroup,
      'gradeLevel': gradeLevel,
      'subject': subject,
      'curriculum': curriculum,
      'isWholesaleAvailable': isWholesaleAvailable,
      'wholesalePrice': wholesalePrice,
      'wholesaleMinQuantity': wholesaleMinQuantity,
      'warrantyTerms': warrantyTerms,
      'warrantyPeriod': warrantyPeriod,
      'careInstructions': careInstructions,
      'safetyInstructions': safetyInstructions,
      'rating': rating,
      'reviewCount': reviewCount,
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
  factory StationeryProduct.fromJson(Map<String, dynamic> json) {
    return StationeryProduct(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: StationeryCategory.values.firstWhere((e) => e.name == json['category']),
      brand: json['brand'],
      model: json['model'],
      sku: json['sku'],
      barcode: json['barcode'],
      costPrice: json['costPrice'].toDouble(),
      sellingPrice: json['sellingPrice'].toDouble(),
      discountedPrice: json['discountedPrice']?.toDouble(),
      markupPercentage: json['markupPercentage'].toDouble(),
      stockQuantity: json['stockQuantity'],
      reorderPoint: json['reorderPoint'],
      unit: json['unit'],
      weight: json['weight']?.toDouble(),
      dimensions: json['dimensions'],
      color: json['color'],
      material: json['material'],
      paperType: json['paperType'] != null 
          ? PaperType.values.firstWhere((e) => e.name == json['paperType'])
          : null,
      writingType: json['writingType'] != null 
          ? WritingType.values.firstWhere((e) => e.name == json['writingType'])
          : null,
      artMedium: json['artMedium'] != null 
          ? ArtMedium.values.firstWhere((e) => e.name == json['artMedium'])
          : null,
      features: List<String>.from(json['features'] ?? []),
      applications: List<String>.from(json['applications'] ?? []),
      compatibleItems: List<String>.from(json['compatibleItems'] ?? []),
      isRefillable: json['isRefillable'] ?? false,
      isReusable: json['isReusable'] ?? false,
      isEcoFriendly: json['isEcoFriendly'] ?? false,
      isRecycled: json['isRecycled'] ?? false,
      isNonToxic: json['isNonToxic'] ?? false,
      isWashable: json['isWashable'] ?? false,
      isEraseable: json['isEraseable'] ?? false,
      isWaterproof: json['isWaterproof'] ?? false,
      isLightfast: json['isLightfast'] ?? false,
      isAcidFree: json['isAcidFree'] ?? false,
      isArchival: json['isArchival'] ?? false,
      isBulkAvailable: json['isBulkAvailable'] ?? false,
      bulkPricing: (json['bulkPricing'] as List? ?? []).map((pricing) => BulkPricing.fromJson(pricing)).toList(),
      isSeasonal: json['isSeasonal'] ?? false,
      seasonalStartDate: json['seasonalStartDate'] != null ? DateTime.parse(json['seasonalStartDate']) : null,
      seasonalEndDate: json['seasonalEndDate'] != null ? DateTime.parse(json['seasonalEndDate']) : null,
      isLimitedEdition: json['isLimitedEdition'] ?? false,
      isNewArrival: json['isNewArrival'] ?? false,
      isBestSeller: json['isBestSeller'] ?? false,
      isTrending: json['isTrending'] ?? false,
      isEducational: json['isEducational'] ?? false,
      ageGroup: json['ageGroup'],
      gradeLevel: json['gradeLevel'],
      subject: json['subject'],
      curriculum: json['curriculum'],
      isWholesaleAvailable: json['isWholesaleAvailable'] ?? false,
      wholesalePrice: json['wholesalePrice']?.toDouble(),
      wholesaleMinQuantity: json['wholesaleMinQuantity'],
      warrantyTerms: json['warrantyTerms'],
      warrantyPeriod: json['warrantyPeriod'],
      careInstructions: json['careInstructions'],
      safetyInstructions: json['safetyInstructions'],
      rating: json['rating']?.toDouble(),
      reviewCount: json['reviewCount'],
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

class BulkPricing {
  final String id;
  final BulkPricingType type;
  final int minQuantity;
  final int? maxQuantity;
  final double pricePerUnit;
  final double discountPercentage;
  final String? description;

  BulkPricing({
    required this.id,
    required this.type,
    required this.minQuantity,
    this.maxQuantity,
    required this.pricePerUnit,
    required this.discountPercentage,
    this.description,
  });

  // Get quantity range display
  String get quantityRangeDisplay {
    if (maxQuantity == null) return '${minQuantity}+';
    return '$minQuantity - $maxQuantity';
  }

  // Get type display
  String get typeDisplay {
    switch (type) {
      case BulkPricingType.quantity:
        return 'Quantity';
      case BulkPricingType.weight:
        return 'Weight';
      case BulkPricingType.volume:
        return 'Volume';
      case BulkPricingType.sets:
        return 'Sets';
      case BulkPricingType.packs:
        return 'Packs';
    }
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'minQuantity': minQuantity,
      'maxQuantity': maxQuantity,
      'pricePerUnit': pricePerUnit,
      'discountPercentage': discountPercentage,
      'description': description,
    };
  }

  // Create from JSON
  factory BulkPricing.fromJson(Map<String, dynamic> json) {
    return BulkPricing(
      id: json['id'],
      type: BulkPricingType.values.firstWhere((e) => e.name == json['type']),
      minQuantity: json['minQuantity'],
      maxQuantity: json['maxQuantity'],
      pricePerUnit: json['pricePerUnit'].toDouble(),
      discountPercentage: json['discountPercentage'].toDouble(),
      description: json['description'],
    );
  }
}

class SchoolSupply {
  final String id;
  final String productId;
  final String productName;
  final String gradeLevel;
  final String subject;
  final String? teacher;
  final String? classroom;
  final int requiredQuantity;
  final int? providedQuantity;
  final bool isRequired;
  final bool isOptional;
  final bool isProvided;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  SchoolSupply({
    required this.id,
    required this.productId,
    required this.productName,
    required this.gradeLevel,
    required this.subject,
    this.teacher,
    this.classroom,
    required this.requiredQuantity,
    this.providedQuantity,
    this.isRequired = true,
    this.isOptional = false,
    this.isProvided = false,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  // Get remaining quantity needed
  int get remainingQuantity {
    if (providedQuantity == null) return requiredQuantity;
    return (requiredQuantity - providedQuantity!).clamp(0, requiredQuantity);
  }

  // Check if fully provided
  bool get isFullyProvided => providedQuantity != null && providedQuantity! >= requiredQuantity;

  // Check if partially provided
  bool get isPartiallyProvided => providedQuantity != null && providedQuantity! > 0 && providedQuantity! < requiredQuantity;

  // Get status display
  String get statusDisplay {
    if (isFullyProvided) return 'Complete';
    if (isPartiallyProvided) return 'Partial';
    return 'Pending';
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'gradeLevel': gradeLevel,
      'subject': subject,
      'teacher': teacher,
      'classroom': classroom,
      'requiredQuantity': requiredQuantity,
      'providedQuantity': providedQuantity,
      'isRequired': isRequired,
      'isOptional': isOptional,
      'isProvided': isProvided,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory SchoolSupply.fromJson(Map<String, dynamic> json) {
    return SchoolSupply(
      id: json['id'],
      productId: json['productId'],
      productName: json['productName'],
      gradeLevel: json['gradeLevel'],
      subject: json['subject'],
      teacher: json['teacher'],
      classroom: json['classroom'],
      requiredQuantity: json['requiredQuantity'],
      providedQuantity: json['providedQuantity'],
      isRequired: json['isRequired'] ?? true,
      isOptional: json['isOptional'] ?? false,
      isProvided: json['isProvided'] ?? false,
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

// Extensions for display names
extension StationeryCategoryExtension on StationeryCategory {
  String get displayName {
    switch (this) {
      case StationeryCategory.writingSupplies:
        return 'Writing Supplies';
      case StationeryCategory.paperProducts:
        return 'Paper Products';
      case StationeryCategory.artSupplies:
        return 'Art Supplies';
      case StationeryCategory.officeSupplies:
        return 'Office Supplies';
      case StationeryCategory.schoolSupplies:
        return 'School Supplies';
      case StationeryCategory.craftMaterials:
        return 'Craft Materials';
      case StationeryCategory.deskAccessories:
        return 'Desk Accessories';
      case StationeryCategory.storageOrganizers:
        return 'Storage & Organizers';
      case StationeryCategory.technologyAccessories:
        return 'Technology Accessories';
      case StationeryCategory.seasonalItems:
        return 'Seasonal Items';
      case StationeryCategory.bulkSupplies:
        return 'Bulk Supplies';
      case StationeryCategory.specialtyItems:
        return 'Specialty Items';
    }
  }

  IconData get icon {
    switch (this) {
      case StationeryCategory.writingSupplies:
        return Icons.edit;
      case StationeryCategory.paperProducts:
        return Icons.description;
      case StationeryCategory.artSupplies:
        return Icons.palette;
      case StationeryCategory.officeSupplies:
        return Icons.business;
      case StationeryCategory.schoolSupplies:
        return Icons.school;
      case StationeryCategory.craftMaterials:
        return Icons.build;
      case StationeryCategory.deskAccessories:
        return Icons.desk;
      case StationeryCategory.storageOrganizers:
        return Icons.inventory;
      case StationeryCategory.technologyAccessories:
        return Icons.devices;
      case StationeryCategory.seasonalItems:
        return Icons.wb_sunny;
      case StationeryCategory.bulkSupplies:
        return Icons.inventory_2;
      case StationeryCategory.specialtyItems:
        return Icons.star;
    }
  }
}

extension PaperTypeExtension on PaperType {
  String get displayName {
    switch (this) {
      case PaperType.printer:
        return 'Printer Paper';
      case PaperType.notebook:
        return 'Notebook Paper';
      case PaperType.construction:
        return 'Construction Paper';
      case PaperType.art:
        return 'Art Paper';
      case PaperType.specialty:
        return 'Specialty Paper';
      case PaperType.recycled:
        return 'Recycled Paper';
      case PaperType.colored:
        return 'Colored Paper';
      case PaperType.textured:
        return 'Textured Paper';
    }
  }

  IconData get icon {
    switch (this) {
      case PaperType.printer:
        return Icons.print;
      case PaperType.notebook:
        return Icons.note;
      case PaperType.construction:
        return Icons.construction;
      case PaperType.art:
        return Icons.palette;
      case PaperType.specialty:
        return Icons.star;
      case PaperType.recycled:
        return Icons.recycling;
      case PaperType.colored:
        return Icons.color_lens;
      case PaperType.textured:
        return Icons.texture;
    }
  }
}

extension WritingTypeExtension on WritingType {
  String get displayName {
    switch (this) {
      case WritingType.pen:
        return 'Pen';
      case WritingType.pencil:
        return 'Pencil';
      case WritingType.marker:
        return 'Marker';
      case WritingType.highlighter:
        return 'Highlighter';
      case WritingType.crayon:
        return 'Crayon';
      case WritingType.chalk:
        return 'Chalk';
      case WritingType.paint:
        return 'Paint';
      case WritingType.ink:
        return 'Ink';
    }
  }

  IconData get icon {
    switch (this) {
      case WritingType.pen:
        return Icons.edit;
      case WritingType.pencil:
        return Icons.edit_note;
      case WritingType.marker:
        return Icons.brush;
      case WritingType.highlighter:
        return Icons.highlight;
      case WritingType.crayon:
        return Icons.brush_outlined;
      case WritingType.chalk:
        return Icons.format_color_fill;
      case WritingType.paint:
        return Icons.palette;
      case WritingType.ink:
        return Icons.edit;
    }
  }
}

extension ArtMediumExtension on ArtMedium {
  String get displayName {
    switch (this) {
      case ArtMedium.watercolor:
        return 'Watercolor';
      case ArtMedium.acrylic:
        return 'Acrylic';
      case ArtMedium.oil:
        return 'Oil';
      case ArtMedium.gouache:
        return 'Gouache';
      case ArtMedium.tempera:
        return 'Tempera';
      case ArtMedium.pastel:
        return 'Pastel';
      case ArtMedium.charcoal:
        return 'Charcoal';
      case ArtMedium.graphite:
        return 'Graphite';
      case ArtMedium.ink:
        return 'Ink';
      case ArtMedium.digital:
        return 'Digital';
    }
  }

  IconData get icon {
    switch (this) {
      case ArtMedium.watercolor:
        return Icons.water_drop;
      case ArtMedium.acrylic:
        return Icons.palette;
      case ArtMedium.oil:
        return Icons.opacity;
      case ArtMedium.gouache:
        return Icons.brush;
      case ArtMedium.tempera:
        return Icons.format_paint;
      case ArtMedium.pastel:
        return Icons.color_lens;
      case ArtMedium.charcoal:
        return Icons.brush_outlined;
      case ArtMedium.graphite:
        return Icons.edit;
      case ArtMedium.ink:
        return Icons.edit;
      case ArtMedium.digital:
        return Icons.computer;
    }
  }
}

extension BulkPricingTypeExtension on BulkPricingType {
  String get displayName {
    switch (this) {
      case BulkPricingType.quantity:
        return 'Quantity';
      case BulkPricingType.weight:
        return 'Weight';
      case BulkPricingType.volume:
        return 'Volume';
      case BulkPricingType.sets:
        return 'Sets';
      case BulkPricingType.packs:
        return 'Packs';
    }
  }

  IconData get icon {
    switch (this) {
      case BulkPricingType.quantity:
        return Icons.numbers;
      case BulkPricingType.weight:
        return Icons.monitor_weight;
      case BulkPricingType.volume:
        return Icons.volume_up;
      case BulkPricingType.sets:
        return Icons.inventory_2;
      case BulkPricingType.packs:
        return Icons.inventory;
    }
  }
}