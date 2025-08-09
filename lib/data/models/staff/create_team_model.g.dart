// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_team_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateTeamModel _$CreateTeamModelFromJson(Map<String, dynamic> json) =>
    CreateTeamModel(
      json['name'] as String,
      json['business'] as String,
      (json['users'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$CreateTeamModelToJson(CreateTeamModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'business': instance.business,
      'users': instance.users,
    };
