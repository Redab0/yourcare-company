import 'package:cleaning_service_driver/core/utils/request_status_enum.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_request_frequency_request.g.dart';

@JsonSerializable(checked: true)
class UpdateRequestFrequencyRequest {
  final String? frequencyDateId;
  final RequestStatus? status;

  UpdateRequestFrequencyRequest({
    required this.frequencyDateId,
    required this.status,
  });

  factory UpdateRequestFrequencyRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateRequestFrequencyRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateRequestFrequencyRequestToJson(this);
}
