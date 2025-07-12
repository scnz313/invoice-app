import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'client.g.dart';

@JsonSerializable()
class Client {
  final String id;
  final String name;
  final String email;
  final String address;
  final String phone;
  
  // Jewelry shop specific fields
  final String? gstNumber;
  final String? panNumber;
  final String? alternatePhone;
  final String? city;
  final String? state;
  final String? pincode;
  final String? customerType; // Regular, VIP, Wholesale, etc.
  final DateTime? dateOfBirth;
  final String? anniversaryDate;
  final String? preferences; // Jewelry preferences, size preferences, etc.

  Client({
    required this.id,
    required this.name,
    required this.email,
    required this.address,
    required this.phone,
    this.gstNumber,
    this.panNumber,
    this.alternatePhone,
    this.city,
    this.state,
    this.pincode,
    this.customerType,
    this.dateOfBirth,
    this.anniversaryDate,
    this.preferences,
  });

  // Factory constructor for creating a new client with auto-generated ID
  factory Client.create({
    required String name,
    required String email,
    required String address,
    required String phone,
    String? gstNumber,
    String? panNumber,
    String? alternatePhone,
    String? city,
    String? state,
    String? pincode,
    String? customerType,
    DateTime? dateOfBirth,
    String? anniversaryDate,
    String? preferences,
  }) {
    return Client(
      id: const Uuid().v4(),
      name: name,
      email: email,
      address: address,
      phone: phone,
      gstNumber: gstNumber,
      panNumber: panNumber,
      alternatePhone: alternatePhone,
      city: city,
      state: state,
      pincode: pincode,
      customerType: customerType,
      dateOfBirth: dateOfBirth,
      anniversaryDate: anniversaryDate,
      preferences: preferences,
    );
  }

  // Factory constructor for creating an empty client
  factory Client.empty() {
    return Client(
      id: '',
      name: '',
      email: '',
      address: '',
      phone: '',
    );
  }

  // Get full address
  String get fullAddress {
    List<String> parts = [address];
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (pincode != null && pincode!.isNotEmpty) parts.add(pincode!);
    return parts.join(', ');
  }

  // Check if client has business details
  bool get hasBusinessDetails => 
    gstNumber != null && gstNumber!.isNotEmpty || 
    panNumber != null && panNumber!.isNotEmpty;

  // Check if client has complete address
  bool get hasCompleteAddress => 
    city != null && city!.isNotEmpty && 
    state != null && state!.isNotEmpty && 
    pincode != null && pincode!.isNotEmpty;

  // JSON serialization
  factory Client.fromJson(Map<String, dynamic> json) => _$ClientFromJson(json);
  Map<String, dynamic> toJson() => _$ClientToJson(this);

  // CopyWith method for updating client data
  Client copyWith({
    String? name,
    String? email,
    String? address,
    String? phone,
    String? gstNumber,
    String? panNumber,
    String? alternatePhone,
    String? city,
    String? state,
    String? pincode,
    String? customerType,
    DateTime? dateOfBirth,
    String? anniversaryDate,
    String? preferences,
  }) {
    return Client(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      gstNumber: gstNumber ?? this.gstNumber,
      panNumber: panNumber ?? this.panNumber,
      alternatePhone: alternatePhone ?? this.alternatePhone,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      customerType: customerType ?? this.customerType,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      anniversaryDate: anniversaryDate ?? this.anniversaryDate,
      preferences: preferences ?? this.preferences,
    );
  }

  @override
  String toString() {
    return 'Client(id: $id, name: $name, email: $email, phone: $phone)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Client && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 