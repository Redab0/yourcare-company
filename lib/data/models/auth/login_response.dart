import 'package:cleaning_service_driver/data/models/auth/address.dart';
import 'package:cleaning_service_driver/data/models/staff/permission_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'login_response.g.dart';

@JsonSerializable()
class LoginResponse {
  final bool success;
  final String message;
  final LoginData data;

  LoginResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}

@JsonSerializable()
class LoginData {
  final User user;
  final String token;
  final String message;
  final String locale;

  LoginData({
    required this.user,
    required this.token,
    required this.message,
    required this.locale,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) =>
      _$LoginDataFromJson(json);

  Map<String, dynamic> toJson() => _$LoginDataToJson(this);
}

@JsonSerializable()
class User {
  final String? id;
  final String? username;
  final String? email;
  final String? phone;
  final String? role;
  final String? image;
  final bool? enabled;
  final String? businessId;
  final List<String>? services;
  final List<Address>? addresses;
  final List<PermissionModel>? permissions;
  final String? createdAt;
  final String? updatedAt;

  User({
    this.id,
    this.username,
    this.email,
    this.phone,
    this.role,
    this.enabled,
    this.createdAt,
    this.updatedAt,
    this.businessId,
    this.services,
    this.image,
    this.permissions = const [],
    this.addresses = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? phone,
    String? role,
    bool? enabled,
    String? createdAt,
    String? updatedAt,
    String? businessId,
    List<String>? services,
    List<Address>? addresses,
    List<PermissionModel>? permissions,
    String? image,
  }) {
    return User(
        id: id ?? this.id,
        username: username ?? this.username,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        role: role ?? this.role,
        enabled: enabled ?? this.enabled,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        businessId: businessId ?? this.businessId,
        services: services ?? this.services,
        addresses: addresses ?? this.addresses,
        permissions: permissions ?? this.permissions,
        image: image ?? this.image);
  }
}
