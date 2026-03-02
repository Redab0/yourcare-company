import 'package:json_annotation/json_annotation.dart';

part 'register_token_response.g.dart';

@JsonSerializable(includeIfNull: false)
class RegisterTokenResponse {
  final String message;
  final bool success;
  final String platform;
  final int tokensCount;

  RegisterTokenResponse(
      {required this.tokensCount,
      required this.platform,
      required this.success,
      required this.message});

  factory RegisterTokenResponse.fromJson(Map<String, dynamic> json) =>
      _$RegisterTokenResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterTokenResponseToJson(this);
}
