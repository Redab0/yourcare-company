// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auto_bid_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$AutoBidOptionToJson(AutoBidOption instance) =>
    <String, dynamic>{
      if (instance.categoryOptionId case final value?)
        'categoryOptionId': value,
      if (instance.price case final value?) 'price': value,
      if (instance.expectedTimeInDays case final value?)
        'expectedTimeInDays': value,
    };

Map<String, dynamic> _$AutoBidDeepCleaningPricingToJson(
        AutoBidDeepCleaningPricing instance) =>
    <String, dynamic>{
      'departmentTypes':
          instance.departmentTypes.map((e) => e.toJson()).toList(),
      'bedrooms': instance.bedrooms.map((e) => e.toJson()).toList(),
      'bathrooms': instance.bathrooms.map((e) => e.toJson()).toList(),
      'kitchens': instance.kitchens.map((e) => e.toJson()).toList(),
      'livingRooms': instance.livingRooms.map((e) => e.toJson()).toList(),
      'numberOfFloors': instance.numberOfFloors.map((e) => e.toJson()).toList(),
      'sizeOptions': instance.sizeOptions.map((e) => e.toJson()).toList(),
    };

Map<String, dynamic> _$AutoBidTypeOverrideToJson(
        AutoBidTypeOverride instance) =>
    <String, dynamic>{
      if (instance.categoryTypeId case final value?) 'categoryTypeId': value,
      'sizes': instance.sizes.map((e) => e.toJson()).toList(),
      'materials': instance.materials.map((e) => e.toJson()).toList(),
      'conditions': instance.conditions.map((e) => e.toJson()).toList(),
    };

Map<String, dynamic> _$AutoBidUpholsteryPricingToJson(
        AutoBidUpholsteryPricing instance) =>
    <String, dynamic>{
      'typeOverrides': instance.typeOverrides.map((e) => e.toJson()).toList(),
    };

Map<String, dynamic> _$AutoBidConfigRequestToJson(
        AutoBidConfigRequest instance) =>
    <String, dynamic>{
      'serviceType': instance.serviceType,
      'isEnabled': instance.isEnabled,
      if (instance.deepCleaningPricing?.toJson() case final value?)
        'deepCleaningPricing': value,
      if (instance.upholsteryPricing?.toJson() case final value?)
        'upholsteryPricing': value,
    };
