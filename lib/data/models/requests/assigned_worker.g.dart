// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assigned_worker.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssignedWorker _$AssignedWorkerFromJson(Map<String, dynamic> json) =>
    AssignedWorker(
      json['image'] as String?,
      json['id'] as String,
      json['username'] as String?,
      json['email'] as String?,
      json['phone'] as String?,
    );

Map<String, dynamic> _$AssignedWorkerToJson(AssignedWorker instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'image': instance.image,
      'email': instance.email,
      'phone': instance.phone,
    };
