import 'package:json_annotation/json_annotation.dart';

part 'assign_permission_model.g.dart';

@JsonSerializable()
class AssignPermissionModel {
  final String? userId;
  final List<String>? permissionIds;

  AssignPermissionModel(this.userId, this.permissionIds);

  factory AssignPermissionModel.fromJson(Map<String, dynamic> json) =>
      _$AssignPermissionModelFromJson(json);

  Map<String, dynamic> toJson() => _$AssignPermissionModelToJson(this);
}
