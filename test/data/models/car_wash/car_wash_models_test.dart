import 'package:cleaning_service_driver/data/models/car_wash/car_wash_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CarWashPackagesConfiguration', () {
    test('parses standalone packages, assignments, duration, and area fees',
        () {
      final configuration = CarWashPackagesConfiguration.fromJson({
        'data': {
          'packages': [
            {
              '_id': 'package-1',
              'titleEn': 'Full wash',
              'titleAr': 'غسيل كامل',
              'descriptionEn': 'Inside and outside',
              'descriptionAr': 'داخلي وخارجي',
              'pricing': [
                {
                  'vehicleTypeId': 'vehicle-1',
                  'price': 10,
                },
                {
                  'vehicleTypeID': 'vehicle-2',
                  'price': 14,
                },
              ],
              'discountPercentage': 15,
              'duration': 45,
              'enabled': false,
              'workingHours': [
                {
                  'dayOfWeek': 1,
                  'startTime': '09:00',
                  'endTime': '12:00',
                },
              ],
            },
          ],
          'resolvedPricing': [
            {
              'vehicleTypeId': 'vehicle-1',
              'packages': [
                {
                  'packageId': 'package-1',
                  'titleEn': 'Full wash',
                  'titleAr': 'غسيل كامل',
                  'price': 10,
                },
              ],
            },
          ],
          'areaFees': [
            {
              'areaId': {'_id': 'area-1'},
              'fee': 2.5,
            },
          ],
        },
      });

      final package = configuration.packages.single;
      expect(package.id, 'package-1');
      expect(package.discountPercentage, 15);
      expect(package.duration, 45);
      expect(package.enabled, isFalse);
      expect(package.workingHours.single.dayOfWeek, 1);
      expect(package.priceForVehicle('vehicle-1'), 10);
      expect(package.priceForVehicle('vehicle-2'), 14);
      expect(configuration.assignments.single.vehicleTypeId, 'vehicle-1');
      expect(configuration.assignments.single.packageIds, ['package-1']);
      expect(configuration.areaFees.single.areaId, 'area-1');
      expect(configuration.areaFees.single.fee, 2.5);
    });

    test('keeps parsing the previous embedded pricing response', () {
      final configuration = CarWashPackagesConfiguration.fromJson([
        {
          'vehicleTypeId': 'vehicle-1',
          'packages': [
            {
              'packageId': 'package-1',
              'titleEn': 'External wash',
              'titleAr': 'غسيل خارجي',
              'price': 5,
            },
          ],
        },
      ]);

      expect(configuration.packages.single.id, 'package-1');
      expect(configuration.packages.single.priceForVehicle('vehicle-1'), 5);
      expect(configuration.assignments.single.packageIds, ['package-1']);
    });
  });

  test('package mutation matches the current create and update DTO', () {
    const request = CarWashPackageMutationRequest(
      titleEn: ' Full wash ',
      titleAr: ' غسيل كامل ',
      descriptionEn: ' Inside and outside ',
      descriptionAr: ' داخلي وخارجي ',
      pricing: [
        CarWashPackageVehiclePrice(
          vehicleTypeId: 'vehicle-1',
          price: 10,
        ),
        CarWashPackageVehiclePrice(
          vehicleTypeId: 'vehicle-2',
          price: 15,
        ),
      ],
      discountPercentage: 15,
      duration: 45,
      enabled: false,
      workingHours: [
        CarWashPackageWorkingHour(
          dayOfWeek: 1,
          startTime: '09:00',
          endTime: '12:00',
        ),
      ],
    );

    final json = request.toJson();
    final hour = (json['workingHours'] as List).single as Map<String, dynamic>;
    expect(json['titleEn'], 'Full wash');
    expect(json, isNot(contains('id')));
    expect(json, isNot(contains('_id')));
    expect(json, isNot(contains('packageId')));
    expect(json, isNot(contains('price')));
    expect(json['duration'], 45);
    expect(json['enabled'], isFalse);
    expect(json['pricing'], [
      {'vehicleTypeId': 'vehicle-1', 'price': 10.0},
      {'vehicleTypeId': 'vehicle-2', 'price': 15.0},
    ]);
    expect(hour.keys, containsAll(['dayOfWeek', 'startTime', 'endTime']));
    expect(hour, isNot(contains('maxWorkers')));
    expect(hour['dayOfWeek'], 1);
  });

  test('vehicle assignment sends package references without prices', () {
    final request = CarWashPricingAssignmentRequest(
      pricing: [
        CarWashVehiclePackageAssignment(
          vehicleTypeId: 'vehicle-1',
          packageIds: ['package-1', 'package-2'],
        ),
      ],
    );

    final json = request.toJson();
    final assignment = (json['pricing'] as List).single as Map<String, dynamic>;
    final packages =
        (assignment['packages'] as List).cast<Map<String, dynamic>>();
    expect(assignment['vehicleTypeId'], 'vehicle-1');
    expect(packages, [
      {'packageId': 'package-1'},
      {'packageId': 'package-2'},
    ]);
    expect(assignment, isNot(contains('packageIds')));
    expect(packages.every((package) => !package.containsKey('price')), isTrue);
  });

  test('package mutation preserves a zero vehicle price', () {
    const request = CarWashPackageMutationRequest(
      titleEn: 'Free wash',
      titleAr: 'غسيل مجاني',
      pricing: [
        CarWashPackageVehiclePrice(
          vehicleTypeId: 'vehicle-1',
          price: 0,
        ),
      ],
      duration: 30,
      enabled: true,
    );

    expect(request.toJson()['pricing'], [
      {'vehicleTypeId': 'vehicle-1', 'price': 0.0},
    ]);
    expect(request.toJson()['enabled'], isTrue);
  });
}
