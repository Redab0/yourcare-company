// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_request_frequency_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateRequestFrequencyRequest _$UpdateRequestFrequencyRequestFromJson(
        Map<String, dynamic> json) =>
    $checkedCreate(
      'UpdateRequestFrequencyRequest',
      json,
      ($checkedConvert) {
        final val = UpdateRequestFrequencyRequest(
          frequencyDateId:
              $checkedConvert('frequencyDateId', (v) => v as String?),
          status: $checkedConvert(
              'status', (v) => $enumDecodeNullable(_$RequestStatusEnumMap, v)),
        );
        return val;
      },
    );

Map<String, dynamic> _$UpdateRequestFrequencyRequestToJson(
        UpdateRequestFrequencyRequest instance) =>
    <String, dynamic>{
      'frequencyDateId': instance.frequencyDateId,
      'status': _$RequestStatusEnumMap[instance.status],
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
