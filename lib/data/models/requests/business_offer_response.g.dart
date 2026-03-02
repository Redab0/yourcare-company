// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_offer_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BusinessOfferResponse _$BusinessOfferResponseFromJson(
        Map<String, dynamic> json) =>
    $checkedCreate(
      'BusinessOfferResponse',
      json,
      ($checkedConvert) {
        final val = BusinessOfferResponse(
          readableId: $checkedConvert('readableId', (v) => v as String?),
          id: $checkedConvert('id', (v) => v as String),
          totalPrice:
              $checkedConvert('totalPrice', (v) => (v as num).toDouble()),
          requestStatus: $checkedConvert(
              'requestStatus', (v) => $enumDecode(_$RequestStatusEnumMap, v)),
          createdAt: $checkedConvert('createdAt', (v) => v as String),
          updatedAt: $checkedConvert('updatedAt', (v) => v as String),
          serviceFrequencyCount: $checkedConvert(
              'serviceFrequencyCount', (v) => (v as num?)?.toInt()),
          serviceIntervalDays: $checkedConvert(
              'serviceIntervalDays', (v) => (v as num?)?.toInt()),
        );
        return val;
      },
    );

Map<String, dynamic> _$BusinessOfferResponseToJson(
        BusinessOfferResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'readableId': instance.readableId,
      'totalPrice': instance.totalPrice,
      'requestStatus': _$RequestStatusEnumMap[instance.requestStatus]!,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'serviceFrequencyCount': instance.serviceFrequencyCount,
      'serviceIntervalDays': instance.serviceIntervalDays,
    };

const _$RequestStatusEnumMap = {
  RequestStatus.confirmed: 'confirmed',
  RequestStatus.pending: 'pending',
  RequestStatus.inProgress: 'inProgress',
  RequestStatus.completed: 'completed',
  RequestStatus.cancelled: 'cancelled',
  RequestStatus.canceled: 'canceled',
  RequestStatus.notPaid: 'notPaid',
  RequestStatus.paid: 'paid',
  RequestStatus.unknown: 'unknown',
};
