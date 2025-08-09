import 'package:json_annotation/json_annotation.dart';

part 'accept_house_keeping_model.g.dart';

@JsonSerializable()
class AcceptHouseKeepingModel {
  final List<String> cleanerIds;

  AcceptHouseKeepingModel({required this.cleanerIds});

  factory AcceptHouseKeepingModel.fromJson(Map<String, dynamic> json) =>
      _$AcceptHouseKeepingModelFromJson(json);

  Map<String, dynamic> toJson() => _$AcceptHouseKeepingModelToJson(this);
}
