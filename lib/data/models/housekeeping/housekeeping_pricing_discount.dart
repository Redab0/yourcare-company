import 'package:json_annotation/json_annotation.dart';

part 'housekeeping_pricing_discount.g.dart';

@JsonSerializable()
class HousekeepingPricingDiscount {
  final String optionId;
  final double discountPercentage;

  const HousekeepingPricingDiscount({
    required this.optionId,
    required this.discountPercentage,
  });

  factory HousekeepingPricingDiscount.fromJson(Map<String, dynamic> json) =>
      _$HousekeepingPricingDiscountFromJson(json);

  Map<String, dynamic> toJson() => _$HousekeepingPricingDiscountToJson(this);
}
