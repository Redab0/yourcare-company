import 'dart:async';
import 'dart:convert';

import 'package:cleaning_service_driver/core/api/api_environment.dart';
import 'package:cleaning_service_driver/core/utils/loading_controller.dart';
import 'package:cleaning_service_driver/data/models/upholstery/upholstery_pricing_models.dart';
import 'package:cleaning_service_driver/domain/usecases/upholstery/get_upholstery_availability_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/upholstery/get_upholstery_pricing_config_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/upholstery/update_upholstery_availability_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/upholstery/update_upholstery_pricing_usecase.dart';
import 'package:cleaning_service_driver/features/bloc/upholstery/upholstery_pricing_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/upholstery/upholstery_pricing_event.dart';
import 'package:cleaning_service_driver/features/bloc/upholstery/upholstery_pricing_state.dart';
import 'package:cleaning_service_driver/features/screens/upholstery/upholstery_pricing_screen.dart';
import 'package:cleaning_service_driver/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

typedef _Config = ({
  List<UpholsteryType> types,
  List<UpholsteryPricingGroup> pricing
});

const _types = [
  UpholsteryType(id: 'sofa', titleEn: 'Sofa', titleAr: 'كنب', sizes: [
    UpholsterySize(id: 'single', titleEn: 'Single seat', titleAr: 'مقعد واحد'),
  ]),
  UpholsteryType(
      id: 'new-type', titleEn: 'New furniture', titleAr: 'أثاث جديد'),
];
const _disabled = UpholsteryPricingGroup(
  upholsteryTypeId: 'sofa',
  isEnabled: false,
  packages: [
    UpholsteryPricingPackage(
      packageId: 'stable-id',
      titleEn: 'Single seat',
      titleAr: 'مقعد واحد',
      price: 1.125,
      discountPercentage: 12.5,
    )
  ],
);

void main() {
  test(
      'stored disabled group keeps values and IDs; new catalog group stays off',
      () async {
    final fixture = _Fixture();
    addTearDown(fixture.bloc.close);
    await fixture.load();
    final saved = fixture.bloc.state.pricing.first;
    expect(saved.isEnabled, isFalse);
    expect(saved.packages.single.packageId, 'stable-id');
    expect(saved.packages.single.sizeId, 'single');
    expect(saved.packages.single.price, 1.125);
    expect(saved.packages.single.discountPercentage, 12.5);
    expect(fixture.bloc.state.pricing.last.isEnabled, isFalse);
  });

  test('disabled prices save, reload, edit and re-enable without losing IDs',
      () async {
    final fixture = _Fixture();
    addTearDown(fixture.bloc.close);
    await fixture.load();
    fixture.bloc.add(const UpdateUpholsteryPackagePrice(
      upholsteryTypeId: 'sofa',
      packageRowKey: 'single',
      price: 2.375,
    ));
    await _flush();
    fixture.bloc.add(const SaveUpholsteryPricing());
    await _until(fixture.bloc, (state) => state.successMessage != null);
    expect(fixture.requests.single.pricing.first.enabled, isFalse);
    expect(fixture.requests.single.pricing, hasLength(2));
    expect(fixture.requests.single.pricing.first.packages.single.price, 2.375);
    await fixture.load();
    expect(fixture.bloc.state.pricing.first.isEnabled, isFalse);
    expect(fixture.bloc.state.pricing.first.packages.single.price, 2.375);
    expect(fixture.bloc.state.pricing.first.packages.single.packageId,
        'stable-id');
    fixture.bloc.add(
        const ToggleUpholsteryType(upholsteryTypeId: 'sofa', isEnabled: true));
    await _flush();
    fixture.bloc.add(const SaveUpholsteryPricing());
    await _until(fixture.bloc, (state) => state.successMessage != null);
    expect(fixture.requests.last.pricing.first.enabled, isTrue);
    expect(fixture.bloc.state.pricing.first.packages.single.price, 2.375);
    expect(fixture.bloc.state.pricing.first.packages.single.discountPercentage,
        12.5);
    fixture.bloc.add(
        const ToggleUpholsteryType(upholsteryTypeId: 'sofa', isEnabled: false));
    await _flush();
    fixture.bloc.add(const SaveUpholsteryPricing());
    await _until(fixture.bloc, (state) => state.successMessage != null);
    await fixture.load();
    expect(fixture.bloc.state.pricing.first.isEnabled, isFalse);
    expect(fixture.bloc.state.pricing.first.packages.single.packageId,
        'stable-id');
    expect(fixture.bloc.state.pricing.first.packages.single.price, 2.375);
  });

  for (final price in [-1.0, double.nan, double.infinity]) {
    test('invalid disabled price $price is blocked before API save', () async {
      final fixture = _Fixture();
      addTearDown(fixture.bloc.close);
      await fixture.load();
      fixture.bloc.add(UpdateUpholsteryPackagePrice(
        upholsteryTypeId: 'sofa',
        packageRowKey: 'single',
        price: price,
      ));
      await _flush();
      fixture.bloc.add(const SaveUpholsteryPricing());
      await _until(fixture.bloc, (state) => state.error != null);
      expect(fixture.requests, isEmpty);
      expect(fixture.bloc.state.pricing.first.isEnabled, isFalse);
    });
  }

  test('disabled custom package requires bilingual titles; zero price is valid',
      () async {
    final fixture = _Fixture();
    addTearDown(fixture.bloc.close);
    await fixture.load();
    fixture.bloc.add(const AddUpholsteryPackage(upholsteryTypeId: 'sofa'));
    await _flush();
    fixture.bloc.add(const SaveUpholsteryPricing());
    await _until(fixture.bloc, (state) => state.error != null);
    expect(fixture.requests, isEmpty);
    final key = fixture.bloc.state.pricing.first.packages.last.rowKey;
    fixture.bloc.add(UpdateUpholsteryPackageDetails(
      upholsteryTypeId: 'sofa',
      packageRowKey: key,
      titleEn: 'Extra',
      titleAr: 'إضافي',
    ));
    await _flush();
    fixture.bloc.add(const SaveUpholsteryPricing());
    await _until(fixture.bloc, (state) => state.successMessage != null);
    expect(fixture.requests.single.pricing.first.packages.last.price, 0);
    expect(fixture.requests.single.pricing.first.enabled, isFalse);
  });

  test(
      'availability is authoritative, serializes in-flight changes and preserves latest draft',
      () async {
    final pending = Completer<UpholsteryAvailability>();
    var patches = 0;
    final fixture = _Fixture(updateAvailability: (request) {
      patches++;
      return pending.future;
    });
    addTearDown(fixture.bloc.close);
    await fixture.load();
    fixture.bloc.add(const ChangeUpholsteryAvailability(false));
    await _until(fixture.bloc, (state) => state.isAvailabilitySaving);
    fixture.bloc.add(const ChangeUpholsteryAvailability(true));
    fixture.bloc.add(const UpdateUpholsteryPackagePrice(
      upholsteryTypeId: 'sofa',
      packageRowKey: 'single',
      price: 8.125,
    ));
    await _flush();
    expect(fixture.bloc.state.available, isTrue);
    expect(patches, 1);
    pending.complete(const UpholsteryAvailability(available: true));
    await _until(fixture.bloc, (state) => !state.isAvailabilitySaving);
    expect(fixture.bloc.state.available, isTrue);
    expect(fixture.bloc.state.pricing.first.packages.single.price, 8.125);
    expect(fixture.bloc.state.pricing.first.isEnabled, isFalse);
    expect(fixture.requests, isEmpty);
  });

  test('failed availability read and write preserve draft and confirmed status',
      () async {
    var reads = 0;
    final fixture = _Fixture(
      getAvailability: () async {
        if (reads++ == 0) throw Exception('Not deployed');
        return const UpholsteryAvailability(available: true);
      },
      updateAvailability: (_) async => throw Exception('Permission denied'),
    );
    addTearDown(fixture.bloc.close);
    await fixture.load(withAvailability: false);
    fixture.bloc.add(const LoadUpholsteryAvailability());
    await _until(fixture.bloc, (state) => state.availabilityError != null);
    expect(fixture.bloc.state.available, isNull);
    fixture.bloc.add(const ChangeUpholsteryAvailability(false));
    await _flush();
    expect(fixture.bloc.state.available, isNull);
    fixture.bloc.add(const LoadUpholsteryAvailability());
    await _until(fixture.bloc, (state) => state.available != null);
    expect(fixture.bloc.state.availabilityError, isNull);
    fixture.bloc.add(const ChangeUpholsteryAvailability(false));
    await _until(fixture.bloc, (state) => state.availabilityError != null);
    expect(fixture.bloc.state.available, isTrue);
    expect(fixture.bloc.state.pricing.first.packages.single.price, 1.125);
    expect(fixture.requests, isEmpty);
  });

  testWidgets(
      'old backend blocks pricing writes until availability retry confirms support',
      (tester) async {
    _user(role: 'business_owner');
    var reads = 0;
    final fixture = _Fixture(getAvailability: () async {
      if (reads++ == 0) {
        throw Exception('HTTP 404: missing availability resource');
      }
      return const UpholsteryAvailability(available: false);
    });
    addTearDown(fixture.bloc.close);
    await _pump(tester, fixture.bloc, 'en');
    await tester.pumpAndSettle();
    final save = find.byKey(const ValueKey('upholstery-save-pricing'));
    expect(tester.widget<FilledButton>(save).onPressed, isNull);
    await tester.tap(find.byKey(const ValueKey('upholstery-expand-sofa')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '9.125');
    await tester.pumpAndSettle();
    fixture.bloc.add(const SaveUpholsteryPricing());
    await tester.pumpAndSettle();
    expect(fixture.requests, isEmpty);
    expect(fixture.bloc.state.pricing.first.packages.single.price, 9.125);
    expect(fixture.bloc.state.pricing.first.isEnabled, isFalse);
    tester.testTextInput.hide();
    await tester.drag(find.byType(ListView), const Offset(0, 1500));
    await tester.pumpAndSettle();
    await tester
        .tap(find.byKey(const ValueKey('upholstery-availability-retry')));
    await tester.pumpAndSettle();
    expect(fixture.bloc.state.available, isFalse);
    expect(tester.widget<FilledButton>(save).onPressed, isNotNull);
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(fixture.requests.single.pricing.first.packages.single.price, 9.125);
    expect(fixture.requests.single.pricing.first.enabled, isFalse);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('initial pricing GET failure cannot save an empty replacement',
      (tester) async {
    _user(role: 'business_owner');
    final fixture =
        _Fixture(getConfig: () async => throw Exception('Pricing unavailable'));
    addTearDown(fixture.bloc.close);
    await _pump(tester, fixture.bloc, 'en');
    await tester.pumpAndSettle();
    expect(fixture.bloc.state.available, isTrue);
    expect(fixture.bloc.state.pricing, isEmpty);
    expect(
        tester
            .widget<FilledButton>(
                find.byKey(const ValueKey('upholstery-save-pricing')))
            .onPressed,
        isNull);
    fixture.bloc.add(const SaveUpholsteryPricing());
    await tester.pumpAndSettle();
    expect(fixture.requests, isEmpty);
    expect(
        find.byKey(const ValueKey('upholstery-availability')), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  test('a later pricing load error preserves the loaded draft', () async {
    var reads = 0;
    final fixture = _Fixture(getConfig: () async {
      if (reads++ > 0) throw Exception('Pricing refresh failed');
      return (types: _types, pricing: [_disabled]);
    });
    addTearDown(fixture.bloc.close);
    await fixture.load();
    fixture.bloc.add(const UpdateUpholsteryPackagePrice(
        upholsteryTypeId: 'sofa', packageRowKey: 'single', price: 8.875));
    await _flush();
    fixture.bloc.add(const LoadUpholsteryPricingConfig());
    await _until(fixture.bloc, (state) => state.error != null);
    expect(fixture.bloc.state.pricing.first.packages.single.price, 8.875);
    expect(fixture.bloc.state.pricing.first.isEnabled, isFalse);
    expect(fixture.requests, isEmpty);
  });

  for (final language in ['en', 'ar']) {
    for (final width in [320.0, 1200.0]) {
      testWidgets(
          'availability and editable disabled prices $language at $width',
          (tester) async {
        tester.view.physicalSize = Size(width, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        _user(role: 'business_owner');
        var reads = 0;
        final pending = Completer<UpholsteryAvailability>();
        final fixture = _Fixture(
          getAvailability: () async {
            if (reads++ == 0) throw Exception('Network failure');
            return const UpholsteryAvailability(available: true);
          },
          updateAvailability: (_) => pending.future,
        );
        addTearDown(fixture.bloc.close);
        await _pump(tester, fixture.bloc, language);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(_switch(tester).onChanged, isNull);
        await tester
            .tap(find.byKey(const ValueKey('upholstery-availability-retry')));
        await tester.pumpAndSettle();
        expect(_switch(tester).value, isTrue);
        expect(_switch(tester).onChanged, isNotNull);
        await tester.tap(find.byKey(const ValueKey('upholstery-expand-sofa')));
        await tester.pumpAndSettle();
        final price = find.byType(TextField).first;
        await tester.ensureVisible(price);
        await tester.enterText(price, '6.875');
        await tester.pumpAndSettle();
        tester.testTextInput.hide();
        await tester.drag(find.byType(ListView), const Offset(0, 1500));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('upholstery-availability')));
        await tester.pump();
        expect(find.byKey(const ValueKey('upholstery-availability-progress')),
            findsOneWidget);
        expect(_switch(tester).value, isTrue);
        expect(_switch(tester).onChanged, isNull);
        pending.complete(const UpholsteryAvailability(available: false));
        await tester.pumpAndSettle();
        expect(_switch(tester).value, isFalse);
        expect(fixture.bloc.state.pricing.first.isEnabled, isFalse);
        expect(fixture.bloc.state.pricing.first.packages.single.price, 6.875);
        final save = find.byKey(const ValueKey('upholstery-save-pricing'));
        await tester.tap(save);
        await tester.pumpAndSettle();
        expect(fixture.requests.single.pricing.first.enabled, isFalse);
        expect(
            fixture.requests.single.pricing.first.packages.single.price, 6.875);
        expect(fixture.bloc.state.pricing.first.packages.single.packageId,
            'stable-id');
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  }

  for (final entry in [
    (role: 'manager', permissions: <Map<String, String>>[], allowed: false),
    (
      role: 'manager',
      permissions: [
        {'name': 'business:update'}
      ],
      allowed: true
    ),
  ]) {
    testWidgets('manager availability permission ${entry.allowed}',
        (tester) async {
      _user(role: entry.role, permissions: entry.permissions);
      final fixture = _Fixture();
      addTearDown(fixture.bloc.close);
      await _pump(tester, fixture.bloc, 'en');
      await tester.pumpAndSettle();
      expect(_switch(tester).onChanged != null, entry.allowed);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}

Switch _switch(WidgetTester tester) => tester
    .widget<Switch>(find.byKey(const ValueKey('upholstery-availability')));

void _user(
    {required String role, List<Map<String, String>> permissions = const []}) {
  FlutterSecureStorage.setMockInitialValues({
    ApiEnvironment.storageKey('auth_user'):
        jsonEncode({'role': role, 'permissions': permissions}),
  });
}

Future<void> _pump(
        WidgetTester tester, UpholsteryPricingBloc bloc, String language) =>
    tester.pumpWidget(MaterialApp(
      locale: Locale(language),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider.value(
          value: bloc, child: const UpholsteryPricingScreen()),
    ));

Future<void> _flush() => Future<void>.delayed(Duration.zero);
Future<void> _until(UpholsteryPricingBloc bloc,
        bool Function(UpholsteryPricingState) predicate) =>
    bloc.stream.firstWhere(predicate).timeout(const Duration(seconds: 3));

class _Fixture {
  late final UpholsteryPricingBloc bloc;
  List<UpholsteryPricingGroup> persisted = [_disabled];
  final requests = <UpholsteryPricingRequest>[];

  _Fixture({
    Future<_Config> Function()? getConfig,
    Future<UpholsteryAvailability> Function()? getAvailability,
    Future<UpholsteryAvailability> Function(
            UpdateUpholsteryAvailabilityRequest)?
        updateAvailability,
  }) {
    bloc = UpholsteryPricingBloc(
      loader: _Loader(),
      getConfigUseCase: _GetConfig(
          getConfig ?? () async => (types: _types, pricing: persisted)),
      updatePricingUseCase: _UpdatePricing((request) async {
        requests.add(request);
        persisted = request.sourcePricing;
        return persisted;
      }),
      getAvailabilityUseCase: _GetAvailability(getAvailability ??
          () async => const UpholsteryAvailability(available: true)),
      updateAvailabilityUseCase: _UpdateAvailability(updateAvailability ??
          (request) async =>
              UpholsteryAvailability(available: request.available)),
    );
  }

  Future<void> load({bool withAvailability = true}) async {
    bloc.add(const LoadUpholsteryPricingConfig());
    await _until(bloc, (state) => !state.isLoading && state.pricing.isNotEmpty);
    if (withAvailability && bloc.state.available == null) {
      bloc.add(const LoadUpholsteryAvailability());
      await _until(
          bloc,
          (state) =>
              !state.isAvailabilityLoading &&
              (state.available != null || state.availabilityError != null));
    }
  }
}

class _GetConfig implements GetUpholsteryPricingConfigUseCase {
  final Future<_Config> Function() callback;
  _GetConfig(this.callback);
  @override
  Future<_Config> call() => callback();
}

class _UpdatePricing implements UpdateUpholsteryPricingUseCase {
  final Future<List<UpholsteryPricingGroup>> Function(UpholsteryPricingRequest)
      callback;
  _UpdatePricing(this.callback);
  @override
  Future<List<UpholsteryPricingGroup>> call(UpholsteryPricingRequest request) =>
      callback(request);
}

class _GetAvailability implements GetUpholsteryAvailabilityUseCase {
  final Future<UpholsteryAvailability> Function() callback;
  _GetAvailability(this.callback);
  @override
  Future<UpholsteryAvailability> call() => callback();
}

class _UpdateAvailability implements UpdateUpholsteryAvailabilityUseCase {
  final Future<UpholsteryAvailability> Function(
      UpdateUpholsteryAvailabilityRequest) callback;
  _UpdateAvailability(this.callback);
  @override
  Future<UpholsteryAvailability> call(
          UpdateUpholsteryAvailabilityRequest request) =>
      callback(request);
}

class _Loader implements LoadingController {
  @override
  void show([String tag = 'global']) {}
  @override
  void hide([String tag = 'global']) {}
}
