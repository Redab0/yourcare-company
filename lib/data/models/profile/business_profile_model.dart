import 'package:cleaning_service_driver/data/models/profile/area_response.dart';
import 'package:json_annotation/json_annotation.dart';

part 'business_profile_model.g.dart';

@JsonSerializable()
class BusinessProfileModel {
  final String? id;
  final String? name;
  final String? description;
  final String? address;
  final String? logo;
  final List<String>? images;
  final String? phone;
  final String? email;
  final String? website;
  final List<AreaModel>? areas;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BusinessProfileModel(
      this.id,
      this.name,
      this.description,
      this.address,
      this.logo,
      this.images,
      this.phone,
      this.email,
      this.website,
      this.areas,
      this.createdAt,
      this.updatedAt);

  factory BusinessProfileModel.fromJson(Map<String, dynamic> json) =>
      _$BusinessProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$BusinessProfileModelToJson(this);
}
