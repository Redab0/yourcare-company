// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upholstery_pricing_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpholsteryBusinessCategory _$UpholsteryBusinessCategoryFromJson(
        Map<String, dynamic> json) =>
    UpholsteryBusinessCategory(
      type: json['type'] as String? ?? '',
      upholsteryTypes: (json['upholsteryTypes'] as List<dynamic>?)
              ?.map((e) => UpholsteryType.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$UpholsteryBusinessCategoryToJson(
        UpholsteryBusinessCategory instance) =>
    <String, dynamic>{
      'type': instance.type,
      'upholsteryTypes': instance.upholsteryTypes,
    };

UpholsteryType _$UpholsteryTypeFromJson(Map<String, dynamic> json) =>
    UpholsteryType(
      id: _readId(json, 'id') as String? ?? '',
      title: json['title'] as String?,
      titleEn: json['titleEn'] as String?,
      titleAr: json['titleAr'] as String?,
      description: json['description'] as String?,
      descriptionEn: json['descriptionEn'] as String?,
      descriptionAr: json['descriptionAr'] as String?,
      sizes: (json['sizes'] as List<dynamic>?)
              ?.map((e) => UpholsterySize.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$UpholsteryTypeToJson(UpholsteryType instance) =>
    <String, dynamic>{
      'id': instance.id,
      if (instance.title case final value?) 'title': value,
      if (instance.titleEn case final value?) 'titleEn': value,
      if (instance.titleAr case final value?) 'titleAr': value,
      if (instance.description case final value?) 'description': value,
      if (instance.descriptionEn case final value?) 'descriptionEn': value,
      if (instance.descriptionAr case final value?) 'descriptionAr': value,
      'sizes': instance.sizes,
    };

UpholsterySize _$UpholsterySizeFromJson(Map<String, dynamic> json) =>
    UpholsterySize(
      id: _readId(json, 'id') as String? ?? '',
      title: json['title'] as String?,
      titleEn: json['titleEn'] as String?,
      titleAr: json['titleAr'] as String?,
      description: json['description'] as String?,
      descriptionEn: json['descriptionEn'] as String?,
      descriptionAr: json['descriptionAr'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$UpholsterySizeToJson(UpholsterySize instance) =>
    <String, dynamic>{
      'id': instance.id,
      if (instance.title case final value?) 'title': value,
      if (instance.titleEn case final value?) 'titleEn': value,
      if (instance.titleAr case final value?) 'titleAr': value,
      if (instance.description case final value?) 'description': value,
      if (instance.descriptionEn case final value?) 'descriptionEn': value,
      if (instance.descriptionAr case final value?) 'descriptionAr': value,
      'price': instance.price,
    };

UpholsteryPricingPackage _$UpholsteryPricingPackageFromJson(
        Map<String, dynamic> json) =>
    UpholsteryPricingPackage(
      packageId: _readPackageId(json, 'packageId') as String?,
      titleEn: json['titleEn'] as String?,
      titleAr: json['titleAr'] as String?,
      descriptionEn: json['descriptionEn'] as String?,
      descriptionAr: json['descriptionAr'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$UpholsteryPricingPackageToJson(
        UpholsteryPricingPackage instance) =>
    <String, dynamic>{
      if (instance.titleEn case final value?) 'titleEn': value,
      if (instance.titleAr case final value?) 'titleAr': value,
      if (instance.descriptionEn case final value?) 'descriptionEn': value,
      if (instance.descriptionAr case final value?) 'descriptionAr': value,
      'price': instance.price,
      'discountPercentage': instance.discountPercentage,
    };

UpholsteryPricingGroup _$UpholsteryPricingGroupFromJson(
        Map<String, dynamic> json) =>
    UpholsteryPricingGroup(
      upholsteryTypeId:
          _readUpholsteryTypeId(json, 'upholsteryTypeId') as String,
      packages: (json['packages'] as List<dynamic>?)
              ?.map((e) =>
                  UpholsteryPricingPackage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$UpholsteryPricingGroupToJson(
        UpholsteryPricingGroup instance) =>
    <String, dynamic>{
      'upholsteryTypeId': instance.upholsteryTypeId,
      'packages': instance.packages,
    };

UpholsteryPricingRequest _$UpholsteryPricingRequestFromJson(
        Map<String, dynamic> json) =>
    UpholsteryPricingRequest(
      pricing: (json['pricing'] as List<dynamic>)
          .map(
              (e) => UpholsteryPricingGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
