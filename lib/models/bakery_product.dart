import 'package:flutter/material.dart';

enum BakeryCategory {
  bread,
  cakes,
  pastries,
  cookies,
  muffins,
  pies,
  donuts,
  sandwiches,
  beverages,
  customOrders,
  seasonalItems,
  dietaryOptions,
}

enum ProductionStatus {
  scheduled,
  inProgress,
  completed,
  cancelled,
  delayed,
}

enum OrderType {
  regular,
  custom,
  catering,
  wholesale,
  preOrder,
}

enum AllergenType {
  gluten,
  dairy,
  eggs,
  nuts,
  soy,
  wheat,
  fish,
  shellfish,
  sesame,
  sulfites,
  none,
}

enum DietaryType {
  vegetarian,
  vegan,
  glutenFree,
  dairyFree,
  nutFree,
  sugarFree,
  keto,
  paleo,
  halal,
  kosher,
  regular,
}

class BakeryProduct {
  final String id;
  final String name;
  final String description;
  final BakeryCategory category;
  final double costPrice;
  final double sellingPrice;
  final double? discountedPrice;
  final double markupPercentage;
  final int stockQuantity;
  final int reorderPoint;
  final String? sku;
  final String? barcode;
  final List<Ingredient> ingredients;
  final List<AllergenType> allergens;
  final List<DietaryType> dietaryTypes;
  final String? recipe;
  final int preparationTime; // in minutes
  final int bakingTime; // in minutes
  final int coolingTime; // in minutes
  final double? weight; // in grams
  final String? dimensions; // for cakes
  final int? servings;
  final bool isCustomizable;
  final List<String> customizationOptions;
  final bool isSeasonal;
  final DateTime? seasonalStartDate;
  final DateTime? seasonalEndDate;
  final bool isLimitedEdition;
  final int? maxQuantityPerOrder;
  final bool isPreOrderAvailable;
  final int? preOrderDays;
  final bool isCateringAvailable;
  final double? cateringPrice;
  final String? cateringDetails;
  final bool isWholesaleAvailable;
  final double? wholesalePrice;
  final int? wholesaleMinQuantity;
  final String? storageInstructions;
  final String? servingInstructions;
  final DateTime? bestBeforeDate;
  final bool isFresh;
  final bool isFrozen;
  final double? rating;
  final int? reviewCount;
  final List<String> images;
  final List<String> tags;
  final String? chefId;
  final String? chefName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  BakeryProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.costPrice,
    required this.sellingPrice,
    this.discountedPrice,
    required this.markupPercentage,
    required this.stockQuantity,
    required this.reorderPoint,
    this.sku,
    this.barcode,
    this.ingredients = const [],
    this.allergens = const [],
    this.dietaryTypes = const [],
    this.recipe,
    required this.preparationTime,
    required this.bakingTime,
    required this.coolingTime,
    this.weight,
    this.dimensions,
    this.servings,
    this.isCustomizable = false,
    this.customizationOptions = const [],
    this.isSeasonal = false,
    this.seasonalStartDate,
    this.seasonalEndDate,
    this.isLimitedEdition = false,
    this.maxQuantityPerOrder,
    this.isPreOrderAvailable = false,
    this.preOrderDays,
    this.isCateringAvailable = false,
    this.cateringPrice,
    this.cateringDetails,
    this.isWholesaleAvailable = false,
    this.wholesalePrice,
    this.wholesaleMinQuantity,
    this.storageInstructions,
    this.servingInstructions,
    this.bestBeforeDate,
    this.isFresh = true,
    this.isFrozen = false,
    this.rating,
    this.reviewCount,
    this.images = const [],
    this.tags = const [],
    this.chefId,
    this.chefName,
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

  // Get total production time
  int get totalProductionTime => preparationTime + bakingTime + coolingTime;

  // Check if currently in season
  bool get isInSeason {
    if (!isSeasonal) return true;
    if (seasonalStartDate == null || seasonalEndDate == null) return true;
    final now = DateTime.now();
    return now.isAfter(seasonalStartDate!) && now.isBefore(seasonalEndDate!);
  }

  // Get allergens display
  String get allergensDisplay {
    if (allergens.isEmpty) return 'No known allergens';
    return allergens.map((a) => a.displayName).join(', ');
  }

  // Get dietary types display
  String get dietaryTypesDisplay {
    if (dietaryTypes.isEmpty) return 'Regular';
    return dietaryTypes.map((d) => d.displayName).join(', ');
  }

  // Get ingredients display
  String get ingredientsDisplay {
    if (ingredients.isEmpty) return 'Ingredients not specified';
    return ingredients.map((i) => '${i.name} (${i.quantity}${i.unit})').join(', ');
  }

  // Get customization display
  String get customizationDisplay {
    if (!isCustomizable) return 'Not customizable';
    if (customizationOptions.isEmpty) return 'Contact for customization';
    return customizationOptions.join(', ');
  }

  // Get catering display
  String get cateringDisplay {
    if (!isCateringAvailable) return 'Not available';
    if (cateringPrice != null) return '₹${cateringPrice!.toStringAsFixed(2)}';
    return 'Contact for pricing';
  }

  // Get wholesale display
  String get wholesaleDisplay {
    if (!isWholesaleAvailable) return 'Not available';
    if (wholesalePrice != null && wholesaleMinQuantity != null) {
      return '₹${wholesalePrice!.toStringAsFixed(2)} (min ${wholesaleMinQuantity})';
    }
    return 'Contact for pricing';
  }

  // Get pre-order display
  String get preOrderDisplay {
    if (!isPreOrderAvailable) return 'Not available';
    if (preOrderDays != null) return '${preOrderDays} days advance';
    return 'Contact for details';
  }

  // Get rating display
  String get ratingDisplay {
    if (rating == null) return 'No ratings';
    return '${rating!.toStringAsFixed(1)} (${reviewCount ?? 0} reviews)';
  }

  // Get storage display
  String get storageDisplay {
    if (isFrozen) return 'Frozen';
    if (isFresh) return 'Fresh';
    return 'Room temperature';
  }

  // Create copy with updated values
  BakeryProduct copyWith({
    String? id,
    String? name,
    String? description,
    BakeryCategory? category,
    double? costPrice,
    double? sellingPrice,
    double? discountedPrice,
    double? markupPercentage,
    int? stockQuantity,
    int? reorderPoint,
    String? sku,
    String? barcode,
    List<Ingredient>? ingredients,
    List<AllergenType>? allergens,
    List<DietaryType>? dietaryTypes,
    String? recipe,
    int? preparationTime,
    int? bakingTime,
    int? coolingTime,
    double? weight,
    String? dimensions,
    int? servings,
    bool? isCustomizable,
    List<String>? customizationOptions,
    bool? isSeasonal,
    DateTime? seasonalStartDate,
    DateTime? seasonalEndDate,
    bool? isLimitedEdition,
    int? maxQuantityPerOrder,
    bool? isPreOrderAvailable,
    int? preOrderDays,
    bool? isCateringAvailable,
    double? cateringPrice,
    String? cateringDetails,
    bool? isWholesaleAvailable,
    double? wholesalePrice,
    int? wholesaleMinQuantity,
    String? storageInstructions,
    String? servingInstructions,
    DateTime? bestBeforeDate,
    bool? isFresh,
    bool? isFrozen,
    double? rating,
    int? reviewCount,
    List<String>? images,
    List<String>? tags,
    String? chefId,
    String? chefName,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return BakeryProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      markupPercentage: markupPercentage ?? this.markupPercentage,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      reorderPoint: reorderPoint ?? this.reorderPoint,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      ingredients: ingredients ?? this.ingredients,
      allergens: allergens ?? this.allergens,
      dietaryTypes: dietaryTypes ?? this.dietaryTypes,
      recipe: recipe ?? this.recipe,
      preparationTime: preparationTime ?? this.preparationTime,
      bakingTime: bakingTime ?? this.bakingTime,
      coolingTime: coolingTime ?? this.coolingTime,
      weight: weight ?? this.weight,
      dimensions: dimensions ?? this.dimensions,
      servings: servings ?? this.servings,
      isCustomizable: isCustomizable ?? this.isCustomizable,
      customizationOptions: customizationOptions ?? this.customizationOptions,
      isSeasonal: isSeasonal ?? this.isSeasonal,
      seasonalStartDate: seasonalStartDate ?? this.seasonalStartDate,
      seasonalEndDate: seasonalEndDate ?? this.seasonalEndDate,
      isLimitedEdition: isLimitedEdition ?? this.isLimitedEdition,
      maxQuantityPerOrder: maxQuantityPerOrder ?? this.maxQuantityPerOrder,
      isPreOrderAvailable: isPreOrderAvailable ?? this.isPreOrderAvailable,
      preOrderDays: preOrderDays ?? this.preOrderDays,
      isCateringAvailable: isCateringAvailable ?? this.isCateringAvailable,
      cateringPrice: cateringPrice ?? this.cateringPrice,
      cateringDetails: cateringDetails ?? this.cateringDetails,
      isWholesaleAvailable: isWholesaleAvailable ?? this.isWholesaleAvailable,
      wholesalePrice: wholesalePrice ?? this.wholesalePrice,
      wholesaleMinQuantity: wholesaleMinQuantity ?? this.wholesaleMinQuantity,
      storageInstructions: storageInstructions ?? this.storageInstructions,
      servingInstructions: servingInstructions ?? this.servingInstructions,
      bestBeforeDate: bestBeforeDate ?? this.bestBeforeDate,
      isFresh: isFresh ?? this.isFresh,
      isFrozen: isFrozen ?? this.isFrozen,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      images: images ?? this.images,
      tags: tags ?? this.tags,
      chefId: chefId ?? this.chefId,
      chefName: chefName ?? this.chefName,
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
      'costPrice': costPrice,
      'sellingPrice': sellingPrice,
      'discountedPrice': discountedPrice,
      'markupPercentage': markupPercentage,
      'stockQuantity': stockQuantity,
      'reorderPoint': reorderPoint,
      'sku': sku,
      'barcode': barcode,
      'ingredients': ingredients.map((ingredient) => ingredient.toJson()).toList(),
      'allergens': allergens.map((allergen) => allergen.name).toList(),
      'dietaryTypes': dietaryTypes.map((dietary) => dietary.name).toList(),
      'recipe': recipe,
      'preparationTime': preparationTime,
      'bakingTime': bakingTime,
      'coolingTime': coolingTime,
      'weight': weight,
      'dimensions': dimensions,
      'servings': servings,
      'isCustomizable': isCustomizable,
      'customizationOptions': customizationOptions,
      'isSeasonal': isSeasonal,
      'seasonalStartDate': seasonalStartDate?.toIso8601String(),
      'seasonalEndDate': seasonalEndDate?.toIso8601String(),
      'isLimitedEdition': isLimitedEdition,
      'maxQuantityPerOrder': maxQuantityPerOrder,
      'isPreOrderAvailable': isPreOrderAvailable,
      'preOrderDays': preOrderDays,
      'isCateringAvailable': isCateringAvailable,
      'cateringPrice': cateringPrice,
      'cateringDetails': cateringDetails,
      'isWholesaleAvailable': isWholesaleAvailable,
      'wholesalePrice': wholesalePrice,
      'wholesaleMinQuantity': wholesaleMinQuantity,
      'storageInstructions': storageInstructions,
      'servingInstructions': servingInstructions,
      'bestBeforeDate': bestBeforeDate?.toIso8601String(),
      'isFresh': isFresh,
      'isFrozen': isFrozen,
      'rating': rating,
      'reviewCount': reviewCount,
      'images': images,
      'tags': tags,
      'chefId': chefId,
      'chefName': chefName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  // Create from JSON
  factory BakeryProduct.fromJson(Map<String, dynamic> json) {
    return BakeryProduct(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: BakeryCategory.values.firstWhere((e) => e.name == json['category']),
      costPrice: json['costPrice'].toDouble(),
      sellingPrice: json['sellingPrice'].toDouble(),
      discountedPrice: json['discountedPrice']?.toDouble(),
      markupPercentage: json['markupPercentage'].toDouble(),
      stockQuantity: json['stockQuantity'],
      reorderPoint: json['reorderPoint'],
      sku: json['sku'],
      barcode: json['barcode'],
      ingredients: (json['ingredients'] as List? ?? []).map((ingredient) => Ingredient.fromJson(ingredient)).toList(),
      allergens: (json['allergens'] as List? ?? []).map((allergen) => AllergenType.values.firstWhere((e) => e.name == allergen)).toList(),
      dietaryTypes: (json['dietaryTypes'] as List? ?? []).map((dietary) => DietaryType.values.firstWhere((e) => e.name == dietary)).toList(),
      recipe: json['recipe'],
      preparationTime: json['preparationTime'],
      bakingTime: json['bakingTime'],
      coolingTime: json['coolingTime'],
      weight: json['weight']?.toDouble(),
      dimensions: json['dimensions'],
      servings: json['servings'],
      isCustomizable: json['isCustomizable'] ?? false,
      customizationOptions: List<String>.from(json['customizationOptions'] ?? []),
      isSeasonal: json['isSeasonal'] ?? false,
      seasonalStartDate: json['seasonalStartDate'] != null ? DateTime.parse(json['seasonalStartDate']) : null,
      seasonalEndDate: json['seasonalEndDate'] != null ? DateTime.parse(json['seasonalEndDate']) : null,
      isLimitedEdition: json['isLimitedEdition'] ?? false,
      maxQuantityPerOrder: json['maxQuantityPerOrder'],
      isPreOrderAvailable: json['isPreOrderAvailable'] ?? false,
      preOrderDays: json['preOrderDays'],
      isCateringAvailable: json['isCateringAvailable'] ?? false,
      cateringPrice: json['cateringPrice']?.toDouble(),
      cateringDetails: json['cateringDetails'],
      isWholesaleAvailable: json['isWholesaleAvailable'] ?? false,
      wholesalePrice: json['wholesalePrice']?.toDouble(),
      wholesaleMinQuantity: json['wholesaleMinQuantity'],
      storageInstructions: json['storageInstructions'],
      servingInstructions: json['servingInstructions'],
      bestBeforeDate: json['bestBeforeDate'] != null ? DateTime.parse(json['bestBeforeDate']) : null,
      isFresh: json['isFresh'] ?? true,
      isFrozen: json['isFrozen'] ?? false,
      rating: json['rating']?.toDouble(),
      reviewCount: json['reviewCount'],
      images: List<String>.from(json['images'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      chefId: json['chefId'],
      chefName: json['chefName'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isActive: json['isActive'] ?? true,
    );
  }
}

class Ingredient {
  final String id;
  final String name;
  final double quantity;
  final String unit;
  final double costPerUnit;
  final double totalCost;
  final String? supplier;
  final DateTime? expiryDate;
  final bool isInStock;

  Ingredient({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.costPerUnit,
    required this.totalCost,
    this.supplier,
    this.expiryDate,
    this.isInStock = true,
  });

  // Check if ingredient is expired
  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  // Check if ingredient is expiring soon (within 7 days)
  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final now = DateTime.now();
    final sevenDaysFromNow = now.add(const Duration(days: 7));
    return expiryDate!.isBefore(sevenDaysFromNow) && !isExpired;
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'costPerUnit': costPerUnit,
      'totalCost': totalCost,
      'supplier': supplier,
      'expiryDate': expiryDate?.toIso8601String(),
      'isInStock': isInStock,
    };
  }

  // Create from JSON
  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'].toDouble(),
      unit: json['unit'],
      costPerUnit: json['costPerUnit'].toDouble(),
      totalCost: json['totalCost'].toDouble(),
      supplier: json['supplier'],
      expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate']) : null,
      isInStock: json['isInStock'] ?? true,
    );
  }
}

class ProductionSchedule {
  final String id;
  final String productId;
  final String productName;
  final int quantity;
  final DateTime scheduledDate;
  final DateTime? startTime;
  final DateTime? completionTime;
  final ProductionStatus status;
  final String? assignedChefId;
  final String? assignedChefName;
  final List<String> notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductionSchedule({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.scheduledDate,
    this.startTime,
    this.completionTime,
    required this.status,
    this.assignedChefId,
    this.assignedChefName,
    this.notes = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  // Get production duration
  Duration? get productionDuration {
    if (startTime == null || completionTime == null) return null;
    return completionTime!.difference(startTime!);
  }

  // Check if production is active
  bool get isActive => status == ProductionStatus.inProgress;

  // Check if production is completed
  bool get isCompleted => status == ProductionStatus.completed;

  // Check if production is delayed
  bool get isDelayed => status == ProductionStatus.delayed;

  // Check if production is overdue
  bool get isOverdue {
    if (status == ProductionStatus.completed) return false;
    return DateTime.now().isAfter(scheduledDate);
  }

  // Create copy with updated values
  ProductionSchedule copyWith({
    String? id,
    String? productId,
    String? productName,
    int? quantity,
    DateTime? scheduledDate,
    DateTime? startTime,
    DateTime? completionTime,
    ProductionStatus? status,
    String? assignedChefId,
    String? assignedChefName,
    List<String>? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductionSchedule(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      startTime: startTime ?? this.startTime,
      completionTime: completionTime ?? this.completionTime,
      status: status ?? this.status,
      assignedChefId: assignedChefId ?? this.assignedChefId,
      assignedChefName: assignedChefName ?? this.assignedChefName,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'scheduledDate': scheduledDate.toIso8601String(),
      'startTime': startTime?.toIso8601String(),
      'completionTime': completionTime?.toIso8601String(),
      'status': status.name,
      'assignedChefId': assignedChefId,
      'assignedChefName': assignedChefName,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory ProductionSchedule.fromJson(Map<String, dynamic> json) {
    return ProductionSchedule(
      id: json['id'],
      productId: json['productId'],
      productName: json['productName'],
      quantity: json['quantity'],
      scheduledDate: DateTime.parse(json['scheduledDate']),
      startTime: json['startTime'] != null ? DateTime.parse(json['startTime']) : null,
      completionTime: json['completionTime'] != null ? DateTime.parse(json['completionTime']) : null,
      status: ProductionStatus.values.firstWhere((e) => e.name == json['status']),
      assignedChefId: json['assignedChefId'],
      assignedChefName: json['assignedChefName'],
      notes: List<String>.from(json['notes'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class CustomOrder {
  final String id;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final String productName;
  final String description;
  final OrderType orderType;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final DateTime orderDate;
  final DateTime requiredDate;
  final DateTime? completionDate;
  final List<String> specialInstructions;
  final List<String> customizationDetails;
  final List<AllergenType> allergensToAvoid;
  final List<DietaryType> dietaryRequirements;
  final String? occasion;
  final String? theme;
  final String? color;
  final String? size;
  final String? shape;
  final String? decoration;
  final String? message;
  final bool isUrgent;
  final double? rushFee;
  final String? status;
  final String? assignedChefId;
  final String? assignedChefName;
  final DateTime createdAt;
  final DateTime updatedAt;

  CustomOrder({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.customerEmail,
    required this.productName,
    required this.description,
    required this.orderType,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.orderDate,
    required this.requiredDate,
    this.completionDate,
    this.specialInstructions = const [],
    this.customizationDetails = const [],
    this.allergensToAvoid = const [],
    this.dietaryRequirements = const [],
    this.occasion,
    this.theme,
    this.color,
    this.size,
    this.shape,
    this.decoration,
    this.message,
    this.isUrgent = false,
    this.rushFee,
    this.status,
    this.assignedChefId,
    this.assignedChefName,
    required this.createdAt,
    required this.updatedAt,
  });

  // Get order duration
  Duration get orderDuration => requiredDate.difference(orderDate);

  // Get production time remaining
  Duration get productionTimeRemaining => requiredDate.difference(DateTime.now());

  // Check if order is urgent
  bool get isUrgentOrder => isUrgent || productionTimeRemaining.inDays < 2;

  // Check if order is overdue
  bool get isOverdue => DateTime.now().isAfter(requiredDate) && completionDate == null;

  // Get final price with rush fee
  double get finalPrice {
    if (rushFee != null) return totalPrice + rushFee!;
    return totalPrice;
  }

  // Get allergens to avoid display
  String get allergensToAvoidDisplay {
    if (allergensToAvoid.isEmpty) return 'None specified';
    return allergensToAvoid.map((a) => a.displayName).join(', ');
  }

  // Get dietary requirements display
  String get dietaryRequirementsDisplay {
    if (dietaryRequirements.isEmpty) return 'None specified';
    return dietaryRequirements.map((d) => d.displayName).join(', ');
  }

  // Get customization display
  String get customizationDisplay {
    if (customizationDetails.isEmpty) return 'No customizations';
    return customizationDetails.join(', ');
  }

  // Create copy with updated values
  CustomOrder copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? productName,
    String? description,
    OrderType? orderType,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
    DateTime? orderDate,
    DateTime? requiredDate,
    DateTime? completionDate,
    List<String>? specialInstructions,
    List<String>? customizationDetails,
    List<AllergenType>? allergensToAvoid,
    List<DietaryType>? dietaryRequirements,
    String? occasion,
    String? theme,
    String? color,
    String? size,
    String? shape,
    String? decoration,
    String? message,
    bool? isUrgent,
    double? rushFee,
    String? status,
    String? assignedChefId,
    String? assignedChefName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomOrder(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerEmail: customerEmail ?? this.customerEmail,
      productName: productName ?? this.productName,
      description: description ?? this.description,
      orderType: orderType ?? this.orderType,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      orderDate: orderDate ?? this.orderDate,
      requiredDate: requiredDate ?? this.requiredDate,
      completionDate: completionDate ?? this.completionDate,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      customizationDetails: customizationDetails ?? this.customizationDetails,
      allergensToAvoid: allergensToAvoid ?? this.allergensToAvoid,
      dietaryRequirements: dietaryRequirements ?? this.dietaryRequirements,
      occasion: occasion ?? this.occasion,
      theme: theme ?? this.theme,
      color: color ?? this.color,
      size: size ?? this.size,
      shape: shape ?? this.shape,
      decoration: decoration ?? this.decoration,
      message: message ?? this.message,
      isUrgent: isUrgent ?? this.isUrgent,
      rushFee: rushFee ?? this.rushFee,
      status: status ?? this.status,
      assignedChefId: assignedChefId ?? this.assignedChefId,
      assignedChefName: assignedChefName ?? this.assignedChefName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerEmail': customerEmail,
      'productName': productName,
      'description': description,
      'orderType': orderType.name,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'orderDate': orderDate.toIso8601String(),
      'requiredDate': requiredDate.toIso8601String(),
      'completionDate': completionDate?.toIso8601String(),
      'specialInstructions': specialInstructions,
      'customizationDetails': customizationDetails,
      'allergensToAvoid': allergensToAvoid.map((allergen) => allergen.name).toList(),
      'dietaryRequirements': dietaryRequirements.map((dietary) => dietary.name).toList(),
      'occasion': occasion,
      'theme': theme,
      'color': color,
      'size': size,
      'shape': shape,
      'decoration': decoration,
      'message': message,
      'isUrgent': isUrgent,
      'rushFee': rushFee,
      'status': status,
      'assignedChefId': assignedChefId,
      'assignedChefName': assignedChefName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory CustomOrder.fromJson(Map<String, dynamic> json) {
    return CustomOrder(
      id: json['id'],
      customerId: json['customerId'],
      customerName: json['customerName'],
      customerPhone: json['customerPhone'],
      customerEmail: json['customerEmail'],
      productName: json['productName'],
      description: json['description'],
      orderType: OrderType.values.firstWhere((e) => e.name == json['orderType']),
      quantity: json['quantity'],
      unitPrice: json['unitPrice'].toDouble(),
      totalPrice: json['totalPrice'].toDouble(),
      orderDate: DateTime.parse(json['orderDate']),
      requiredDate: DateTime.parse(json['requiredDate']),
      completionDate: json['completionDate'] != null ? DateTime.parse(json['completionDate']) : null,
      specialInstructions: List<String>.from(json['specialInstructions'] ?? []),
      customizationDetails: List<String>.from(json['customizationDetails'] ?? []),
      allergensToAvoid: (json['allergensToAvoid'] as List? ?? []).map((allergen) => AllergenType.values.firstWhere((e) => e.name == allergen)).toList(),
      dietaryRequirements: (json['dietaryRequirements'] as List? ?? []).map((dietary) => DietaryType.values.firstWhere((e) => e.name == dietary)).toList(),
      occasion: json['occasion'],
      theme: json['theme'],
      color: json['color'],
      size: json['size'],
      shape: json['shape'],
      decoration: json['decoration'],
      message: json['message'],
      isUrgent: json['isUrgent'] ?? false,
      rushFee: json['rushFee']?.toDouble(),
      status: json['status'],
      assignedChefId: json['assignedChefId'],
      assignedChefName: json['assignedChefName'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

// Extensions for display names
extension BakeryCategoryExtension on BakeryCategory {
  String get displayName {
    switch (this) {
      case BakeryCategory.bread:
        return 'Bread';
      case BakeryCategory.cakes:
        return 'Cakes';
      case BakeryCategory.pastries:
        return 'Pastries';
      case BakeryCategory.cookies:
        return 'Cookies';
      case BakeryCategory.muffins:
        return 'Muffins';
      case BakeryCategory.pies:
        return 'Pies';
      case BakeryCategory.donuts:
        return 'Donuts';
      case BakeryCategory.sandwiches:
        return 'Sandwiches';
      case BakeryCategory.beverages:
        return 'Beverages';
      case BakeryCategory.customOrders:
        return 'Custom Orders';
      case BakeryCategory.seasonalItems:
        return 'Seasonal Items';
      case BakeryCategory.dietaryOptions:
        return 'Dietary Options';
    }
  }

  IconData get icon {
    switch (this) {
      case BakeryCategory.bread:
        return Icons.breakfast_dining;
      case BakeryCategory.cakes:
        return Icons.cake;
      case BakeryCategory.pastries:
        return Icons.cake_outlined;
      case BakeryCategory.cookies:
        return Icons.cookie;
      case BakeryCategory.muffins:
        return Icons.cake_outlined;
      case BakeryCategory.pies:
        return Icons.pie_chart;
      case BakeryCategory.donuts:
        return Icons.circle;
      case BakeryCategory.sandwiches:
        return Icons.lunch_dining;
      case BakeryCategory.beverages:
        return Icons.local_cafe;
      case BakeryCategory.customOrders:
        return Icons.edit;
      case BakeryCategory.seasonalItems:
        return Icons.wb_sunny;
      case BakeryCategory.dietaryOptions:
        return Icons.warning;
    }
  }
}

extension ProductionStatusExtension on ProductionStatus {
  String get displayName {
    switch (this) {
      case ProductionStatus.scheduled:
        return 'Scheduled';
      case ProductionStatus.inProgress:
        return 'In Progress';
      case ProductionStatus.completed:
        return 'Completed';
      case ProductionStatus.cancelled:
        return 'Cancelled';
      case ProductionStatus.delayed:
        return 'Delayed';
    }
  }

  Color get color {
    switch (this) {
      case ProductionStatus.scheduled:
        return Colors.blue;
      case ProductionStatus.inProgress:
        return Colors.orange;
      case ProductionStatus.completed:
        return Colors.green;
      case ProductionStatus.cancelled:
        return Colors.red;
      case ProductionStatus.delayed:
        return Colors.yellow;
    }
  }
}

extension OrderTypeExtension on OrderType {
  String get displayName {
    switch (this) {
      case OrderType.regular:
        return 'Regular';
      case OrderType.custom:
        return 'Custom';
      case OrderType.catering:
        return 'Catering';
      case OrderType.wholesale:
        return 'Wholesale';
      case OrderType.preOrder:
        return 'Pre-Order';
    }
  }

  IconData get icon {
    switch (this) {
      case OrderType.regular:
        return Icons.shopping_cart;
      case OrderType.custom:
        return Icons.edit;
      case OrderType.catering:
        return Icons.event;
      case OrderType.wholesale:
        return Icons.business;
      case OrderType.preOrder:
        return Icons.schedule;
    }
  }
}

extension AllergenTypeExtension on AllergenType {
  String get displayName {
    switch (this) {
      case AllergenType.gluten:
        return 'Gluten';
      case AllergenType.dairy:
        return 'Dairy';
      case AllergenType.eggs:
        return 'Eggs';
      case AllergenType.nuts:
        return 'Nuts';
      case AllergenType.soy:
        return 'Soy';
      case AllergenType.wheat:
        return 'Wheat';
      case AllergenType.fish:
        return 'Fish';
      case AllergenType.shellfish:
        return 'Shellfish';
      case AllergenType.sesame:
        return 'Sesame';
      case AllergenType.sulfites:
        return 'Sulfites';
      case AllergenType.none:
        return 'None';
    }
  }

  Color get color {
    switch (this) {
      case AllergenType.gluten:
        return Colors.orange;
      case AllergenType.dairy:
        return Colors.blue;
      case AllergenType.eggs:
        return Colors.yellow;
      case AllergenType.nuts:
        return Colors.brown;
      case AllergenType.soy:
        return Colors.green;
      case AllergenType.wheat:
        return Colors.amber;
      case AllergenType.fish:
        return Colors.cyan;
      case AllergenType.shellfish:
        return Colors.pink;
      case AllergenType.sesame:
        return Colors.grey;
      case AllergenType.sulfites:
        return Colors.purple;
      case AllergenType.none:
        return Colors.grey;
    }
  }
}

extension DietaryTypeExtension on DietaryType {
  String get displayName {
    switch (this) {
      case DietaryType.vegetarian:
        return 'Vegetarian';
      case DietaryType.vegan:
        return 'Vegan';
      case DietaryType.glutenFree:
        return 'Gluten-Free';
      case DietaryType.dairyFree:
        return 'Dairy-Free';
      case DietaryType.nutFree:
        return 'Nut-Free';
      case DietaryType.sugarFree:
        return 'Sugar-Free';
      case DietaryType.keto:
        return 'Keto';
      case DietaryType.paleo:
        return 'Paleo';
      case DietaryType.halal:
        return 'Halal';
      case DietaryType.kosher:
        return 'Kosher';
      case DietaryType.regular:
        return 'Regular';
    }
  }

  Color get color {
    switch (this) {
      case DietaryType.vegetarian:
        return Colors.green;
      case DietaryType.vegan:
        return Colors.lightGreen;
      case DietaryType.glutenFree:
        return Colors.orange;
      case DietaryType.dairyFree:
        return Colors.blue;
      case DietaryType.nutFree:
        return Colors.brown;
      case DietaryType.sugarFree:
        return Colors.pink;
      case DietaryType.keto:
        return Colors.purple;
      case DietaryType.paleo:
        return Colors.amber;
      case DietaryType.halal:
        return Colors.teal;
      case DietaryType.kosher:
        return Colors.indigo;
      case DietaryType.regular:
        return Colors.grey;
    }
  }
}