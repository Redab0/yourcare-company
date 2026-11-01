import 'package:cleaning_service_driver/data/models/schedule/cleaner_availability.dart';
import 'package:cleaning_service_driver/data/models/schedule/dated_availability_schedule.dart';
import 'package:cleaning_service_driver/data/models/schedule/hourly_availability_schedule.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('window starts today in Kuwait and includes exactly 14 calendar dates',
      () {
    final beforeMidnight = DateTime.utc(2026, 12, 25, 20, 59);
    final afterMidnight = DateTime.utc(2026, 12, 25, 21);
    expect(
      DatedAvailabilitySchedule.dateKey(
        DatedAvailabilitySchedule.today(now: beforeMidnight),
      ),
      '2026-12-25',
    );
    final dates = DatedAvailabilitySchedule.dates(
      DatedAvailabilitySchedule.today(now: afterMidnight),
    );
    expect(dates, hasLength(14));
    expect(dates.first, '2026-12-26');
    expect(dates.last, '2027-01-08');
    expect(dates.toSet(), hasLength(14));
  });

  test('same weekdays in separate weeks never share capacity', () {
    final dates = DatedAvailabilitySchedule.dates(DateTime.utc(2026, 10, 17));
    final schedule = DatedAvailabilitySchedule.fromSlots(const [
      CleanerAvailabilitySlot(
        date: '2026-10-17',
        dayOfWeek: 6,
        startHour: 0,
        endHour: 2,
        totalCleaners: 2,
      ),
      CleanerAvailabilitySlot(
        date: '2026-10-24',
        dayOfWeek: 6,
        startHour: 0,
        endHour: 1,
        totalCleaners: 5,
      ),
      // Legacy weekly data must not supply unconfigured dates.
      CleanerAvailabilitySlot(dayOfWeek: 0, startHour: 0, endHour: 24),
      CleanerAvailabilitySlot(
          date: '2026-10-31', dayOfWeek: 6, startHour: 0, endHour: 24),
    ], dates);
    expect(schedule, hasLength(14));
    expect(schedule[0]![0].totalCleaners, 2);
    expect(schedule[7]![0].totalCleaners, 5);
    expect(schedule[7]![1].isEnabled, isFalse);
    expect(schedule[1]!.every((hour) => !hour.isEnabled), isTrue);
    expect(schedule[13]!.every((hour) => !hour.isEnabled), isTrue);

    schedule[7] = HourlyAvailabilitySchedule.copyDay(schedule[0]!);
    schedule[7]![0] = schedule[7]![0].copyWith(totalCleaners: 9);
    expect(schedule[0]![0].totalCleaners, 2);
  });

  test('atomic body includes only dates and ranges, including closed dates',
      () {
    final hours = HourlyAvailabilitySchedule.emptyWeek()[0]!;
    hours[8] = const HourlyAvailabilityCell(isEnabled: true, totalCleaners: 3);
    hours[9] = const HourlyAvailabilityCell(isEnabled: true, totalCleaners: 3);
    hours[10] = const HourlyAvailabilityCell(isEnabled: true, totalCleaners: 4);
    final request = DatedAvailabilityRequest(
      serviceType: AvailabilityServiceType.carWash,
      days: [
        DatedAvailabilitySchedule.requestForDate(
            date: '2026-10-17', hours: hours),
        DatedAvailabilitySchedule.requestForDate(
          date: '2026-10-24',
          hours: HourlyAvailabilitySchedule.emptyWeek()[0]!,
        ),
      ],
    );
    expect(request.toJson(), {
      'serviceType': 'carWash',
      'days': [
        {
          'date': '2026-10-17',
          'slots': [
            {'startHour': 8, 'endHour': 10, 'totalCleaners': 3},
            {'startHour': 10, 'endHour': 11, 'totalCleaners': 4},
          ],
        },
        {'date': '2026-10-24', 'slots': []},
      ],
    });
  });

  test('response date remains a calendar key and furniture stays weekly', () {
    final slot = CleanerAvailabilitySlot.fromJson({
      'date': '2026-10-17',
      'serviceType': 'houseCleaning',
      'dayOfWeek': 6,
    });
    expect(slot.date, '2026-10-17');
    expect(AvailabilityServiceType.houseCleaning.usesDatedAvailability, isTrue);
    expect(AvailabilityServiceType.carWash.usesDatedAvailability, isTrue);
    expect(
      AvailabilityServiceType.upholsteryCleaning.usesDatedAvailability,
      isFalse,
    );
  });
}
