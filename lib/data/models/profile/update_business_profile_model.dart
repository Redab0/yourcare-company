import 'package:json_annotation/json_annotation.dart';

part 'update_business_profile_model.g.dart';

@JsonSerializable()
class UpdateBusinessProfileModel {
  final String? name;
  final String? description;
  final String? address;
  final String? logo;
  final List<String>? images;
  final String? phone;
  final String? email;
  final String? website;
  final List<String>? areas;

  UpdateBusinessProfileModel(
    this.name,
    this.description,
    this.address,
    this.logo,
    this.images,
    this.phone,
    this.email,
    this.website,
    this.areas,
  );

  factory UpdateBusinessProfileModel.fromJson(Map<String, dynamic> json) =>
      _$UpdateBusinessProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateBusinessProfileModelToJson(this);
}
