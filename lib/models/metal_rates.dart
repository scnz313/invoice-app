import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import 'jewelry_item.dart';

part 'metal_rates.g.dart';

@JsonSerializable()
class MetalRate {
  final String id;
  final DateTime date;
  final MetalType metalType;
  final GoldPurity? goldPurity;
  final SilverPurity? silverPurity;
  final double buyingRate;
  final double sellingRate;
  final double makingChargePerGram;
  final double wastagePercentage;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  MetalRate({
    required this.id,
    required this.date,
    required this.metalType,
    this.goldPurity,
    this.silverPurity,
    required this.buyingRate,
    required this.sellingRate,
    required this.makingChargePerGram,
    this.wastagePercentage = 0.0,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MetalRate.create({
    required DateTime date,
    required MetalType metalType,
    GoldPurity? goldPurity,
    SilverPurity? silverPurity,
    required double buyingRate,
    required double sellingRate,
    required double makingChargePerGram,
    double wastagePercentage = 0.0,
    String? notes,
  }) {
    final now = DateTime.now();
    return MetalRate(
      id: const Uuid().v4(),
      date: date,
      metalType: metalType,
      goldPurity: goldPurity,
      silverPurity: silverPurity,
      buyingRate: buyingRate,
      sellingRate: sellingRate,
      makingChargePerGram: makingChargePerGram,
      wastagePercentage: wastagePercentage,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
  }

  String get metalDisplay {
    switch (metalType) {
      case MetalType.gold:
        return 'Gold ${goldPurity?.display ?? ''}';
      case MetalType.silver:
        return 'Silver ${silverPurity?.display ?? ''}';
      case MetalType.platinum:
        return 'Platinum';
      case MetalType.whitegold:
        return 'White Gold ${goldPurity?.display ?? ''}';
      case MetalType.rosegold:
        return 'Rose Gold ${goldPurity?.display ?? ''}';
      default:
        return metalType.name;
    }
  }

  double get marginAmount => sellingRate - buyingRate;
  double get marginPercentage => (marginAmount / buyingRate) * 100;

  factory MetalRate.fromJson(Map<String, dynamic> json) => _$MetalRateFromJson(json);
  Map<String, dynamic> toJson() => _$MetalRateToJson(this);

  MetalRate copyWith({
    DateTime? date,
    MetalType? metalType,
    GoldPurity? goldPurity,
    SilverPurity? silverPurity,
    double? buyingRate,
    double? sellingRate,
    double? makingChargePerGram,
    double? wastagePercentage,
    String? notes,
  }) {
    return MetalRate(
      id: id,
      date: date ?? this.date,
      metalType: metalType ?? this.metalType,
      goldPurity: goldPurity ?? this.goldPurity,
      silverPurity: silverPurity ?? this.silverPurity,
      buyingRate: buyingRate ?? this.buyingRate,
      sellingRate: sellingRate ?? this.sellingRate,
      makingChargePerGram: makingChargePerGram ?? this.makingChargePerGram,
      wastagePercentage: wastagePercentage ?? this.wastagePercentage,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

@JsonSerializable()
class DailyMetalRates {
  final String id;
  final DateTime date;
  final List<MetalRate> rates;
  final DateTime createdAt;
  final DateTime updatedAt;

  DailyMetalRates({
    required this.id,
    required this.date,
    required this.rates,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DailyMetalRates.create({
    required DateTime date,
    required List<MetalRate> rates,
  }) {
    final now = DateTime.now();
    return DailyMetalRates(
      id: const Uuid().v4(),
      date: date,
      rates: rates,
      createdAt: now,
      updatedAt: now,
    );
  }

  // Get rate by metal type and purity
  MetalRate? getRateByMetal(MetalType metalType, {GoldPurity? goldPurity, SilverPurity? silverPurity}) {
    return rates.firstWhere(
      (rate) =>
          rate.metalType == metalType &&
          rate.goldPurity == goldPurity &&
          rate.silverPurity == silverPurity,
      orElse: () => rates.firstWhere(
        (rate) => rate.metalType == metalType,
        orElse: () => throw Exception('Rate not found for $metalType'),
      ),
    );
  }

  // Get all gold rates
  List<MetalRate> get goldRates => rates.where((rate) => rate.metalType == MetalType.gold).toList();

  // Get all silver rates
  List<MetalRate> get silverRates => rates.where((rate) => rate.metalType == MetalType.silver).toList();

  // Get highest gold rate
  MetalRate? get highestGoldRate {
    final goldRatesList = goldRates;
    if (goldRatesList.isEmpty) return null;
    return goldRatesList.reduce((a, b) => a.sellingRate > b.sellingRate ? a : b);
  }

  // Get lowest gold rate
  MetalRate? get lowestGoldRate {
    final goldRatesList = goldRates;
    if (goldRatesList.isEmpty) return null;
    return goldRatesList.reduce((a, b) => a.sellingRate < b.sellingRate ? a : b);
  }

  factory DailyMetalRates.fromJson(Map<String, dynamic> json) => _$DailyMetalRatesFromJson(json);
  Map<String, dynamic> toJson() => _$DailyMetalRatesToJson(this);

  DailyMetalRates copyWith({
    DateTime? date,
    List<MetalRate>? rates,
  }) {
    return DailyMetalRates(
      id: id,
      date: date ?? this.date,
      rates: rates ?? this.rates,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}