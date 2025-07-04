import 'package:json_annotation/json_annotation.dart';

part 'company_settings.g.dart';

@JsonSerializable()
class CompanySettings {
  final String name;
  final String address;
  final String phone;
  final String email;
  final String bankName;
  final String bankAccount;
  final String bankIFSC;
  final String? logoPath; // Path to the company logo image

  CompanySettings({
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.bankName,
    required this.bankAccount,
    required this.bankIFSC,
    this.logoPath,
  });

  factory CompanySettings.fromJson(Map<String, dynamic> json) =>
      _$CompanySettingsFromJson(json);

  Map<String, dynamic> toJson() => _$CompanySettingsToJson(this);

  CompanySettings copyWith({
    String? name,
    String? address,
    String? phone,
    String? email,
    String? bankName,
    String? bankAccount,
    String? bankIFSC,
    String? logoPath,
  }) {
    return CompanySettings(
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      bankName: bankName ?? this.bankName,
      bankAccount: bankAccount ?? this.bankAccount,
      bankIFSC: bankIFSC ?? this.bankIFSC,
      logoPath: logoPath ?? this.logoPath,
    );
  }

  static CompanySettings get defaultSettings => CompanySettings(
    name: 'Your Company Name',
    address: 'Your Address, City, State, PIN Code',
    phone: '+1234567890',
    email: 'info@yourcompany.com',
    bankName: 'Your Bank Name',
    bankAccount: '1234567890123456',
    bankIFSC: 'YOURBANK123',
    logoPath: null,
  );
} 