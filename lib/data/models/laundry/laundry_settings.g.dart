// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'laundry_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LaundryWorkingHour _$LaundryWorkingHourFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'LaundryWorkingHour',
      json,
      ($checkedConvert) {
        final val = LaundryWorkingHour(
          dayOfWeek: $checkedConvert('dayOfWeek', (v) => (v as num).toInt()),
          startTime: $checkedConvert('startTime', (v) => v as String),
          endTime: $checkedConvert('endTime', (v) => v as String),
        );
        return val;
      },
    );

Map<String, dynamic> _$LaundryWorkingHourToJson(LaundryWorkingHour instance) =>
    <String, dynamic>{
      'dayOfWeek': instance.dayOfWeek,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
    };

LaundrySettings _$LaundrySettingsFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'LaundrySettings',
      json,
      ($checkedConvert) {
        final val = LaundrySettings(
          sameDayEnabled: $checkedConvert('sameDayEnabled', (v) => v as bool),
          sameDayCutoffTime:
              $checkedConvert('sameDayCutoffTime', (v) => v as String?),
          timeZone: $checkedConvert('timeZone', (v) => v as String),
          available: $checkedConvert('available', (v) => v as bool? ?? true),
          minimumCharge: $checkedConvert(
              'minimumCharge', (v) => (v as num?)?.toDouble() ?? 0),
          workingHours: $checkedConvert(
              'workingHours',
              (v) => (v as List<dynamic>?)
                  ?.map((e) =>
                      LaundryWorkingHour.fromJson(e as Map<String, dynamic>))
                  .toList()),
        );
        return val;
      },
    );

Map<String, dynamic> _$LaundrySettingsToJson(LaundrySettings instance) =>
    <String, dynamic>{
      'sameDayEnabled': instance.sameDayEnabled,
      'sameDayCutoffTime': instance.sameDayCutoffTime,
      'timeZone': instance.timeZone,
      'available': instance.available,
      'minimumCharge': instance.minimumCharge,
      'workingHours': instance.workingHours?.map((e) => e.toJson()).toList(),
    };

Map<String, dynamic> _$LaundrySettingsRequestToJson(
        LaundrySettingsRequest instance) =>
    <String, dynamic>{
      if (instance.sameDayEnabled case final value?) 'sameDayEnabled': value,
      if (instance.sameDayCutoffTime case final value?)
        'sameDayCutoffTime': value,
      if (instance.available case final value?) 'available': value,
      if (instance.minimumCharge case final value?) 'minimumCharge': value,
      if (instance.workingHours?.map((e) => e.toJson()).toList()
          case final value?)
        'workingHours': value,
    };
