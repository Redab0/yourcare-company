// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_team_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateTeamResponse _$CreateTeamResponseFromJson(Map<String, dynamic> json) =>
    CreateTeamResponse(
      json['name'] as String,
      json['business'] as String,
      (json['users'] as List<dynamic>).map((e) => e as String).toList(),
      json['id'] as String,
      DateTime.parse(json['createdAt'] as String),
      DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$CreateTeamResponseToJson(CreateTeamResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'business': instance.business,
      'users': instance.users,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
