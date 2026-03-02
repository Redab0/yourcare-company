import 'package:json_annotation/json_annotation.dart';

part 'cleaner_availability.g.dart';

String? _readEmployeeId(Map json, String key) {
  final direct = json['employeeId'];
  if (direct is String) return direct;
  final cleaner = json['cleanerId'];
  if (cleaner is String) return cleaner;
  return null;
}

@JsonSerializable(checked: true)
class CleanerAvailabilitySlot {
  final String? id;
  final int? dayOfWeek;
  final int? startHour;
  final int? endHour;
  final int? totalCleaners;
  @JsonKey(readValue: _readEmployeeId)
  final String? employeeId;

  const CleanerAvailabilitySlot({
    this.id,
    this.dayOfWeek,
    this.startHour,
    this.endHour,
    this.totalCleaners,
    this.employeeId,
  });

  factory CleanerAvailabilitySlot.fromJson(Map<String, dynamic> json) =>
      _$CleanerAvailabilitySlotFromJson(json);

  Map<String, dynamic> toJson() => _$CleanerAvailabilitySlotToJson(this);
}

@JsonSerializable()
class CleanerAvailabilityRequest {
  final int dayOfWeek;
  final int startHour;
  final int endHour;
  final int totalCleaners;

  const CleanerAvailabilityRequest({
    required this.dayOfWeek,
    required this.startHour,
    required this.endHour,
    required this.totalCleaners,
  });

  factory CleanerAvailabilityRequest.fromJson(Map<String, dynamic> json) =>
      _$CleanerAvailabilityRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CleanerAvailabilityRequestToJson(this);
}
