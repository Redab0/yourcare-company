// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BusinessProfileModel _$BusinessProfileModelFromJson(
        Map<String, dynamic> json) =>
    BusinessProfileModel(
      json['id'] as String?,
      json['name'] as String?,
      json['description'] as String?,
      json['address'] as String?,
      json['logo'] as String?,
      (json['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
      json['phone'] as String?,
      json['email'] as String?,
      json['website'] as String?,
      (json['services'] as List<dynamic>?)?.map((e) => e as String).toList(),
      (json['serviceDescriptions'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      (json['coveredServices'] as List<dynamic>?)
          ?.map((e) => CoveredServiceGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['carWashPricing'] as List<dynamic>?)
          ?.map((e) => CarWashPricingGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['carWashWorkingHours'] as List<dynamic>?)
          ?.map((e) => CarWashWorkingHour.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['upholsteryPricing'] as List<dynamic>?)
          ?.map(
              (e) => UpholsteryPricingGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['areas'] as List<dynamic>?)
          ?.map((e) => AreaModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$BusinessProfileModelToJson(
        BusinessProfileModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'address': instance.address,
      'logo': instance.logo,
      'images': instance.images,
      'phone': instance.phone,
      'email': instance.email,
      'website': instance.website,
      'services': instance.services,
      'serviceDescriptions': instance.serviceDescriptions,
      'coveredServices': instance.coveredServices,
      'carWashPricing': instance.carWashPricing,
      'carWashWorkingHours': instance.carWashWorkingHours,
      'upholsteryPricing': instance.upholsteryPricing,
      'areas': instance.areas,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
