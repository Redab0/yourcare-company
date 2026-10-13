// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'housekeeping_pricing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$HousekeepingPricingRequestToJson(
        HousekeepingPricingRequest instance) =>
    <String, dynamic>{
      'areaFees': instance.areaFees.map((e) => e.toJson()).toList(),
      'isActive': instance.isActive,
      'cleaningProductsPrice': instance.cleaningProductsPrice,
      'singlePricingModel': instance.singlePricingModel.toJson(),
      'multiplePricingModel': instance.multiplePricingModel.toJson(),
      'frequencyDiscounts':
          instance.frequencyDiscounts.map((e) => e.toJson()).toList(),
    };

Map<String, dynamic> _$HousekeepingAreaFeeRequestToJson(
        HousekeepingAreaFeeRequest instance) =>
    <String, dynamic>{
      'areaId': instance.areaId,
      'fee': instance.fee,
    };

Map<String, dynamic> _$HousekeepingPricingOptionRequestToJson(
        HousekeepingPricingOptionRequest instance) =>
    <String, dynamic>{
      'optionId': instance.optionId,
      'price': instance.price,
    };

Map<String, dynamic> _$HousekeepingSinglePricingRequestToJson(
        HousekeepingSinglePricingRequest instance) =>
    <String, dynamic>{
      'isActive': instance.isActive,
      'basePricePerCleanerPerHour': instance.basePricePerCleanerPerHour,
    };

Map<String, dynamic> _$HousekeepingMultiplePricingRequestToJson(
        HousekeepingMultiplePricingRequest instance) =>
    <String, dynamic>{
      'isActive': instance.isActive,
      'options': instance.options.map((e) => e.toJson()).toList(),
    };

Map<String, dynamic> _$HousekeepingFrequencyDiscountRequestToJson(
        HousekeepingFrequencyDiscountRequest instance) =>
    <String, dynamic>{
      'optionId': instance.optionId,
      'discountPercentage': instance.discountPercentage,
    };
