import 'package:json_annotation/json_annotation.dart';

part 'assigned_worker.g.dart';

@JsonSerializable()
class AssignedWorker {
  final String id;
  final String username;
  final String? image;

  AssignedWorker(this.image, this.id, this.username);

  factory AssignedWorker.fromJson(Map<String, dynamic> json) =>
      _$AssignedWorkerFromJson(json);

  Map<String, dynamic> toJson() => _$AssignedWorkerToJson(this);
}
