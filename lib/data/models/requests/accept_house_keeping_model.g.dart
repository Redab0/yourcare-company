// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accept_house_keeping_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AcceptHouseKeepingModel _$AcceptHouseKeepingModelFromJson(
        Map<String, dynamic> json) =>
    AcceptHouseKeepingModel(
      cleanerIds: (json['cleanerIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$AcceptHouseKeepingModelToJson(
        AcceptHouseKeepingModel instance) =>
    <String, dynamic>{
      'cleanerIds': instance.cleanerIds,
    };
