// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'covered_service_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoveredServiceGroup _$CoveredServiceGroupFromJson(Map<String, dynamic> json) =>
    CoveredServiceGroup(
      serviceType: json['serviceType'] as String,
      services: (json['services'] as List<dynamic>)
          .map((e) => CoveredServiceItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CoveredServiceGroupToJson(
        CoveredServiceGroup instance) =>
    <String, dynamic>{
      'serviceType': instance.serviceType,
      'services': instance.services,
    };

CoveredServiceItem _$CoveredServiceItemFromJson(Map<String, dynamic> json) =>
    CoveredServiceItem(
      id: json['id'] as String,
      titleEn: json['titleEn'] as String?,
      titleAr: json['titleAr'] as String?,
      selected: json['selected'] as bool? ?? false,
      canManage: json['canManage'] as bool? ?? false,
    );

Map<String, dynamic> _$CoveredServiceItemToJson(CoveredServiceItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'titleEn': instance.titleEn,
      'titleAr': instance.titleAr,
      'selected': instance.selected,
      'canManage': instance.canManage,
    };
