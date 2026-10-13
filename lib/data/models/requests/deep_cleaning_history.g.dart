// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deep_cleaning_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeepCleaningHistory _$DeepCleaningHistoryFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'DeepCleaningHistory',
      json,
      ($checkedConvert) {
        final val = DeepCleaningHistory(
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
          createdAt:
              $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
          updatedAt:
              $checkedConvert('updatedAt', (v) => DateTime.parse(v as String)),
          detail: $checkedConvert('DeepCleaning',
              (v) => DeepCleaningDetail.fromJson(v as Map<String, dynamic>)),
          scheduledTime: $checkedConvert(
              'scheduledTime',
              (v) => _$JsonConverterFromJson<String, DateTime>(
                  v, const KuwaitScheduleConverter().fromJson)),
          customer: $checkedConvert(
              'customer', (v) => Customer.fromJson(v as Map<String, dynamic>)),
          assignedTeam: $checkedConvert(
              'team',
              (v) => v == null
                  ? null
                  : TeamModel.fromJson(v as Map<String, dynamic>)),
          companyInformation: $checkedConvert(
              'businessId',
              (v) => v == null
                  ? null
                  : CompanyInformation.fromJson(v as Map<String, dynamic>)),
          serviceFrequencyCount: $checkedConvert(
              'serviceFrequencyCount', (v) => (v as num?)?.toInt()),
          serviceIntervalDays: $checkedConvert(
              'serviceIntervalDays', (v) => (v as num?)?.toInt()),
          frequencyDates: $checkedConvert(
              'frequencyDates',
              (v) => (v as List<dynamic>?)
                  ?.map(
                      (e) => FrequencyDate.fromJson(e as Map<String, dynamic>))
                  .toList()),
          myBid: $checkedConvert(
              'myBid',
              (v) => v == null
                  ? null
                  : BusinessOfferResponse.fromJson(v as Map<String, dynamic>)),
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
        'detail': 'DeepCleaning',
        'assignedTeam': 'team',
        'companyInformation': 'businessId'
      },
    );

Map<String, dynamic> _$DeepCleaningHistoryToJson(
        DeepCleaningHistory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'totalPrice': instance.totalPrice,
      'registrationGiftApplied': instance.registrationGiftApplied,
      'campaign': instance.campaign,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'scheduledTime': _$JsonConverterToJson<String, DateTime>(
          instance.scheduledTime, const KuwaitScheduleConverter().toJson),
      'customer': instance.customer,
      'DeepCleaning': instance.detail,
      'team': instance.assignedTeam,
      'businessId': instance.companyInformation,
      'serviceFrequencyCount': instance.serviceFrequencyCount,
      'serviceIntervalDays': instance.serviceIntervalDays,
      'frequencyDates': instance.frequencyDates,
      'requestStatus': _$RequestStatusEnumMap[instance.requestStatus]!,
      'extraFees': instance.extraFees,
      'extraFeesDescription': instance.extraFeesDescription,
      'awaitingExtraPayment': instance.awaitingExtraPayment,
      'extraPaymentUrl': instance.extraPaymentUrl,
      'invoices': instance.invoices,
      'myBid': instance.myBid,
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

DeepCleaningDetail _$DeepCleaningDetailFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'DeepCleaningDetail',
      json,
      ($checkedConvert) {
        final val = DeepCleaningDetail(
          departmentSelection: $checkedConvert(
              'departmentSelection',
              (v) => v == null
                  ? null
                  : DeepCleaningDepartmentSelection.fromJson(
                      v as Map<String, dynamic>)),
          departmentType: $checkedConvert(
              'departmentType',
              (v) => v == null
                  ? null
                  : CleaningItem.fromJson(v as Map<String, dynamic>)),
          bedroom: $checkedConvert(
              'bedroom',
              (v) => v == null
                  ? null
                  : CleaningItem.fromJson(v as Map<String, dynamic>)),
          bathroom: $checkedConvert(
              'bathroom',
              (v) => v == null
                  ? null
                  : CleaningItem.fromJson(v as Map<String, dynamic>)),
          kitchen: $checkedConvert(
              'kitchen',
              (v) => v == null
                  ? null
                  : CleaningItem.fromJson(v as Map<String, dynamic>)),
          livingRoom: $checkedConvert(
              'livingRoom',
              (v) => v == null
                  ? null
                  : CleaningItem.fromJson(v as Map<String, dynamic>)),
          numberOfFloors: $checkedConvert(
              'numberOfFloors',
              (v) => v == null
                  ? null
                  : CleaningItem.fromJson(v as Map<String, dynamic>)),
          address: $checkedConvert(
              'address',
              (v) => v == null
                  ? null
                  : Address.fromJson(v as Map<String, dynamic>)),
          additionalInformation:
              $checkedConvert('additionalInformation', (v) => v as String?),
          photosAndVideos: $checkedConvert('photosAndVideos',
              (v) => (v as List<dynamic>?)?.map((e) => e as String).toList()),
          scheduledTime: $checkedConvert(
              'scheduledTime',
              (v) => _$JsonConverterFromJson<String, DateTime>(
                  v, const KuwaitScheduleConverter().fromJson)),
          area: $checkedConvert('area', (v) => v as String?),
          areaId: $checkedConvert('areaId', (v) => v as String?),
        );
        return val;
      },
    );

Map<String, dynamic> _$DeepCleaningDetailToJson(DeepCleaningDetail instance) =>
    <String, dynamic>{
      'departmentSelection': instance.departmentSelection,
      'departmentType': instance.departmentType,
      'bedroom': instance.bedroom,
      'bathroom': instance.bathroom,
      'kitchen': instance.kitchen,
      'livingRoom': instance.livingRoom,
      'numberOfFloors': instance.numberOfFloors,
      'address': instance.address,
      'additionalInformation': instance.additionalInformation,
      'photosAndVideos': instance.photosAndVideos,
      'scheduledTime': _$JsonConverterToJson<String, DateTime>(
          instance.scheduledTime, const KuwaitScheduleConverter().toJson),
      'area': instance.area,
      'areaId': instance.areaId,
    };

DeepCleaningDepartmentSelection _$DeepCleaningDepartmentSelectionFromJson(
        Map<String, dynamic> json) =>
    $checkedCreate(
      'DeepCleaningDepartmentSelection',
      json,
      ($checkedConvert) {
        final val = DeepCleaningDepartmentSelection(
          departmentType: $checkedConvert(
              'departmentType',
              (v) => v == null
                  ? null
                  : CleaningItem.fromJson(v as Map<String, dynamic>)),
          bedrooms: $checkedConvert(
              'bedrooms',
              (v) => v == null
                  ? null
                  : CleaningItem.fromJson(v as Map<String, dynamic>)),
          bathrooms: $checkedConvert(
              'bathrooms',
              (v) => v == null
                  ? null
                  : CleaningItem.fromJson(v as Map<String, dynamic>)),
          kitchens: $checkedConvert(
              'kitchens',
              (v) => v == null
                  ? null
                  : CleaningItem.fromJson(v as Map<String, dynamic>)),
          livingRooms: $checkedConvert(
              'livingRooms',
              (v) => v == null
                  ? null
                  : CleaningItem.fromJson(v as Map<String, dynamic>)),
          numberOfFloors: $checkedConvert(
              'numberOfFloors',
              (v) => v == null
                  ? null
                  : CleaningItem.fromJson(v as Map<String, dynamic>)),
          sizeOptions: $checkedConvert(
              'sizeOptions',
              (v) => v == null
                  ? null
                  : CleaningItem.fromJson(v as Map<String, dynamic>)),
          furnitureCheckbox:
              $checkedConvert('furnitureCheckbox', (v) => v as bool?),
          kitchenCheckbox:
              $checkedConvert('kitchenCheckbox', (v) => v as bool?),
          bathroomCheckbox:
              $checkedConvert('bathroomCheckbox', (v) => v as bool?),
          additionalInformation:
              $checkedConvert('additionalInformation', (v) => v as String?),
          calculatedPrice: $checkedConvert(
              'calculatedPrice', (v) => (v as num?)?.toDouble()),
        );
        return val;
      },
    );

Map<String, dynamic> _$DeepCleaningDepartmentSelectionToJson(
        DeepCleaningDepartmentSelection instance) =>
    <String, dynamic>{
      'departmentType': instance.departmentType,
      'bedrooms': instance.bedrooms,
      'bathrooms': instance.bathrooms,
      'kitchens': instance.kitchens,
      'livingRooms': instance.livingRooms,
      'numberOfFloors': instance.numberOfFloors,
      'sizeOptions': instance.sizeOptions,
      'furnitureCheckbox': instance.furnitureCheckbox,
      'kitchenCheckbox': instance.kitchenCheckbox,
      'bathroomCheckbox': instance.bathroomCheckbox,
      'additionalInformation': instance.additionalInformation,
      'calculatedPrice': instance.calculatedPrice,
    };

FrequencyDate _$FrequencyDateFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'FrequencyDate',
      json,
      ($checkedConvert) {
        final val = FrequencyDate(
          id: $checkedConvert('id', (v) => v as String?),
          date: $checkedConvert(
              'date',
              (v) => _$JsonConverterFromJson<String, DateTime>(
                  v, const KuwaitScheduleConverter().fromJson)),
          status: $checkedConvert('status', (v) => v as String?),
        );
        return val;
      },
    );

Map<String, dynamic> _$FrequencyDateToJson(FrequencyDate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': _$JsonConverterToJson<String, DateTime>(
          instance.date, const KuwaitScheduleConverter().toJson),
      'status': instance.status,
    };
