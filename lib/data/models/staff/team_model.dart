import 'package:json_annotation/json_annotation.dart';

part 'team_model.g.dart';

@JsonSerializable(checked: true)
class TeamModel {
  final String? id;
  final String? name;
  final Business? business;
  @JsonKey(name: "users")
  final List<TeamMember> users;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TeamModel(this.name, this.business, this.users, this.id, this.createdAt,
      this.updatedAt);

  factory TeamModel.fromJson(Map<String, dynamic> json) =>
      _$TeamModelFromJson(json);

  Map<String, dynamic> toJson() => _$TeamModelToJson(this);
}

@JsonSerializable(checked: true)
class Business {
  @JsonKey(name: "_id")
  final String id;
  final String name;

  Business(
    this.id,
    this.name,
  );

  factory Business.fromJson(Map<String, dynamic> json) =>
      _$BusinessFromJson(json);

  Map<String, dynamic> toJson() => _$BusinessToJson(this);
}

@JsonSerializable(checked: true)
class TeamMember {
  @JsonKey(name: "_id")
  final String? id;
  final String? role;
  final String? email;
  final String? image;

  TeamMember(
    this.id,
    this.role,
    this.email,
    this.image,
  );

  factory TeamMember.fromJson(Map<String, dynamic> json) =>
      _$TeamMemberFromJson(json);

  Map<String, dynamic> toJson() => _$TeamMemberToJson(this);
}
