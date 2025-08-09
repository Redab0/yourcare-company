import 'package:cleaning_service_driver/data/models/auth/address.dart';
import 'package:json_annotation/json_annotation.dart';

part 'auth_user.g.dart';

@JsonSerializable()
class AuthUser {
  final String email;
  final String username;
  final String? phone;
  final String? profileImage;
  final List<Address> addresses;

  AuthUser({
    required this.email,
    required this.username,
    this.phone,
    this.profileImage,
    this.addresses = const [],
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) =>
      _$AuthUserFromJson(json);

  Map<String, dynamic> toJson() => _$AuthUserToJson(this);

  bool get hasRequiredInfo {
    return (phone != null && phone!.isNotEmpty) && addresses.isNotEmpty;
  }
}
