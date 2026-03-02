import 'package:json_annotation/json_annotation.dart';

part 'deactivate_token_response.g.dart';

@JsonSerializable(includeIfNull: false)
class DeactivateTokenResponse {
  final String message;
  final bool success;

  DeactivateTokenResponse({required this.success, required this.message});

  factory DeactivateTokenResponse.fromJson(Map<String, dynamic> json) =>
      _$DeactivateTokenResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DeactivateTokenResponseToJson(this);
}
