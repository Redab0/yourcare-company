import 'package:json_annotation/json_annotation.dart';

/// Service appointments use Kuwait (UTC+3), regardless of the device timezone.
/// Response values with an offset are instants; legacy offsetless values are
/// Kuwait wall-clock values. Keep instants in models and project only for UI.
const kuwaitUtcOffset = Duration(hours: 3);

DateTime parseKuwaitSchedule(String value) {
  final text = value.trim();
  final hasOffset = RegExp(r'(?:[zZ]|[+-]\d{2}:?\d{2})$').hasMatch(text);
  if (hasOffset) return DateTime.parse(text).toUtc();
  final withTime = text.contains(RegExp(r'[T ]')) ? text : '${text}T00:00:00';
  return DateTime.parse('$withTime+03:00').toUtc();
}

DateTime? tryParseKuwaitSchedule(Object? value) {
  if (value == null) return null;
  if (value is DateTime) return kuwaitInstant(value);
  try {
    return parseKuwaitSchedule(value.toString());
  } on FormatException {
    return null;
  }
}

/// A timezone-free clock projection for formatting and picker calculations.
/// Never serialize this projection as a UTC instant or project it twice.
DateTime kuwaitWallTime(DateTime value) =>
    wallClock(value.isUtc ? value.add(kuwaitUtcOffset) : value);

DateTime wallClock(DateTime value) => DateTime.utc(
      value.year,
      value.month,
      value.day,
      value.hour,
      value.minute,
      value.second,
      value.millisecond,
      value.microsecond,
    );

DateTime kuwaitNow() => kuwaitWallTime(DateTime.now().toUtc());

DateTime kuwaitInstant(DateTime value) =>
    value.isUtc ? value : wallClock(value).subtract(kuwaitUtcOffset);

/// Picker values are clock fields, not device-local instants. Keep their hour.
String kuwaitWallTimeToJson(DateTime value) =>
    wallClock(value).toIso8601String().replaceFirst(RegExp(r'Z$'), '');

class KuwaitScheduleConverter implements JsonConverter<DateTime, String> {
  const KuwaitScheduleConverter();

  @override
  DateTime fromJson(String value) => parseKuwaitSchedule(value);

  @override
  String toJson(DateTime value) => kuwaitInstant(value).toIso8601String();
}
