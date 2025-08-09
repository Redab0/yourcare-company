import 'package:json_annotation/json_annotation.dart';

part 'response_payload.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class ResponsePayload<T> {
  final T? data;
  final String locale;

  ResponsePayload({
    this.data,
    required this.locale,
  });

  factory ResponsePayload.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$ResponsePayloadFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(
    Object Function(T value) toJsonT,
  ) =>
      _$ResponsePayloadToJson(this, toJsonT);
}
