import 'package:json_annotation/json_annotation.dart';

part 'laundry_settings.g.dart';

@JsonSerializable(checked: true)
class LaundryWorkingHour {
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  const LaundryWorkingHour(
      {required this.dayOfWeek,
      required this.startTime,
      required this.endTime});
  factory LaundryWorkingHour.fromJson(Map<String, dynamic> json) =>
      _$LaundryWorkingHourFromJson(json);
  Map<String, dynamic> toJson() => _$LaundryWorkingHourToJson(this);
  LaundryWorkingHour forDay(int day) => LaundryWorkingHour(
      dayOfWeek: day, startTime: startTime, endTime: endTime);

  static int? minutes(String value, {bool end = false}) {
    if (end && value == '24:00') return 1440;
    if (!LaundrySettings.isValidCutoff(value)) return null;
    final parts = value.split(':').map(int.parse).toList();
    return parts[0] * 60 + parts[1];
  }

  static bool validSchedule(List<LaundryWorkingHour>? hours) {
    if (hours == null) return true;
    if (hours.length > 168) return false;
    for (final slot in hours) {
      final start = minutes(slot.startTime);
      final end = minutes(slot.endTime, end: true);
      if (slot.dayOfWeek < 0 ||
          slot.dayOfWeek > 6 ||
          start == null ||
          end == null ||
          start >= end) {
        return false;
      }
    }
    for (var day = 0; day < 7; day++) {
      final slots = hours.where((slot) => slot.dayOfWeek == day).toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime));
      for (var i = 1; i < slots.length; i++) {
        if (minutes(slots[i].startTime)! <
            minutes(slots[i - 1].endTime, end: true)!) {
          return false;
        }
      }
    }
    return true;
  }
}

@JsonSerializable(checked: true, explicitToJson: true)
class LaundrySettings {
  final bool sameDayEnabled;
  final String? sameDayCutoffTime;
  final String timeZone;
  final bool available;
  final double minimumCharge;

  /// Null is the legacy unrestricted schedule; [] explicitly closes all days.
  final List<LaundryWorkingHour>? workingHours;
  const LaundrySettings(
      {required this.sameDayEnabled,
      required this.sameDayCutoffTime,
      required this.timeZone,
      this.available = true,
      this.minimumCharge = 0,
      this.workingHours});
  factory LaundrySettings.fromJson(Map<String, dynamic> json) =>
      _$LaundrySettingsFromJson(json);
  Map<String, dynamic> toJson() => _$LaundrySettingsToJson(this);
  static bool isValidCutoff(String? value) =>
      value != null &&
      RegExp(r'^(?:[01][0-9]|2[0-3]):[0-5][0-9]$').hasMatch(value);
}

@JsonSerializable(
    createFactory: false, includeIfNull: false, explicitToJson: true)
class LaundrySettingsRequest {
  final bool? sameDayEnabled;
  final String? sameDayCutoffTime;
  final bool? available;
  final double? minimumCharge;
  final List<LaundryWorkingHour>? workingHours;
  LaundrySettingsRequest(
      {this.sameDayEnabled,
      this.sameDayCutoffTime,
      this.available,
      this.minimumCharge,
      this.workingHours}) {
    if ((sameDayEnabled == true || sameDayCutoffTime != null) &&
        !LaundrySettings.isValidCutoff(sameDayCutoffTime)) {
      throw ArgumentError.value(sameDayCutoffTime, 'sameDayCutoffTime',
          'A valid 24-hour HH:mm cutoff is required.');
    }
    if (minimumCharge != null &&
        (!minimumCharge!.isFinite ||
            minimumCharge! < 0 ||
            minimumCharge! > 100000 ||
            (minimumCharge! * 1000 - (minimumCharge! * 1000).round()).abs() >
                0.000001)) {
      throw ArgumentError.value(minimumCharge, 'minimumCharge',
          'Use a non-negative amount with at most three decimals.');
    }
    if (!LaundryWorkingHour.validSchedule(workingHours)) {
      throw ArgumentError.value(workingHours, 'workingHours',
          'Working hours must be valid and non-overlapping.');
    }
  }
  Map<String, dynamic> toJson() => _$LaundrySettingsRequestToJson(this);
}
