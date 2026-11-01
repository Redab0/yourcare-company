import 'dart:async';

import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/core/themes/app_theme.dart';
import 'package:cleaning_service_driver/core/utils/loading_controller.dart';
import 'package:cleaning_service_driver/data/models/schedule/cleaner_availability.dart';
import 'package:cleaning_service_driver/data/repositories/schedule/schedule_repository.dart';
import 'package:cleaning_service_driver/data/services/schedule/schedule_service.dart';
import 'package:cleaning_service_driver/domain/usecases/schedule/create_cleaner_availability_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/schedule/delete_cleaner_availability_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/schedule/get_cleaner_availability_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/schedule/replace_dated_availability_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/schedule/update_cleaner_availability_usecase.dart';
import 'package:cleaning_service_driver/features/bloc/schedule/employee_availability_bloc.dart';
import 'package:cleaning_service_driver/features/screens/schedule/employee_availability_screen.dart';
import 'package:cleaning_service_driver/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

const _saveKey = ValueKey('availability-save');
const _selectorKey = ValueKey('availability-day-selector');
const _now = '2026-10-17T09:00:00Z';

class _Loader implements LoadingController {
  @override
  void show([String tag = 'global']) {}
  @override
  void hide([String tag = 'global']) {}
}

class _Repository extends ScheduleRepository {
  _Repository(this.serviceType)
      : super(ScheduleService(
            Dio(BaseOptions(baseUrl: 'https://example.test')))) {
    slots = [
      CleanerAvailabilitySlot(
          id: 'today',
          serviceType: serviceType.apiValue,
          date: serviceType.usesDatedAvailability ? '2026-10-17' : null,
          dayOfWeek: 6,
          startHour: 0,
          endHour: 1,
          totalCleaners: 2),
      if (serviceType.usesDatedAvailability)
        CleanerAvailabilitySlot(
            id: 'next-week',
            serviceType: serviceType.apiValue,
            date: '2026-10-24',
            dayOfWeek: 6,
            startHour: 0,
            endHour: 1,
            totalCleaners: 5),
    ];
  }

  final AvailabilityServiceType serviceType;
  late List<CleanerAvailabilitySlot> slots;
  final writes = <DatedAvailabilityRequest>[];
  final creates = <CleanerAvailabilityRequest>[];
  final deletes = <String>[];
  bool failRead = false;
  bool failSave = false;
  Completer<void>? saveGate;

  @override
  Future<List<CleanerAvailabilitySlot>> getCleanerAvailability(
    AvailabilityServiceType serviceType,
  ) async {
    if (failRead) throw Exception('offline');
    return slots;
  }

  @override
  Future<List<CleanerAvailabilitySlot>> replaceDatedAvailability(
    DatedAvailabilityRequest request,
  ) async {
    writes.add(request);
    await saveGate?.future;
    if (failSave) throw Exception('offline');
    final dates = request.days.map((day) => day.date).toSet();
    slots = [
      ...slots.where((slot) => !dates.contains(slot.date)),
      for (final day in request.days)
        for (final range in day.slots)
          CleanerAvailabilitySlot(
            date: day.date,
            serviceType: request.serviceType.apiValue,
            dayOfWeek: DateTime.parse(day.date).weekday % 7,
            startHour: range.startHour,
            endHour: range.endHour,
            totalCleaners: range.totalCleaners,
          ),
    ];
    return slots;
  }

  @override
  Future<void> deleteCleanerAvailability(String id) async {
    deletes.add(id);
    slots = slots.where((slot) => slot.id != id).toList();
  }

  @override
  Future<CleanerAvailabilitySlot> createCleanerAvailability(
    CleanerAvailabilityRequest request,
  ) async {
    creates.add(request);
    final slot = CleanerAvailabilitySlot(
      dayOfWeek: request.dayOfWeek,
      startHour: request.startHour,
      endHour: request.endHour,
      totalCleaners: request.totalCleaners,
      serviceType: request.serviceType.apiValue,
    );
    slots.add(slot);
    return slot;
  }
}

Future<EmployeeAvailabilityBloc> _open(
  WidgetTester tester,
  _Repository repository, {
  String language = 'en',
  Size size = const Size(390, 900),
  DateTime Function()? clock,
}) async {
  await sl.reset();
  FlutterSecureStorage.setMockInitialValues({});
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  sl.registerFactory(() => GetCleanerAvailabilityUseCase(repository));
  sl.registerFactory(() => CreateCleanerAvailabilityUseCase(repository));
  sl.registerFactory(() => UpdateCleanerAvailabilityUseCase(repository));
  sl.registerFactory(() => DeleteCleanerAvailabilityUseCase(repository));
  sl.registerFactory(() => ReplaceDatedAvailabilityUseCase(repository));
  sl.registerSingleton<LoadingController>(_Loader());
  final bloc = EmployeeAvailabilityBloc();
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await bloc.close();
    await sl.reset();
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.light(),
    locale: Locale(language),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: BlocProvider.value(
      value: bloc,
      child: EmployeeAvailabilityScreen(
        serviceType: repository.serviceType,
        currentTime: clock ?? () => DateTime.parse(_now),
      ),
    ),
  ));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  return bloc;
}

Future<void> _select(WidgetTester tester, String day) async {
  await _scrollToTop(tester);
  final target = find.byKey(ValueKey('availability-day-$day'));
  final scrollable = find.descendant(
      of: find.byKey(_selectorKey), matching: find.byType(Scrollable));
  await tester.scrollUntilVisible(target, 120,
      scrollable: scrollable, maxScrolls: 20);
  await Scrollable.ensureVisible(tester.element(target), alignment: 0.5);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> _scrollToTop(WidgetTester tester) async {
  final scrollable = find
      .descendant(
        of: find.byKey(const ValueKey('availability-editor')),
        matching: find.byType(Scrollable),
      )
      .first;
  tester.state<ScrollableState>(scrollable).position.jumpTo(0);
  await tester.pumpAndSettle();
}

Finder _workers(int day) => find.byKey(ValueKey('availability-workers-$day-0'));

Future<void> _edit(WidgetTester tester, int day, String value) async {
  await tester.ensureVisible(_workers(day));
  await tester.enterText(_workers(day), value);
  await tester.pump();
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('ar');
  });

  for (final service in [
    AvailabilityServiceType.houseCleaning,
    AvailabilityServiceType.carWash,
  ]) {
    for (final language in ['en', 'ar']) {
      for (final width in [390.0, 1200.0]) {
        testWidgets(
            '${service.apiValue} $language $width shows 14 independent dates and saves one date',
            (tester) async {
          final repository = _Repository(service);
          await _open(tester, repository,
              language: language, size: Size(width, 900));
          final selector = tester.widget<ListView>(find.byKey(_selectorKey));
          expect(selector.childrenDelegate.estimatedChildCount, 27);
          expect(tester.widget<TextField>(_workers(0)).controller!.text, '2');
          await _select(tester, '2026-10-24');
          expect(tester.widget<TextField>(_workers(7)).controller!.text, '5');
          await _edit(tester, 7, '7');
          await tester.tap(find.byKey(_saveKey));
          await tester.pumpAndSettle();
          expect(repository.writes, hasLength(1));
          expect(repository.writes.single.days.single.date, '2026-10-24');
          expect(
              repository.writes.single.days.single.slots.single.totalCleaners,
              7);
          expect(
              repository.slots
                  .firstWhere((slot) => slot.date == '2026-10-17')
                  .totalCleaners,
              2);
          expect(repository.creates, isEmpty);
          expect(repository.deletes, isEmpty);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  testWidgets('failed save retains drafts and blocks duplicate in-flight saves',
      (tester) async {
    final repository = _Repository(AvailabilityServiceType.houseCleaning)
      ..failSave = true
      ..saveGate = Completer<void>();
    await _open(tester, repository);
    await _edit(tester, 0, '4');
    await tester.tap(find.byKey(_saveKey));
    await tester.pump();
    expect(repository.writes, hasLength(1));
    expect(tester.widget<FilledButton>(find.byKey(_saveKey)).onPressed, isNull);
    await tester.tap(find.byKey(_saveKey));
    await tester.pump();
    expect(repository.writes, hasLength(1));
    repository.saveGate!.complete();
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(_workers(0)).controller!.text, '4');
    expect(
        tester.widget<FilledButton>(find.byKey(_saveKey)).onPressed, isNotNull);
    repository
      ..saveGate = null
      ..failSave = false;
    await tester.tap(find.byKey(_saveKey));
    await tester.pumpAndSettle();
    expect(repository.writes, hasLength(2));
    expect(repository.writes.last.days.single.slots.single.totalCleaners, 4);
    expect(tester.widget<FilledButton>(find.byKey(_saveKey)).onPressed, isNull);
  });

  testWidgets(
      'copy targets actual dates and leaves source independently editable',
      (tester) async {
    final repository = _Repository(AvailabilityServiceType.carWash);
    await _open(tester, repository);
    await _edit(tester, 0, '3');
    await _scrollToTop(tester);
    final copy = find.text('Apply to other days');
    await tester.ensureVisible(copy);
    await tester.tap(copy);
    await tester.pumpAndSettle();
    final target = find.byKey(const ValueKey('availability-copy-2026-10-24'));
    await tester.ensureVisible(target);
    await tester.tap(target);
    await tester.pump();
    await tester.tap(find.text('Apply to selected days'));
    await tester.pumpAndSettle();
    // The copy remains a draft; only one save persists both changed dates.
    expect(repository.writes, isEmpty);
    await _select(tester, '2026-10-24');
    expect(tester.widget<TextField>(_workers(7)).controller!.text, '3');
    await _edit(tester, 7, '6');
    await tester.tap(find.byKey(_saveKey));
    await tester.pumpAndSettle();
    expect(repository.writes, hasLength(1));
    expect(repository.writes.single.days.map((day) => day.date),
        ['2026-10-17', '2026-10-24']);
    expect(
        repository.writes.single.days
            .map((day) => day.slots.single.totalCleaners),
        [3, 6]);
  });

  testWidgets('Kuwait midnight blocks stale saves without losing drafts',
      (tester) async {
    var now = DateTime.utc(2026, 10, 17, 20, 59);
    final repository = _Repository(AvailabilityServiceType.houseCleaning);
    await _open(tester, repository, clock: () => now);
    await _edit(tester, 0, '4');
    now = DateTime.utc(2026, 10, 17, 21);
    await tester.pump(const Duration(seconds: 30));
    expect(tester.widget<FilledButton>(find.byKey(_saveKey)).onPressed, isNull);
    expect(tester.widget<TextField>(_workers(0)).controller!.text, '4');
    expect(find.textContaining('The date window has changed.'), findsWidgets);
    expect(repository.writes, isEmpty);
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    await _scrollToTop(tester);
    expect(find.byKey(const ValueKey('availability-day-2026-10-18')),
        findsOneWidget);
    expect(find.byKey(const ValueKey('availability-day-2026-10-17')),
        findsNothing);
    expect(tester.widget<TextField>(_workers(0)).enabled, isFalse);
  });

  testWidgets('load failure offers retry without treating failure as closed',
      (tester) async {
    final repository = _Repository(AvailabilityServiceType.carWash)
      ..failRead = true;
    await _open(tester, repository);
    expect(find.text('Could not load availability'), findsOneWidget);
    expect(find.byKey(_selectorKey), findsNothing);
    repository.failRead = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.byKey(_selectorKey), findsOneWidget);
  });

  testWidgets('closing a date saves empty slots without changing other dates',
      (tester) async {
    final repository = _Repository(AvailabilityServiceType.carWash);
    await _open(tester, repository);
    final toggle = find.byKey(const ValueKey('availability-day-enabled'));
    await tester.ensureVisible(toggle);
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(_saveKey));
    await tester.pumpAndSettle();
    expect(repository.writes.single.days.single.date, '2026-10-17');
    expect(repository.writes.single.days.single.slots, isEmpty);
    expect(repository.slots.single.date, '2026-10-24');
    expect(repository.deletes, isEmpty);
    expect(repository.creates, isEmpty);
  });

  testWidgets('furniture retains the seven-day weekly editor', (tester) async {
    final repository = _Repository(AvailabilityServiceType.upholsteryCleaning);
    await _open(tester, repository);
    expect(find.text('Weekly Availability'), findsOneWidget);
    final selector = tester.widget<ListView>(find.byKey(_selectorKey));
    expect(selector.childrenDelegate.estimatedChildCount, 13);
    await _select(tester, '6');
    await _edit(tester, 6, '4');
    await tester.tap(find.byKey(_saveKey));
    await tester.pumpAndSettle();
    expect(repository.writes, isEmpty);
    expect(repository.deletes, ['today']);
    expect(repository.creates.single.dayOfWeek, 6);
    expect(repository.creates.single.totalCleaners, 4);
    expect(repository.creates.single.serviceType,
        AvailabilityServiceType.upholsteryCleaning);
  });
}
