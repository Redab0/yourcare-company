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
          registrationGiftApplied: $checkedConvert(
              'registrationGiftApplied', (v) => v as bool? ?? false),
          campaign: $checkedConvert(
              'campaign',
              (v) => v == null
                  ? null
                  : RequestCampaign.fromJson(v as Map<String, dynamic>)),
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
          scheduledTime: $checkedConvert('scheduledTime',
              (v) => const KuwaitScheduleConverter().fromJson(v as String)),
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
          invoices: $checkedConvert(
              'invoices',
              (v) =>
                  (v as List<dynamic>?)
                      ?.map((e) =>
                          RequestInvoice.fromJson(e as Map<String, dynamic>))
                      .toList() ??
                  []),
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
      'registrationGiftApplied': instance.registrationGiftApplied,
      'campaign': instance.campaign,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'scheduledTime':
          const KuwaitScheduleConverter().toJson(instance.scheduledTime),
      'customer': instance.customer,
      'requestStatus': _$RequestStatusEnumMap[instance.requestStatus]!,
      'extraFees': instance.extraFees,
      'extraFeesDescription': instance.extraFeesDescription,
      'awaitingExtraPayment': instance.awaitingExtraPayment,
      'extraPaymentUrl': instance.extraPaymentUrl,
      'invoices': instance.invoices,
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
          scheduledTime: $checkedConvert(
              'scheduledTime',
              (v) => _$JsonConverterFromJson<String, DateTime>(
                  v, const KuwaitScheduleConverter().fromJson)),
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
      'scheduledTime': _$JsonConverterToJson<String, DateTime>(
          instance.scheduledTime, const KuwaitScheduleConverter().toJson),
      'specialNotes': instance.specialNotes,
      'totalPrice': instance.totalPrice,
      'area': instance.area,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);

FrequentRequestModel _$FrequentRequestModelFromJson(
        Map<String, dynamic> json) =>
    FrequentRequestModel(
      status: $enumDecodeNullable(_$RequestStatusEnumMap, json['status']),
      id: json['id'] as String?,
      date: _$JsonConverterFromJson<String, DateTime>(
          json['date'], const KuwaitScheduleConverter().fromJson),
    );

Map<String, dynamic> _$FrequentRequestModelToJson(
        FrequentRequestModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': _$JsonConverterToJson<String, DateTime>(
          instance.date, const KuwaitScheduleConverter().toJson),
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
