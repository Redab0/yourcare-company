import 'package:json_annotation/json_annotation.dart';

part 'register_token.g.dart';

@JsonSerializable(includeIfNull: false)
class RegisterToken {
  final String fcmToken;
  final String platform;
  final String deviceId;

  RegisterToken(
      {required this.fcmToken, required this.deviceId, required this.platform});

  factory RegisterToken.fromJson(Map<String, dynamic> json) =>
      _$RegisterTokenFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterTokenToJson(this);
}
