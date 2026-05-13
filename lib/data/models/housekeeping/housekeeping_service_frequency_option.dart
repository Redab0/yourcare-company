import 'package:json_annotation/json_annotation.dart';

part 'housekeeping_service_frequency_option.g.dart';

@JsonSerializable()
class HousekeepingServiceFrequencyOption {
  final String id;
  final String? titleAr;
  final String? titleEn;
  final int? numberOfWeeklyVisits;
  final int? serviceFrequencyCount;
  final double? discountPercentage;

  const HousekeepingServiceFrequencyOption({
    required this.id,
    this.titleAr,
    this.titleEn,
    this.numberOfWeeklyVisits,
    this.serviceFrequencyCount,
    this.discountPercentage,
  });

  factory HousekeepingServiceFrequencyOption.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$HousekeepingServiceFrequencyOptionFromJson(json);

  Map<String, dynamic> toJson() =>
      _$HousekeepingServiceFrequencyOptionToJson(this);
}
