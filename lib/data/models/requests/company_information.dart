import 'package:json_annotation/json_annotation.dart';

part 'company_information.g.dart';

@JsonSerializable(checked: true)
class CompanyInformation {
  final String? id;
  final String? name;
  final String? logo;
  final List<String>? images;
  final String? phone;
  final String? email;

  CompanyInformation(
      this.id, this.name, this.images, this.logo, this.phone, this.email);

  factory CompanyInformation.fromJson(Map<String, dynamic> json) =>
      _$CompanyInformationFromJson(json);

  Map<String, dynamic> toJson() => _$CompanyInformationToJson(this);
}

/// Request projections may contain a populated company or its bare reference.
CompanyInformation? companyInformationFromJson(Object? value) {
  if (value == null) return null;
  if (value is String) {
    return CompanyInformation(value, null, null, null, null, null);
  }
  if (value is Map) {
    final json = Map<String, dynamic>.from(value);
    return CompanyInformation.fromJson(
        {...json, 'id': json['id'] ?? json['_id']});
  }
  throw const FormatException('Invalid company reference.');
}
