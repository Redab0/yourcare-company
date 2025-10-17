import 'package:json_annotation/json_annotation.dart';

part 'complete_job_media_request.g.dart';

@JsonSerializable()
class CompleteJobRequest {
  final List<String>? files;
  const CompleteJobRequest({this.files});
  factory CompleteJobRequest.fromJson(Map<String, dynamic> json) =>
      _$CompleteJobRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CompleteJobRequestToJson(this);
}
