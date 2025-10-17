import 'package:json_annotation/json_annotation.dart';

part 'assigned_worker.g.dart';

@JsonSerializable()
class AssignedWorker {
  final String id;
  final String? username;
  final String? image;
  final String? email;
  final String? phone;

  AssignedWorker(this.image, this.id, this.username, this.email, this.phone);

  factory AssignedWorker.fromJson(Map<String, dynamic> json) =>
      _$AssignedWorkerFromJson(json);

  Map<String, dynamic> toJson() => _$AssignedWorkerToJson(this);
}
