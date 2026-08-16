// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'car_wash_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CarWashCategoryResponse _$CarWashCategoryResponseFromJson(
        Map<String, dynamic> json) =>
    CarWashCategoryResponse(
      vehicleTypes: (json['vehicleTypes'] as List<dynamic>?)
              ?.map(
                  (e) => CarWashVehicleType.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$CarWashCategoryResponseToJson(
        CarWashCategoryResponse instance) =>
    <String, dynamic>{
      'vehicleTypes': instance.vehicleTypes,
    };

CarWashVehicleType _$CarWashVehicleTypeFromJson(Map<String, dynamic> json) =>
    CarWashVehicleType(
      id: _readId(json, 'id') as String? ?? '',
      titleEn: json['titleEn'] as String?,
      titleAr: json['titleAr'] as String?,
      sizes: (json['sizes'] as List<dynamic>?)
              ?.map(
                  (e) => CarWashSizeOption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$CarWashVehicleTypeToJson(CarWashVehicleType instance) =>
    <String, dynamic>{
      'id': instance.id,
      if (instance.titleEn case final value?) 'titleEn': value,
      if (instance.titleAr case final value?) 'titleAr': value,
      'sizes': instance.sizes,
    };

CarWashSizeOption _$CarWashSizeOptionFromJson(Map<String, dynamic> json) =>
    CarWashSizeOption(
      id: _readId(json, 'id') as String? ?? '',
      titleEn: json['titleEn'] as String?,
      titleAr: json['titleAr'] as String?,
    );

Map<String, dynamic> _$CarWashSizeOptionToJson(CarWashSizeOption instance) =>
    <String, dynamic>{
      'id': instance.id,
      if (instance.titleEn case final value?) 'titleEn': value,
      if (instance.titleAr case final value?) 'titleAr': value,
    };

CarWashPricingPackage _$CarWashPricingPackageFromJson(
        Map<String, dynamic> json) =>
    CarWashPricingPackage(
      packageId: _readPackageId(json, 'packageId') as String?,
      titleEn: json['titleEn'] as String?,
      titleAr: json['titleAr'] as String?,
      descriptionEn: json['descriptionEn'] as String?,
      descriptionAr: json['descriptionAr'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$CarWashPricingPackageToJson(
        CarWashPricingPackage instance) =>
    <String, dynamic>{
      if (instance.titleEn case final value?) 'titleEn': value,
      if (instance.titleAr case final value?) 'titleAr': value,
      if (instance.descriptionEn case final value?) 'descriptionEn': value,
      if (instance.descriptionAr case final value?) 'descriptionAr': value,
      'price': instance.price,
      'discountPercentage': instance.discountPercentage,
    };

Map<String, dynamic> _$CarWashPricingGroupToJson(
        CarWashPricingGroup instance) =>
    <String, dynamic>{
      if (instance.stringify case final value?) 'stringify': value,
      'hashCode': instance.hashCode,
      'vehicleTypeId': instance.vehicleTypeId,
      'packages': instance.packages,
      'props': instance.props,
    };

CarWashPricingRequest _$CarWashPricingRequestFromJson(
        Map<String, dynamic> json) =>
    CarWashPricingRequest(
      pricing: (json['pricing'] as List<dynamic>)
          .map((e) => CarWashPricingGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

CarWashWorkingHour _$CarWashWorkingHourFromJson(Map<String, dynamic> json) =>
    CarWashWorkingHour(
      dayOfWeek: (json['dayOfWeek'] as num).toInt(),
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
    );

Map<String, dynamic> _$CarWashWorkingHourToJson(CarWashWorkingHour instance) =>
    <String, dynamic>{
      'dayOfWeek': instance.dayOfWeek,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
    };

CarWashWorkingHoursRequest _$CarWashWorkingHoursRequestFromJson(
        Map<String, dynamic> json) =>
    CarWashWorkingHoursRequest(
      hours: (json['hours'] as List<dynamic>)
          .map((e) => CarWashWorkingHour.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CarWashWorkingHoursRequestToJson(
        CarWashWorkingHoursRequest instance) =>
    <String, dynamic>{
      'hours': instance.hours,
    };
