// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Address _$AddressFromJson(Map<String, dynamic> json) => $checkedCreate(
      'Address',
      json,
      ($checkedConvert) {
        final val = Address(
          latitude: $checkedConvert('latitude', (v) => (v as num?)?.toDouble()),
          longitude:
              $checkedConvert('longitude', (v) => (v as num?)?.toDouble()),
          areaId: $checkedConvert('areaId', (v) => v as String?),
          area: $checkedConvert('area', (v) => v as String?),
          street: $checkedConvert('street', (v) => v as String?),
          building: $checkedConvert('building', (v) => v as String?),
          avenue: $checkedConvert('avenue', (v) => v as String?),
          block: $checkedConvert('block', (v) => v as String?),
          name: $checkedConvert('name', (v) => v as String?),
          id: $checkedConvert('id', (v) => v as String?),
          isDefault: $checkedConvert('isDefault', (v) => v as bool?),
          floor: $checkedConvert('floor', (v) => v as String?),
          apartment: $checkedConvert('apartment', (v) => v as String?),
        );
        return val;
      },
    );

Map<String, dynamic> _$AddressToJson(Address instance) => <String, dynamic>{
      if (instance.id case final value?) 'id': value,
      if (instance.latitude case final value?) 'latitude': value,
      if (instance.longitude case final value?) 'longitude': value,
      if (instance.areaId case final value?) 'areaId': value,
      if (instance.area case final value?) 'area': value,
      if (instance.street case final value?) 'street': value,
      if (instance.building case final value?) 'building': value,
      if (instance.avenue case final value?) 'avenue': value,
      if (instance.block case final value?) 'block': value,
      if (instance.name case final value?) 'name': value,
      if (instance.floor case final value?) 'floor': value,
      if (instance.apartment case final value?) 'apartment': value,
      if (instance.isDefault case final value?) 'isDefault': value,
    };
