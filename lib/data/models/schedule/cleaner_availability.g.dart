// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cleaner_availability.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CleanerAvailabilitySlot _$CleanerAvailabilitySlotFromJson(
        Map<String, dynamic> json) =>
    $checkedCreate(
      'CleanerAvailabilitySlot',
      json,
      ($checkedConvert) {
        final val = CleanerAvailabilitySlot(
          id: $checkedConvert('id', (v) => v as String?),
          dayOfWeek: $checkedConvert('dayOfWeek', (v) => (v as num?)?.toInt()),
          startHour: $checkedConvert('startHour', (v) => (v as num?)?.toInt()),
          endHour: $checkedConvert('endHour', (v) => (v as num?)?.toInt()),
          totalCleaners:
              $checkedConvert('totalCleaners', (v) => (v as num?)?.toInt()),
          serviceType: $checkedConvert('serviceType', (v) => v as String?),
          employeeId: $checkedConvert(
            'employeeId',
            (v) => v as String?,
            readValue: _readEmployeeId,
          ),
        );
        return val;
      },
    );

Map<String, dynamic> _$CleanerAvailabilitySlotToJson(
        CleanerAvailabilitySlot instance) =>
    <String, dynamic>{
      'id': instance.id,
      'dayOfWeek': instance.dayOfWeek,
      'startHour': instance.startHour,
      'endHour': instance.endHour,
      'totalCleaners': instance.totalCleaners,
      'serviceType': instance.serviceType,
      'employeeId': instance.employeeId,
    };

const _$AvailabilityServiceTypeEnumMap = {
  AvailabilityServiceType.houseCleaning: 'houseCleaning',
  AvailabilityServiceType.carWash: 'carWash',
  AvailabilityServiceType.upholsteryCleaning: 'upholsteryCleaning',
};

CleanerAvailabilityRequest _$CleanerAvailabilityRequestFromJson(
        Map<String, dynamic> json) =>
    CleanerAvailabilityRequest(
      dayOfWeek: (json['dayOfWeek'] as num).toInt(),
      startHour: (json['startHour'] as num).toInt(),
      endHour: (json['endHour'] as num).toInt(),
      totalCleaners: (json['totalCleaners'] as num).toInt(),
      serviceType:
          $enumDecode(_$AvailabilityServiceTypeEnumMap, json['serviceType']),
    );

Map<String, dynamic> _$CleanerAvailabilityRequestToJson(
        CleanerAvailabilityRequest instance) =>
    <String, dynamic>{
      'dayOfWeek': instance.dayOfWeek,
      'startHour': instance.startHour,
      'endHour': instance.endHour,
      'totalCleaners': instance.totalCleaners,
      'serviceType': _$AvailabilityServiceTypeEnumMap[instance.serviceType]!,
    };
