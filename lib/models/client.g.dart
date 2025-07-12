// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Client _$ClientFromJson(Map<String, dynamic> json) => Client(
  id: json['id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  address: json['address'] as String,
  phone: json['phone'] as String,
  gstNumber: json['gstNumber'] as String?,
  panNumber: json['panNumber'] as String?,
  alternatePhone: json['alternatePhone'] as String?,
  city: json['city'] as String?,
  state: json['state'] as String?,
  pincode: json['pincode'] as String?,
  customerType: json['customerType'] as String?,
  dateOfBirth: json['dateOfBirth'] == null
      ? null
      : DateTime.parse(json['dateOfBirth'] as String),
  anniversaryDate: json['anniversaryDate'] as String?,
  preferences: json['preferences'] as String?,
);

Map<String, dynamic> _$ClientToJson(Client instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'address': instance.address,
  'phone': instance.phone,
  'gstNumber': instance.gstNumber,
  'panNumber': instance.panNumber,
  'alternatePhone': instance.alternatePhone,
  'city': instance.city,
  'state': instance.state,
  'pincode': instance.pincode,
  'customerType': instance.customerType,
  'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
  'anniversaryDate': instance.anniversaryDate,
  'preferences': instance.preferences,
};
