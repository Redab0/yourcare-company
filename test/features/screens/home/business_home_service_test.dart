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

  test(
      'laundry companies see their catalog and jobs without deep-cleaning bids',
      () {
    const services = {CompanyProvidedService.laundry};
    expect(
        BusinessHomeService.laundryConfiguration
            .canShow(permissions: allPermissions, companyServices: services),
        isTrue);
    expect(
        BusinessHomeService.upcomingJobs
            .canShow(permissions: allPermissions, companyServices: services),
        isTrue);
    expect(
        BusinessHomeService.cleaningRequests
            .canShow(permissions: allPermissions, companyServices: services),
        isFalse);
    expect(
        BusinessHomeService.autoBidding
            .canShow(permissions: allPermissions, companyServices: services),
        isFalse);
    expect(
        orderedBusinessSetupTourServices([
          BusinessHomeService.upcomingJobs,
          BusinessHomeService.laundryConfiguration
        ]),
        [
          BusinessHomeService.laundryConfiguration,
          BusinessHomeService.upcomingJobs
        ]);
    expect(
        BusinessHomeService.laundryConfiguration
            .canShow(permissions: [], companyServices: services),
        isFalse);
  });

  test('furniture configuration uses its dedicated home icon', () {
    expect(
      BusinessHomeService.upholsteryConfiguration.imageAsset,
      'assets/images/business_upholstery_configuration.png',
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

  test('quote requests remain available to deep-cleaning and furniture', () {
    for (final companyServices in [
      const {CompanyProvidedService.houseCleaning},
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
    expect(
      BusinessHomeService.cleaningRequests.canShow(
        permissions: allPermissions,
        companyServices: const {CompanyProvidedService.upholsteryCleaning},
      ),
      isTrue,
    );
  });

  test('owners use server-authorized menus without seeded grants', () {
    for (final service in BusinessHomeService.values
        .where((service) => service != BusinessHomeService.cleaningRequests)) {
      expect(
          service.canShow(
              permissions: const [],
              companyServices: CompanyProvidedService.values.toSet(),
              isBusinessOwner: true,
              role: 'business_owner'),
          isTrue,
          reason: service.name);
    }
    for (final services in [null, <CompanyProvidedService>{}]) {
      expect(
          BusinessHomeService.upcomingJobs.canShow(
              permissions: const [],
              companyServices: services,
              isBusinessOwner: true),
          isTrue);
    }
  });

  test('quote opportunities require their actual grant even for owners', () {
    const services = {CompanyProvidedService.deepCleaning};
    expect(
        BusinessHomeService.cleaningRequests.canShow(
            permissions: const [],
            companyServices: services,
            isBusinessOwner: true),
        isFalse);
    expect(
        BusinessHomeService.cleaningRequests.canShow(
            permissions: allPermissions,
            companyServices: services,
            isBusinessOwner: true),
        isTrue);
    expect(
        BusinessHomeService.cleaningRequests.canShow(
            permissions: allPermissions
                .where((p) => p.name == 'available_requests_browse')
                .toList(),
            companyServices: services,
            isBusinessOwner: true),
        isFalse);
  });

  test('managers are not granted menus by owner fallbacks', () {
    for (final service in BusinessHomeService.values
        .where((service) => service != BusinessHomeService.documentsCenter)) {
      expect(
          service.canShow(
              permissions: const [],
              role: 'manager',
              companyServices: CompanyProvidedService.values.toSet()),
          isFalse,
          reason: service.name);
    }
  });

  test('existing company jobs do not depend on offered services', () {
    for (final services in [null, <CompanyProvidedService>{}]) {
      expect(
          BusinessHomeService.upcomingJobs
              .canShow(permissions: allPermissions, companyServices: services),
          isTrue);
    }
  });

  test('price denial still hides financial menus for a cached owner', () {
    for (final service in [
      BusinessHomeService.reports,
      BusinessHomeService.autoBidding,
      BusinessHomeService.documentsCenter
    ]) {
      expect(
          service.canShow(
              permissions: allPermissions,
              companyServices: CompanyProvidedService.values.toSet(),
              isBusinessOwner: true,
              role: 'business_owner',
              canSeePrices: false),
          isFalse);
    }
  });

  test('staff entry requires an actual staff, team or calendar capability', () {
    final definitionOnly = allPermissions
        .where((p) => [
              'permissions:read',
              'permissions:update',
              'requests:read'
            ].contains(p.name))
        .toList();
    expect(
        BusinessHomeService.staffManagement
            .canShow(permissions: definitionOnly, companyServices: null),
        isFalse);
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
