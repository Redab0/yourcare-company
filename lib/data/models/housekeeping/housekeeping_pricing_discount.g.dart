// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'housekeeping_pricing_discount.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HousekeepingPricingDiscount _$HousekeepingPricingDiscountFromJson(
        Map<String, dynamic> json) =>
    HousekeepingPricingDiscount(
      optionId: json['optionId'] as String,
      discountPercentage: (json['discountPercentage'] as num).toDouble(),
    );

Map<String, dynamic> _$HousekeepingPricingDiscountToJson(
        HousekeepingPricingDiscount instance) =>
    <String, dynamic>{
      'optionId': instance.optionId,
      'discountPercentage': instance.discountPercentage,
    };
