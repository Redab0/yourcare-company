// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upholstery_cleaning_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpholsteryCleaningHistory _$UpholsteryCleaningHistoryFromJson(
        Map<String, dynamic> json) =>
    $checkedCreate(
      'UpholsteryCleaningHistory',
      json,
      ($checkedConvert) {
        final val = UpholsteryCleaningHistory(
          id: $checkedConvert('id', (v) => v as String?),
          customer: $checkedConvert(
              'customer', (v) => Customer.fromJson(v as Map<String, dynamic>)),
          requestStatus: $checkedConvert(
              'requestStatus', (v) => $enumDecode(_$RequestStatusEnumMap, v)),
          totalPrice:
              $checkedConvert('totalPrice', (v) => (v as num).toDouble()),
          type: $checkedConvert('type', (v) => v as String),
          createdAt:
              $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
          updatedAt:
              $checkedConvert('updatedAt', (v) => DateTime.parse(v as String)),
          upholsteryCleaning: $checkedConvert(
              'UpholsteryCleaning',
              (v) => UpholsteryCleaningDetails.fromJson(
                  v as Map<String, dynamic>)),
          scheduledTime: $checkedConvert('scheduledTime',
              (v) => v == null ? null : DateTime.parse(v as String)),
          companyInformation: $checkedConvert(
              'businessId',
              (v) => v == null
                  ? null
                  : CompanyInformation.fromJson(v as Map<String, dynamic>)),
          assignedWorker: $checkedConvert(
              'cleaners',
              (v) => (v as List<dynamic>?)
                  ?.map(
                      (e) => AssignedWorker.fromJson(e as Map<String, dynamic>))
                  .toList()),
          subRequests: $checkedConvert(
              'frequencyDates',
              (v) => (v as List<dynamic>?)
                  ?.map((e) =>
                      FrequentRequestModel.fromJson(e as Map<String, dynamic>))
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
        );
        return val;
      },
      fieldKeyMap: const {
        'upholsteryCleaning': 'UpholsteryCleaning',
        'companyInformation': 'businessId',
        'assignedWorker': 'cleaners',
        'subRequests': 'frequencyDates'
      },
    );

Map<String, dynamic> _$UpholsteryCleaningHistoryToJson(
        UpholsteryCleaningHistory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'requestStatus': _$RequestStatusEnumMap[instance.requestStatus]!,
      'totalPrice': instance.totalPrice,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'customer': instance.customer,
      'scheduledTime': instance.scheduledTime?.toIso8601String(),
      'extraFees': instance.extraFees,
      'extraFeesDescription': instance.extraFeesDescription,
      'awaitingExtraPayment': instance.awaitingExtraPayment,
      'extraPaymentUrl': instance.extraPaymentUrl,
      'businessId': instance.companyInformation,
      'cleaners': instance.assignedWorker,
      'frequencyDates': instance.subRequests,
      'UpholsteryCleaning': instance.upholsteryCleaning,
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

UpholsteryCleaningDetails _$UpholsteryCleaningDetailsFromJson(
        Map<String, dynamic> json) =>
    $checkedCreate(
      'UpholsteryCleaningDetails',
      json,
      ($checkedConvert) {
        final val = UpholsteryCleaningDetails(
          items: $checkedConvert(
              'items',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => UpholsteryCleaningItems.fromJson(
                      e as Map<String, dynamic>))
                  .toList()),
          address: $checkedConvert(
              'address',
              (v) => v == null
                  ? null
                  : Address.fromJson(v as Map<String, dynamic>)),
          addressId: $checkedConvert('addressId', (v) => v as String?),
          areaId: $checkedConvert('areaId', (v) => v as String?),
          specialNotes: $checkedConvert('specialNotes', (v) => v as String?),
          scheduledTime: $checkedConvert('scheduledTime',
              (v) => v == null ? null : DateTime.parse(v as String)),
        );
        return val;
      },
    );

Map<String, dynamic> _$UpholsteryCleaningDetailsToJson(
        UpholsteryCleaningDetails instance) =>
    <String, dynamic>{
      'address': instance.address,
      'addressId': instance.addressId,
      'areaId': instance.areaId,
      'specialNotes': instance.specialNotes,
      'scheduledTime': instance.scheduledTime?.toIso8601String(),
      'items': instance.items,
    };

UpholsteryCleaningItems _$UpholsteryCleaningItemsFromJson(
        Map<String, dynamic> json) =>
    $checkedCreate(
      'UpholsteryCleaningItems',
      json,
      ($checkedConvert) {
        final val = UpholsteryCleaningItems(
          quantity: $checkedConvert('quantity', (v) => (v as num?)?.toInt()),
          calculatedPrice: $checkedConvert(
              'calculatedPrice', (v) => (v as num?)?.toDouble()),
          type: $checkedConvert('type', (v) => _parseCleaningItemType(v)),
          size: $checkedConvert('size', (v) => _parseCleaningItemSize(v)),
          material:
              $checkedConvert('material', (v) => _parseCleaningItemMaterial(v)),
          condition: $checkedConvert(
              'condition', (v) => _parseCleaningItemCondition(v)),
          mediaUrls: $checkedConvert('mediaUrls',
              (v) => (v as List<dynamic>?)?.map((e) => e as String).toList()),
          additionalInformation:
              $checkedConvert('additionalInformation', (v) => v as String?),
          upholsteryTypeId:
              $checkedConvert('upholsteryTypeId', (v) => v as String?),
          packageId: $checkedConvert('packageId', (v) => v as String?),
          package: $checkedConvert(
              'package',
              (v) => v == null
                  ? null
                  : UpholsteryCleaningPackage.fromJson(
                      v as Map<String, dynamic>)),
          price: $checkedConvert('price', (v) => (v as num?)?.toDouble()),
        );
        return val;
      },
    );

Map<String, dynamic> _$UpholsteryCleaningItemsToJson(
        UpholsteryCleaningItems instance) =>
    <String, dynamic>{
      'quantity': instance.quantity,
      'calculatedPrice': instance.calculatedPrice,
      'type': instance.type,
      'size': instance.size,
      'material': instance.material,
      'condition': instance.condition,
      'mediaUrls': instance.mediaUrls,
      'additionalInformation': instance.additionalInformation,
      'upholsteryTypeId': instance.upholsteryTypeId,
      'packageId': instance.packageId,
      'package': instance.package,
      'price': instance.price,
    };

UpholsteryCleaningPackage _$UpholsteryCleaningPackageFromJson(
        Map<String, dynamic> json) =>
    $checkedCreate(
      'UpholsteryCleaningPackage',
      json,
      ($checkedConvert) {
        final val = UpholsteryCleaningPackage(
          packageId: $checkedConvert('packageId', (v) => v as String?),
          titleEn: $checkedConvert('titleEn', (v) => v as String?),
          titleAr: $checkedConvert('titleAr', (v) => v as String?),
          descriptionEn: $checkedConvert('descriptionEn', (v) => v as String?),
          descriptionAr: $checkedConvert('descriptionAr', (v) => v as String?),
          price: $checkedConvert('price', (v) => (v as num?)?.toDouble()),
          discountPercentage: $checkedConvert(
              'discountPercentage', (v) => (v as num?)?.toDouble()),
        );
        return val;
      },
    );

Map<String, dynamic> _$UpholsteryCleaningPackageToJson(
        UpholsteryCleaningPackage instance) =>
    <String, dynamic>{
      'packageId': instance.packageId,
      'titleEn': instance.titleEn,
      'titleAr': instance.titleAr,
      'descriptionEn': instance.descriptionEn,
      'descriptionAr': instance.descriptionAr,
      'price': instance.price,
      'discountPercentage': instance.discountPercentage,
    };

FrequentRequestModel _$FrequentRequestModelFromJson(
        Map<String, dynamic> json) =>
    FrequentRequestModel(
      $enumDecodeNullable(_$RequestStatusEnumMap, json['status']),
      json['id'] as String?,
      json['date'] == null ? null : DateTime.parse(json['date'] as String),
    );

Map<String, dynamic> _$FrequentRequestModelToJson(
        FrequentRequestModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date?.toIso8601String(),
      'status': _$RequestStatusEnumMap[instance.status],
    };

CleaningItemType _$CleaningItemTypeFromJson(Map<String, dynamic> json) =>
    CleaningItemType(
      json['id'] as String?,
      json['titleEn'] as String?,
      json['titleAr'] as String?,
      json['title'] as String?,
      json['descriptionEn'] as String?,
      json['descriptionAr'] as String?,
      json['description'] as String?,
    );

Map<String, dynamic> _$CleaningItemTypeToJson(CleaningItemType instance) =>
    <String, dynamic>{
      'id': instance.id,
      'titleEn': instance.titleEn,
      'titleAr': instance.titleAr,
      'title': instance.title,
      'descriptionEn': instance.descriptionEn,
      'descriptionAr': instance.descriptionAr,
      'description': instance.description,
    };

CleaningItemSize _$CleaningItemSizeFromJson(Map<String, dynamic> json) =>
    CleaningItemSize(
      json['id'] as String?,
      json['title'] as String?,
      json['description'] as String?,
    );

Map<String, dynamic> _$CleaningItemSizeToJson(CleaningItemSize instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
    };

CleaningItemMaterial _$CleaningItemMaterialFromJson(
        Map<String, dynamic> json) =>
    CleaningItemMaterial(
      json['id'] as String?,
      json['title'] as String?,
      json['description'] as String?,
    );

Map<String, dynamic> _$CleaningItemMaterialToJson(
        CleaningItemMaterial instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
    };

CleaningItemCondition _$CleaningItemConditionFromJson(
        Map<String, dynamic> json) =>
    CleaningItemCondition(
      json['id'] as String,
      json['title'] as String,
      json['description'] as String,
    );

Map<String, dynamic> _$CleaningItemConditionToJson(
        CleaningItemCondition instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
    };
