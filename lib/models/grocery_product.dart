import 'package:json_annotation/json_annotation.dart';

part 'grocery_product.g.dart';

enum GroceryCategory {
  freshProduce,
  dairyEggs,
  meatSeafood,
  bakeryBread,
  pantryStaples,
  beverages,
  snacksConfectionery,
  healthBeauty,
  babyCare,
  householdItems,
  frozenFoods,
  spicesSeasonings,
}

enum UnitType {
  // Weight-based
  kg,
  grams,
  pounds,
  ounces,
  
  // Volume-based
  liters,
  ml,
  gallons,
  
  // Count-based
  pieces,
  dozens,
  packs,
  units,
  
  // Bundle-based
  bundles,
  boxes,
  cartons,
  bags,
}

enum StockAlertType {
  lowStock,
  outOfStock,
  expiringSoon,
  expired,
  overstocked,
}

@JsonSerializable()
class GroceryProduct {
  final String id;
  final String name;
  final String? barcode;
  final GroceryCategory category;
  final String? subcategory;
  final String? brand;
  final String? description;
  final double unitPrice;
  final double costPrice;
  final UnitType unitType;
  final double currentStock;
  final double reorderPoint;
  final double maxStock;
  final DateTime? expiryDate;
  final String? batchNumber;
  final String? supplierName;
  final String? supplierContact;
  final bool isPerishable;
  final bool isActive;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const GroceryProduct({
    required this.id,
    required this.name,
    this.barcode,
    required this.category,
    this.subcategory,
    this.brand,
    this.description,
    required this.unitPrice,
    required this.costPrice,
    required this.unitType,
    required this.currentStock,
    required this.reorderPoint,
    required this.maxStock,
    this.expiryDate,
    this.batchNumber,
    this.supplierName,
    this.supplierContact,
    this.isPerishable = false,
    this.isActive = true,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GroceryProduct.fromJson(Map<String, dynamic> json) => _$GroceryProductFromJson(json);
  Map<String, dynamic> toJson() => _$GroceryProductToJson(this);

  GroceryProduct copyWith({
    String? id,
    String? name,
    String? barcode,
    GroceryCategory? category,
    String? subcategory,
    String? brand,
    String? description,
    double? unitPrice,
    double? costPrice,
    UnitType? unitType,
    double? currentStock,
    double? reorderPoint,
    double? maxStock,
    DateTime? expiryDate,
    String? batchNumber,
    String? supplierName,
    String? supplierContact,
    bool? isPerishable,
    bool? isActive,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GroceryProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      brand: brand ?? this.brand,
      description: description ?? this.description,
      unitPrice: unitPrice ?? this.unitPrice,
      costPrice: costPrice ?? this.costPrice,
      unitType: unitType ?? this.unitType,
      currentStock: currentStock ?? this.currentStock,
      reorderPoint: reorderPoint ?? this.reorderPoint,
      maxStock: maxStock ?? this.maxStock,
      expiryDate: expiryDate ?? this.expiryDate,
      batchNumber: batchNumber ?? this.batchNumber,
      supplierName: supplierName ?? this.supplierName,
      supplierContact: supplierContact ?? this.supplierContact,
      isPerishable: isPerishable ?? this.isPerishable,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Computed properties
  double get profitMargin => unitPrice - costPrice;
  double get profitMarginPercentage => costPrice > 0 ? ((unitPrice - costPrice) / costPrice) * 100 : 0;
  
  bool get isLowStock => currentStock <= reorderPoint;
  bool get isOutOfStock => currentStock <= 0;
  bool get isOverstocked => currentStock > maxStock;
  
  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final daysUntilExpiry = expiryDate!.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 7 && daysUntilExpiry >= 0;
  }
  
  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  StockAlertType? get stockAlertType {
    if (isExpired) return StockAlertType.expired;
    if (isExpiringSoon) return StockAlertType.expiringSoon;
    if (isOutOfStock) return StockAlertType.outOfStock;
    if (isLowStock) return StockAlertType.lowStock;
    if (isOverstocked) return StockAlertType.overstocked;
    return null;
  }

  String get displayName {
    if (brand != null && brand!.isNotEmpty) {
      return '$brand $name';
    }
    return name;
  }

  String get fullDisplayName {
    final parts = <String>[displayName];
    if (subcategory != null) parts.add('($subcategory)');
    return parts.join(' ');
  }
}

extension GroceryCategoryExtension on GroceryCategory {
  String get displayName {
    switch (this) {
      case GroceryCategory.freshProduce:
        return 'Fresh Produce';
      case GroceryCategory.dairyEggs:
        return 'Dairy & Eggs';
      case GroceryCategory.meatSeafood:
        return 'Meat & Seafood';
      case GroceryCategory.bakeryBread:
        return 'Bakery & Bread';
      case GroceryCategory.pantryStaples:
        return 'Pantry Staples';
      case GroceryCategory.beverages:
        return 'Beverages';
      case GroceryCategory.snacksConfectionery:
        return 'Snacks & Confectionery';
      case GroceryCategory.healthBeauty:
        return 'Health & Beauty';
      case GroceryCategory.babyCare:
        return 'Baby Care';
      case GroceryCategory.householdItems:
        return 'Household Items';
      case GroceryCategory.frozenFoods:
        return 'Frozen Foods';
      case GroceryCategory.spicesSeasonings:
        return 'Spices & Seasonings';
    }
  }

  String get description {
    switch (this) {
      case GroceryCategory.freshProduce:
        return 'Fresh fruits and vegetables';
      case GroceryCategory.dairyEggs:
        return 'Milk, cheese, yogurt, and eggs';
      case GroceryCategory.meatSeafood:
        return 'Fresh meat, poultry, and seafood';
      case GroceryCategory.bakeryBread:
        return 'Fresh bread, pastries, and baked goods';
      case GroceryCategory.pantryStaples:
        return 'Rice, flour, oil, and basic ingredients';
      case GroceryCategory.beverages:
        return 'Soft drinks, juices, and beverages';
      case GroceryCategory.snacksConfectionery:
        return 'Snacks, chocolates, and candies';
      case GroceryCategory.healthBeauty:
        return 'Health supplements and beauty products';
      case GroceryCategory.babyCare:
        return 'Baby food, diapers, and care products';
      case GroceryCategory.householdItems:
        return 'Cleaning supplies and household essentials';
      case GroceryCategory.frozenFoods:
        return 'Frozen vegetables, meat, and ready-to-eat items';
      case GroceryCategory.spicesSeasonings:
        return 'Spices, herbs, and seasonings';
    }
  }

  IconData get icon {
    switch (this) {
      case GroceryCategory.freshProduce:
        return Icons.eco;
      case GroceryCategory.dairyEggs:
        return Icons.local_drink;
      case GroceryCategory.meatSeafood:
        return Icons.set_meal;
      case GroceryCategory.bakeryBread:
        return Icons.flatware;
      case GroceryCategory.pantryStaples:
        return Icons.inventory;
      case GroceryCategory.beverages:
        return Icons.local_bar;
      case GroceryCategory.snacksConfectionery:
        return Icons.cake;
      case GroceryCategory.healthBeauty:
        return Icons.healing;
      case GroceryCategory.babyCare:
        return Icons.child_care;
      case GroceryCategory.householdItems:
        return Icons.home;
      case GroceryCategory.frozenFoods:
        return Icons.ac_unit;
      case GroceryCategory.spicesSeasonings:
        return Icons.restaurant;
    }
  }

  Color get color {
    switch (this) {
      case GroceryCategory.freshProduce:
        return Colors.green;
      case GroceryCategory.dairyEggs:
        return Colors.blue;
      case GroceryCategory.meatSeafood:
        return Colors.red;
      case GroceryCategory.bakeryBread:
        return Colors.orange;
      case GroceryCategory.pantryStaples:
        return Colors.brown;
      case GroceryCategory.beverages:
        return Colors.purple;
      case GroceryCategory.snacksConfectionery:
        return Colors.pink;
      case GroceryCategory.healthBeauty:
        return Colors.teal;
      case GroceryCategory.babyCare:
        return Colors.cyan;
      case GroceryCategory.householdItems:
        return Colors.grey;
      case GroceryCategory.frozenFoods:
        return Colors.lightBlue;
      case GroceryCategory.spicesSeasonings:
        return Colors.amber;
    }
  }
}

extension UnitTypeExtension on UnitType {
  String get displayName {
    switch (this) {
      case UnitType.kg:
        return 'Kilogram (kg)';
      case UnitType.grams:
        return 'Grams (g)';
      case UnitType.pounds:
        return 'Pounds (lb)';
      case UnitType.ounces:
        return 'Ounces (oz)';
      case UnitType.liters:
        return 'Liters (L)';
      case UnitType.ml:
        return 'Milliliters (ml)';
      case UnitType.gallons:
        return 'Gallons (gal)';
      case UnitType.pieces:
        return 'Pieces';
      case UnitType.dozens:
        return 'Dozens';
      case UnitType.packs:
        return 'Packs';
      case UnitType.units:
        return 'Units';
      case UnitType.bundles:
        return 'Bundles';
      case UnitType.boxes:
        return 'Boxes';
      case UnitType.cartons:
        return 'Cartons';
      case UnitType.bags:
        return 'Bags';
    }
  }

  String get shortName {
    switch (this) {
      case UnitType.kg:
        return 'kg';
      case UnitType.grams:
        return 'g';
      case UnitType.pounds:
        return 'lb';
      case UnitType.ounces:
        return 'oz';
      case UnitType.liters:
        return 'L';
      case UnitType.ml:
        return 'ml';
      case UnitType.gallons:
        return 'gal';
      case UnitType.pieces:
        return 'pcs';
      case UnitType.dozens:
        return 'doz';
      case UnitType.packs:
        return 'packs';
      case UnitType.units:
        return 'units';
      case UnitType.bundles:
        return 'bundles';
      case UnitType.boxes:
        return 'boxes';
      case UnitType.cartons:
        return 'cartons';
      case UnitType.bags:
        return 'bags';
    }
  }

  bool get isWeightBased {
    return this == UnitType.kg || 
           this == UnitType.grams || 
           this == UnitType.pounds || 
           this == UnitType.ounces;
  }

  bool get isVolumeBased {
    return this == UnitType.liters || 
           this == UnitType.ml || 
           this == UnitType.gallons;
  }

  bool get isCountBased {
    return this == UnitType.pieces || 
           this == UnitType.dozens || 
           this == UnitType.packs || 
           this == UnitType.units;
  }

  bool get isBundleBased {
    return this == UnitType.bundles || 
           this == UnitType.boxes || 
           this == UnitType.cartons || 
           this == UnitType.bags;
  }
}

extension StockAlertTypeExtension on StockAlertType {
  String get displayName {
    switch (this) {
      case StockAlertType.lowStock:
        return 'Low Stock';
      case StockAlertType.outOfStock:
        return 'Out of Stock';
      case StockAlertType.expiringSoon:
        return 'Expiring Soon';
      case StockAlertType.expired:
        return 'Expired';
      case StockAlertType.overstocked:
        return 'Overstocked';
    }
  }

  Color get color {
    switch (this) {
      case StockAlertType.lowStock:
        return Colors.orange;
      case StockAlertType.outOfStock:
        return Colors.red;
      case StockAlertType.expiringSoon:
        return Colors.yellow;
      case StockAlertType.expired:
        return Colors.red;
      case StockAlertType.overstocked:
        return Colors.blue;
    }
  }

  IconData get icon {
    switch (this) {
      case StockAlertType.lowStock:
        return Icons.warning;
      case StockAlertType.outOfStock:
        return Icons.remove_shopping_cart;
      case StockAlertType.expiringSoon:
        return Icons.schedule;
      case StockAlertType.expired:
        return Icons.block;
      case StockAlertType.overstocked:
        return Icons.inventory_2;
    }
  }
}