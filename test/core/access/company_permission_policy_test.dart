import 'dart:async';
import 'package:cleaning_service_driver/core/access/company_permission_context.dart';
import 'package:cleaning_service_driver/core/access/company_permission_policy.dart';
import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:cleaning_service_driver/data/models/profile/business_profile_model.dart';
import 'package:cleaning_service_driver/data/models/profile/company_services.dart';
import 'package:cleaning_service_driver/data/models/staff/permission_model.dart';
import 'package:flutter_test/flutter_test.dart';

PermissionModel permission(String name, {String? resource}) => PermissionModel(
    name,
    null,
    name,
    null,
    null,
    resource ?? name.split(':').first,
    name.split(':').last);
BusinessProfileModel company(String id, List<String>? services) =>
    BusinessProfileModel.fromJson({'id': id, 'services': services});

CompanyServices servicesContext(String id, List<String> services) =>
    CompanyServices(businessId: id, services: services);

void main() {
  final catalog = {
    ...companyGeneralPermissionNames,
    ...companyServicePermissionNames.keys,
    'business:create',
    'business:delete',
    'requests:delete',
    'staff:delete',
    'teams:delete',
    'chat:update',
    'chat:delete',
    'housekeeping_pricing:delete',
    'auto_bid:delete',
    'email:create',
    'permissions:create',
    'categories:update',
    'car_wash:read',
    'available_requests_browse',
  }.map(permission).toList();
  final owner =
      User(id: 'actor', businessId: 'company', role: 'business_owner');
  Set<String?> options(User actor, List<String>? services) =>
      companyPermissionOptions(
              catalog: catalog, actor: actor, companyServices: services)
          .map((p) => p.name)
          .toSet();

  test('owner generic choices remain with empty or missing services', () {
    expect(options(owner, []), companyGeneralPermissionNames);
    expect(options(owner, null), companyGeneralPermissionNames);
  });
  test('deep cleaning never offers unrelated housekeeping or platform access',
      () {
    final names = options(owner, ['deepCleaning']);
    expect(
        names,
        containsAll(
            ['auto_bid:read', 'requests:create', 'cleaner_availability:read']));
    expect(names, isNot(contains('housekeeping_pricing:read')));
    for (final name in [
      'business:create',
      'business:delete',
      'requests:delete',
      'staff:delete',
      'teams:delete',
      'chat:update',
      'chat:delete',
      'auto_bid:delete',
      'permissions:create',
      'car_wash:read'
    ]) {
      expect(names, isNot(contains(name)), reason: name);
    }
  });
  test('specialized choices match every offered-service family', () {
    expect(options(owner, ['houseCleaning']),
        contains('housekeeping_pricing:update'));
    expect(options(owner, ['houseCleaning']), isNot(contains('auto_bid:read')));
    expect(options(owner, ['upholsteryCleaning']), contains('requests:create'));
    expect(options(owner, ['upholsteryCleaning']),
        isNot(contains('auto_bid:read')));
    expect(
        options(owner, ['carWash']), contains('cleaner_availability:create'));
    expect(options(owner, ['laundry']), companyGeneralPermissionNames);
  });
  test('manager choices are capped at its own eligible named grants', () {
    final manager = User(role: 'manager', permissions: [
      permission('business:create'),
      permission('staff:read'),
      permission('auto_bid:read'),
      permission('housekeeping_pricing:read')
    ]);
    expect(options(manager, ['deepCleaning']), {'staff:read', 'auto_bid:read'});
  });
  test('workers cannot delegate and administrators retain the full catalog',
      () {
    expect(
        options(User(role: 'worker', permissions: catalog), ['deepCleaning']),
        isEmpty);
    expect(
        options(User(role: 'admin'), []), catalog.map((p) => p.name).toSet());
  });
  test('mismatched metadata cannot disguise a platform name', () {
    expect(
        companyPermissionOptions(
            catalog: [permission('business:create', resource: 'staff')],
            actor: owner,
            companyServices: ['deepCleaning']),
        isEmpty);
  });

  CompanyPermissionContextLoader loader(
          {required int Function() generation,
          Future<User> Function(String)? fetchUser,
          Future<CompanyServices> Function()? fetchCompany,
          Future<List<PermissionModel>> Function()? fetchCatalog}) =>
      CompanyPermissionContextLoader(
          generation: generation,
          readUser: () async => owner,
          fetchUser: fetchUser ?? (_) async => owner,
          fetchCompany: fetchCompany ??
              () async => servicesContext('company', ['deepCleaning']),
          fetchCatalog: fetchCatalog ?? () async => catalog);

  test('fresh company data wins over stale actor service claims', () async {
    final context = await loader(
        generation: () => 0,
        fetchUser: (_) async => owner.copyWith(services: ['carWash'])).load();
    expect(context.services, ['deepCleaning']);
    expect(context.options.map((p) => p.name), contains('auto_bid:read'));
    expect(context.options.map((p) => p.name),
        isNot(contains('housekeeping_pricing:read')));
  });
  test('company read failure keeps generic options and exposes retry state',
      () async {
    final context = await loader(
            generation: () => 0,
            fetchCompany: () async => throw StateError('synthetic unavailable'))
        .load();
    expect(context.servicesUnavailable, isTrue);
    expect(context.options.map((p) => p.name).toSet(),
        companyGeneralPermissionNames);
  });
  test('a different company cannot supply specialized context', () async {
    final context = await loader(
        generation: () => 0,
        fetchCompany: () async =>
            servicesContext('other-company', ['houseCleaning'])).load();
    expect(context.servicesUnavailable, isTrue);
    expect(context.options.map((p) => p.name).toSet(),
        companyGeneralPermissionNames);
  });
  test('account switch while resolving actor never starts subsequent reads',
      () async {
    var generation = 0;
    var catalogCalls = 0;
    final pending = Completer<User>();
    final operation = loader(
        generation: () => generation,
        fetchUser: (_) => pending.future,
        fetchCatalog: () async {
          catalogCalls++;
          return catalog;
        }).load();
    await Future<void>.delayed(Duration.zero);
    generation++;
    pending.complete(owner);
    await expectLater(operation, throwsStateError);
    expect(catalogCalls, 0);
  });
  test('account switch during company read cannot publish old options',
      () async {
    var generation = 0;
    final pending = Completer<CompanyServices>();
    final operation =
        loader(generation: () => generation, fetchCompany: () => pending.future)
            .load();
    await Future<void>.delayed(Duration.zero);
    generation++;
    pending.complete(servicesContext('company', ['deepCleaning']));
    await expectLater(operation, throwsStateError);
  });
  test('wrong returned current-user identity fails before company reads',
      () async {
    await expectLater(
        loader(
            generation: () => 0,
            fetchUser: (_) async =>
                User(id: 'other', role: 'business_owner')).load(),
        throwsStateError);
  });
}
