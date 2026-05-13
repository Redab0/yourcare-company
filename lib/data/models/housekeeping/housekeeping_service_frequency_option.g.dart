// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'housekeeping_service_frequency_option.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HousekeepingServiceFrequencyOption _$HousekeepingServiceFrequencyOptionFromJson(
        Map<String, dynamic> json) =>
    HousekeepingServiceFrequencyOption(
      id: json['id'] as String,
      titleAr: json['titleAr'] as String?,
      titleEn: json['titleEn'] as String?,
      numberOfWeeklyVisits: (json['numberOfWeeklyVisits'] as num?)?.toInt(),
      serviceFrequencyCount: (json['serviceFrequencyCount'] as num?)?.toInt(),
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$HousekeepingServiceFrequencyOptionToJson(
        HousekeepingServiceFrequencyOption instance) =>
    <String, dynamic>{
      'id': instance.id,
      'titleAr': instance.titleAr,
      'titleEn': instance.titleEn,
      'numberOfWeeklyVisits': instance.numberOfWeeklyVisits,
      'serviceFrequencyCount': instance.serviceFrequencyCount,
      'discountPercentage': instance.discountPercentage,
    };
