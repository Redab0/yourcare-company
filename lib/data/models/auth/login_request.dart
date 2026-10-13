import 'package:json_annotation/json_annotation.dart';

part 'login_request.g.dart';

@JsonSerializable(createFactory: false)
class LoginRequest {
  final String email;
  final String password;
  @JsonKey(name: 'device_id')
  final String deviceId;

  LoginRequest({
    required this.email,
    required this.password,
    required this.deviceId,
  });

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}
