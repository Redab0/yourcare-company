import 'dart:async';
import 'dart:convert';

import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/data/models/laundry/laundry_models.dart';
import 'package:cleaning_service_driver/features/screens/laundry/laundry_catalog_screen.dart';
import 'package:cleaning_service_driver/features/screens/laundry/laundry_minimum_charge_card.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:cleaning_service_driver/core/themes/app_theme.dart';
import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:cleaning_service_driver/data/models/laundry/laundry_settings.dart';
import 'package:cleaning_service_driver/data/models/staff/permission_model.dart';
import 'package:cleaning_service_driver/data/repositories/laundry/laundry_repository.dart';
import 'package:cleaning_service_driver/data/services/laundry/laundry_service.dart';
import 'package:cleaning_service_driver/features/bloc/laundry/laundry_settings_cubit.dart';
import 'package:cleaning_service_driver/features/screens/laundry/laundry_same_day_settings_card.dart';
import 'package:cleaning_service_driver/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _disabled = LaundrySettings(
    sameDayEnabled: false, sameDayCutoffTime: null, timeZone: 'Asia/Kuwait');

class _Repository extends LaundryRepository {
  LaundrySettings value;
  bool loadFails = false;
  bool saveFails = false;
  Completer<LaundrySettings>? saveResult;
  final updates = <LaundrySettingsRequest>[];
  int settingsLoads = 0;
  int catalogLoads = 0;

  _Repository([this.value = _disabled]) : super(LaundryService(Dio()));
  @override
  Future<List<LaundryCatalogItem>> getCatalog() async {
    catalogLoads++;
    return [];
  }

  @override
  Future<LaundrySettings> getSettings() async {
    settingsLoads++;
    if (loadFails) throw Exception('Unavailable');
    return value;
  }

  @override
  Future<LaundrySettings> updateSettings(LaundrySettingsRequest body) async {
    updates.add(body);
    if (saveFails) throw Exception('Unavailable');
    if (saveResult != null) return saveResult!.future;
    return value = LaundrySettings(
        sameDayEnabled: body.sameDayEnabled ?? value.sameDayEnabled,
        sameDayCutoffTime: body.sameDayCutoffTime ?? value.sameDayCutoffTime,
        timeZone: 'Asia/Kuwait',
        minimumCharge: body.minimumCharge ?? value.minimumCharge);
  }
}

Widget _app(LaundrySettingsCubit cubit,
        {String language = 'en', bool canEdit = true}) =>
    MaterialApp(
      theme: AppTheme.light(),
      locale: Locale(language),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
          body: SingleChildScrollView(
              child:
                  LaundrySameDaySettingsCard(cubit: cubit, canEdit: canEdit))),
    );

void main() {
  test('cutoff accepts only zero-padded 24-hour boundaries', () {
    for (final value in ['00:00', '09:05', '12:00', '23:59']) {
      expect(LaundrySettings.isValidCutoff(value), isTrue);
      expect(
          LaundrySettingsRequest(sameDayEnabled: true, sameDayCutoffTime: value)
              .toJson(),
          {'sameDayEnabled': true, 'sameDayCutoffTime': value});
    }
    for (final value in [
      null,
      '',
      '9:00',
      '12:5',
      '24:00',
      '23:60',
      '12:00:00',
      ' 12:00',
      '12:00\n',
      '١٢:٠٠'
    ]) {
      expect(LaundrySettings.isValidCutoff(value), isFalse, reason: '$value');
      expect(
          () => LaundrySettingsRequest(
              sameDayEnabled: true, sameDayCutoffTime: value),
          throwsArgumentError);
    }
    expect(LaundrySettingsRequest(sameDayEnabled: false).toJson(),
        {'sameDayEnabled': false});
  });

  test(
      'owner access matches backend bypass and managers need profile permissions',
      () {
    User user(String role, List<String> names) => User(
        role: role,
        permissions: names
            .map((name) => PermissionModel.fromJson({'name': name}))
            .toList());
    expect(canAccessLaundrySettings(user('business_owner', [])), isTrue);
    expect(canAccessLaundrySettings(user('business_owner', []), edit: true),
        isTrue);
    for (final role in ['manager']) {
      final reader = user(role, ['company_profile:read']);
      expect(canAccessLaundrySettings(reader), isTrue);
      expect(canAccessLaundrySettings(reader, edit: true), isFalse);
      final editor =
          user(role, ['company_profile:read', 'company_profile:update']);
      expect(canAccessLaundrySettings(editor, edit: true), isTrue);
      expect(canAccessLaundrySettings(user(role, ['business:read'])), isFalse);
    }
    for (final role in ['driver', 'worker', 'admin']) {
      expect(
          canAccessLaundrySettings(
              user(role, ['company_profile:read', 'company_profile:update']),
              edit: true),
          isFalse);
    }
    expect(canAccessLaundrySettings(null), isFalse);
  });

  test('settings use wrapped typed GET and PATCH with no timezone mutation',
      () async {
    final dio = Dio();
    addTearDown(dio.close);
    final calls = <String>[];
    dio.interceptors.add(InterceptorsWrapper(onRequest: (request, handler) {
      calls.add(request.method);
      expect(request.path, '/business/my-business/laundry-settings');
      if (request.method == 'PATCH') {
        expect(request.data,
            {'sameDayEnabled': true, 'sameDayCutoffTime': '09:05'});
      } else {
        expect(request.data, isNull);
      }
      handler.resolve(Response(requestOptions: request, data: {
        'success': true,
        'message': 'Success',
        'data': {
          'locale': 'en',
          'data': {
            'sameDayEnabled': request.method == 'PATCH',
            'sameDayCutoffTime': request.method == 'PATCH' ? '09:05' : null,
            'timeZone': 'Asia/Kuwait',
          }
        }
      }));
    }));
    final repo = LaundryRepository(LaundryService(dio));
    expect((await repo.getSettings()).sameDayCutoffTime, isNull);
    final saved = await repo.updateSettings(LaundrySettingsRequest(
        sameDayEnabled: true, sameDayCutoffTime: '09:05'));
    expect(saved.sameDayEnabled, isTrue);
    expect(saved.timeZone, 'Asia/Kuwait');
    expect(calls, ['GET', 'PATCH']);
  });

  test(
      'failed API envelope and missing route cannot resolve as a saved default',
      () async {
    final dio = Dio();
    addTearDown(dio.close);
    dio.interceptors.add(InterceptorsWrapper(onRequest: (request, handler) {
      if (request.method == 'GET') {
        handler.reject(DioException(
            requestOptions: request,
            response: Response(requestOptions: request, statusCode: 404)));
      } else {
        handler.resolve(Response(requestOptions: request, data: {
          'success': false,
          'message': 'Not saved',
          'data': null,
        }));
      }
    }));
    final repo = LaundryRepository(LaundryService(dio));
    await expectLater(repo.getSettings(), throwsA(isA<DioException>()));
    await expectLater(
        repo.updateSettings(LaundrySettingsRequest(sameDayEnabled: false)),
        throwsException);
  });

  test(
      'enabling without cutoff never issues PATCH, disabled draft retains cutoff',
      () async {
    final repo = _Repository();
    final cubit = LaundrySettingsCubit(repo);
    addTearDown(cubit.close);
    await cubit.load();
    cubit.change(enabled: true);
    await cubit.save();
    expect(repo.updates, isEmpty);
    cubit.change(cutoff: '23:59');
    await cubit.save();
    cubit.change(enabled: false);
    await cubit.save();
    expect(repo.updates.last.toJson(),
        {'sameDayEnabled': false, 'sameDayCutoffTime': '23:59'});
    cubit.change(enabled: true);
    expect(cubit.state.cutoff, '23:59');
  });

  for (final language in ['en', 'ar']) {
    testWidgets('cutoff picker and server-confirmed save work in $language',
        (tester) async {
      tester.view.physicalSize = const Size(360, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repo = _Repository();
      final cubit = LaundrySettingsCubit(repo);
      addTearDown(cubit.close);
      await cubit.load();
      await tester.pumpWidget(_app(cubit, language: language));
      await tester.pumpAndSettle();
      final l10n = AppLocalizations.of(
          tester.element(find.byType(LaundrySameDaySettingsCard)))!;
      await tester.tap(find.byKey(const ValueKey('laundry-same-day-toggle')));
      await tester.pumpAndSettle();
      expect(find.text(l10n.laundry_same_day_cutoff_required), findsOneWidget);
      expect(
          tester
              .widget<FilledButton>(
                  find.byKey(const ValueKey('laundry-same-day-save')))
              .onPressed,
          isNull);
      await tester.tap(find.byKey(const ValueKey('laundry-same-day-cutoff')));
      await tester.pumpAndSettle();
      final material = MaterialLocalizations.of(
          tester.element(find.byType(TimePickerDialog)));
      await tester.tap(find.text(material.okButtonLabel));
      await tester.pumpAndSettle();
      expect(cubit.state.cutoff, '12:00');
      final pending = Completer<LaundrySettings>();
      repo.saveResult = pending;
      await tester.tap(find.byKey(const ValueKey('laundry-same-day-save')));
      await tester.pump();
      expect(find.text(l10n.laundry_same_day_saved), findsNothing);
      expect(repo.updates.single.toJson(),
          {'sameDayEnabled': true, 'sameDayCutoffTime': '12:00'});
      pending.complete(const LaundrySettings(
          sameDayEnabled: true,
          sameDayCutoffTime: '12:00',
          timeZone: 'Asia/Kuwait'));
      await tester.pumpAndSettle();
      expect(find.text(l10n.laundry_same_day_saved), findsOneWidget);
      expect(cubit.state.dirty, isFalse);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
      'failed load offers retry without controls and failed save keeps draft',
      (tester) async {
    final repo = _Repository()..loadFails = true;
    final cubit = LaundrySettingsCubit(repo);
    addTearDown(cubit.close);
    await cubit.load();
    await tester.pumpWidget(_app(cubit));
    await tester.pumpAndSettle();
    expect(find.byType(SwitchListTile), findsNothing);
    expect(find.byKey(const ValueKey('laundry-same-day-save')), findsNothing);
    repo.loadFails = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    cubit.change(enabled: true, cutoff: '10:30');
    repo.saveFails = true;
    await cubit.save();
    await tester.pumpAndSettle();
    expect(find.text('Settings were not saved. Please try again.'),
        findsOneWidget);
    expect(find.text('Same-day settings saved'), findsNothing);
    expect(cubit.state.cutoff, '10:30');
    expect(cubit.state.enabled, isTrue);
    expect(cubit.state.saved?.sameDayEnabled, isFalse);
    expect(cubit.state.dirty, isTrue);
  });

  testWidgets('read-only permissions disable changes and hide save',
      (tester) async {
    final cubit = LaundrySettingsCubit(_Repository());
    addTearDown(cubit.close);
    await cubit.load();
    await tester.pumpWidget(_app(cubit, canEdit: false));
    await tester.pumpAndSettle();
    expect(tester.widget<SwitchListTile>(find.byType(SwitchListTile)).onChanged,
        isNull);
    expect(
        tester
            .widget<OutlinedButton>(
                find.byKey(const ValueKey('laundry-same-day-cutoff')))
            .onPressed,
        isNull);
    expect(find.byKey(const ValueKey('laundry-same-day-save')), findsNothing);
  });
  testWidgets('catalog loads settings once and preserves the draft on refresh',
      (tester) async {
    final repo = _Repository();
    FlutterSecureStorage.setMockInitialValues({
      'auth_user': jsonEncode({
        'role': 'manager',
        'permissions': [
          {'name': 'company_profile:read'},
          {'name': 'company_profile:update'},
        ],
      }),
    });
    sl.registerSingleton<LaundryRepository>(repo);
    addTearDown(() {
      sl.unregister<LaundryRepository>();
      FlutterSecureStorage.setMockInitialValues({});
    });
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const LaundryCatalogScreen(),
    ));
    await tester.pumpAndSettle();
    final settings = tester.widget<LaundryMinimumChargeCard>(
        find.byType(LaundryMinimumChargeCard));
    expect(settings.canEdit, isTrue);
    settings.cubit.change(minimumChargeText: '5');
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pumpAndSettle();
    expect(repo.catalogLoads, 2);
    expect(repo.settingsLoads, 1);
    expect(settings.cubit.state.minimumCharge, 5);
    expect(settings.cubit.state.dirty, isTrue);
    expect(repo.updates, isEmpty);
    expect(tester.takeException(), isNull);
  });
}
