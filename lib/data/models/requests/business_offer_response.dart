import 'package:cleaning_service_driver/core/utils/request_status_enum.dart';
import 'package:json_annotation/json_annotation.dart';

part 'business_offer_response.g.dart';

@JsonSerializable(checked: true)
class BusinessOfferResponse {
  final String? id;
  final String? readableId;
  @JsonKey(defaultValue: 0)
  final double totalPrice;
  @JsonKey(unknownEnumValue: RequestStatus.unknown)
  final RequestStatus? requestStatus;
  final String? createdAt;
  final String? updatedAt;
  final int? serviceFrequencyCount;
  final int? serviceIntervalDays;
  final String? timelineBusinessOffer;
  final String? descriptionBusinessOffer;

  BusinessOfferResponse({
    this.readableId,
    this.id,
    this.totalPrice = 0,
    this.requestStatus,
    this.createdAt,
    this.updatedAt,
    this.serviceFrequencyCount,
    this.serviceIntervalDays,
    this.timelineBusinessOffer,
    this.descriptionBusinessOffer,
  });

  factory BusinessOfferResponse.fromJson(Map<String, dynamic> json) =>
      _$BusinessOfferResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BusinessOfferResponseToJson(this);
}
