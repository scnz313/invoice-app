import 'package:json_annotation/json_annotation.dart';

enum LoyaltyTier {
  bronze,
  silver,
  gold,
  platinum,
  diamond,
}

enum LoyaltyTransactionType {
  earn,
  redeem,
  expire,
  bonus,
  adjustment,
}

class CustomerLoyalty {
  final String id;
  final String customerId;
  final int currentPoints;
  final int totalPointsEarned;
  final int totalPointsRedeemed;
  final LoyaltyTier tier;
  final DateTime? lastPurchaseDate;
  final DateTime? tierUpgradeDate;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CustomerLoyalty({
    required this.id,
    required this.customerId,
    required this.currentPoints,
    required this.totalPointsEarned,
    required this.totalPointsRedeemed,
    required this.tier,
    this.lastPurchaseDate,
    this.tierUpgradeDate,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomerLoyalty.fromJson(Map<String, dynamic> json) {
    return CustomerLoyalty(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      currentPoints: json['currentPoints'] as int,
      totalPointsEarned: json['totalPointsEarned'] as int,
      totalPointsRedeemed: json['totalPointsRedeemed'] as int,
      tier: LoyaltyTier.values.firstWhere((e) => e.name == json['tier']),
      lastPurchaseDate: json['lastPurchaseDate'] != null 
          ? DateTime.parse(json['lastPurchaseDate'] as String)
          : null,
      tierUpgradeDate: json['tierUpgradeDate'] != null 
          ? DateTime.parse(json['tierUpgradeDate'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'currentPoints': currentPoints,
      'totalPointsEarned': totalPointsEarned,
      'totalPointsRedeemed': totalPointsRedeemed,
      'tier': tier.name,
      'lastPurchaseDate': lastPurchaseDate?.toIso8601String(),
      'tierUpgradeDate': tierUpgradeDate?.toIso8601String(),
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  CustomerLoyalty copyWith({
    String? id,
    String? customerId,
    int? currentPoints,
    int? totalPointsEarned,
    int? totalPointsRedeemed,
    LoyaltyTier? tier,
    DateTime? lastPurchaseDate,
    DateTime? tierUpgradeDate,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomerLoyalty(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      currentPoints: currentPoints ?? this.currentPoints,
      totalPointsEarned: totalPointsEarned ?? this.totalPointsEarned,
      totalPointsRedeemed: totalPointsRedeemed ?? this.totalPointsRedeemed,
      tier: tier ?? this.tier,
      lastPurchaseDate: lastPurchaseDate ?? this.lastPurchaseDate,
      tierUpgradeDate: tierUpgradeDate ?? this.tierUpgradeDate,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Computed properties
  double get pointsValue => currentPoints * 0.01; // 1 point = ₹0.01
  double get totalValueEarned => totalPointsEarned * 0.01;
  double get totalValueRedeemed => totalPointsRedeemed * 0.01;
  
  bool get canRedeem => currentPoints >= 100; // Minimum 100 points to redeem
  int get maxRedemptionAmount => (currentPoints / 100).floor() * 100; // Redeem in 100 point increments
}

class LoyaltyTransaction {
  final String id;
  final String customerId;
  final LoyaltyTransactionType type;
  final int points;
  final String? description;
  final String? invoiceId;
  final double? purchaseAmount;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  const LoyaltyTransaction({
    required this.id,
    required this.customerId,
    required this.type,
    required this.points,
    this.description,
    this.invoiceId,
    this.purchaseAmount,
    this.metadata,
    required this.createdAt,
  });

  factory LoyaltyTransaction.fromJson(Map<String, dynamic> json) {
    return LoyaltyTransaction(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      type: LoyaltyTransactionType.values.firstWhere((e) => e.name == json['type']),
      points: json['points'] as int,
      description: json['description'] as String?,
      invoiceId: json['invoiceId'] as String?,
      purchaseAmount: json['purchaseAmount'] as double?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'type': type.name,
      'points': points,
      'description': description,
      'invoiceId': invoiceId,
      'purchaseAmount': purchaseAmount,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class LoyaltyRule {
  final String id;
  final String name;
  final String description;
  final double pointsPerRupee;
  final double minimumPurchase;
  final double maximumPoints;
  final bool isActive;
  final DateTime? validFrom;
  final DateTime? validUntil;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LoyaltyRule({
    required this.id,
    required this.name,
    required this.description,
    required this.pointsPerRupee,
    required this.minimumPurchase,
    required this.maximumPoints,
    required this.isActive,
    this.validFrom,
    this.validUntil,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LoyaltyRule.fromJson(Map<String, dynamic> json) {
    return LoyaltyRule(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      pointsPerRupee: (json['pointsPerRupee'] as num).toDouble(),
      minimumPurchase: (json['minimumPurchase'] as num).toDouble(),
      maximumPoints: (json['maximumPoints'] as num).toDouble(),
      isActive: json['isActive'] as bool,
      validFrom: json['validFrom'] != null 
          ? DateTime.parse(json['validFrom'] as String)
          : null,
      validUntil: json['validUntil'] != null 
          ? DateTime.parse(json['validUntil'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'pointsPerRupee': pointsPerRupee,
      'minimumPurchase': minimumPurchase,
      'maximumPoints': maximumPoints,
      'isActive': isActive,
      'validFrom': validFrom?.toIso8601String(),
      'validUntil': validUntil?.toIso8601String(),
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isValid {
    final now = DateTime.now();
    if (!isActive) return false;
    if (validFrom != null && now.isBefore(validFrom!)) return false;
    if (validUntil != null && now.isAfter(validUntil!)) return false;
    return true;
  }

  int calculatePoints(double purchaseAmount) {
    if (purchaseAmount < minimumPurchase) return 0;
    final calculatedPoints = (purchaseAmount * pointsPerRupee).round();
    return calculatedPoints > maximumPoints ? maximumPoints.round() : calculatedPoints;
  }
}

class LoyaltyReward {
  final String id;
  final String name;
  final String description;
  final int pointsRequired;
  final double discountAmount;
  final double discountPercentage;
  final bool isPercentage;
  final double minimumPurchase;
  final bool isActive;
  final DateTime? validFrom;
  final DateTime? validUntil;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LoyaltyReward({
    required this.id,
    required this.name,
    required this.description,
    required this.pointsRequired,
    required this.discountAmount,
    required this.discountPercentage,
    required this.isPercentage,
    required this.minimumPurchase,
    required this.isActive,
    this.validFrom,
    this.validUntil,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LoyaltyReward.fromJson(Map<String, dynamic> json) {
    return LoyaltyReward(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      pointsRequired: json['pointsRequired'] as int,
      discountAmount: (json['discountAmount'] as num).toDouble(),
      discountPercentage: (json['discountPercentage'] as num).toDouble(),
      isPercentage: json['isPercentage'] as bool,
      minimumPurchase: (json['minimumPurchase'] as num).toDouble(),
      isActive: json['isActive'] as bool,
      validFrom: json['validFrom'] != null 
          ? DateTime.parse(json['validFrom'] as String)
          : null,
      validUntil: json['validUntil'] != null 
          ? DateTime.parse(json['validUntil'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'pointsRequired': pointsRequired,
      'discountAmount': discountAmount,
      'discountPercentage': discountPercentage,
      'isPercentage': isPercentage,
      'minimumPurchase': minimumPurchase,
      'isActive': isActive,
      'validFrom': validFrom?.toIso8601String(),
      'validUntil': validUntil?.toIso8601String(),
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isValid {
    final now = DateTime.now();
    if (!isActive) return false;
    if (validFrom != null && now.isBefore(validFrom!)) return false;
    if (validUntil != null && now.isAfter(validUntil!)) return false;
    return true;
  }

  double calculateDiscount(double purchaseAmount) {
    if (purchaseAmount < minimumPurchase) return 0;
    if (isPercentage) {
      return (purchaseAmount * discountPercentage / 100);
    } else {
      return discountAmount;
    }
  }
}

extension LoyaltyTierExtension on LoyaltyTier {
  String get displayName {
    switch (this) {
      case LoyaltyTier.bronze:
        return 'Bronze';
      case LoyaltyTier.silver:
        return 'Silver';
      case LoyaltyTier.gold:
        return 'Gold';
      case LoyaltyTier.platinum:
        return 'Platinum';
      case LoyaltyTier.diamond:
        return 'Diamond';
    }
  }

  String get description {
    switch (this) {
      case LoyaltyTier.bronze:
        return 'New customer tier';
      case LoyaltyTier.silver:
        return 'Regular customer tier';
      case LoyaltyTier.gold:
        return 'Frequent customer tier';
      case LoyaltyTier.platinum:
        return 'Premium customer tier';
      case LoyaltyTier.diamond:
        return 'VIP customer tier';
    }
  }

  Color get color {
    switch (this) {
      case LoyaltyTier.bronze:
        return Colors.brown;
      case LoyaltyTier.silver:
        return Colors.grey;
      case LoyaltyTier.gold:
        return Colors.amber;
      case LoyaltyTier.platinum:
        return Colors.blueGrey;
      case LoyaltyTier.diamond:
        return Colors.cyan;
    }
  }

  IconData get icon {
    switch (this) {
      case LoyaltyTier.bronze:
        return Icons.star_border;
      case LoyaltyTier.silver:
        return Icons.star_half;
      case LoyaltyTier.gold:
        return Icons.star;
      case LoyaltyTier.platinum:
        return Icons.star_rate;
      case LoyaltyTier.diamond:
        return Icons.diamond;
    }
  }

  double get pointsMultiplier {
    switch (this) {
      case LoyaltyTier.bronze:
        return 1.0;
      case LoyaltyTier.silver:
        return 1.2;
      case LoyaltyTier.gold:
        return 1.5;
      case LoyaltyTier.platinum:
        return 2.0;
      case LoyaltyTier.diamond:
        return 3.0;
    }
  }

  int get tierUpgradeThreshold {
    switch (this) {
      case LoyaltyTier.bronze:
        return 0;
      case LoyaltyTier.silver:
        return 1000;
      case LoyaltyTier.gold:
        return 5000;
      case LoyaltyTier.platinum:
        return 15000;
      case LoyaltyTier.diamond:
        return 50000;
    }
  }

  List<String> get benefits {
    switch (this) {
      case LoyaltyTier.bronze:
        return [
          'Basic points earning',
          'Standard customer service',
        ];
      case LoyaltyTier.silver:
        return [
          '20% bonus points',
          'Priority customer service',
          'Birthday rewards',
        ];
      case LoyaltyTier.gold:
        return [
          '50% bonus points',
          'VIP customer service',
          'Birthday rewards',
          'Exclusive offers',
        ];
      case LoyaltyTier.platinum:
        return [
          '100% bonus points',
          'Premium customer service',
          'Birthday rewards',
          'Exclusive offers',
          'Free delivery',
        ];
      case LoyaltyTier.diamond:
        return [
          '200% bonus points',
          'Concierge service',
          'Birthday rewards',
          'Exclusive offers',
          'Free delivery',
          'Priority access to new products',
        ];
    }
  }
}

extension LoyaltyTransactionTypeExtension on LoyaltyTransactionType {
  String get displayName {
    switch (this) {
      case LoyaltyTransactionType.earn:
        return 'Points Earned';
      case LoyaltyTransactionType.redeem:
        return 'Points Redeemed';
      case LoyaltyTransactionType.expire:
        return 'Points Expired';
      case LoyaltyTransactionType.bonus:
        return 'Bonus Points';
      case LoyaltyTransactionType.adjustment:
        return 'Points Adjustment';
    }
  }

  Color get color {
    switch (this) {
      case LoyaltyTransactionType.earn:
        return Colors.green;
      case LoyaltyTransactionType.redeem:
        return Colors.orange;
      case LoyaltyTransactionType.expire:
        return Colors.red;
      case LoyaltyTransactionType.bonus:
        return Colors.blue;
      case LoyaltyTransactionType.adjustment:
        return Colors.purple;
    }
  }

  IconData get icon {
    switch (this) {
      case LoyaltyTransactionType.earn:
        return Icons.add_circle;
      case LoyaltyTransactionType.redeem:
        return Icons.remove_circle;
      case LoyaltyTransactionType.expire:
        return Icons.schedule;
      case LoyaltyTransactionType.bonus:
        return Icons.card_giftcard;
      case LoyaltyTransactionType.adjustment:
        return Icons.edit;
    }
  }
}

// Loyalty calculation utilities
class LoyaltyCalculator {
  static int calculatePointsEarned(double purchaseAmount, LoyaltyTier tier, LoyaltyRule rule) {
    if (!rule.isValid) return 0;
    final basePoints = rule.calculatePoints(purchaseAmount);
    return (basePoints * tier.pointsMultiplier).round();
  }

  static LoyaltyTier calculateTier(int totalPointsEarned) {
    if (totalPointsEarned >= LoyaltyTier.diamond.tierUpgradeThreshold) {
      return LoyaltyTier.diamond;
    } else if (totalPointsEarned >= LoyaltyTier.platinum.tierUpgradeThreshold) {
      return LoyaltyTier.platinum;
    } else if (totalPointsEarned >= LoyaltyTier.gold.tierUpgradeThreshold) {
      return LoyaltyTier.gold;
    } else if (totalPointsEarned >= LoyaltyTier.silver.tierUpgradeThreshold) {
      return LoyaltyTier.silver;
    } else {
      return LoyaltyTier.bronze;
    }
  }

  static double calculateDiscount(double purchaseAmount, int pointsToRedeem, LoyaltyReward reward) {
    if (!reward.isValid) return 0;
    if (pointsToRedeem < reward.pointsRequired) return 0;
    return reward.calculateDiscount(purchaseAmount);
  }

  static int calculateMaxRedemptionPoints(int currentPoints, double purchaseAmount, List<LoyaltyReward> availableRewards) {
    if (currentPoints < 100) return 0;
    
    int maxPoints = 0;
    for (final reward in availableRewards) {
      if (reward.isValid && purchaseAmount >= reward.minimumPurchase) {
        final maxRedemption = (currentPoints / reward.pointsRequired).floor() * reward.pointsRequired;
        if (maxRedemption > maxPoints) {
          maxPoints = maxRedemption;
        }
      }
    }
    
    return maxPoints;
  }
}