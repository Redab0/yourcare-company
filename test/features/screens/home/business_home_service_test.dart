import 'package:cleaning_service_driver/features/screens/home/business_home_service.dart';
import 'package:cleaning_service_driver/core/utils/permissions_helper.dart';
import 'package:cleaning_service_driver/data/models/staff/permission_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final allPermissions = Permission.values
      .map(
        (permission) => PermissionModel(
          null,
          null,
          permission.value,
          null,
          null,
          null,
          null,
        ),
      )
      .toList(growable: false);

  test('furniture configuration uses its dedicated home icon', () {
    expect(
      BusinessHomeService.upholsteryConfiguration.imageAsset,
      'assets/images/ic_furniture_config.png',
    );
  });

  test('normalizes the company services returned with login', () {
    expect(
      CompanyProvidedService.parseAll([
        ' houseCleaning ',
        'CARWASH',
        'unknown',
      ]),
      {
        CompanyProvidedService.houseCleaning,
        CompanyProvidedService.carWash,
      },
    );
  });

  test('furniture-only companies do not see deep-cleaning auto bid', () {
    expect(
      BusinessHomeService.autoBidding.canShow(
        permissions: allPermissions,
        companyServices: const {
          CompanyProvidedService.upholsteryCleaning,
        },
      ),
      isFalse,
    );
  });

  test('new requests is only shown to deep-cleaning companies', () {
    for (final companyServices in [
      const {CompanyProvidedService.houseCleaning},
      const {CompanyProvidedService.upholsteryCleaning},
      const {CompanyProvidedService.carWash},
    ]) {
      expect(
        BusinessHomeService.cleaningRequests.canShow(
          permissions: allPermissions,
          companyServices: companyServices,
        ),
        isFalse,
      );
    }

    expect(
      BusinessHomeService.cleaningRequests.canShow(
        permissions: allPermissions,
        companyServices: const {CompanyProvidedService.deepCleaning},
      ),
      isTrue,
    );
  });

  test('housekeeping-only companies do not see unrelated configuration', () {
    const companyServices = {CompanyProvidedService.houseCleaning};

    expect(
      BusinessHomeService.houseKeepingConfiguration.canShow(
        permissions: allPermissions,
        companyServices: companyServices,
      ),
      isTrue,
    );
    expect(
      BusinessHomeService.carWashConfiguration.canShow(
        permissions: allPermissions,
        companyServices: companyServices,
      ),
      isFalse,
    );
    expect(
      BusinessHomeService.upholsteryConfiguration.canShow(
        permissions: allPermissions,
        companyServices: companyServices,
      ),
      isFalse,
    );
    expect(
      BusinessHomeService.autoBidding.canShow(
        permissions: allPermissions,
        companyServices: companyServices,
      ),
      isFalse,
    );
  });

  test('service-specific entries stay hidden until services are known', () {
    for (final service in [
      BusinessHomeService.houseKeepingConfiguration,
      BusinessHomeService.carWashConfiguration,
      BusinessHomeService.upholsteryConfiguration,
      BusinessHomeService.autoBidding,
      BusinessHomeService.cleaningRequests,
    ]) {
      expect(
        service.canShow(
          permissions: allPermissions,
          companyServices: null,
        ),
        isFalse,
      );
    }

    expect(
      BusinessHomeService.companyProfile.canShow(
        permissions: allPermissions,
        companyServices: null,
      ),
      isTrue,
    );
  });

  test('setup tour keeps setup first and excludes non-onboarding reports', () {
    final ordered = orderedBusinessSetupTourServices([
      BusinessHomeService.reports,
      BusinessHomeService.upcomingJobs,
      BusinessHomeService.carWashConfiguration,
      BusinessHomeService.companyProfile,
      BusinessHomeService.cleaningRequests,
    ]);

    expect(ordered, [
      BusinessHomeService.companyProfile,
      BusinessHomeService.carWashConfiguration,
      BusinessHomeService.cleaningRequests,
      BusinessHomeService.upcomingJobs,
    ]);
  });
}
