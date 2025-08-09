// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_offer_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BusinessOfferResponse _$BusinessOfferResponseFromJson(
        Map<String, dynamic> json) =>
    BusinessOfferResponse(
      id: json['id'] as String,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      requestStatus: $enumDecode(_$RequestStatusEnumMap, json['requestStatus']),
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );

Map<String, dynamic> _$BusinessOfferResponseToJson(
        BusinessOfferResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'totalPrice': instance.totalPrice,
      'requestStatus': _$RequestStatusEnumMap[instance.requestStatus]!,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

const _$RequestStatusEnumMap = {
  RequestStatus.confirmed: 'confirmed',
  RequestStatus.pending: 'pending',
  RequestStatus.inProgress: 'inProgress',
  RequestStatus.completed: 'completed',
  RequestStatus.cancelled: 'cancelled',
  RequestStatus.unknown: 'unknown',
};
