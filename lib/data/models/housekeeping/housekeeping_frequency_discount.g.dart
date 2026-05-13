// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'housekeeping_frequency_discount.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HousekeepingFrequencyDiscount _$HousekeepingFrequencyDiscountFromJson(
        Map<String, dynamic> json) =>
    HousekeepingFrequencyDiscount(
      frequencyOptionId: json['frequencyOptionId'] as String,
      discountPercentage: (json['discountPercentage'] as num).toDouble(),
    );

Map<String, dynamic> _$HousekeepingFrequencyDiscountToJson(
        HousekeepingFrequencyDiscount instance) =>
    <String, dynamic>{
      'frequencyOptionId': instance.frequencyOptionId,
      'discountPercentage': instance.discountPercentage,
    };
