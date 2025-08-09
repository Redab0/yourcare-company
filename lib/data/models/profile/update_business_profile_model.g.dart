// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_business_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateBusinessProfileModel _$UpdateBusinessProfileModelFromJson(
        Map<String, dynamic> json) =>
    UpdateBusinessProfileModel(
      json['name'] as String?,
      json['description'] as String?,
      json['address'] as String?,
      json['logo'] as String?,
      (json['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
      json['phone'] as String?,
      json['email'] as String?,
      json['website'] as String?,
      (json['areas'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$UpdateBusinessProfileModelToJson(
        UpdateBusinessProfileModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'address': instance.address,
      'logo': instance.logo,
      'images': instance.images,
      'phone': instance.phone,
      'email': instance.email,
      'website': instance.website,
      'areas': instance.areas,
    };
