// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'area_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AreaModel _$AreaModelFromJson(Map<String, dynamic> json) => AreaModel(
      id: json['id'] as String?,
      areaEn: json['areaEn'] as String?,
      areaAr: json['areaAr'] as String?,
      isActive: json['isActive'] as bool?,
      sortOrder: (json['sortOrder'] as num?)?.toInt(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$AreaModelToJson(AreaModel instance) => <String, dynamic>{
      if (instance.id case final value?) 'id': value,
      if (instance.areaEn case final value?) 'areaEn': value,
      if (instance.areaAr case final value?) 'areaAr': value,
      if (instance.sortOrder case final value?) 'sortOrder': value,
      if (instance.isActive case final value?) 'isActive': value,
      if (instance.createdAt?.toIso8601String() case final value?)
        'createdAt': value,
      if (instance.updatedAt?.toIso8601String() case final value?)
        'updatedAt': value,
    };
