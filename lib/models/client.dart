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

  Client({
    required this.id,
    required this.name,
    required this.email,
    required this.address,
    required this.phone,
  });

  // Factory constructor for creating a new client with auto-generated ID
  factory Client.create({
    required String name,
    required String email,
    required String address,
    required String phone,
  }) {
    return Client(
      id: const Uuid().v4(),
      name: name,
      email: email,
      address: address,
      phone: phone,
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

  // JSON serialization
  factory Client.fromJson(Map<String, dynamic> json) => _$ClientFromJson(json);
  Map<String, dynamic> toJson() => _$ClientToJson(this);

  // CopyWith method for updating client data
  Client copyWith({
    String? name,
    String? email,
    String? address,
    String? phone,
  }) {
    return Client(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      address: address ?? this.address,
      phone: phone ?? this.phone,
    );
  }

  @override
  String toString() {
    return 'Client(id: $id, name: $name, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Client && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 