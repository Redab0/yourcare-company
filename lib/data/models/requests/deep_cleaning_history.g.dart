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
          scheduledTime: $checkedConvert(
              'scheduledTime', (v) => DateTime.parse(v as String)),
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
      'scheduledTime': instance.scheduledTime.toIso8601String(),
      'customer': instance.customer,
      'DeepCleaning': instance.detail,
      'team': instance.assignedTeam,
      'businessId': instance.companyInformation,
      'requestStatus': _$RequestStatusEnumMap[instance.requestStatus]!,
    };

const _$RequestStatusEnumMap = {
  RequestStatus.confirmed: 'confirmed',
  RequestStatus.pending: 'pending',
  RequestStatus.inProgress: 'inProgress',
  RequestStatus.completed: 'completed',
  RequestStatus.cancelled: 'cancelled',
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
        );
        return val;
      },
    );

Map<String, dynamic> _$DeepCleaningDetailToJson(DeepCleaningDetail instance) =>
    <String, dynamic>{
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
    };
