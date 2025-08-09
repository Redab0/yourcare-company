import 'package:json_annotation/json_annotation.dart';

part 'create_user_model.g.dart';

@JsonSerializable()
class CreateUserModel {
  final String role;
  final String username;
  final String password;
  final String email;
  final String phone;
  final String image;

  CreateUserModel(
      {required this.username,
      required this.role,
      required this.image,
      required this.email,
      required this.password,
      required this.phone});

  factory CreateUserModel.fromJson(Map<String, dynamic> json) =>
      _$CreateUserModelFromJson(json);

  Map<String, dynamic> toJson() => _$CreateUserModelToJson(this);
}
