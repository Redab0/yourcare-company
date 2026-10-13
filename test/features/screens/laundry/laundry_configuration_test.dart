import 'dart:convert';
import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/core/themes/app_theme.dart';
import 'package:cleaning_service_driver/data/models/laundry/laundry_history.dart';
import 'package:cleaning_service_driver/data/models/laundry/laundry_models.dart';
import 'package:cleaning_service_driver/data/models/laundry/laundry_settings.dart';
import 'package:cleaning_service_driver/data/repositories/laundry/laundry_repository.dart';
import 'package:cleaning_service_driver/data/services/laundry/laundry_service.dart';
import 'package:cleaning_service_driver/features/bloc/laundry/laundry_settings_cubit.dart';
import 'package:cleaning_service_driver/features/screens/laundry/laundry_configuration_screen.dart';
import 'package:cleaning_service_driver/features/screens/laundry/laundry_catalog_screen.dart';
import 'package:cleaning_service_driver/features/screens/home/business_home_service.dart';
import 'package:cleaning_service_driver/features/screens/laundry/laundry_working_hours_screen.dart';
import 'package:cleaning_service_driver/features/screens/laundry/laundry_minimum_charge_card.dart';
import 'package:cleaning_service_driver/features/screens/laundry/laundry_invoice_editor.dart';
import 'package:cleaning_service_driver/features/screens/laundry/laundry_same_day_settings_card.dart';
import 'package:cleaning_service_driver/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _base = LaundrySettings(
    sameDayEnabled: false, sameDayCutoffTime: null, timeZone: 'Asia/Kuwait');

class _Repository extends LaundryRepository {
  LaundrySettings value = _base;
  final updates = <LaundrySettingsRequest>[];
  bool fail = false;
  int loads = 0;
  _Repository() : super(LaundryService(Dio()));
  @override
  Future<List<LaundryCatalogItem>> getCatalog() async => const [
        LaundryCatalogItem(
            id: 'shirt', nameEn: 'Shirt', nameAr: 'قميص', price: 2)
      ];
  @override
  Future<LaundrySettings> getSettings() async {
    loads++;
    return value;
  }

  @override
  Future<LaundrySettings> updateSettings(LaundrySettingsRequest body) async {
    updates.add(body);
    if (fail) throw Exception('Unavailable');
    return value = LaundrySettings(
        sameDayEnabled: body.sameDayEnabled ?? value.sameDayEnabled,
        sameDayCutoffTime: body.sameDayCutoffTime ?? value.sameDayCutoffTime,
        timeZone: value.timeZone,
        available: body.available ?? value.available,
        minimumCharge: body.minimumCharge ?? value.minimumCharge,
        workingHours: body.workingHours ?? value.workingHours);
  }
}

LaundryWorkingHour _slot(int day, String start, String end) =>
    LaundryWorkingHour(dayOfWeek: day, startTime: start, endTime: end);
Widget _app(Widget child, {String language = 'en'}) => MaterialApp(
    theme: AppTheme.light(),
    locale: Locale(language),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child);
void _user({bool edit = true, bool read = true}) =>
    FlutterSecureStorage.setMockInitialValues({
      'auth_user': jsonEncode({
        'role': 'manager',
        'permissions': [
          if (read) {'name': 'company_profile:read'},
          if (edit) {'name': 'company_profile:update'},
          {'name': 'business:read'}
        ]
      })
    });
void main() {
  test('working hours cap matches the backend 168-window limit', () {
    String time(int minutes) =>
        '${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}';
    final windows = List.generate(
        169,
        (index) => _slot(
            index ~/ 25, time(index % 25 * 30), time(index % 25 * 30 + 30)));
    expect(
        LaundrySettingsRequest(workingHours: windows.take(168).toList())
            .workingHours!
            .length,
        168);
    expect(() => LaundrySettingsRequest(workingHours: windows),
        throwsArgumentError);
  });

  test('legacy settings stay available with no minimum and unrestricted hours',
      () {
    final value = LaundrySettings.fromJson({
      'sameDayEnabled': false,
      'sameDayCutoffTime': null,
      'timeZone': 'Asia/Kuwait'
    });
    expect(value.available, isTrue);
    expect(value.minimumCharge, 0);
    expect(value.workingHours, isNull);
    expect(LaundrySettingsRequest(workingHours: []).toJson(),
        {'workingHours': []});
    expect(LaundrySettingsRequest(minimumCharge: 0).toJson(),
        {'minimumCharge': 0.0});
    expect(LaundrySettingsRequest(available: false).toJson(),
        {'available': false});
  });
  test(
      'multiple windows, adjacent boundaries and 24:00 roundtrip; reject overlaps and malformed hours',
      () {
    final hours = [
      _slot(0, '09:05', '12:00'),
      _slot(0, '12:00', '24:00'),
      _slot(6, '00:00', '08:00')
    ];
    final body = LaundrySettingsRequest(workingHours: hours).toJson();
    expect((body['workingHours'] as List).first,
        {'dayOfWeek': 0, 'startTime': '09:05', 'endTime': '12:00'});
    expect(
        LaundryWorkingHour.fromJson((body['workingHours'] as List).last)
            .endTime,
        '08:00');
    for (final invalid in [
      [_slot(0, '09:00', '09:00')],
      [_slot(0, '22:00', '06:00')],
      [_slot(0, '24:00', '24:00')],
      [_slot(-1, '09:00', '10:00')],
      [_slot(7, '09:00', '10:00')],
      [_slot(0, '9:00', '10:00')],
      [_slot(0, '09:00', '12:00'), _slot(0, '11:00', '13:00')],
    ]) {
      expect(() => LaundrySettingsRequest(workingHours: invalid),
          throwsArgumentError);
    }
  });
  test(
      'minimum accepts three decimals and rejects negative nonfinite or excessive precision',
      () {
    for (final amount in [0.0, 0.001, 7.125, 100000.0]) {
      expect(
          LaundrySettingsRequest(minimumCharge: amount).minimumCharge, amount);
    }
    for (final amount in [
      -1.0,
      double.nan,
      double.infinity,
      1.0001,
      100000.001
    ]) {
      expect(() => LaundrySettingsRequest(minimumCharge: amount),
          throwsArgumentError);
    }
  });
  test('availability PATCH preserves concurrent pricing and same-day settings',
      () async {
    final repo = _Repository();
    final cubit = LaundrySettingsCubit(repo);
    addTearDown(cubit.close);
    await cubit.load();
    repo.value = const LaundrySettings(
        sameDayEnabled: true,
        sameDayCutoffTime: '13:00',
        timeZone: 'Asia/Kuwait',
        minimumCharge: 10);
    cubit.change(available: false);
    await cubit.save();
    expect(repo.updates.single.toJson(), {'available': false});
    expect(cubit.state.saved!.minimumCharge, 10);
    expect(cubit.state.enabled, isTrue);
    expect(cubit.state.cutoff, '13:00');
  });
  test(
      'day close/open retains ranges, copy is independent, all-week closure stays explicit',
      () async {
    final repo = _Repository();
    final cubit = LaundrySettingsCubit(repo);
    addTearDown(cubit.close);
    await cubit.load();
    expect(cubit.state.effectiveHours.length, 7);
    expect(cubit.state.dirty, isFalse);
    cubit.setDay(0, [_slot(0, '09:00', '12:00'), _slot(0, '16:00', '20:00')]);
    cubit.toggleDay(0, false);
    cubit.toggleDay(0, true);
    expect(cubit.state.effectiveHours.where((s) => s.dayOfWeek == 0).length, 2);
    cubit.copyDay(0, [1, 2]);
    cubit.setDay(0, [_slot(0, '10:00', '11:00')]);
    expect(
        cubit.state.effectiveHours
            .where((s) => s.dayOfWeek == 1)
            .first
            .startTime,
        '09:00');
    for (var day = 0; day < 7; day++) {
      cubit.toggleDay(day, false);
    }
    await cubit.save();
    expect(repo.updates.single.toJson(), {'workingHours': []});
    expect(cubit.state.saved!.workingHours, isEmpty);
  });
  test(
      'invalid schedule never saves and failed valid save retains every draft field',
      () async {
    final repo = _Repository();
    final cubit = LaundrySettingsCubit(repo);
    addTearDown(cubit.close);
    await cubit.load();
    cubit.change(
        available: false,
        enabled: true,
        cutoff: '11:00',
        workingHours: [_slot(0, '10:00', '09:00')]);
    await cubit.save();
    expect(repo.updates, isEmpty);
    cubit.change(workingHours: [_slot(0, '10:00', '17:00')]);
    repo.fail = true;
    await cubit.save();
    expect(cubit.state.available, isFalse);
    expect(cubit.state.cutoff, '11:00');
    expect(cubit.state.workingHours!.single.endTime, '17:00');
    expect(cubit.state.dirty, isTrue);
    expect(cubit.state.saving, isFalse);
  });
  test('Arabic numerals parse and malformed minimum never saves', () async {
    final repo = _Repository();
    final cubit = LaundrySettingsCubit(repo);
    addTearDown(cubit.close);
    await cubit.load();
    for (final value in ['', '-1', 'NaN', '1.0001', '100001']) {
      cubit.change(minimumChargeText: value);
      await cubit.save();
    }
    expect(repo.updates, isEmpty);
    cubit.change(minimumChargeText: '٥٫٢٥٠');
    await cubit.save();
    expect(repo.updates.single.toJson(), {'minimumCharge': 5.25});
  });
  for (final language in ['en', 'ar']) {
    testWidgets(
        'configuration navigates to Working Hours and Pricing with reliable back in $language',
        (tester) async {
      _user();
      final router = GoRouter(initialLocation: '/laundry', routes: [
        GoRoute(path: '/', name: 'home', builder: (_, __) => const Scaffold()),
        GoRoute(
            path: '/laundry',
            name: 'laundry-main-screen',
            builder: (_, __) => const LaundryConfigurationScreen()),
        GoRoute(
            path: '/hours',
            name: 'laundry-working-hours-screen',
            builder: (_, __) =>
                const Scaffold(body: Text('hours destination'))),
        GoRoute(
            path: '/pricing',
            name: 'laundry-catalog-screen',
            builder: (_, __) =>
                const Scaffold(body: Text('pricing destination'))),
      ]);
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(
          routerConfig: router,
          theme: AppTheme.light(),
          locale: Locale(language),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales));
      await tester.pumpAndSettle();
      final l10n = AppLocalizations.of(
          tester.element(find.byType(LaundryConfigurationScreen)))!;
      expect(find.text(l10n.laundry_configuration), findsOneWidget);
      await tester.tap(find.text(l10n.laundry_working_hours));
      await tester.pumpAndSettle();
      expect(find.text('hours destination'), findsOneWidget);
      router.pop();
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.laundry_pricing));
      await tester.pumpAndSettle();
      expect(find.text('pricing destination'), findsOneWidget);
    });
    testWidgets(
        'working hours availability and same-day save together in $language',
        (tester) async {
      tester.view.physicalSize = const Size(600, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      _user();
      final repo = _Repository();
      sl.registerSingleton<LaundryRepository>(repo);
      addTearDown(() => sl.unregister<LaundryRepository>());
      await tester.pumpWidget(
          _app(const LaundryWorkingHoursScreen(), language: language));
      await tester.pumpAndSettle();
      expect(repo.loads, 1);
      await tester.tap(find.byKey(const ValueKey('laundry-available')));
      await tester.pumpAndSettle();
      final card = tester.widget<LaundrySameDaySettingsCard>(
          find.byType(LaundrySameDaySettingsCard));
      card.cubit.change(enabled: true, cutoff: '12:30');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('laundry-settings-save')));
      await tester.pumpAndSettle();
      expect(repo.updates.single.toJson(), {
        'available': false,
        'sameDayEnabled': true,
        'sameDayCutoffTime': '12:30'
      });
      expect(tester.takeException(), isNull);
    });
    testWidgets(
        'minimum control blocks invalid saves and only patches minimum in $language',
        (tester) async {
      final repo = _Repository();
      final cubit = LaundrySettingsCubit(repo);
      addTearDown(cubit.close);
      await cubit.load();
      await tester.pumpWidget(_app(
          Scaffold(
              body: SingleChildScrollView(
                  child:
                      LaundryMinimumChargeCard(cubit: cubit, canEdit: true))),
          language: language));
      await tester.enterText(find.byType(TextFormField), '0.0001');
      await tester.pumpAndSettle();
      expect(
          tester
              .widget<FilledButton>(
                  find.byKey(const ValueKey('laundry-minimum-save')))
              .onPressed,
          isNull);
      await tester.enterText(find.byType(TextFormField), '6.125');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('laundry-minimum-save')));
      await tester.pumpAndSettle();
      expect(repo.updates.single.toJson(), {'minimumCharge': 6.125});
      expect(tester.takeException(), isNull);
    });
    testWidgets(
        'invoice cannot send below item minimum even with fees but can save draft in $language',
        (tester) async {
      tester.view.physicalSize = const Size(600, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_app(
          const LaundryInvoiceEditor(
              minimumCharge: 5,
              catalog: [
                LaundryCatalogItem(
                    id: 'shirt', nameEn: 'Shirt', nameAr: 'قميص', price: 2)
              ],
              draft: LaundryInvoiceRequest(
                  send: false,
                  items: [
                    LaundryInvoiceSelection(itemId: 'shirt', quantity: 1)
                  ],
                  pickupFee: 10,
                  deliveryFee: 10)),
          language: language));
      await tester.pumpAndSettle();
      final l10n = AppLocalizations.of(
          tester.element(find.byType(LaundryInvoiceEditor)))!;
      FilledButton send() => tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, l10n.laundry_send_invoice));
      expect(send().onPressed, isNull);
      expect(
          tester
              .widget<OutlinedButton>(
                  find.widgetWithText(OutlinedButton, l10n.laundry_save_draft))
              .onPressed,
          isNotNull);
      await tester.enterText(find.byType(TextFormField).first, '3');
      await tester.pumpAndSettle();
      expect(send().onPressed, isNotNull);
      expect(tester.takeException(), isNull);
    });
  }
  test(
      'saved invoice uses order minimum snapshot with invoice override and ignores fees',
      () {
    LaundryDetails details({double? invoiceMinimum, double subtotal = 4}) =>
        LaundryDetails(
            pricingMode: 'pickup_invoice_later',
            status: 'picked_up',
            paymentStatus: 'unpaid',
            minimumCharge: 5,
            invoice: LaundryInvoice(
                status: 'draft',
                subtotal: subtotal,
                pickupFee: 10,
                total: subtotal + 10,
                minimumCharge: invoiceMinimum));
    expect(details().canSendInvoice, isFalse);
    expect(details(subtotal: 5).canSendInvoice, isTrue);
    expect(details(invoiceMinimum: 0).canSendInvoice, isTrue);
    expect(
        LaundryDetails.fromJson({
          'pricingMode': 'pickup_invoice_later',
          'status': 'picked_up',
          'paymentStatus': 'unpaid',
          'minimumCharge': 7.125
        }).minimumCharge,
        7.125);
  });
  testWidgets('read-only user sees settings without mutation controls',
      (tester) async {
    _user(edit: false);
    final repo = _Repository();
    sl.registerSingleton<LaundryRepository>(repo);
    addTearDown(() => sl.unregister<LaundryRepository>());
    await tester.pumpWidget(_app(const LaundryWorkingHoursScreen()));
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<SwitchListTile>(
                find.byKey(const ValueKey('laundry-available')))
            .onChanged,
        isNull);
    expect(find.byKey(const ValueKey('laundry-settings-save')), findsNothing);
    expect(find.byKey(const ValueKey('laundry-add-hours')), findsNothing);
  });
  test(
      'owner bypass still requires laundry service and unrelated permissions cannot show entry',
      () {
    final entry = BusinessHomeService.laundryConfiguration;
    expect(
        entry.canShow(
            permissions: [],
            companyServices: {CompanyProvidedService.laundry},
            isBusinessOwner: true),
        isTrue);
    expect(
        entry.canShow(
            permissions: [],
            companyServices: {CompanyProvidedService.houseCleaning},
            isBusinessOwner: true),
        isFalse);
    expect(
        entry.canShow(
            permissions: [], companyServices: {CompanyProvidedService.laundry}),
        isFalse);
  });
  testWidgets('pricing read permission cannot mutate item prices or minimum',
      (tester) async {
    _user(edit: false);
    final repo = _Repository();
    sl.registerSingleton<LaundryRepository>(repo);
    addTearDown(() => sl.unregister<LaundryRepository>());
    await tester.pumpWidget(_app(const LaundryCatalogScreen()));
    await tester.pumpAndSettle();
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(tester.widget<SwitchListTile>(find.byType(SwitchListTile)).onChanged,
        isNull);
    expect(find.byKey(const ValueKey('laundry-minimum-save')), findsNothing);
    expect(repo.updates, isEmpty);
  });
  testWidgets(
      '24:00 is an end option, weekly draft survives cancelled back, discard exits',
      (tester) async {
    tester.view.physicalSize = const Size(600, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    _user();
    final repo = _Repository();
    sl.registerSingleton<LaundryRepository>(repo);
    addTearDown(() => sl.unregister<LaundryRepository>());
    final router = GoRouter(initialLocation: '/', routes: [
      GoRoute(
          path: '/',
          name: 'laundry-main-screen',
          builder: (context, _) => Scaffold(
              body: TextButton(
                  onPressed: () => context.push('/hours'),
                  child: const Text('open hours')))),
      GoRoute(
          path: '/hours',
          builder: (_, __) => const LaundryWorkingHoursScreen()),
    ]);
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(
        routerConfig: router,
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales));
    await tester.tap(find.text('open hours'));
    await tester.pumpAndSettle();
    final fields = tester
        .widgetList<DropdownButtonFormField<String>>(
            find.byType(DropdownButtonFormField<String>))
        .toList();
    expect(fields.length, 2);
    // Dropdown's current value verifies midnight remains an explicit end boundary.
    expect(find.text('24:00'), findsWidgets);
    await tester.tap(find.byKey(const ValueKey('laundry-available')));
    await tester.pumpAndSettle();
    final card = tester.widget<LaundrySameDaySettingsCard>(
        find.byType(LaundrySameDaySettingsCard));
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(card.cubit.state.dirty, isTrue);
    expect(card.cubit.state.available, isFalse);
    expect(repo.updates, isEmpty);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(find.text('open hours'), findsOneWidget);
  });
  testWidgets(
      'invoice uses booked minimum even when company changes current configuration',
      (tester) async {
    tester.view.physicalSize = const Size(600, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repo = _Repository()
      ..value = const LaundrySettings(
          sameDayEnabled: false,
          sameDayCutoffTime: null,
          timeZone: 'Asia/Kuwait',
          minimumCharge: 100);
    sl.registerSingleton<LaundryRepository>(repo);
    addTearDown(() => sl.unregister<LaundryRepository>());
    await tester.pumpWidget(_app(const LaundryInvoiceEditor(
        minimumCharge: 5,
        catalog: [
          LaundryCatalogItem(
              id: 'shirt', nameEn: 'Shirt', nameAr: 'قميص', price: 5)
        ],
        draft: LaundryInvoiceRequest(
            send: false,
            items: [LaundryInvoiceSelection(itemId: 'shirt', quantity: 1)]))));
    await tester.pumpAndSettle();
    final l10n =
        AppLocalizations.of(tester.element(find.byType(LaundryInvoiceEditor)))!;
    expect(
        tester
            .widget<FilledButton>(
                find.widgetWithText(FilledButton, l10n.laundry_send_invoice))
            .onPressed,
        isNotNull);
    expect(repo.loads, 0,
        reason: 'Existing order minimum remains authoritative.');
  });
}
