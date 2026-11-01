import 'package:cleaning_service_driver/core/utils/kuwait_schedule.dart';
import 'package:cleaning_service_driver/data/models/schedule/cleaner_availability.dart';
import 'package:cleaning_service_driver/data/models/schedule/hourly_availability_schedule.dart';

/// Calendar dates are Kuwait wall-clock fields, never appointment instants.
class DatedAvailabilitySchedule {
  static const windowDays = 14;

  static DateTime today({DateTime? now}) {
    final kuwait = kuwaitWallTime((now ?? DateTime.now()).toUtc());
    return DateTime.utc(kuwait.year, kuwait.month, kuwait.day);
  }

  static List<String> dates(DateTime start) => List.generate(
        windowDays,
        (index) => dateKey(start.add(Duration(days: index))),
        growable: false,
      );

  static String dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  static Map<int, List<HourlyAvailabilityCell>> fromSlots(
    Iterable<CleanerAvailabilitySlot> slots,
    List<String> dates,
  ) {
    // Match full dates. Never expand a permanent weekday into a future date.
    return {
      for (var index = 0; index < dates.length; index++)
        index: HourlyAvailabilitySchedule.fromSlots(
          slots.where((slot) => slot.date == dates[index]).map(
                (slot) => CleanerAvailabilitySlot(
                  dayOfWeek: 0,
                  startHour: slot.startHour,
                  endHour: slot.endHour,
                  totalCleaners: slot.totalCleaners,
                ),
              ),
        )[0]!,
    };
  }

  static DatedAvailabilityDay requestForDate({
    required String date,
    required List<HourlyAvailabilityCell> hours,
  }) =>
      DatedAvailabilityDay(
        date: date,
        slots: HourlyAvailabilitySchedule.requestsForDay(
          dayOfWeek: 0,
          hours: hours,
          serviceType: AvailabilityServiceType.houseCleaning,
        )
            .map((slot) => DatedAvailabilityRange(
                  startHour: slot.startHour,
                  endHour: slot.endHour,
                  totalCleaners: slot.totalCleaners,
                ))
            .toList(growable: false),
      );
}
