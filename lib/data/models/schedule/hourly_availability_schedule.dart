import 'package:cleaning_service_driver/data/models/schedule/cleaner_availability.dart';

class HourlyAvailabilityCell {
  final bool isEnabled;
  final int totalCleaners;

  const HourlyAvailabilityCell({
    this.isEnabled = false,
    this.totalCleaners = 1,
  });

  HourlyAvailabilityCell copyWith({
    bool? isEnabled,
    int? totalCleaners,
  }) {
    return HourlyAvailabilityCell(
      isEnabled: isEnabled ?? this.isEnabled,
      totalCleaners: totalCleaners ?? this.totalCleaners,
    );
  }
}

class HourlyAvailabilitySchedule {
  static const int daysPerWeek = 7;
  static const int hoursPerDay = 24;

  static Map<int, List<HourlyAvailabilityCell>> emptyWeek() {
    return {
      for (var day = 0; day < daysPerWeek; day++)
        day: List.generate(
          hoursPerDay,
          (_) => const HourlyAvailabilityCell(),
        ),
    };
  }

  static Map<int, List<HourlyAvailabilityCell>> fromSlots(
    Iterable<CleanerAvailabilitySlot> slots,
  ) {
    final schedule = emptyWeek();
    final sortedSlots = slots.toList()
      ..sort((a, b) {
        final dayComparison = (a.dayOfWeek ?? -1).compareTo(b.dayOfWeek ?? -1);
        if (dayComparison != 0) return dayComparison;
        return (a.startHour ?? -1).compareTo(b.startHour ?? -1);
      });

    for (final slot in sortedSlots) {
      final day = slot.dayOfWeek;
      final start = slot.startHour;
      final end = slot.endHour;
      if (day == null ||
          day < 0 ||
          day >= daysPerWeek ||
          start == null ||
          end == null ||
          start < 0 ||
          start >= hoursPerDay ||
          end <= start ||
          end > hoursPerDay) {
        continue;
      }

      final totalCleaners = (slot.totalCleaners ?? 1).clamp(1, 999);
      for (var hour = start; hour < end; hour++) {
        schedule[day]![hour] = HourlyAvailabilityCell(
          isEnabled: true,
          totalCleaners: totalCleaners,
        );
      }
    }
    return schedule;
  }

  static List<HourlyAvailabilityCell> copyDay(
    List<HourlyAvailabilityCell> source,
  ) {
    assert(source.length == hoursPerDay);
    return source
        .map(
          (cell) => HourlyAvailabilityCell(
            isEnabled: cell.isEnabled,
            totalCleaners: cell.totalCleaners,
          ),
        )
        .toList(growable: false);
  }

  static List<CleanerAvailabilityRequest> requestsForDay({
    required int dayOfWeek,
    required List<HourlyAvailabilityCell> hours,
    required AvailabilityServiceType serviceType,
  }) {
    if (dayOfWeek < 0 || dayOfWeek >= daysPerWeek) {
      throw ArgumentError.value(dayOfWeek, 'dayOfWeek');
    }
    if (hours.length != hoursPerDay) {
      throw ArgumentError.value(hours.length, 'hours.length');
    }

    final requests = <CleanerAvailabilityRequest>[];
    var hour = 0;
    while (hour < hoursPerDay) {
      final cell = hours[hour];
      if (!cell.isEnabled) {
        hour++;
        continue;
      }

      final startHour = hour;
      final totalCleaners = cell.totalCleaners.clamp(1, 999);
      hour++;
      while (hour < hoursPerDay &&
          hours[hour].isEnabled &&
          hours[hour].totalCleaners.clamp(1, 999) == totalCleaners) {
        hour++;
      }

      requests.add(
        CleanerAvailabilityRequest(
          dayOfWeek: dayOfWeek,
          startHour: startHour,
          endHour: hour,
          totalCleaners: totalCleaners,
          serviceType: serviceType,
        ),
      );
    }
    return requests;
  }
}
