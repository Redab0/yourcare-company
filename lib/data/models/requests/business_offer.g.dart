// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_offer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BusinessOffer _$BusinessOfferFromJson(Map<String, dynamic> json) =>
    BusinessOffer(
      requestId: json['requestId'] as String,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      description: json['description'] as String,
      descriptionBusinessOffer: json['descriptionBusinessOffer'] as String,
      timelineBusinessOffer: json['timelineBusinessOffer'] as String,
    );

Map<String, dynamic> _$BusinessOfferToJson(BusinessOffer instance) =>
    <String, dynamic>{
      'requestId': instance.requestId,
      'totalPrice': instance.totalPrice,
      'description': instance.description,
      'timelineBusinessOffer': instance.timelineBusinessOffer,
      'descriptionBusinessOffer': instance.descriptionBusinessOffer,
    };
