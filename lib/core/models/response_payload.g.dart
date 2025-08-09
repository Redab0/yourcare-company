// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'response_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResponsePayload<T> _$ResponsePayloadFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    ResponsePayload<T>(
      data: _$nullableGenericFromJson(json['data'], fromJsonT),
      locale: json['locale'] as String,
    );

Map<String, dynamic> _$ResponsePayloadToJson<T>(
  ResponsePayload<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'data': _$nullableGenericToJson(instance.data, toJsonT),
      'locale': instance.locale,
    };

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) =>
    input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) =>
    input == null ? null : toJson(input);
