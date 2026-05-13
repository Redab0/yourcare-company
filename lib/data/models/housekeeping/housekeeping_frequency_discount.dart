import 'package:json_annotation/json_annotation.dart';

part 'housekeeping_frequency_discount.g.dart';

@JsonSerializable()
class HousekeepingFrequencyDiscount {
  final String frequencyOptionId;
  final double discountPercentage;

  const HousekeepingFrequencyDiscount({
    required this.frequencyOptionId,
    required this.discountPercentage,
  });

  factory HousekeepingFrequencyDiscount.fromJson(Map<String, dynamic> json) =>
      _$HousekeepingFrequencyDiscountFromJson(json);

  Map<String, dynamic> toJson() => _$HousekeepingFrequencyDiscountToJson(this);
}
