// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_campaign.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RequestCampaign _$RequestCampaignFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'RequestCampaign',
      json,
      ($checkedConvert) {
        final val = RequestCampaign(
          campaignId: $checkedConvert('campaignId', (v) => v as String?),
          applicationId: $checkedConvert('applicationId', (v) => v as String?),
          name: $checkedConvert('name', (v) => v as String?),
          type: $checkedConvert('type', (v) => v as String?),
          percentage:
              $checkedConvert('percentage', (v) => (v as num?)?.toDouble()),
          fundedBy: $checkedConvert('fundedBy', (v) => v as String?),
          state: $checkedConvert('state', (v) => v as String?),
          registrationGiftApplied:
              $checkedConvert('registrationGiftApplied', (v) => v as bool?),
          discountKwd:
              $checkedConvert('discountKwd', (v) => (v as num?)?.toDouble()),
          cashbackKwd:
              $checkedConvert('cashbackKwd', (v) => (v as num?)?.toDouble()),
          cashbackSparkle: $checkedConvert(
              'cashbackSparkle', (v) => (v as num?)?.toDouble()),
          sparkleworth:
              $checkedConvert('sparkleworth', (v) => (v as num?)?.toDouble()),
          reversedCashbackKwd: $checkedConvert(
              'reversedCashbackKwd', (v) => (v as num?)?.toDouble()),
          honoredAfterEnd:
              $checkedConvert('honoredAfterEnd', (v) => v as bool?),
          amountKwd:
              $checkedConvert('amountKwd', (v) => (v as num?)?.toDouble()),
          businessId: $checkedConvert('businessId', (v) => v as String?),
          serviceType: $checkedConvert('serviceType', (v) => v as String?),
          onlyOnce: $checkedConvert('onlyOnce', (v) => v as bool?),
          startsAt: $checkedConvert('startsAt',
              (v) => v == null ? null : DateTime.parse(v as String)),
          expiresAt: $checkedConvert('expiresAt',
              (v) => v == null ? null : DateTime.parse(v as String)),
          excludesCashback:
              $checkedConvert('excludesCashback', (v) => v as bool?),
        );
        return val;
      },
    );

Map<String, dynamic> _$RequestCampaignToJson(RequestCampaign instance) =>
    <String, dynamic>{
      'campaignId': instance.campaignId,
      'applicationId': instance.applicationId,
      'name': instance.name,
      'type': instance.type,
      'percentage': instance.percentage,
      'fundedBy': instance.fundedBy,
      'state': instance.state,
      'registrationGiftApplied': instance.registrationGiftApplied,
      'discountKwd': instance.discountKwd,
      'cashbackKwd': instance.cashbackKwd,
      'cashbackSparkle': instance.cashbackSparkle,
      'sparkleworth': instance.sparkleworth,
      'reversedCashbackKwd': instance.reversedCashbackKwd,
      'honoredAfterEnd': instance.honoredAfterEnd,
      'amountKwd': instance.amountKwd,
      'businessId': instance.businessId,
      'serviceType': instance.serviceType,
      'onlyOnce': instance.onlyOnce,
      'startsAt': instance.startsAt?.toIso8601String(),
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'excludesCashback': instance.excludesCashback,
    };
