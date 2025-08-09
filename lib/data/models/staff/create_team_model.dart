import 'package:json_annotation/json_annotation.dart';

part 'create_team_model.g.dart';

@JsonSerializable()
class CreateTeamModel {
  final String name;
  final String business;
  final List<String> users;

  CreateTeamModel(this.name, this.business, this.users);

  factory CreateTeamModel.fromJson(Map<String, dynamic> json) =>
      _$CreateTeamModelFromJson(json);

  Map<String, dynamic> toJson() => _$CreateTeamModelToJson(this);
}
