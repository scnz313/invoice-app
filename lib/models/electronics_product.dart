import 'package:flutter/material.dart';

enum ElectronicsCategory {
  smartphones,
  laptops,
  tablets,
  tvsAudio,
  gaming,
  cameras,
  accessories,
  smartHome,
  wearables,
  computers,
  networking,
  software,
}

enum WarrantyType {
  manufacturer,
  extended,
  store,
  none,
}

enum WarrantyStatus {
  active,
  expired,
  voided,
  claimed,
}

enum TechnicalSupportLevel {
  basic,
  premium,
  enterprise,
  none,
}

enum InstallationType {
  basic,
  premium,
  custom,
  none,
}

enum TradeInCondition {
  excellent,
  good,
  fair,
  poor,
  damaged,
}

class ElectronicsProduct {
  final String id;
  final String name;
  final String description;
  final ElectronicsCategory category;
  final String? brand;
  final String? model;
  final String? serialNumber;
  final String? sku;
  final String? barcode;
  final double costPrice;
  final double sellingPrice;
  final double? discountedPrice;
  final double markupPercentage;
  final int stockQuantity;
  final int reorderPoint;
  final WarrantyType warrantyType;
  final int warrantyPeriod; // in months
  final String? warrantyTerms;
  final bool isExtendedWarrantyAvailable;
  final double? extendedWarrantyPrice;
  final int? extendedWarrantyPeriod;
  final TechnicalSupportLevel technicalSupportLevel;
  final bool isInstallationAvailable;
  final InstallationType installationType;
  final double? installationPrice;
  final String? installationDetails;
  final bool isTradeInEligible;
  final double? tradeInValue;
  final TradeInCondition? tradeInCondition;
  final String? tradeInTerms;
  final List<String> specifications;
  final List<String> features;
  final List<String> compatibleDevices;
  final List<String> includedItems;
  final String? userManual;
  final String? troubleshootingGuide;
  final bool isRefurbished;
  final bool isOpenBox;
  final bool isDemo;
  final bool isNew;
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

  ElectronicsProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.brand,
    this.model,
    this.serialNumber,
    this.sku,
    this.barcode,
    required this.costPrice,
    required this.sellingPrice,
    this.discountedPrice,
    required this.markupPercentage,
    required this.stockQuantity,
    required this.reorderPoint,
    required this.warrantyType,
    required this.warrantyPeriod,
    this.warrantyTerms,
    this.isExtendedWarrantyAvailable = false,
    this.extendedWarrantyPrice,
    this.extendedWarrantyPeriod,
    required this.technicalSupportLevel,
    this.isInstallationAvailable = false,
    this.installationType = InstallationType.none,
    this.installationPrice,
    this.installationDetails,
    this.isTradeInEligible = false,
    this.tradeInValue,
    this.tradeInCondition,
    this.tradeInTerms,
    this.specifications = const [],
    this.features = const [],
    this.compatibleDevices = const [],
    this.includedItems = const [],
    this.userManual,
    this.troubleshootingGuide,
    this.isRefurbished = false,
    this.isOpenBox = false,
    this.isDemo = false,
    this.isNew = true,
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

  // Get warranty display
  String get warrantyDisplay {
    switch (warrantyType) {
      case WarrantyType.manufacturer:
        return 'Manufacturer Warranty (${warrantyPeriod} months)';
      case WarrantyType.extended:
        return 'Extended Warranty (${warrantyPeriod} months)';
      case WarrantyType.store:
        return 'Store Warranty (${warrantyPeriod} months)';
      case WarrantyType.none:
        return 'No Warranty';
    }
  }

  // Get technical support display
  String get technicalSupportDisplay {
    switch (technicalSupportLevel) {
      case TechnicalSupportLevel.basic:
        return 'Basic Support';
      case TechnicalSupportLevel.premium:
        return 'Premium Support';
      case TechnicalSupportLevel.enterprise:
        return 'Enterprise Support';
      case TechnicalSupportLevel.none:
        return 'No Support';
    }
  }

  // Get installation display
  String get installationDisplay {
    if (!isInstallationAvailable) return 'Not Available';
    
    switch (installationType) {
      case InstallationType.basic:
        return 'Basic Installation';
      case InstallationType.premium:
        return 'Premium Installation';
      case InstallationType.custom:
        return 'Custom Installation';
      case InstallationType.none:
        return 'No Installation';
    }
  }

  // Get trade-in display
  String get tradeInDisplay {
    if (!isTradeInEligible) return 'Not Available';
    return 'Trade-in Value: ₹${tradeInValue?.toStringAsFixed(2) ?? '0.00'}';
  }

  // Get condition display
  String get conditionDisplay {
    if (isNew) return 'New';
    if (isRefurbished) return 'Refurbished';
    if (isOpenBox) return 'Open Box';
    if (isDemo) return 'Demo';
    return 'Used';
  }

  // Get rating display
  String get ratingDisplay {
    if (rating == null) return 'No ratings';
    return '${rating!.toStringAsFixed(1)} (${reviewCount ?? 0} reviews)';
  }

  // Get specifications display
  String get specificationsDisplay {
    if (specifications.isEmpty) return 'No specifications available';
    return specifications.join(', ');
  }

  // Get features display
  String get featuresDisplay {
    if (features.isEmpty) return 'No features listed';
    return features.join(', ');
  }

  // Get included items display
  String get includedItemsDisplay {
    if (includedItems.isEmpty) return 'No items included';
    return includedItems.join(', ');
  }

  // Create copy with updated values
  ElectronicsProduct copyWith({
    String? id,
    String? name,
    String? description,
    ElectronicsCategory? category,
    String? brand,
    String? model,
    String? serialNumber,
    String? sku,
    String? barcode,
    double? costPrice,
    double? sellingPrice,
    double? discountedPrice,
    double? markupPercentage,
    int? stockQuantity,
    int? reorderPoint,
    WarrantyType? warrantyType,
    int? warrantyPeriod,
    String? warrantyTerms,
    bool? isExtendedWarrantyAvailable,
    double? extendedWarrantyPrice,
    int? extendedWarrantyPeriod,
    TechnicalSupportLevel? technicalSupportLevel,
    bool? isInstallationAvailable,
    InstallationType? installationType,
    double? installationPrice,
    String? installationDetails,
    bool? isTradeInEligible,
    double? tradeInValue,
    TradeInCondition? tradeInCondition,
    String? tradeInTerms,
    List<String>? specifications,
    List<String>? features,
    List<String>? compatibleDevices,
    List<String>? includedItems,
    String? userManual,
    String? troubleshootingGuide,
    bool? isRefurbished,
    bool? isOpenBox,
    bool? isDemo,
    bool? isNew,
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
    return ElectronicsProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      serialNumber: serialNumber ?? this.serialNumber,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      markupPercentage: markupPercentage ?? this.markupPercentage,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      reorderPoint: reorderPoint ?? this.reorderPoint,
      warrantyType: warrantyType ?? this.warrantyType,
      warrantyPeriod: warrantyPeriod ?? this.warrantyPeriod,
      warrantyTerms: warrantyTerms ?? this.warrantyTerms,
      isExtendedWarrantyAvailable: isExtendedWarrantyAvailable ?? this.isExtendedWarrantyAvailable,
      extendedWarrantyPrice: extendedWarrantyPrice ?? this.extendedWarrantyPrice,
      extendedWarrantyPeriod: extendedWarrantyPeriod ?? this.extendedWarrantyPeriod,
      technicalSupportLevel: technicalSupportLevel ?? this.technicalSupportLevel,
      isInstallationAvailable: isInstallationAvailable ?? this.isInstallationAvailable,
      installationType: installationType ?? this.installationType,
      installationPrice: installationPrice ?? this.installationPrice,
      installationDetails: installationDetails ?? this.installationDetails,
      isTradeInEligible: isTradeInEligible ?? this.isTradeInEligible,
      tradeInValue: tradeInValue ?? this.tradeInValue,
      tradeInCondition: tradeInCondition ?? this.tradeInCondition,
      tradeInTerms: tradeInTerms ?? this.tradeInTerms,
      specifications: specifications ?? this.specifications,
      features: features ?? this.features,
      compatibleDevices: compatibleDevices ?? this.compatibleDevices,
      includedItems: includedItems ?? this.includedItems,
      userManual: userManual ?? this.userManual,
      troubleshootingGuide: troubleshootingGuide ?? this.troubleshootingGuide,
      isRefurbished: isRefurbished ?? this.isRefurbished,
      isOpenBox: isOpenBox ?? this.isOpenBox,
      isDemo: isDemo ?? this.isDemo,
      isNew: isNew ?? this.isNew,
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
      'serialNumber': serialNumber,
      'sku': sku,
      'barcode': barcode,
      'costPrice': costPrice,
      'sellingPrice': sellingPrice,
      'discountedPrice': discountedPrice,
      'markupPercentage': markupPercentage,
      'stockQuantity': stockQuantity,
      'reorderPoint': reorderPoint,
      'warrantyType': warrantyType.name,
      'warrantyPeriod': warrantyPeriod,
      'warrantyTerms': warrantyTerms,
      'isExtendedWarrantyAvailable': isExtendedWarrantyAvailable,
      'extendedWarrantyPrice': extendedWarrantyPrice,
      'extendedWarrantyPeriod': extendedWarrantyPeriod,
      'technicalSupportLevel': technicalSupportLevel.name,
      'isInstallationAvailable': isInstallationAvailable,
      'installationType': installationType.name,
      'installationPrice': installationPrice,
      'installationDetails': installationDetails,
      'isTradeInEligible': isTradeInEligible,
      'tradeInValue': tradeInValue,
      'tradeInCondition': tradeInCondition?.name,
      'tradeInTerms': tradeInTerms,
      'specifications': specifications,
      'features': features,
      'compatibleDevices': compatibleDevices,
      'includedItems': includedItems,
      'userManual': userManual,
      'troubleshootingGuide': troubleshootingGuide,
      'isRefurbished': isRefurbished,
      'isOpenBox': isOpenBox,
      'isDemo': isDemo,
      'isNew': isNew,
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
  factory ElectronicsProduct.fromJson(Map<String, dynamic> json) {
    return ElectronicsProduct(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: ElectronicsCategory.values.firstWhere((e) => e.name == json['category']),
      brand: json['brand'],
      model: json['model'],
      serialNumber: json['serialNumber'],
      sku: json['sku'],
      barcode: json['barcode'],
      costPrice: json['costPrice'].toDouble(),
      sellingPrice: json['sellingPrice'].toDouble(),
      discountedPrice: json['discountedPrice']?.toDouble(),
      markupPercentage: json['markupPercentage'].toDouble(),
      stockQuantity: json['stockQuantity'],
      reorderPoint: json['reorderPoint'],
      warrantyType: WarrantyType.values.firstWhere((e) => e.name == json['warrantyType']),
      warrantyPeriod: json['warrantyPeriod'],
      warrantyTerms: json['warrantyTerms'],
      isExtendedWarrantyAvailable: json['isExtendedWarrantyAvailable'] ?? false,
      extendedWarrantyPrice: json['extendedWarrantyPrice']?.toDouble(),
      extendedWarrantyPeriod: json['extendedWarrantyPeriod'],
      technicalSupportLevel: TechnicalSupportLevel.values.firstWhere((e) => e.name == json['technicalSupportLevel']),
      isInstallationAvailable: json['isInstallationAvailable'] ?? false,
      installationType: InstallationType.values.firstWhere((e) => e.name == json['installationType']),
      installationPrice: json['installationPrice']?.toDouble(),
      installationDetails: json['installationDetails'],
      isTradeInEligible: json['isTradeInEligible'] ?? false,
      tradeInValue: json['tradeInValue']?.toDouble(),
      tradeInCondition: json['tradeInCondition'] != null 
          ? TradeInCondition.values.firstWhere((e) => e.name == json['tradeInCondition'])
          : null,
      tradeInTerms: json['tradeInTerms'],
      specifications: List<String>.from(json['specifications'] ?? []),
      features: List<String>.from(json['features'] ?? []),
      compatibleDevices: List<String>.from(json['compatibleDevices'] ?? []),
      includedItems: List<String>.from(json['includedItems'] ?? []),
      userManual: json['userManual'],
      troubleshootingGuide: json['troubleshootingGuide'],
      isRefurbished: json['isRefurbished'] ?? false,
      isOpenBox: json['isOpenBox'] ?? false,
      isDemo: json['isDemo'] ?? false,
      isNew: json['isNew'] ?? true,
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

class WarrantyClaim {
  final String id;
  final String productId;
  final String productName;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final String issueDescription;
  final DateTime issueDate;
  final DateTime? claimDate;
  final WarrantyStatus status;
  final String? claimNumber;
  final String? serviceCenterId;
  final String? serviceCenterName;
  final String? technicianId;
  final String? technicianName;
  final DateTime? estimatedCompletionDate;
  final DateTime? actualCompletionDate;
  final double? repairCost;
  final String? repairNotes;
  final bool isCoveredByWarranty;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  WarrantyClaim({
    required this.id,
    required this.productId,
    required this.productName,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.customerEmail,
    required this.issueDescription,
    required this.issueDate,
    this.claimDate,
    required this.status,
    this.claimNumber,
    this.serviceCenterId,
    this.serviceCenterName,
    this.technicianId,
    this.technicianName,
    this.estimatedCompletionDate,
    this.actualCompletionDate,
    this.repairCost,
    this.repairNotes,
    this.isCoveredByWarranty = true,
    this.rejectionReason,
    required this.createdAt,
    required this.updatedAt,
  });

  // Get claim duration
  Duration get claimDuration => DateTime.now().difference(claimDate ?? createdAt);

  // Get repair duration
  Duration? get repairDuration {
    if (actualCompletionDate == null || claimDate == null) return null;
    return actualCompletionDate!.difference(claimDate!);
  }

  // Check if claim is active
  bool get isActive => status == WarrantyStatus.active;

  // Check if claim is completed
  bool get isCompleted => status == WarrantyStatus.claimed;

  // Check if claim is expired
  bool get isExpired => status == WarrantyStatus.expired;

  // Create copy with updated values
  WarrantyClaim copyWith({
    String? id,
    String? productId,
    String? productName,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? issueDescription,
    DateTime? issueDate,
    DateTime? claimDate,
    WarrantyStatus? status,
    String? claimNumber,
    String? serviceCenterId,
    String? serviceCenterName,
    String? technicianId,
    String? technicianName,
    DateTime? estimatedCompletionDate,
    DateTime? actualCompletionDate,
    double? repairCost,
    String? repairNotes,
    bool? isCoveredByWarranty,
    String? rejectionReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WarrantyClaim(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerEmail: customerEmail ?? this.customerEmail,
      issueDescription: issueDescription ?? this.issueDescription,
      issueDate: issueDate ?? this.issueDate,
      claimDate: claimDate ?? this.claimDate,
      status: status ?? this.status,
      claimNumber: claimNumber ?? this.claimNumber,
      serviceCenterId: serviceCenterId ?? this.serviceCenterId,
      serviceCenterName: serviceCenterName ?? this.serviceCenterName,
      technicianId: technicianId ?? this.technicianId,
      technicianName: technicianName ?? this.technicianName,
      estimatedCompletionDate: estimatedCompletionDate ?? this.estimatedCompletionDate,
      actualCompletionDate: actualCompletionDate ?? this.actualCompletionDate,
      repairCost: repairCost ?? this.repairCost,
      repairNotes: repairNotes ?? this.repairNotes,
      isCoveredByWarranty: isCoveredByWarranty ?? this.isCoveredByWarranty,
      rejectionReason: rejectionReason ?? this.rejectionReason,
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
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerEmail': customerEmail,
      'issueDescription': issueDescription,
      'issueDate': issueDate.toIso8601String(),
      'claimDate': claimDate?.toIso8601String(),
      'status': status.name,
      'claimNumber': claimNumber,
      'serviceCenterId': serviceCenterId,
      'serviceCenterName': serviceCenterName,
      'technicianId': technicianId,
      'technicianName': technicianName,
      'estimatedCompletionDate': estimatedCompletionDate?.toIso8601String(),
      'actualCompletionDate': actualCompletionDate?.toIso8601String(),
      'repairCost': repairCost,
      'repairNotes': repairNotes,
      'isCoveredByWarranty': isCoveredByWarranty,
      'rejectionReason': rejectionReason,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory WarrantyClaim.fromJson(Map<String, dynamic> json) {
    return WarrantyClaim(
      id: json['id'],
      productId: json['productId'],
      productName: json['productName'],
      customerId: json['customerId'],
      customerName: json['customerName'],
      customerPhone: json['customerPhone'],
      customerEmail: json['customerEmail'],
      issueDescription: json['issueDescription'],
      issueDate: DateTime.parse(json['issueDate']),
      claimDate: json['claimDate'] != null ? DateTime.parse(json['claimDate']) : null,
      status: WarrantyStatus.values.firstWhere((e) => e.name == json['status']),
      claimNumber: json['claimNumber'],
      serviceCenterId: json['serviceCenterId'],
      serviceCenterName: json['serviceCenterName'],
      technicianId: json['technicianId'],
      technicianName: json['technicianName'],
      estimatedCompletionDate: json['estimatedCompletionDate'] != null 
          ? DateTime.parse(json['estimatedCompletionDate'])
          : null,
      actualCompletionDate: json['actualCompletionDate'] != null 
          ? DateTime.parse(json['actualCompletionDate'])
          : null,
      repairCost: json['repairCost']?.toDouble(),
      repairNotes: json['repairNotes'],
      isCoveredByWarranty: json['isCoveredByWarranty'] ?? true,
      rejectionReason: json['rejectionReason'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

// Extensions for display names
extension ElectronicsCategoryExtension on ElectronicsCategory {
  String get displayName {
    switch (this) {
      case ElectronicsCategory.smartphones:
        return 'Smartphones';
      case ElectronicsCategory.laptops:
        return 'Laptops';
      case ElectronicsCategory.tablets:
        return 'Tablets';
      case ElectronicsCategory.tvsAudio:
        return 'TVs & Audio';
      case ElectronicsCategory.gaming:
        return 'Gaming';
      case ElectronicsCategory.cameras:
        return 'Cameras';
      case ElectronicsCategory.accessories:
        return 'Accessories';
      case ElectronicsCategory.smartHome:
        return 'Smart Home';
      case ElectronicsCategory.wearables:
        return 'Wearables';
      case ElectronicsCategory.computers:
        return 'Computers';
      case ElectronicsCategory.networking:
        return 'Networking';
      case ElectronicsCategory.software:
        return 'Software';
    }
  }

  IconData get icon {
    switch (this) {
      case ElectronicsCategory.smartphones:
        return Icons.phone_android;
      case ElectronicsCategory.laptops:
        return Icons.laptop;
      case ElectronicsCategory.tablets:
        return Icons.tablet_android;
      case ElectronicsCategory.tvsAudio:
        return Icons.tv;
      case ElectronicsCategory.gaming:
        return Icons.games;
      case ElectronicsCategory.cameras:
        return Icons.camera_alt;
      case ElectronicsCategory.accessories:
        return Icons.devices_other;
      case ElectronicsCategory.smartHome:
        return Icons.home;
      case ElectronicsCategory.wearables:
        return Icons.watch;
      case ElectronicsCategory.computers:
        return Icons.computer;
      case ElectronicsCategory.networking:
        return Icons.router;
      case ElectronicsCategory.software:
        return Icons.code;
    }
  }
}

extension WarrantyStatusExtension on WarrantyStatus {
  String get displayName {
    switch (this) {
      case WarrantyStatus.active:
        return 'Active';
      case WarrantyStatus.expired:
        return 'Expired';
      case WarrantyStatus.voided:
        return 'Voided';
      case WarrantyStatus.claimed:
        return 'Claimed';
    }
  }

  Color get color {
    switch (this) {
      case WarrantyStatus.active:
        return Colors.green;
      case WarrantyStatus.expired:
        return Colors.red;
      case WarrantyStatus.voided:
        return Colors.orange;
      case WarrantyStatus.claimed:
        return Colors.blue;
    }
  }
}

extension TradeInConditionExtension on TradeInCondition {
  String get displayName {
    switch (this) {
      case TradeInCondition.excellent:
        return 'Excellent';
      case TradeInCondition.good:
        return 'Good';
      case TradeInCondition.fair:
        return 'Fair';
      case TradeInCondition.poor:
        return 'Poor';
      case TradeInCondition.damaged:
        return 'Damaged';
    }
  }

  Color get color {
    switch (this) {
      case TradeInCondition.excellent:
        return Colors.green;
      case TradeInCondition.good:
        return Colors.blue;
      case TradeInCondition.fair:
        return Colors.orange;
      case TradeInCondition.poor:
        return Colors.red;
      case TradeInCondition.damaged:
        return Colors.grey;
    }
  }
}