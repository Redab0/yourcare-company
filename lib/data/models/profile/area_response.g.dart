// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'area_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AreaResponse _$AreaResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'AreaResponse',
      json,
      ($checkedConvert) {
        final val = AreaResponse(
          title: $checkedConvert(
              'title',
              (v) => v == null
                  ? null
                  : Governorate.fromJson(v as Map<String, dynamic>)),
          areas: $checkedConvert(
              'areas',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => AreaModel.fromJson(e as Map<String, dynamic>))
                  .toList()),
        );
        return val;
      },
    );

Map<String, dynamic> _$AreaResponseToJson(AreaResponse instance) =>
    <String, dynamic>{
      'title': instance.title,
      'areas': instance.areas,
    };

AreaModel _$AreaModelFromJson(Map<String, dynamic> json) => $checkedCreate(
      'AreaModel',
      json,
      ($checkedConvert) {
        final val = AreaModel(
          id: $checkedConvert('id', (v) => v as String?),
          en: $checkedConvert('en', (v) => v as String?),
          ar: $checkedConvert('ar', (v) => v as String?),
          name: $checkedConvert('name', (v) => v as String?),
          areaEn: $checkedConvert('areaEn', (v) => v as String?),
          areaAr: $checkedConvert('areaAr', (v) => v as String?),
          governorateEn: $checkedConvert('governorateEn', (v) => v as String?),
          governorateAr: $checkedConvert('governorateAr', (v) => v as String?),
        );
        return val;
      },
    );

Map<String, dynamic> _$AreaModelToJson(AreaModel instance) => <String, dynamic>{
      'id': instance.id,
      'en': instance.en,
      'ar': instance.ar,
      'name': instance.name,
      'areaEn': instance.areaEn,
      'areaAr': instance.areaAr,
      'governorateEn': instance.governorateEn,
      'governorateAr': instance.governorateAr,
    };

Governorate _$GovernorateFromJson(Map<String, dynamic> json) => $checkedCreate(
      'Governorate',
      json,
      ($checkedConvert) {
        final val = Governorate(
          ar: $checkedConvert('ar', (v) => v as String?),
          en: $checkedConvert('en', (v) => v as String?),
        );
        return val;
      },
    );

Map<String, dynamic> _$GovernorateToJson(Governorate instance) =>
    <String, dynamic>{
      'en': instance.en,
      'ar': instance.ar,
    };
