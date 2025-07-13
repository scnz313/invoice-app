import 'package:flutter/material.dart';

enum HardwareCategory {
  tools,
  buildingMaterials,
  electrical,
  plumbing,
  paintSupplies,
  gardenOutdoor,
  safetyEquipment,
  automotive,
  fasteners,
  adhesives,
  measuringTools,
  powerTools,
}

enum ProjectType {
  residential,
  commercial,
  industrial,
  renovation,
  newConstruction,
  maintenance,
  repair,
  installation,
}

enum ProjectStatus {
  planning,
  inProgress,
  onHold,
  completed,
  cancelled,
}

enum ContractorType {
  individual,
  company,
  subcontractor,
  specialist,
}

enum ToolRentalStatus {
  available,
  rented,
  maintenance,
  retired,
}

enum MaterialUnit {
  pieces,
  kilograms,
  meters,
  liters,
  squareMeters,
  cubicMeters,
  boxes,
  rolls,
  sets,
  bundles,
}

class HardwareProduct {
  final String id;
  final String name;
  final String description;
  final HardwareCategory category;
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
  final MaterialUnit unit;
  final double? weight; // in kg
  final String? dimensions; // L x W x H
  final String? specifications;
  final List<String> features;
  final List<String> applications;
  final List<String> compatibleItems;
  final String? safetyInstructions;
  final String? userManual;
  final bool isRentalAvailable;
  final double? rentalPricePerDay;
  final double? rentalPricePerWeek;
  final double? rentalPricePerMonth;
  final bool isDeliveryAvailable;
  final double? deliveryCharge;
  final bool isInstallationAvailable;
  final double? installationPrice;
  final String? installationDetails;
  final bool isBulkPricingAvailable;
  final List<BulkPricing> bulkPricing;
  final bool isProjectSpecific;
  final List<ProjectType> suitableProjects;
  final String? warrantyTerms;
  final int? warrantyPeriod; // in months
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

  HardwareProduct({
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
    required this.unit,
    this.weight,
    this.dimensions,
    this.specifications,
    this.features = const [],
    this.applications = const [],
    this.compatibleItems = const [],
    this.safetyInstructions,
    this.userManual,
    this.isRentalAvailable = false,
    this.rentalPricePerDay,
    this.rentalPricePerWeek,
    this.rentalPricePerMonth,
    this.isDeliveryAvailable = false,
    this.deliveryCharge,
    this.isInstallationAvailable = false,
    this.installationPrice,
    this.installationDetails,
    this.isBulkPricingAvailable = false,
    this.bulkPricing = const [],
    this.isProjectSpecific = false,
    this.suitableProjects = const [],
    this.warrantyTerms,
    this.warrantyPeriod,
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

  // Get rental display
  String get rentalDisplay {
    if (!isRentalAvailable) return 'Not Available';
    if (rentalPricePerDay != null) return '₹${rentalPricePerDay!.toStringAsFixed(2)}/day';
    if (rentalPricePerWeek != null) return '₹${rentalPricePerWeek!.toStringAsFixed(2)}/week';
    if (rentalPricePerMonth != null) return '₹${rentalPricePerMonth!.toStringAsFixed(2)}/month';
    return 'Contact for pricing';
  }

  // Get delivery display
  String get deliveryDisplay {
    if (!isDeliveryAvailable) return 'Not Available';
    if (deliveryCharge != null) return '₹${deliveryCharge!.toStringAsFixed(2)}';
    return 'Free';
  }

  // Get installation display
  String get installationDisplay {
    if (!isInstallationAvailable) return 'Not Available';
    if (installationPrice != null) return '₹${installationPrice!.toStringAsFixed(2)}';
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

  // Get unit display
  String get unitDisplay {
    switch (unit) {
      case MaterialUnit.pieces:
        return 'Pieces';
      case MaterialUnit.kilograms:
        return 'KG';
      case MaterialUnit.meters:
        return 'Meters';
      case MaterialUnit.liters:
        return 'Liters';
      case MaterialUnit.squareMeters:
        return 'Sq. Meters';
      case MaterialUnit.cubicMeters:
        return 'Cubic Meters';
      case MaterialUnit.boxes:
        return 'Boxes';
      case MaterialUnit.rolls:
        return 'Rolls';
      case MaterialUnit.sets:
        return 'Sets';
      case MaterialUnit.bundles:
        return 'Bundles';
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

  // Get suitable projects display
  String get suitableProjectsDisplay {
    if (suitableProjects.isEmpty) return 'All projects';
    return suitableProjects.map((p) => p.displayName).join(', ');
  }

  // Create copy with updated values
  HardwareProduct copyWith({
    String? id,
    String? name,
    String? description,
    HardwareCategory? category,
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
    MaterialUnit? unit,
    double? weight,
    String? dimensions,
    String? specifications,
    List<String>? features,
    List<String>? applications,
    List<String>? compatibleItems,
    String? safetyInstructions,
    String? userManual,
    bool? isRentalAvailable,
    double? rentalPricePerDay,
    double? rentalPricePerWeek,
    double? rentalPricePerMonth,
    bool? isDeliveryAvailable,
    double? deliveryCharge,
    bool? isInstallationAvailable,
    double? installationPrice,
    String? installationDetails,
    bool? isBulkPricingAvailable,
    List<BulkPricing>? bulkPricing,
    bool? isProjectSpecific,
    List<ProjectType>? suitableProjects,
    String? warrantyTerms,
    int? warrantyPeriod,
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
    return HardwareProduct(
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
      specifications: specifications ?? this.specifications,
      features: features ?? this.features,
      applications: applications ?? this.applications,
      compatibleItems: compatibleItems ?? this.compatibleItems,
      safetyInstructions: safetyInstructions ?? this.safetyInstructions,
      userManual: userManual ?? this.userManual,
      isRentalAvailable: isRentalAvailable ?? this.isRentalAvailable,
      rentalPricePerDay: rentalPricePerDay ?? this.rentalPricePerDay,
      rentalPricePerWeek: rentalPricePerWeek ?? this.rentalPricePerWeek,
      rentalPricePerMonth: rentalPricePerMonth ?? this.rentalPricePerMonth,
      isDeliveryAvailable: isDeliveryAvailable ?? this.isDeliveryAvailable,
      deliveryCharge: deliveryCharge ?? this.deliveryCharge,
      isInstallationAvailable: isInstallationAvailable ?? this.isInstallationAvailable,
      installationPrice: installationPrice ?? this.installationPrice,
      installationDetails: installationDetails ?? this.installationDetails,
      isBulkPricingAvailable: isBulkPricingAvailable ?? this.isBulkPricingAvailable,
      bulkPricing: bulkPricing ?? this.bulkPricing,
      isProjectSpecific: isProjectSpecific ?? this.isProjectSpecific,
      suitableProjects: suitableProjects ?? this.suitableProjects,
      warrantyTerms: warrantyTerms ?? this.warrantyTerms,
      warrantyPeriod: warrantyPeriod ?? this.warrantyPeriod,
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
      'unit': unit.name,
      'weight': weight,
      'dimensions': dimensions,
      'specifications': specifications,
      'features': features,
      'applications': applications,
      'compatibleItems': compatibleItems,
      'safetyInstructions': safetyInstructions,
      'userManual': userManual,
      'isRentalAvailable': isRentalAvailable,
      'rentalPricePerDay': rentalPricePerDay,
      'rentalPricePerWeek': rentalPricePerWeek,
      'rentalPricePerMonth': rentalPricePerMonth,
      'isDeliveryAvailable': isDeliveryAvailable,
      'deliveryCharge': deliveryCharge,
      'isInstallationAvailable': isInstallationAvailable,
      'installationPrice': installationPrice,
      'installationDetails': installationDetails,
      'isBulkPricingAvailable': isBulkPricingAvailable,
      'bulkPricing': bulkPricing.map((pricing) => pricing.toJson()).toList(),
      'isProjectSpecific': isProjectSpecific,
      'suitableProjects': suitableProjects.map((project) => project.name).toList(),
      'warrantyTerms': warrantyTerms,
      'warrantyPeriod': warrantyPeriod,
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
  factory HardwareProduct.fromJson(Map<String, dynamic> json) {
    return HardwareProduct(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: HardwareCategory.values.firstWhere((e) => e.name == json['category']),
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
      unit: MaterialUnit.values.firstWhere((e) => e.name == json['unit']),
      weight: json['weight']?.toDouble(),
      dimensions: json['dimensions'],
      specifications: json['specifications'],
      features: List<String>.from(json['features'] ?? []),
      applications: List<String>.from(json['applications'] ?? []),
      compatibleItems: List<String>.from(json['compatibleItems'] ?? []),
      safetyInstructions: json['safetyInstructions'],
      userManual: json['userManual'],
      isRentalAvailable: json['isRentalAvailable'] ?? false,
      rentalPricePerDay: json['rentalPricePerDay']?.toDouble(),
      rentalPricePerWeek: json['rentalPricePerWeek']?.toDouble(),
      rentalPricePerMonth: json['rentalPricePerMonth']?.toDouble(),
      isDeliveryAvailable: json['isDeliveryAvailable'] ?? false,
      deliveryCharge: json['deliveryCharge']?.toDouble(),
      isInstallationAvailable: json['isInstallationAvailable'] ?? false,
      installationPrice: json['installationPrice']?.toDouble(),
      installationDetails: json['installationDetails'],
      isBulkPricingAvailable: json['isBulkPricingAvailable'] ?? false,
      bulkPricing: (json['bulkPricing'] as List? ?? []).map((pricing) => BulkPricing.fromJson(pricing)).toList(),
      isProjectSpecific: json['isProjectSpecific'] ?? false,
      suitableProjects: (json['suitableProjects'] as List? ?? []).map((project) => ProjectType.values.firstWhere((e) => e.name == project)).toList(),
      warrantyTerms: json['warrantyTerms'],
      warrantyPeriod: json['warrantyPeriod'],
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
  final int minQuantity;
  final int? maxQuantity;
  final double pricePerUnit;
  final double discountPercentage;

  BulkPricing({
    required this.id,
    required this.minQuantity,
    this.maxQuantity,
    required this.pricePerUnit,
    required this.discountPercentage,
  });

  // Get quantity range display
  String get quantityRangeDisplay {
    if (maxQuantity == null) return '${minQuantity}+';
    return '$minQuantity - $maxQuantity';
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'minQuantity': minQuantity,
      'maxQuantity': maxQuantity,
      'pricePerUnit': pricePerUnit,
      'discountPercentage': discountPercentage,
    };
  }

  // Create from JSON
  factory BulkPricing.fromJson(Map<String, dynamic> json) {
    return BulkPricing(
      id: json['id'],
      minQuantity: json['minQuantity'],
      maxQuantity: json['maxQuantity'],
      pricePerUnit: json['pricePerUnit'].toDouble(),
      discountPercentage: json['discountPercentage'].toDouble(),
    );
  }
}

class Project {
  final String id;
  final String name;
  final String description;
  final ProjectType type;
  final ProjectStatus status;
  final String? customerId;
  final String? customerName;
  final String? customerPhone;
  final String? customerEmail;
  final String? address;
  final DateTime? startDate;
  final DateTime? estimatedEndDate;
  final DateTime? actualEndDate;
  final double estimatedBudget;
  final double actualBudget;
  final String? contractorId;
  final String? contractorName;
  final String? contractorPhone;
  final String? contractorEmail;
  final List<ProjectMaterial> materials;
  final List<ProjectTask> tasks;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.status,
    this.customerId,
    this.customerName,
    this.customerPhone,
    this.customerEmail,
    this.address,
    this.startDate,
    this.estimatedEndDate,
    this.actualEndDate,
    required this.estimatedBudget,
    required this.actualBudget,
    this.contractorId,
    this.contractorName,
    this.contractorPhone,
    this.contractorEmail,
    this.materials = const [],
    this.tasks = const [],
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  // Get project duration
  Duration? get projectDuration {
    if (startDate == null || actualEndDate == null) return null;
    return actualEndDate!.difference(startDate!);
  }

  // Get estimated duration
  Duration? get estimatedDuration {
    if (startDate == null || estimatedEndDate == null) return null;
    return estimatedEndDate!.difference(startDate!);
  }

  // Get budget variance
  double get budgetVariance => actualBudget - estimatedBudget;

  // Get budget variance percentage
  double get budgetVariancePercentage => (budgetVariance / estimatedBudget) * 100;

  // Get total material cost
  double get totalMaterialCost => materials.fold(0.0, (sum, material) => sum + material.totalCost);

  // Get completed tasks count
  int get completedTasksCount => tasks.where((task) => task.isCompleted).length;

  // Get total tasks count
  int get totalTasksCount => tasks.length;

  // Get progress percentage
  double get progressPercentage {
    if (totalTasksCount == 0) return 0.0;
    return (completedTasksCount / totalTasksCount) * 100;
  }

  // Check if project is active
  bool get isActive => status == ProjectStatus.inProgress;

  // Check if project is completed
  bool get isCompleted => status == ProjectStatus.completed;

  // Check if project is on hold
  bool get isOnHold => status == ProjectStatus.onHold;

  // Create copy with updated values
  Project copyWith({
    String? id,
    String? name,
    String? description,
    ProjectType? type,
    ProjectStatus? status,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? address,
    DateTime? startDate,
    DateTime? estimatedEndDate,
    DateTime? actualEndDate,
    double? estimatedBudget,
    double? actualBudget,
    String? contractorId,
    String? contractorName,
    String? contractorPhone,
    String? contractorEmail,
    List<ProjectMaterial>? materials,
    List<ProjectTask>? tasks,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerEmail: customerEmail ?? this.customerEmail,
      address: address ?? this.address,
      startDate: startDate ?? this.startDate,
      estimatedEndDate: estimatedEndDate ?? this.estimatedEndDate,
      actualEndDate: actualEndDate ?? this.actualEndDate,
      estimatedBudget: estimatedBudget ?? this.estimatedBudget,
      actualBudget: actualBudget ?? this.actualBudget,
      contractorId: contractorId ?? this.contractorId,
      contractorName: contractorName ?? this.contractorName,
      contractorPhone: contractorPhone ?? this.contractorPhone,
      contractorEmail: contractorEmail ?? this.contractorEmail,
      materials: materials ?? this.materials,
      tasks: tasks ?? this.tasks,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'status': status.name,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerEmail': customerEmail,
      'address': address,
      'startDate': startDate?.toIso8601String(),
      'estimatedEndDate': estimatedEndDate?.toIso8601String(),
      'actualEndDate': actualEndDate?.toIso8601String(),
      'estimatedBudget': estimatedBudget,
      'actualBudget': actualBudget,
      'contractorId': contractorId,
      'contractorName': contractorName,
      'contractorPhone': contractorPhone,
      'contractorEmail': contractorEmail,
      'materials': materials.map((material) => material.toJson()).toList(),
      'tasks': tasks.map((task) => task.toJson()).toList(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: ProjectType.values.firstWhere((e) => e.name == json['type']),
      status: ProjectStatus.values.firstWhere((e) => e.name == json['status']),
      customerId: json['customerId'],
      customerName: json['customerName'],
      customerPhone: json['customerPhone'],
      customerEmail: json['customerEmail'],
      address: json['address'],
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      estimatedEndDate: json['estimatedEndDate'] != null ? DateTime.parse(json['estimatedEndDate']) : null,
      actualEndDate: json['actualEndDate'] != null ? DateTime.parse(json['actualEndDate']) : null,
      estimatedBudget: json['estimatedBudget'].toDouble(),
      actualBudget: json['actualBudget'].toDouble(),
      contractorId: json['contractorId'],
      contractorName: json['contractorName'],
      contractorPhone: json['contractorPhone'],
      contractorEmail: json['contractorEmail'],
      materials: (json['materials'] as List? ?? []).map((material) => ProjectMaterial.fromJson(material)).toList(),
      tasks: (json['tasks'] as List? ?? []).map((task) => ProjectTask.fromJson(task)).toList(),
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class ProjectMaterial {
  final String id;
  final String productId;
  final String productName;
  final int quantity;
  final MaterialUnit unit;
  final double unitPrice;
  final double totalCost;
  final bool isDelivered;
  final DateTime? deliveryDate;
  final String? notes;

  ProjectMaterial({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.totalCost,
    this.isDelivered = false,
    this.deliveryDate,
    this.notes,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unit': unit.name,
      'unitPrice': unitPrice,
      'totalCost': totalCost,
      'isDelivered': isDelivered,
      'deliveryDate': deliveryDate?.toIso8601String(),
      'notes': notes,
    };
  }

  // Create from JSON
  factory ProjectMaterial.fromJson(Map<String, dynamic> json) {
    return ProjectMaterial(
      id: json['id'],
      productId: json['productId'],
      productName: json['productName'],
      quantity: json['quantity'],
      unit: MaterialUnit.values.firstWhere((e) => e.name == json['unit']),
      unitPrice: json['unitPrice'].toDouble(),
      totalCost: json['totalCost'].toDouble(),
      isDelivered: json['isDelivered'] ?? false,
      deliveryDate: json['deliveryDate'] != null ? DateTime.parse(json['deliveryDate']) : null,
      notes: json['notes'],
    );
  }
}

class ProjectTask {
  final String id;
  final String name;
  final String description;
  final bool isCompleted;
  final DateTime? startDate;
  final DateTime? estimatedEndDate;
  final DateTime? actualEndDate;
  final String? assignedTo;
  final double estimatedHours;
  final double actualHours;
  final String? notes;

  ProjectTask({
    required this.id,
    required this.name,
    required this.description,
    this.isCompleted = false,
    this.startDate,
    this.estimatedEndDate,
    this.actualEndDate,
    this.assignedTo,
    required this.estimatedHours,
    required this.actualHours,
    this.notes,
  });

  // Get task duration
  Duration? get taskDuration {
    if (startDate == null || actualEndDate == null) return null;
    return actualEndDate!.difference(startDate!);
  }

  // Get estimated duration
  Duration? get estimatedDuration {
    if (startDate == null || estimatedEndDate == null) return null;
    return estimatedEndDate!.difference(startDate!);
  }

  // Get hours variance
  double get hoursVariance => actualHours - estimatedHours;

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isCompleted': isCompleted,
      'startDate': startDate?.toIso8601String(),
      'estimatedEndDate': estimatedEndDate?.toIso8601String(),
      'actualEndDate': actualEndDate?.toIso8601String(),
      'assignedTo': assignedTo,
      'estimatedHours': estimatedHours,
      'actualHours': actualHours,
      'notes': notes,
    };
  }

  // Create from JSON
  factory ProjectTask.fromJson(Map<String, dynamic> json) {
    return ProjectTask(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      isCompleted: json['isCompleted'] ?? false,
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      estimatedEndDate: json['estimatedEndDate'] != null ? DateTime.parse(json['estimatedEndDate']) : null,
      actualEndDate: json['actualEndDate'] != null ? DateTime.parse(json['actualEndDate']) : null,
      assignedTo: json['assignedTo'],
      estimatedHours: json['estimatedHours'].toDouble(),
      actualHours: json['actualHours'].toDouble(),
      notes: json['notes'],
    );
  }
}

// Extensions for display names
extension HardwareCategoryExtension on HardwareCategory {
  String get displayName {
    switch (this) {
      case HardwareCategory.tools:
        return 'Tools';
      case HardwareCategory.buildingMaterials:
        return 'Building Materials';
      case HardwareCategory.electrical:
        return 'Electrical';
      case HardwareCategory.plumbing:
        return 'Plumbing';
      case HardwareCategory.paintSupplies:
        return 'Paint & Supplies';
      case HardwareCategory.gardenOutdoor:
        return 'Garden & Outdoor';
      case HardwareCategory.safetyEquipment:
        return 'Safety Equipment';
      case HardwareCategory.automotive:
        return 'Automotive';
      case HardwareCategory.fasteners:
        return 'Fasteners';
      case HardwareCategory.adhesives:
        return 'Adhesives';
      case HardwareCategory.measuringTools:
        return 'Measuring Tools';
      case HardwareCategory.powerTools:
        return 'Power Tools';
    }
  }

  IconData get icon {
    switch (this) {
      case HardwareCategory.tools:
        return Icons.build;
      case HardwareCategory.buildingMaterials:
        return Icons.construction;
      case HardwareCategory.electrical:
        return Icons.electrical_services;
      case HardwareCategory.plumbing:
        return Icons.plumbing;
      case HardwareCategory.paintSupplies:
        return Icons.format_paint;
      case HardwareCategory.gardenOutdoor:
        return Icons.yard;
      case HardwareCategory.safetyEquipment:
        return Icons.security;
      case HardwareCategory.automotive:
        return Icons.directions_car;
      case HardwareCategory.fasteners:
        return Icons.settings;
      case HardwareCategory.adhesives:
        return Icons.attach_file;
      case HardwareCategory.measuringTools:
        return Icons.straighten;
      case HardwareCategory.powerTools:
        return Icons.power;
    }
  }
}

extension ProjectTypeExtension on ProjectType {
  String get displayName {
    switch (this) {
      case ProjectType.residential:
        return 'Residential';
      case ProjectType.commercial:
        return 'Commercial';
      case ProjectType.industrial:
        return 'Industrial';
      case ProjectType.renovation:
        return 'Renovation';
      case ProjectType.newConstruction:
        return 'New Construction';
      case ProjectType.maintenance:
        return 'Maintenance';
      case ProjectType.repair:
        return 'Repair';
      case ProjectType.installation:
        return 'Installation';
    }
  }

  IconData get icon {
    switch (this) {
      case ProjectType.residential:
        return Icons.home;
      case ProjectType.commercial:
        return Icons.business;
      case ProjectType.industrial:
        return Icons.factory;
      case ProjectType.renovation:
        return Icons.construction;
      case ProjectType.newConstruction:
        return Icons.add_business;
      case ProjectType.maintenance:
        return Icons.build;
      case ProjectType.repair:
        return Icons.handyman;
      case ProjectType.installation:
        return Icons.install_desktop;
    }
  }
}

extension ProjectStatusExtension on ProjectStatus {
  String get displayName {
    switch (this) {
      case ProjectStatus.planning:
        return 'Planning';
      case ProjectStatus.inProgress:
        return 'In Progress';
      case ProjectStatus.onHold:
        return 'On Hold';
      case ProjectStatus.completed:
        return 'Completed';
      case ProjectStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case ProjectStatus.planning:
        return Colors.blue;
      case ProjectStatus.inProgress:
        return Colors.orange;
      case ProjectStatus.onHold:
        return Colors.yellow;
      case ProjectStatus.completed:
        return Colors.green;
      case ProjectStatus.cancelled:
        return Colors.red;
    }
  }
}

extension MaterialUnitExtension on MaterialUnit {
  String get displayName {
    switch (this) {
      case MaterialUnit.pieces:
        return 'Pieces';
      case MaterialUnit.kilograms:
        return 'Kilograms';
      case MaterialUnit.meters:
        return 'Meters';
      case MaterialUnit.liters:
        return 'Liters';
      case MaterialUnit.squareMeters:
        return 'Square Meters';
      case MaterialUnit.cubicMeters:
        return 'Cubic Meters';
      case MaterialUnit.boxes:
        return 'Boxes';
      case MaterialUnit.rolls:
        return 'Rolls';
      case MaterialUnit.sets:
        return 'Sets';
      case MaterialUnit.bundles:
        return 'Bundles';
    }
  }
}