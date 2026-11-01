/// Nonfinancial own-company metadata. Never represents a private profile.
class CompanyServices {
  const CompanyServices({required this.businessId, required this.services});
  final String businessId;
  final List<String> services;

  factory CompanyServices.fromJson(Map<String, dynamic> json) {
    final id = json['businessId'];
    final values = json['services'];
    if (id is! String ||
        id.isEmpty ||
        values is! List ||
        values.any((value) => value is! String)) {
      throw const FormatException('Invalid company service context.');
    }
    return CompanyServices(
        businessId: id, services: List<String>.unmodifiable(values));
  }
}
