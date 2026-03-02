import 'package:cleaning_service_driver/core/utils/request_status_enum.dart';
import 'package:json_annotation/json_annotation.dart';

part 'business_offer_response.g.dart';

@JsonSerializable(checked: true)
class BusinessOfferResponse {
  final String id;
  final String? readableId;
  final double totalPrice;
  final RequestStatus requestStatus;
  final String createdAt;
  final String updatedAt;
  final int? serviceFrequencyCount;
  final int? serviceIntervalDays;

  BusinessOfferResponse({
    this.readableId,
    required this.id,
    required this.totalPrice,
    required this.requestStatus,
    required this.createdAt,
    required this.updatedAt,
    this.serviceFrequencyCount,
    this.serviceIntervalDays,
  });

  factory BusinessOfferResponse.fromJson(Map<String, dynamic> json) =>
      _$BusinessOfferResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BusinessOfferResponseToJson(this);
}
