// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TeamModel _$TeamModelFromJson(Map<String, dynamic> json) => $checkedCreate(
      'TeamModel',
      json,
      ($checkedConvert) {
        final val = TeamModel(
          $checkedConvert('name', (v) => v as String?),
          $checkedConvert(
              'business',
              (v) => v == null
                  ? null
                  : Business.fromJson(v as Map<String, dynamic>)),
          $checkedConvert(
              'users',
              (v) => (v as List<dynamic>)
                  .map((e) => TeamMember.fromJson(e as Map<String, dynamic>))
                  .toList()),
          $checkedConvert('id', (v) => v as String?),
          $checkedConvert('createdAt',
              (v) => v == null ? null : DateTime.parse(v as String)),
          $checkedConvert('updatedAt',
              (v) => v == null ? null : DateTime.parse(v as String)),
        );
        return val;
      },
    );

Map<String, dynamic> _$TeamModelToJson(TeamModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'business': instance.business,
      'users': instance.users,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

Business _$BusinessFromJson(Map<String, dynamic> json) => $checkedCreate(
      'Business',
      json,
      ($checkedConvert) {
        final val = Business(
          $checkedConvert('_id', (v) => v as String),
          $checkedConvert('name', (v) => v as String),
        );
        return val;
      },
      fieldKeyMap: const {'id': '_id'},
    );

Map<String, dynamic> _$BusinessToJson(Business instance) => <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
    };

TeamMember _$TeamMemberFromJson(Map<String, dynamic> json) => $checkedCreate(
      'TeamMember',
      json,
      ($checkedConvert) {
        final val = TeamMember(
          $checkedConvert('_id', (v) => v as String?),
          $checkedConvert('role', (v) => v as String?),
          $checkedConvert('email', (v) => v as String?),
          $checkedConvert('image', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {'id': '_id'},
    );

Map<String, dynamic> _$TeamMemberToJson(TeamMember instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'role': instance.role,
      'email': instance.email,
      'image': instance.image,
    };
