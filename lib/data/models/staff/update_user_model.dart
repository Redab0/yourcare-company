import 'package:json_annotation/json_annotation.dart';

part 'update_user_model.g.dart';

@JsonSerializable(includeIfNull: false)
class UpdateUserModel {
  final String? username;
  final String? password;
  final String? email;
  final String? phone;
  final String? image;
  final bool? enabled;

  UpdateUserModel({
    this.username,
    this.image,
    this.email,
    this.password,
    this.phone,
    this.enabled,
  });

  factory UpdateUserModel.fromJson(Map<String, dynamic> json) =>
      _$UpdateUserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateUserModelToJson(this);
}
