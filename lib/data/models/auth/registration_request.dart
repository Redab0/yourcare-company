class RegistrationRequest {
  final String name;
  final String email;
  final String password;
  final String phone;
  final String deviceId;

  RegistrationRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.deviceId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'device_id': deviceId,
    };
  }
}