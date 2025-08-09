// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company_information.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompanyInformation _$CompanyInformationFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'CompanyInformation',
      json,
      ($checkedConvert) {
        final val = CompanyInformation(
          $checkedConvert('id', (v) => v as String?),
          $checkedConvert('name', (v) => v as String?),
          $checkedConvert('images',
              (v) => (v as List<dynamic>?)?.map((e) => e as String).toList()),
          $checkedConvert('logo', (v) => v as String?),
        );
        return val;
      },
    );

Map<String, dynamic> _$CompanyInformationToJson(CompanyInformation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'logo': instance.logo,
      'images': instance.images,
    };
