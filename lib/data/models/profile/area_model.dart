import 'package:json_annotation/json_annotation.dart';

part 'area_model.g.dart';

@JsonSerializable(includeIfNull: false)
class AreaModel {
  final String? id;
  final String? areaEn;
  final String? areaAr;
  final int? sortOrder;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AreaModel({
    this.id,
    this.areaEn,
    this.areaAr,
    this.isActive,
    this.sortOrder,
    this.createdAt,
    this.updatedAt,
  });

  factory AreaModel.fromJson(Map<String, dynamic> json) =>
      _$AreaModelFromJson(json);

  Map<String, dynamic> toJson() => _$AreaModelToJson(this);
}
