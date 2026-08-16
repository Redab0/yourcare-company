import 'package:cleaning_service_driver/data/models/schedule/cleaner_availability.dart';
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
}
