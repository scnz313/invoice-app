import 'package:flutter/material.dart';

enum MenuCategory {
  appetizers,
  mainCourse,
  desserts,
  beverages,
  alcoholicDrinks,
  coffeeTea,
  fastFood,
  healthyOptions,
  vegetarian,
  vegan,
  glutenFree,
  kidsMenu,
}

enum OrderType {
  dineIn,
  takeaway,
  delivery,
  catering,
}

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  ready,
  served,
  delivered,
  cancelled,
  completed,
}

enum TableStatus {
  available,
  occupied,
  reserved,
  cleaning,
  maintenance,
}

enum PaymentStatus {
  pending,
  partial,
  completed,
  refunded,
}

class RestaurantProduct {
  final String id;
  final String name;
  final String description;
  final MenuCategory category;
  final double price;
  final double? discountedPrice;
  final bool isVegetarian;
  final bool isVegan;
  final bool isGlutenFree;
  final bool isSpicy;
  final bool isPopular;
  final bool isAvailable;
  final List<String> ingredients;
  final List<String> allergens;
  final String? preparationTime; // in minutes
  final String? cookingInstructions;
  final String? chefNotes;
  final double? rating;
  final int? reviewCount;
  final List<String> images;
  final List<String> tags;
  final String? chefId;
  final String? chefName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  RestaurantProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    this.discountedPrice,
    this.isVegetarian = false,
    this.isVegan = false,
    this.isGlutenFree = false,
    this.isSpicy = false,
    this.isPopular = false,
    this.isAvailable = true,
    this.ingredients = const [],
    this.allergens = const [],
    this.preparationTime,
    this.cookingInstructions,
    this.chefNotes,
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
    if (discountedPrice == null || discountedPrice! >= price) return null;
    return ((price - discountedPrice!) / price) * 100;
  }

  // Get final price (discounted or original)
  double get finalPrice => discountedPrice ?? price;

  // Check if item is on discount
  bool get isOnDiscount => discountedPrice != null && discountedPrice! < price;

  // Get dietary restrictions display
  List<String> get dietaryRestrictions {
    List<String> restrictions = [];
    if (isVegetarian) restrictions.add('Vegetarian');
    if (isVegan) restrictions.add('Vegan');
    if (isGlutenFree) restrictions.add('Gluten-Free');
    if (isSpicy) restrictions.add('Spicy');
    return restrictions;
  }

  // Get allergens display
  String get allergensDisplay {
    if (allergens.isEmpty) return 'No known allergens';
    return allergens.join(', ');
  }

  // Get ingredients display
  String get ingredientsDisplay {
    if (ingredients.isEmpty) return 'Ingredients not specified';
    return ingredients.join(', ');
  }

  // Get rating display
  String get ratingDisplay {
    if (rating == null) return 'No ratings';
    return '${rating!.toStringAsFixed(1)} (${reviewCount ?? 0} reviews)';
  }

  // Create copy with updated values
  RestaurantProduct copyWith({
    String? id,
    String? name,
    String? description,
    MenuCategory? category,
    double? price,
    double? discountedPrice,
    bool? isVegetarian,
    bool? isVegan,
    bool? isGlutenFree,
    bool? isSpicy,
    bool? isPopular,
    bool? isAvailable,
    List<String>? ingredients,
    List<String>? allergens,
    String? preparationTime,
    String? cookingInstructions,
    String? chefNotes,
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
    return RestaurantProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      isVegetarian: isVegetarian ?? this.isVegetarian,
      isVegan: isVegan ?? this.isVegan,
      isGlutenFree: isGlutenFree ?? this.isGlutenFree,
      isSpicy: isSpicy ?? this.isSpicy,
      isPopular: isPopular ?? this.isPopular,
      isAvailable: isAvailable ?? this.isAvailable,
      ingredients: ingredients ?? this.ingredients,
      allergens: allergens ?? this.allergens,
      preparationTime: preparationTime ?? this.preparationTime,
      cookingInstructions: cookingInstructions ?? this.cookingInstructions,
      chefNotes: chefNotes ?? this.chefNotes,
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
      'price': price,
      'discountedPrice': discountedPrice,
      'isVegetarian': isVegetarian,
      'isVegan': isVegan,
      'isGlutenFree': isGlutenFree,
      'isSpicy': isSpicy,
      'isPopular': isPopular,
      'isAvailable': isAvailable,
      'ingredients': ingredients,
      'allergens': allergens,
      'preparationTime': preparationTime,
      'cookingInstructions': cookingInstructions,
      'chefNotes': chefNotes,
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
  factory RestaurantProduct.fromJson(Map<String, dynamic> json) {
    return RestaurantProduct(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: MenuCategory.values.firstWhere((e) => e.name == json['category']),
      price: json['price'].toDouble(),
      discountedPrice: json['discountedPrice']?.toDouble(),
      isVegetarian: json['isVegetarian'] ?? false,
      isVegan: json['isVegan'] ?? false,
      isGlutenFree: json['isGlutenFree'] ?? false,
      isSpicy: json['isSpicy'] ?? false,
      isPopular: json['isPopular'] ?? false,
      isAvailable: json['isAvailable'] ?? true,
      ingredients: List<String>.from(json['ingredients'] ?? []),
      allergens: List<String>.from(json['allergens'] ?? []),
      preparationTime: json['preparationTime'],
      cookingInstructions: json['cookingInstructions'],
      chefNotes: json['chefNotes'],
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

class Table {
  final String id;
  final String tableNumber;
  final int capacity;
  final TableStatus status;
  final String? currentOrderId;
  final String? currentCustomerId;
  final DateTime? occupiedAt;
  final DateTime? reservedAt;
  final String? reservationName;
  final String? reservationPhone;
  final int? reservationGuests;
  final String? waiterId;
  final String? waiterName;
  final String? location; // e.g., "Window", "Garden", "Indoor"
  final bool isSmoking;
  final bool isWheelchairAccessible;
  final DateTime createdAt;
  final DateTime updatedAt;

  Table({
    required this.id,
    required this.tableNumber,
    required this.capacity,
    required this.status,
    this.currentOrderId,
    this.currentCustomerId,
    this.occupiedAt,
    this.reservedAt,
    this.reservationName,
    this.reservationPhone,
    this.reservationGuests,
    this.waiterId,
    this.waiterName,
    this.location,
    this.isSmoking = false,
    this.isWheelchairAccessible = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // Check if table is available
  bool get isAvailable => status == TableStatus.available;

  // Check if table is occupied
  bool get isOccupied => status == TableStatus.occupied;

  // Check if table is reserved
  bool get isReserved => status == TableStatus.reserved;

  // Get occupancy duration
  Duration? get occupancyDuration {
    if (occupiedAt == null) return null;
    return DateTime.now().difference(occupiedAt!);
  }

  // Get reservation time remaining
  Duration? get reservationTimeRemaining {
    if (reservedAt == null) return null;
    final reservationEnd = reservedAt!.add(const Duration(hours: 2)); // Default 2-hour reservation
    return reservationEnd.difference(DateTime.now());
  }

  // Create copy with updated values
  Table copyWith({
    String? id,
    String? tableNumber,
    int? capacity,
    TableStatus? status,
    String? currentOrderId,
    String? currentCustomerId,
    DateTime? occupiedAt,
    DateTime? reservedAt,
    String? reservationName,
    String? reservationPhone,
    int? reservationGuests,
    String? waiterId,
    String? waiterName,
    String? location,
    bool? isSmoking,
    bool? isWheelchairAccessible,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Table(
      id: id ?? this.id,
      tableNumber: tableNumber ?? this.tableNumber,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
      currentOrderId: currentOrderId ?? this.currentOrderId,
      currentCustomerId: currentCustomerId ?? this.currentCustomerId,
      occupiedAt: occupiedAt ?? this.occupiedAt,
      reservedAt: reservedAt ?? this.reservedAt,
      reservationName: reservationName ?? this.reservationName,
      reservationPhone: reservationPhone ?? this.reservationPhone,
      reservationGuests: reservationGuests ?? this.reservationGuests,
      waiterId: waiterId ?? this.waiterId,
      waiterName: waiterName ?? this.waiterName,
      location: location ?? this.location,
      isSmoking: isSmoking ?? this.isSmoking,
      isWheelchairAccessible: isWheelchairAccessible ?? this.isWheelchairAccessible,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tableNumber': tableNumber,
      'capacity': capacity,
      'status': status.name,
      'currentOrderId': currentOrderId,
      'currentCustomerId': currentCustomerId,
      'occupiedAt': occupiedAt?.toIso8601String(),
      'reservedAt': reservedAt?.toIso8601String(),
      'reservationName': reservationName,
      'reservationPhone': reservationPhone,
      'reservationGuests': reservationGuests,
      'waiterId': waiterId,
      'waiterName': waiterName,
      'location': location,
      'isSmoking': isSmoking,
      'isWheelchairAccessible': isWheelchairAccessible,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory Table.fromJson(Map<String, dynamic> json) {
    return Table(
      id: json['id'],
      tableNumber: json['tableNumber'],
      capacity: json['capacity'],
      status: TableStatus.values.firstWhere((e) => e.name == json['status']),
      currentOrderId: json['currentOrderId'],
      currentCustomerId: json['currentCustomerId'],
      occupiedAt: json['occupiedAt'] != null ? DateTime.parse(json['occupiedAt']) : null,
      reservedAt: json['reservedAt'] != null ? DateTime.parse(json['reservedAt']) : null,
      reservationName: json['reservationName'],
      reservationPhone: json['reservationPhone'],
      reservationGuests: json['reservationGuests'],
      waiterId: json['waiterId'],
      waiterName: json['waiterName'],
      location: json['location'],
      isSmoking: json['isSmoking'] ?? false,
      isWheelchairAccessible: json['isWheelchairAccessible'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class RestaurantOrder {
  final String id;
  final String orderNumber;
  final OrderType orderType;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final String? tableId;
  final String? tableNumber;
  final String? customerId;
  final String? customerName;
  final String? customerPhone;
  final String? customerEmail;
  final int numberOfGuests;
  final List<OrderItem> items;
  final double subtotal;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final double? tipAmount;
  final double? deliveryCharge;
  final String? specialInstructions;
  final String? waiterId;
  final String? waiterName;
  final String? chefId;
  final String? chefName;
  final DateTime? estimatedReadyTime;
  final DateTime? actualReadyTime;
  final DateTime? servedAt;
  final DateTime? deliveredAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  RestaurantOrder({
    required this.id,
    required this.orderNumber,
    required this.orderType,
    required this.status,
    required this.paymentStatus,
    this.tableId,
    this.tableNumber,
    this.customerId,
    this.customerName,
    this.customerPhone,
    this.customerEmail,
    required this.numberOfGuests,
    required this.items,
    required this.subtotal,
    required this.taxAmount,
    required this.discountAmount,
    required this.totalAmount,
    this.tipAmount,
    this.deliveryCharge,
    this.specialInstructions,
    this.waiterId,
    this.waiterName,
    this.chefId,
    this.chefName,
    this.estimatedReadyTime,
    this.actualReadyTime,
    this.servedAt,
    this.deliveredAt,
    required this.createdAt,
    required this.updatedAt,
  });

  // Calculate total with tip and delivery
  double get finalTotal {
    double total = totalAmount;
    if (tipAmount != null) total += tipAmount!;
    if (deliveryCharge != null) total += deliveryCharge!;
    return total;
  }

  // Get order duration
  Duration get orderDuration => DateTime.now().difference(createdAt);

  // Get preparation time
  Duration? get preparationTime {
    if (actualReadyTime == null) return null;
    return actualReadyTime!.difference(createdAt);
  }

  // Get service time
  Duration? get serviceTime {
    if (servedAt == null || actualReadyTime == null) return null;
    return servedAt!.difference(actualReadyTime!);
  }

  // Check if order is ready
  bool get isReady => status == OrderStatus.ready;

  // Check if order is completed
  bool get isCompleted => status == OrderStatus.completed;

  // Check if order is cancelled
  bool get isCancelled => status == OrderStatus.cancelled;

  // Get items count
  int get itemsCount => items.fold(0, (sum, item) => sum + item.quantity);

  // Create copy with updated values
  RestaurantOrder copyWith({
    String? id,
    String? orderNumber,
    OrderType? orderType,
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    String? tableId,
    String? tableNumber,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    int? numberOfGuests,
    List<OrderItem>? items,
    double? subtotal,
    double? taxAmount,
    double? discountAmount,
    double? totalAmount,
    double? tipAmount,
    double? deliveryCharge,
    String? specialInstructions,
    String? waiterId,
    String? waiterName,
    String? chefId,
    String? chefName,
    DateTime? estimatedReadyTime,
    DateTime? actualReadyTime,
    DateTime? servedAt,
    DateTime? deliveredAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RestaurantOrder(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      orderType: orderType ?? this.orderType,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      tableId: tableId ?? this.tableId,
      tableNumber: tableNumber ?? this.tableNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerEmail: customerEmail ?? this.customerEmail,
      numberOfGuests: numberOfGuests ?? this.numberOfGuests,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      tipAmount: tipAmount ?? this.tipAmount,
      deliveryCharge: deliveryCharge ?? this.deliveryCharge,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      waiterId: waiterId ?? this.waiterId,
      waiterName: waiterName ?? this.waiterName,
      chefId: chefId ?? this.chefId,
      chefName: chefName ?? this.chefName,
      estimatedReadyTime: estimatedReadyTime ?? this.estimatedReadyTime,
      actualReadyTime: actualReadyTime ?? this.actualReadyTime,
      servedAt: servedAt ?? this.servedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'orderType': orderType.name,
      'status': status.name,
      'paymentStatus': paymentStatus.name,
      'tableId': tableId,
      'tableNumber': tableNumber,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerEmail': customerEmail,
      'numberOfGuests': numberOfGuests,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'discountAmount': discountAmount,
      'totalAmount': totalAmount,
      'tipAmount': tipAmount,
      'deliveryCharge': deliveryCharge,
      'specialInstructions': specialInstructions,
      'waiterId': waiterId,
      'waiterName': waiterName,
      'chefId': chefId,
      'chefName': chefName,
      'estimatedReadyTime': estimatedReadyTime?.toIso8601String(),
      'actualReadyTime': actualReadyTime?.toIso8601String(),
      'servedAt': servedAt?.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory RestaurantOrder.fromJson(Map<String, dynamic> json) {
    return RestaurantOrder(
      id: json['id'],
      orderNumber: json['orderNumber'],
      orderType: OrderType.values.firstWhere((e) => e.name == json['orderType']),
      status: OrderStatus.values.firstWhere((e) => e.name == json['status']),
      paymentStatus: PaymentStatus.values.firstWhere((e) => e.name == json['paymentStatus']),
      tableId: json['tableId'],
      tableNumber: json['tableNumber'],
      customerId: json['customerId'],
      customerName: json['customerName'],
      customerPhone: json['customerPhone'],
      customerEmail: json['customerEmail'],
      numberOfGuests: json['numberOfGuests'],
      items: (json['items'] as List).map((item) => OrderItem.fromJson(item)).toList(),
      subtotal: json['subtotal'].toDouble(),
      taxAmount: json['taxAmount'].toDouble(),
      discountAmount: json['discountAmount'].toDouble(),
      totalAmount: json['totalAmount'].toDouble(),
      tipAmount: json['tipAmount']?.toDouble(),
      deliveryCharge: json['deliveryCharge']?.toDouble(),
      specialInstructions: json['specialInstructions'],
      waiterId: json['waiterId'],
      waiterName: json['waiterName'],
      chefId: json['chefId'],
      chefName: json['chefName'],
      estimatedReadyTime: json['estimatedReadyTime'] != null ? DateTime.parse(json['estimatedReadyTime']) : null,
      actualReadyTime: json['actualReadyTime'] != null ? DateTime.parse(json['actualReadyTime']) : null,
      servedAt: json['servedAt'] != null ? DateTime.parse(json['servedAt']) : null,
      deliveredAt: json['deliveredAt'] != null ? DateTime.parse(json['deliveredAt']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class OrderItem {
  final String id;
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? specialInstructions;
  final List<String> modifications;
  final bool isReady;
  final DateTime? readyAt;

  OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.specialInstructions,
    this.modifications = const [],
    this.isReady = false,
    this.readyAt,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'specialInstructions': specialInstructions,
      'modifications': modifications,
      'isReady': isReady,
      'readyAt': readyAt?.toIso8601String(),
    };
  }

  // Create from JSON
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      productId: json['productId'],
      productName: json['productName'],
      quantity: json['quantity'],
      unitPrice: json['unitPrice'].toDouble(),
      totalPrice: json['totalPrice'].toDouble(),
      specialInstructions: json['specialInstructions'],
      modifications: List<String>.from(json['modifications'] ?? []),
      isReady: json['isReady'] ?? false,
      readyAt: json['readyAt'] != null ? DateTime.parse(json['readyAt']) : null,
    );
  }
}

// Extensions for display names
extension MenuCategoryExtension on MenuCategory {
  String get displayName {
    switch (this) {
      case MenuCategory.appetizers:
        return 'Appetizers';
      case MenuCategory.mainCourse:
        return 'Main Course';
      case MenuCategory.desserts:
        return 'Desserts';
      case MenuCategory.beverages:
        return 'Beverages';
      case MenuCategory.alcoholicDrinks:
        return 'Alcoholic Drinks';
      case MenuCategory.coffeeTea:
        return 'Coffee & Tea';
      case MenuCategory.fastFood:
        return 'Fast Food';
      case MenuCategory.healthyOptions:
        return 'Healthy Options';
      case MenuCategory.vegetarian:
        return 'Vegetarian';
      case MenuCategory.vegan:
        return 'Vegan';
      case MenuCategory.glutenFree:
        return 'Gluten-Free';
      case MenuCategory.kidsMenu:
        return 'Kids Menu';
    }
  }

  IconData get icon {
    switch (this) {
      case MenuCategory.appetizers:
        return Icons.restaurant_menu;
      case MenuCategory.mainCourse:
        return Icons.restaurant;
      case MenuCategory.desserts:
        return Icons.cake;
      case MenuCategory.beverages:
        return Icons.local_drink;
      case MenuCategory.alcoholicDrinks:
        return Icons.wine_bar;
      case MenuCategory.coffeeTea:
        return Icons.coffee;
      case MenuCategory.fastFood:
        return Icons.fastfood;
      case MenuCategory.healthyOptions:
        return Icons.favorite;
      case MenuCategory.vegetarian:
        return Icons.eco;
      case MenuCategory.vegan:
        return Icons.spa;
      case MenuCategory.glutenFree:
        return Icons.warning;
      case MenuCategory.kidsMenu:
        return Icons.child_care;
    }
  }
}

extension OrderTypeExtension on OrderType {
  String get displayName {
    switch (this) {
      case OrderType.dineIn:
        return 'Dine In';
      case OrderType.takeaway:
        return 'Takeaway';
      case OrderType.delivery:
        return 'Delivery';
      case OrderType.catering:
        return 'Catering';
    }
  }

  IconData get icon {
    switch (this) {
      case OrderType.dineIn:
        return Icons.table_restaurant;
      case OrderType.takeaway:
        return Icons.takeout_dining;
      case OrderType.delivery:
        return Icons.delivery_dining;
      case OrderType.catering:
        return Icons.event;
    }
  }
}

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.served:
        return 'Served';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.completed:
        return 'Completed';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.preparing:
        return Colors.purple;
      case OrderStatus.ready:
        return Colors.green;
      case OrderStatus.served:
        return Colors.teal;
      case OrderStatus.delivered:
        return Colors.indigo;
      case OrderStatus.cancelled:
        return Colors.red;
      case OrderStatus.completed:
        return Colors.grey;
    }
  }
}

extension TableStatusExtension on TableStatus {
  String get displayName {
    switch (this) {
      case TableStatus.available:
        return 'Available';
      case TableStatus.occupied:
        return 'Occupied';
      case TableStatus.reserved:
        return 'Reserved';
      case TableStatus.cleaning:
        return 'Cleaning';
      case TableStatus.maintenance:
        return 'Maintenance';
    }
  }

  Color get color {
    switch (this) {
      case TableStatus.available:
        return Colors.green;
      case TableStatus.occupied:
        return Colors.red;
      case TableStatus.reserved:
        return Colors.orange;
      case TableStatus.cleaning:
        return Colors.blue;
      case TableStatus.maintenance:
        return Colors.grey;
    }
  }
}