import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'jewelry_client.g.dart';

enum CustomerType {
  regular,
  vip,
  wholesale,
  corporate,
  online,
}

enum CustomerStatus {
  active,
  inactive,
  blocked,
}

@JsonSerializable()
class CustomerAddress {
  final String id;
  final String type; // home, office, delivery
  final String address;
  final String city;
  final String state;
  final String pincode;
  final String country;
  final bool isDefault;

  CustomerAddress({
    required this.id,
    required this.type,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    this.country = 'India',
    this.isDefault = false,
  });

  factory CustomerAddress.fromJson(Map<String, dynamic> json) => _$CustomerAddressFromJson(json);
  Map<String, dynamic> toJson() => _$CustomerAddressToJson(this);

  String get fullAddress => '$address, $city, $state - $pincode';
}

@JsonSerializable()
class PurchaseHistory {
  final String invoiceId;
  final DateTime date;
  final double amount;
  final String description;

  PurchaseHistory({
    required this.invoiceId,
    required this.date,
    required this.amount,
    required this.description,
  });

  factory PurchaseHistory.fromJson(Map<String, dynamic> json) => _$PurchaseHistoryFromJson(json);
  Map<String, dynamic> toJson() => _$PurchaseHistoryToJson(this);
}

@JsonSerializable()
class JewelryClient {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? alternatePhone;
  final List<CustomerAddress> addresses;
  final CustomerType customerType;
  final CustomerStatus status;
  final double creditLimit;
  final double outstandingAmount;
  final double totalPurchaseAmount;
  final int loyaltyPoints;
  final DateTime? dateOfBirth;
  final DateTime? anniversaryDate;
  final String? gstNumber;
  final String? panNumber;
  final String? aadharNumber;
  final List<PurchaseHistory> purchaseHistory;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? referredBy;
  final double discountPercentage;
  final bool isActive;

  JewelryClient({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.alternatePhone,
    this.addresses = const [],
    this.customerType = CustomerType.regular,
    this.status = CustomerStatus.active,
    this.creditLimit = 0.0,
    this.outstandingAmount = 0.0,
    this.totalPurchaseAmount = 0.0,
    this.loyaltyPoints = 0,
    this.dateOfBirth,
    this.anniversaryDate,
    this.gstNumber,
    this.panNumber,
    this.aadharNumber,
    this.purchaseHistory = const [],
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.referredBy,
    this.discountPercentage = 0.0,
    this.isActive = true,
  });

  factory JewelryClient.create({
    required String name,
    required String email,
    required String phone,
    String? alternatePhone,
    List<CustomerAddress> addresses = const [],
    CustomerType customerType = CustomerType.regular,
    double creditLimit = 0.0,
    DateTime? dateOfBirth,
    DateTime? anniversaryDate,
    String? gstNumber,
    String? panNumber,
    String? aadharNumber,
    String? notes,
    String? referredBy,
    double discountPercentage = 0.0,
  }) {
    final now = DateTime.now();
    return JewelryClient(
      id: const Uuid().v4(),
      name: name,
      email: email,
      phone: phone,
      alternatePhone: alternatePhone,
      addresses: addresses,
      customerType: customerType,
      creditLimit: creditLimit,
      dateOfBirth: dateOfBirth,
      anniversaryDate: anniversaryDate,
      gstNumber: gstNumber,
      panNumber: panNumber,
      aadharNumber: aadharNumber,
      notes: notes,
      createdAt: now,
      updatedAt: now,
      referredBy: referredBy,
      discountPercentage: discountPercentage,
    );
  }

  // Get customer type display
  String get customerTypeDisplay {
    switch (customerType) {
      case CustomerType.regular:
        return 'Regular';
      case CustomerType.vip:
        return 'VIP';
      case CustomerType.wholesale:
        return 'Wholesale';
      case CustomerType.corporate:
        return 'Corporate';
      case CustomerType.online:
        return 'Online';
    }
  }

  // Get status display
  String get statusDisplay {
    switch (status) {
      case CustomerStatus.active:
        return 'Active';
      case CustomerStatus.inactive:
        return 'Inactive';
      case CustomerStatus.blocked:
        return 'Blocked';
    }
  }

  // Get available credit
  double get availableCredit => creditLimit - outstandingAmount;

  // Check if customer has credit limit
  bool get hasCreditLimit => creditLimit > 0;

  // Check if customer is within credit limit
  bool get isWithinCreditLimit => outstandingAmount <= creditLimit;

  // Get default address
  CustomerAddress? get defaultAddress {
    try {
      return addresses.firstWhere((address) => address.isDefault);
    } catch (e) {
      return addresses.isNotEmpty ? addresses.first : null;
    }
  }

  // Get total purchase count
  int get totalPurchaseCount => purchaseHistory.length;

  // Get last purchase date
  DateTime? get lastPurchaseDate {
    if (purchaseHistory.isEmpty) return null;
    return purchaseHistory.map((p) => p.date).reduce((a, b) => a.isAfter(b) ? a : b);
  }

  // Calculate loyalty tier
  String get loyaltyTier {
    if (loyaltyPoints >= 10000) return 'Platinum';
    if (loyaltyPoints >= 5000) return 'Gold';
    if (loyaltyPoints >= 2500) return 'Silver';
    return 'Bronze';
  }

  // Check if birthday is today
  bool get isBirthdayToday {
    if (dateOfBirth == null) return false;
    final today = DateTime.now();
    return dateOfBirth!.day == today.day && dateOfBirth!.month == today.month;
  }

  // Check if anniversary is today
  bool get isAnniversaryToday {
    if (anniversaryDate == null) return false;
    final today = DateTime.now();
    return anniversaryDate!.day == today.day && anniversaryDate!.month == today.month;
  }

  // Check if it's a special occasion
  bool get isSpecialOccasion => isBirthdayToday || isAnniversaryToday;

  // Get age
  int? get age {
    if (dateOfBirth == null) return null;
    final today = DateTime.now();
    int age = today.year - dateOfBirth!.year;
    if (today.month < dateOfBirth!.month ||
        (today.month == dateOfBirth!.month && today.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  // Get years of association
  int get yearsOfAssociation {
    final today = DateTime.now();
    int years = today.year - createdAt.year;
    if (today.month < createdAt.month ||
        (today.month == createdAt.month && today.day < createdAt.day)) {
      years--;
    }
    return years;
  }

  factory JewelryClient.fromJson(Map<String, dynamic> json) => _$JewelryClientFromJson(json);
  Map<String, dynamic> toJson() => _$JewelryClientToJson(this);

  JewelryClient copyWith({
    String? name,
    String? email,
    String? phone,
    String? alternatePhone,
    List<CustomerAddress>? addresses,
    CustomerType? customerType,
    CustomerStatus? status,
    double? creditLimit,
    double? outstandingAmount,
    double? totalPurchaseAmount,
    int? loyaltyPoints,
    DateTime? dateOfBirth,
    DateTime? anniversaryDate,
    String? gstNumber,
    String? panNumber,
    String? aadharNumber,
    List<PurchaseHistory>? purchaseHistory,
    String? notes,
    String? referredBy,
    double? discountPercentage,
    bool? isActive,
  }) {
    return JewelryClient(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      alternatePhone: alternatePhone ?? this.alternatePhone,
      addresses: addresses ?? this.addresses,
      customerType: customerType ?? this.customerType,
      status: status ?? this.status,
      creditLimit: creditLimit ?? this.creditLimit,
      outstandingAmount: outstandingAmount ?? this.outstandingAmount,
      totalPurchaseAmount: totalPurchaseAmount ?? this.totalPurchaseAmount,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      anniversaryDate: anniversaryDate ?? this.anniversaryDate,
      gstNumber: gstNumber ?? this.gstNumber,
      panNumber: panNumber ?? this.panNumber,
      aadharNumber: aadharNumber ?? this.aadharNumber,
      purchaseHistory: purchaseHistory ?? this.purchaseHistory,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      referredBy: referredBy ?? this.referredBy,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'JewelryClient(id: $id, name: $name, email: $email, type: $customerTypeDisplay)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is JewelryClient && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}