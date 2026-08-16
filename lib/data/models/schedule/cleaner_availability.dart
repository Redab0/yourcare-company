import 'package:json_annotation/json_annotation.dart';

part 'cleaner_availability.g.dart';

@JsonEnum(valueField: 'apiValue')
enum AvailabilityServiceType {
  houseCleaning('houseCleaning'),
  carWash('carWash'),
  upholsteryCleaning('upholsteryCleaning');

  final String apiValue;

  const AvailabilityServiceType(this.apiValue);

  static AvailabilityServiceType? fromApiValue(String? value) {
    final normalized = value?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) return null;
    for (final serviceType in values) {
      if (serviceType.apiValue.toLowerCase() == normalized) {
        return serviceType;
      }
    }
    return null;
  }
}

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
  final String? serviceType;
  @JsonKey(readValue: _readEmployeeId)
  final String? employeeId;

  const CleanerAvailabilitySlot({
    this.id,
    this.dayOfWeek,
    this.startHour,
    this.endHour,
    this.totalCleaners,
    this.serviceType,
    this.employeeId,
  });

  factory CleanerAvailabilitySlot.fromJson(Map<String, dynamic> json) =>
      _$CleanerAvailabilitySlotFromJson(json);

  Map<String, dynamic> toJson() => _$CleanerAvailabilitySlotToJson(this);

  bool isForService(AvailabilityServiceType requestedService) {
    if (serviceType?.trim().toLowerCase() ==
        requestedService.apiValue.toLowerCase()) {
      return true;
    }
    // Records created before serviceType was introduced were housekeeping rows.
    return serviceType == null &&
        requestedService == AvailabilityServiceType.houseCleaning;
  }
}

@JsonSerializable()
class CleanerAvailabilityRequest {
  final int dayOfWeek;
  final int startHour;
  final int endHour;
  final int totalCleaners;
  final AvailabilityServiceType serviceType;

  const CleanerAvailabilityRequest({
    required this.dayOfWeek,
    required this.startHour,
    required this.endHour,
    required this.totalCleaners,
    required this.serviceType,
  });

  factory CleanerAvailabilityRequest.fromJson(Map<String, dynamic> json) =>
      _$CleanerAvailabilityRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CleanerAvailabilityRequestToJson(this);

  Map<String, dynamic> toUpdateJson() => {
        'dayOfWeek': dayOfWeek,
        'startHour': startHour,
        'endHour': endHour,
        'totalCleaners': totalCleaners,
      };
}
