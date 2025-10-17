import 'package:json_annotation/json_annotation.dart';

part 'business_offer.g.dart';

@JsonSerializable()
class BusinessOffer {
  final String requestId;
  final double totalPrice;
  final String description;
  final String timelineBusinessOffer;
  final String descriptionBusinessOffer;

  BusinessOffer(
      {required this.requestId,
      required this.totalPrice,
      required this.description,
      required this.descriptionBusinessOffer,
      required this.timelineBusinessOffer});

  factory BusinessOffer.fromJson(Map<String, dynamic> json) =>
      _$BusinessOfferFromJson(json);

  Map<String, dynamic> toJson() => _$BusinessOfferToJson(this);
}
