import 'package:json_annotation/json_annotation.dart';

part 'create_team_response.g.dart';

@JsonSerializable()
class CreateTeamResponse {
  final String id;
  final String name;
  final String business;
  final List<String> users;
  final DateTime createdAt;
  final DateTime updatedAt;

  CreateTeamResponse(this.name, this.business, this.users, this.id,
      this.createdAt, this.updatedAt);

  factory CreateTeamResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateTeamResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CreateTeamResponseToJson(this);
}
