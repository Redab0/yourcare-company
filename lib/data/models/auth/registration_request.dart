import 'package:json_annotation/json_annotation.dart';

part 'registration_request.g.dart';

@JsonSerializable(createFactory: false)
class RegistrationRequest {
  final String name;
  final String email;
  final String password;
  final String phone;
  @JsonKey(name: 'device_id')
  final String deviceId;

  RegistrationRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.deviceId,
  });

  Map<String, dynamic> toJson() => _$RegistrationRequestToJson(this);
}
