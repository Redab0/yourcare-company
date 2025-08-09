// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assign_permission_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssignPermissionModel _$AssignPermissionModelFromJson(
        Map<String, dynamic> json) =>
    AssignPermissionModel(
      json['userId'] as String?,
      (json['permissionIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$AssignPermissionModelToJson(
        AssignPermissionModel instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'permissionIds': instance.permissionIds,
    };
