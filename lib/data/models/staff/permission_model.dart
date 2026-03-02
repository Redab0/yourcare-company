import 'package:json_annotation/json_annotation.dart';

part 'permission_model.g.dart';

@JsonSerializable()
class PermissionModel {
  final String? name;
  final String? resource;
  final String? description;
  final String? action;
  final String? id;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PermissionModel(this.id, this.description, this.name, this.updatedAt,
      this.createdAt, this.resource, this.action);

  String get displayName {
    if (name == null) return '';
    final parts = name!.split(':');
    return parts.length > 1 ? parts.sublist(1).join(':') : name!;
  }

  factory PermissionModel.fromJson(Map<String, dynamic> json) =>
      _$PermissionModelFromJson(json);

  Map<String, dynamic> toJson() => _$PermissionModelToJson(this);
}
