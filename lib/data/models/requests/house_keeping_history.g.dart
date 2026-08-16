// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'house_keeping_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HouseKeepingHistory _$HouseKeepingHistoryFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'HouseKeepingHistory',
      json,
      ($checkedConvert) {
        final val = HouseKeepingHistory(
          id: $checkedConvert('id', (v) => v as String?),
          requestStatus: $checkedConvert(
              'requestStatus', (v) => $enumDecode(_$RequestStatusEnumMap, v)),
          totalPrice:
              $checkedConvert('totalPrice', (v) => (v as num).toDouble()),
          type: $checkedConvert('type', (v) => v as String?),
          cleanersIds: $checkedConvert('cleanersIds',
              (v) => (v as List<dynamic>?)?.map((e) => e as String).toList()),
          createdAt:
              $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
          updatedAt:
              $checkedConvert('updatedAt', (v) => DateTime.parse(v as String)),
          detail: $checkedConvert('HouseCleaning',
              (v) => HouseKeepingDetail.fromJson(v as Map<String, dynamic>)),
          scheduledTime: $checkedConvert(
              'scheduledTime', (v) => DateTime.parse(v as String)),
          assignedWorker: $checkedConvert(
              'cleaners',
              (v) => (v as List<dynamic>?)
                  ?.map(
                      (e) => AssignedWorker.fromJson(e as Map<String, dynamic>))
                  .toList()),
          customer: $checkedConvert(
              'customer', (v) => Customer.fromJson(v as Map<String, dynamic>)),
          companyInformation: $checkedConvert(
              'businessId',
              (v) => v == null
                  ? null
                  : CompanyInformation.fromJson(v as Map<String, dynamic>)),
          subRequests: $checkedConvert(
              'frequencyDates',
              (v) => (v as List<dynamic>?)
                  ?.map((e) =>
                      FrequentRequestModel.fromJson(e as Map<String, dynamic>))
                  .toList()),
          extraFees:
              $checkedConvert('extraFees', (v) => (v as num?)?.toDouble()),
          extraFeesDescription:
              $checkedConvert('extraFeesDescription', (v) => v as String?),
          awaitingExtraPayment: $checkedConvert(
              'awaitingExtraPayment', (v) => v as bool? ?? false),
          extraPaymentUrl:
              $checkedConvert('extraPaymentUrl', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {
        'detail': 'HouseCleaning',
        'assignedWorker': 'cleaners',
        'companyInformation': 'businessId',
        'subRequests': 'frequencyDates'
      },
    );

Map<String, dynamic> _$HouseKeepingHistoryToJson(
        HouseKeepingHistory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'totalPrice': instance.totalPrice,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'scheduledTime': instance.scheduledTime.toIso8601String(),
      'customer': instance.customer,
      'requestStatus': _$RequestStatusEnumMap[instance.requestStatus]!,
      'extraFees': instance.extraFees,
      'extraFeesDescription': instance.extraFeesDescription,
      'awaitingExtraPayment': instance.awaitingExtraPayment,
      'extraPaymentUrl': instance.extraPaymentUrl,
      'cleaners': instance.assignedWorker,
      'HouseCleaning': instance.detail,
      'businessId': instance.companyInformation,
      'cleanersIds': instance.cleanersIds,
      'frequencyDates': instance.subRequests,
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

HouseKeepingDetail _$HouseKeepingDetailFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'HouseKeepingDetail',
      json,
      ($checkedConvert) {
        final val = HouseKeepingDetail(
          numberOfCleaners: $checkedConvert(
              'numberOfCleaners',
              (v) => v == null
                  ? null
                  : HouseKeepingOption.fromJson(v as Map<String, dynamic>)),
          cleaningDurations: $checkedConvert(
              'cleaningDurations',
              (v) => v == null
                  ? null
                  : HouseKeepingOption.fromJson(v as Map<String, dynamic>)),
          cleaningProducts: $checkedConvert(
              'cleaningProducts',
              (v) => v == null
                  ? null
                  : HouseKeepingOption.fromJson(v as Map<String, dynamic>)),
          address: $checkedConvert(
              'address',
              (v) => v == null
                  ? null
                  : Address.fromJson(v as Map<String, dynamic>)),
          scheduledTime: $checkedConvert('scheduledTime',
              (v) => v == null ? null : DateTime.parse(v as String)),
          specialNotes: $checkedConvert('specialNotes', (v) => v as String?),
          totalPrice:
              $checkedConvert('totalPrice', (v) => (v as num?)?.toDouble()),
          area: $checkedConvert('area', (v) => v as String?),
        );
        return val;
      },
    );

Map<String, dynamic> _$HouseKeepingDetailToJson(HouseKeepingDetail instance) =>
    <String, dynamic>{
      'numberOfCleaners': instance.numberOfCleaners,
      'cleaningDurations': instance.cleaningDurations,
      'cleaningProducts': instance.cleaningProducts,
      'address': instance.address,
      'scheduledTime': instance.scheduledTime?.toIso8601String(),
      'specialNotes': instance.specialNotes,
      'totalPrice': instance.totalPrice,
      'area': instance.area,
    };

FrequentRequestModel _$FrequentRequestModelFromJson(
        Map<String, dynamic> json) =>
    FrequentRequestModel(
      status: $enumDecodeNullable(_$RequestStatusEnumMap, json['status']),
      id: json['id'] as String?,
      date:
          json['date'] == null ? null : DateTime.parse(json['date'] as String),
    );

Map<String, dynamic> _$FrequentRequestModelToJson(
        FrequentRequestModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date?.toIso8601String(),
      'status': _$RequestStatusEnumMap[instance.status],
    };

HouseKeepingOption _$HouseKeepingOptionFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'HouseKeepingOption',
      json,
      ($checkedConvert) {
        final val = HouseKeepingOption(
          option: $checkedConvert(
              'option',
              (v) => v == null
                  ? null
                  : CleaningItem.fromJson(v as Map<String, dynamic>)),
          quantity: $checkedConvert('quantity', (v) => (v as num?)?.toInt()),
        );
        return val;
      },
    );

Map<String, dynamic> _$HouseKeepingOptionToJson(HouseKeepingOption instance) =>
    <String, dynamic>{
      'option': instance.option,
      'quantity': instance.quantity,
    };
