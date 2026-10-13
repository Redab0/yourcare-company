import 'package:cleaning_service_driver/data/models/schedule/cleaner_availability.dart';
import 'package:cleaning_service_driver/data/models/schedule/hourly_availability_schedule.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('availability request includes the selected service type', () {
    const request = CleanerAvailabilityRequest(
      dayOfWeek: 1,
      startHour: 9,
      endHour: 17,
      totalCleaners: 3,
      serviceType: AvailabilityServiceType.carWash,
    );

    expect(request.toJson(), {
      'dayOfWeek': 1,
      'startHour': 9,
      'endHour': 17,
      'totalCleaners': 3,
      'serviceType': 'carWash',
    });
  });

  test('availability update request excludes the service type', () {
    const request = CleanerAvailabilityRequest(
      dayOfWeek: 1,
      startHour: 9,
      endHour: 17,
      totalCleaners: 3,
      serviceType: AvailabilityServiceType.carWash,
    );

    expect(request.toUpdateRequest().toJson(), {
      'dayOfWeek': 1,
      'startHour': 9,
      'endHour': 17,
      'totalCleaners': 3,
    });
  });

  test('availability response parses its service scope', () {
    final slot = CleanerAvailabilitySlot.fromJson({
      'id': 'slot-1',
      'dayOfWeek': 2,
      'startHour': 8,
      'endHour': 12,
      'totalCleaners': 2,
      'serviceType': 'upholsteryCleaning',
    });

    expect(slot.serviceType, 'upholsteryCleaning');
  });

  test('availability response keeps unsupported service rows parseable', () {
    final slot = CleanerAvailabilitySlot.fromJson({
      'id': 'deep-slot',
      'serviceType': 'deepCleaning',
    });

    expect(slot.serviceType, 'deepCleaning');
  });

  test('deep cleaning is not a supported shared availability type', () {
    expect(AvailabilityServiceType.fromApiValue('deepCleaning'), isNull);
    expect(
      AvailabilityServiceType.values.map((value) => value.apiValue),
      isNot(contains('deepCleaning')),
    );
  });

  test('service filtering never mixes availability between journeys', () {
    const carWashSlot = CleanerAvailabilitySlot(serviceType: 'carWash');
    const furnitureSlot = CleanerAvailabilitySlot(
      serviceType: 'upholsteryCleaning',
    );
    const legacyHousekeepingSlot = CleanerAvailabilitySlot();

    expect(carWashSlot.isForService(AvailabilityServiceType.carWash), isTrue);
    expect(
      carWashSlot.isForService(AvailabilityServiceType.houseCleaning),
      isFalse,
    );
    expect(
      furnitureSlot.isForService(AvailabilityServiceType.carWash),
      isFalse,
    );
    expect(
      legacyHousekeepingSlot.isForService(
        AvailabilityServiceType.houseCleaning,
      ),
      isTrue,
    );
    expect(
      legacyHousekeepingSlot.isForService(AvailabilityServiceType.carWash),
      isFalse,
    );
  });

  group('hourly availability mapping', () {
    test('expands API ranges into individual hours', () {
      final schedule = HourlyAvailabilitySchedule.fromSlots(const [
        CleanerAvailabilitySlot(
          dayOfWeek: 1,
          startHour: 8,
          endHour: 12,
          totalCleaners: 3,
        ),
      ]);

      expect(schedule[1]!.where((cell) => cell.isEnabled), hasLength(4));
      expect(schedule[1]![7].isEnabled, isFalse);
      expect(schedule[1]![8].totalCleaners, 3);
      expect(schedule[1]![11].isEnabled, isTrue);
      expect(schedule[1]![12].isEnabled, isFalse);
      expect(schedule[2]!.every((cell) => !cell.isEnabled), isTrue);
    });

    test('compresses adjacent hours with the same worker count', () {
      final hours = List.generate(
        HourlyAvailabilitySchedule.hoursPerDay,
        (hour) => HourlyAvailabilityCell(
          isEnabled: hour >= 8 && hour < 12,
          totalCleaners: 2,
        ),
      );

      final requests = HourlyAvailabilitySchedule.requestsForDay(
        dayOfWeek: 4,
        hours: hours,
        serviceType: AvailabilityServiceType.carWash,
      );

      expect(requests, hasLength(1));
      expect(requests.single.dayOfWeek, 4);
      expect(requests.single.startHour, 8);
      expect(requests.single.endHour, 12);
      expect(requests.single.totalCleaners, 2);
      expect(requests.single.serviceType, AvailabilityServiceType.carWash);
    });

    test('splits ranges at disabled hours and worker-count changes', () {
      final hours = List.generate(
        HourlyAvailabilitySchedule.hoursPerDay,
        (_) => const HourlyAvailabilityCell(),
      );
      hours[8] = const HourlyAvailabilityCell(
        isEnabled: true,
        totalCleaners: 2,
      );
      hours[9] = const HourlyAvailabilityCell(
        isEnabled: true,
        totalCleaners: 3,
      );
      hours[11] = const HourlyAvailabilityCell(
        isEnabled: true,
        totalCleaners: 3,
      );

      final requests = HourlyAvailabilitySchedule.requestsForDay(
        dayOfWeek: 0,
        hours: hours,
        serviceType: AvailabilityServiceType.houseCleaning,
      );

      expect(
        requests
            .map((request) =>
                '${request.startHour}-${request.endHour}-${request.totalCleaners}')
            .toList(),
        ['8-9-2', '9-10-3', '11-12-3'],
      );
    });

    test('returns no API ranges when a day is fully disabled', () {
      final schedule = HourlyAvailabilitySchedule.emptyWeek();

      expect(
        HourlyAvailabilitySchedule.requestsForDay(
          dayOfWeek: 6,
          hours: schedule[6]!,
          serviceType: AvailabilityServiceType.houseCleaning,
        ),
        isEmpty,
      );
    });

    test('copied days remain independently editable', () {
      final source = HourlyAvailabilitySchedule.emptyWeek()[0]!;
      source[8] = const HourlyAvailabilityCell(
        isEnabled: true,
        totalCleaners: 2,
      );

      final copied = HourlyAvailabilitySchedule.copyDay(source);
      copied[8] = copied[8].copyWith(totalCleaners: 5);

      expect(source[8].totalCleaners, 2);
      expect(copied[8].totalCleaners, 5);
    });
  });
}
