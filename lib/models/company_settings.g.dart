// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompanySettings _$CompanySettingsFromJson(Map<String, dynamic> json) =>
    CompanySettings(
      name: json['name'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      bankName: json['bankName'] as String,
      bankAccount: json['bankAccount'] as String,
      bankIFSC: json['bankIFSC'] as String,
      logoPath: json['logoPath'] as String?,
    );

Map<String, dynamic> _$CompanySettingsToJson(CompanySettings instance) =>
    <String, dynamic>{
      'name': instance.name,
      'address': instance.address,
      'phone': instance.phone,
      'email': instance.email,
      'bankName': instance.bankName,
      'bankAccount': instance.bankAccount,
      'bankIFSC': instance.bankIFSC,
      'logoPath': instance.logoPath,
    };
