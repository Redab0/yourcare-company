import 'package:cleaning_service_driver/data/models/auth/address.dart';
import 'package:json_annotation/json_annotation.dart';

part 'customer.g.dart';

@JsonSerializable()
class Customer {
  final String? id;
  final String? username;
  final String? email;
  final String? phone;
  final List<Address>? addresses;

  Customer({
    this.id,
    this.username,
    this.email,
    this.phone,
    this.addresses = const [],
  });

  factory Customer.fromJson(Map<String, dynamic> json) =>
      _$CustomerFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerToJson(this);
}
