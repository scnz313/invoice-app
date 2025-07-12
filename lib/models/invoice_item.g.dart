// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StoneDetails _$StoneDetailsFromJson(Map<String, dynamic> json) => StoneDetails(
  type: $enumDecode(_$StoneTypeEnumMap, json['type']),
  weight: (json['weight'] as num).toDouble(),
  color: json['color'] as String,
  clarity: json['clarity'] as String,
  cut: json['cut'] as String,
  certification: json['certification'] as String,
);

Map<String, dynamic> _$StoneDetailsToJson(StoneDetails instance) =>
    <String, dynamic>{
      'type': _$StoneTypeEnumMap[instance.type]!,
      'weight': instance.weight,
      'color': instance.color,
      'clarity': instance.clarity,
      'cut': instance.cut,
      'certification': instance.certification,
    };

const _$StoneTypeEnumMap = {
  StoneType.diamond: 'diamond',
  StoneType.ruby: 'ruby',
  StoneType.emerald: 'emerald',
  StoneType.sapphire: 'sapphire',
  StoneType.pearl: 'pearl',
  StoneType.other: 'other',
  StoneType.none: 'none',
};

InvoiceItem _$InvoiceItemFromJson(Map<String, dynamic> json) => InvoiceItem(
  description: json['description'] as String,
  quantity: (json['quantity'] as num).toInt(),
  price: (json['price'] as num).toDouble(),
  jewelryType: $enumDecodeNullable(_$JewelryTypeEnumMap, json['jewelryType']),
  metalType: $enumDecodeNullable(_$MetalTypeEnumMap, json['metalType']),
  weight: (json['weight'] as num?)?.toDouble(),
  purity: (json['purity'] as num?)?.toDouble(),
  stoneDetails: json['stoneDetails'] == null
      ? null
      : StoneDetails.fromJson(json['stoneDetails'] as Map<String, dynamic>),
  hallmarks: json['hallmarks'] as String?,
  certification: json['certification'] as String?,
  size: json['size'] as String?,
  designCode: json['designCode'] as String?,
  brand: json['brand'] as String?,
);

Map<String, dynamic> _$InvoiceItemToJson(InvoiceItem instance) =>
    <String, dynamic>{
      'description': instance.description,
      'quantity': instance.quantity,
      'price': instance.price,
      'jewelryType': _$JewelryTypeEnumMap[instance.jewelryType],
      'metalType': _$MetalTypeEnumMap[instance.metalType],
      'weight': instance.weight,
      'purity': instance.purity,
      'stoneDetails': instance.stoneDetails?.toJson(),
      'hallmarks': instance.hallmarks,
      'certification': instance.certification,
      'size': instance.size,
      'designCode': instance.designCode,
      'brand': instance.brand,
    };

const _$JewelryTypeEnumMap = {
  JewelryType.ring: 'ring',
  JewelryType.necklace: 'necklace',
  JewelryType.bracelet: 'bracelet',
  JewelryType.earrings: 'earrings',
  JewelryType.pendant: 'pendant',
  JewelryType.chain: 'chain',
  JewelryType.bangles: 'bangles',
  JewelryType.anklet: 'anklet',
  JewelryType.other: 'other',
};

const _$MetalTypeEnumMap = {
  MetalType.gold: 'gold',
  MetalType.silver: 'silver',
  MetalType.platinum: 'platinum',
  MetalType.whiteGold: 'whiteGold',
  MetalType.roseGold: 'roseGold',
  MetalType.other: 'other',
};
