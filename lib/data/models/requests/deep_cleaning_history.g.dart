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
          scheduledTime: $checkedConvert('scheduledTime',
              (v) => v == null ? null : DateTime.parse(v as String)),
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
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'scheduledTime': instance.scheduledTime?.toIso8601String(),
      'customer': instance.customer,
      'DeepCleaning': instance.detail,
      'team': instance.assignedTeam,
      'businessId': instance.companyInformation,
      'serviceFrequencyCount': instance.serviceFrequencyCount,
      'serviceIntervalDays': instance.serviceIntervalDays,
      'frequencyDates': instance.frequencyDates,
      'requestStatus': _$RequestStatusEnumMap[instance.requestStatus]!,
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
          address: $checkedConvert(
              'address',
              (v) => v == null
                  ? null
                  : Address.fromJson(v as Map<String, dynamic>)),
          additionalInformation:
              $checkedConvert('additionalInformation', (v) => v as String?),
          photosAndVideos: $checkedConvert('photosAndVideos',
              (v) => (v as List<dynamic>?)?.map((e) => e as String).toList()),
          scheduledTime: $checkedConvert('scheduledTime',
              (v) => v == null ? null : DateTime.parse(v as String)),
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
      'address': instance.address,
      'additionalInformation': instance.additionalInformation,
      'photosAndVideos': instance.photosAndVideos,
      'scheduledTime': instance.scheduledTime?.toIso8601String(),
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
              'date', (v) => v == null ? null : DateTime.parse(v as String)),
          status: $checkedConvert('status', (v) => v as String?),
        );
        return val;
      },
    );

Map<String, dynamic> _$FrequencyDateToJson(FrequencyDate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date?.toIso8601String(),
      'status': instance.status,
    };
