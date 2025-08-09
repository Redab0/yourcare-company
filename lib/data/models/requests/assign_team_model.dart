import 'package:json_annotation/json_annotation.dart';

part 'assign_team_model.g.dart';

@JsonSerializable()
class AssignTeamModel {
  final String teamId;

  AssignTeamModel(this.teamId);

  factory AssignTeamModel.fromJson(Map<String, dynamic> json) =>
      _$AssignTeamModelFromJson(json);

  Map<String, dynamic> toJson() => _$AssignTeamModelToJson(this);
}
