import 'package:json_annotation/json_annotation.dart';

part 'accept_house_keeping_model.g.dart';

@JsonSerializable(includeIfNull: false)
class AcceptHouseKeepingModel {
  final List<String> cleanerIds;
  final int? serviceFrequencyCount;
  final int? serviceIntervalDays;

  AcceptHouseKeepingModel(
      {required this.cleanerIds,
      this.serviceFrequencyCount,
      this.serviceIntervalDays});

  factory AcceptHouseKeepingModel.fromJson(Map<String, dynamic> json) =>
      _$AcceptHouseKeepingModelFromJson(json);

  Map<String, dynamic> toJson() => _$AcceptHouseKeepingModelToJson(this);
}
