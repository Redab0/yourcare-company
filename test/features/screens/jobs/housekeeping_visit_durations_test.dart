import 'dart:io';
import 'dart:ui' as ui;

import 'package:cleaning_service_driver/components/cleaning_job_card.dart';
import 'package:cleaning_service_driver/core/themes/app_theme.dart';
import 'package:cleaning_service_driver/core/utils/request_status_enum.dart';
import 'package:cleaning_service_driver/data/models/customer/customer.dart';
import 'package:cleaning_service_driver/data/models/requests/cleaning_item.dart';
import 'package:cleaning_service_driver/data/models/requests/house_keeping_history.dart';
import 'package:cleaning_service_driver/features/bloc/jobs/job_actions_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/jobs/job_actions_event.dart';
import 'package:cleaning_service_driver/features/bloc/jobs/job_actions_state.dart';
import 'package:cleaning_service_driver/features/bloc/jobs/job_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/jobs/job_event.dart';
import 'package:cleaning_service_driver/features/bloc/jobs/job_state.dart'
    show JobState, JobInitial;
import 'package:cleaning_service_driver/features/screens/jobs/house_keeping_job_details_screen.dart';
import 'package:cleaning_service_driver/features/screens/jobs/housekeeping_visit_focus.dart';
import 'package:cleaning_service_driver/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

HouseKeepingHistory _fixture({List<FrequentRequestModel>? visits}) {
  final start = DateTime.utc(2026, 10, 25, 9);
  return HouseKeepingHistory(
    id: 'HK303-DEV-PREVIEW',
    type: 'houseCleaning',
    requestStatus: RequestStatus.confirmed,
    totalPrice: 0,
    createdAt: start,
    updatedAt: start,
    scheduledTime: start,
    customer: Customer(username: 'Development customer'),
    detail: HouseKeepingDetail(
      cleaningDurations: HouseKeepingOption(
          option: CleaningItem(titleEn: '3 hours', titleAr: '3 ساعات')),
      numberOfCleaners: HouseKeepingOption(
          option: CleaningItem(titleEn: '2 cleaners', titleAr: 'عاملان 2')),
    ),
    subRequests: visits ??
        [
          for (var date = start;
              !date.isAfter(DateTime.utc(2026, 11, 24, 9));
              date = date.add(const Duration(days: 1)))
            if ([
              DateTime.sunday,
              DateTime.monday,
              DateTime.tuesday,
              DateTime.wednesday,
              DateTime.thursday
            ].contains(date.weekday))
              FrequentRequestModel(
                id: 'preview-visit-${date.month}-${date.day}',
                date: date,
                status: RequestStatus.confirmed,
                durationHours:
                    [DateTime.sunday, DateTime.wednesday].contains(date.weekday)
                        ? 3
                        : 2,
              ),
        ],
  );
}

class _Actions extends Cubit<JobActionsState> implements JobActionsBloc {
  _Actions() : super(JobActionsInitial());
  final events = <JobActionsEvent>[];
  @override
  void add(JobActionsEvent event) => events.add(event);
  void deliver(JobActionsState state) => emit(state);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Jobs extends Cubit<JobState> implements JobBloc {
  _Jobs() : super(JobInitial());
  @override
  void add(JobEvent event) {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<_Actions> _open(
  WidgetTester tester,
  HouseKeepingHistory request, {
  String language = 'en',
  double width = 390,
  bool card = false,
  GlobalKey? captureKey,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, 1000);
  final actions = _Actions();
  final jobs = _Jobs();
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await actions.close();
    await jobs.close();
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpWidget(RepaintBoundary(
    key: captureKey,
    child: MultiBlocProvider(
      providers: [
        BlocProvider<JobActionsBloc>.value(value: actions),
        BlocProvider<JobBloc>.value(value: jobs),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        locale: Locale(language),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: card
            ? Scaffold(
                body: SizedBox(
                height: 700,
                child: CleaningJobCard(
                    request: request, onAccept: () {}, hidePrice: true),
              ))
            : HouseKeepingJobDetails(request: request),
      ),
    ),
  ));
  await tester.pumpAndSettle();
  return actions;
}

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('ar');
    final textFont = FontLoader('Zain')
      ..addFont(rootBundle.load('assets/fonts/Zain-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Zain-Bold.ttf'));
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await textFont.load();
    await icons.load();
  });

  group('visit focus selection', () {
    final now = DateTime.utc(2030, 10, 20, 9);
    FrequentRequestModel visit(String id, int days, RequestStatus status) =>
        FrequentRequestModel(
          id: id,
          date: now.add(Duration(days: days)),
          status: status,
          durationHours: 2,
        );

    test('selects the nearest future visit regardless of array order', () {
      final request = _fixture(visits: [
        visit('later', 3, RequestStatus.confirmed),
        visit('completed', 1, RequestStatus.completed),
        visit('next', 2, RequestStatus.pending),
      ]);
      expect(HousekeepingVisitFocus.index(request, now: now), 2);
    });

    test('an in-progress visit stays prominent until completion', () {
      final request = _fixture(visits: [
        visit('next', 1, RequestStatus.confirmed),
        visit('current', -1, RequestStatus.inProgress),
      ]);
      expect(HousekeepingVisitFocus.index(request, now: now), 1);
    });

    for (final status in [
      RequestStatus.completed,
      RequestStatus.cancelled,
      RequestStatus.canceled,
    ]) {
      test('terminal parent $status has no upcoming visit', () {
        final request = _fixture(visits: [
          visit('stale', 1, RequestStatus.confirmed),
          visit('stale-current', 1, RequestStatus.inProgress),
        ]).copyWith(requestStatus: status);
        expect(HousekeepingVisitFocus.index(request, now: now), isNull);
      });
    }

    test('does not promote canceled, completed, past or undated visits', () {
      final request = _fixture(visits: [
        visit('past', -1, RequestStatus.confirmed),
        visit('completed', 1, RequestStatus.completed),
        visit('canceled', 1, RequestStatus.canceled),
        visit('cancelled', 1, RequestStatus.cancelled),
        visit('unknown', 1, RequestStatus.unknown),
        FrequentRequestModel(id: 'undated', status: RequestStatus.confirmed),
      ]);
      expect(HousekeepingVisitFocus.index(request, now: now), isNull);
    });

    test('a visit starting now is still eligible', () {
      expect(
        HousekeepingVisitFocus.index(
            _fixture(visits: [visit('now', 0, RequestStatus.confirmed)]),
            now: now),
        0,
      );
    });

    test('compares legacy Kuwait clock fields as appointment instants', () {
      final request = _fixture(visits: [
        FrequentRequestModel(
          id: 'kuwait-noon',
          date: DateTime(2030, 10, 20, 12),
          status: RequestStatus.confirmed,
        ),
      ]);
      expect(HousekeepingVisitFocus.index(request, now: now), 0);
      expect(
        HousekeepingVisitFocus.index(request,
            now: now.add(const Duration(minutes: 1))),
        isNull,
      );
    });
  });

  test('preview schedule has the agreed 23 visits, 55 hours and noon Kuwait',
      () {
    final request = _fixture();
    expect(request.subRequests, hasLength(23));
    expect(
        request.subRequests!
            .fold<double>(0, (sum, visit) => sum + visit.durationHours!),
        55);
    expect(
        request.subRequests!.every((visit) => visit.date!.hour == 9), isTrue);
  });

  for (final language in ['en', 'ar']) {
    for (final width in [320.0, 1200.0]) {
      testWidgets(
          'mixed durations and legacy fallback render in $language at $width',
          (tester) async {
        final request = _fixture(visits: [
          FrequentRequestModel(
              id: 'three',
              date: DateTime.utc(2026, 10, 25, 9),
              status: RequestStatus.confirmed,
              durationHours: 3),
          FrequentRequestModel(
              id: 'two',
              date: DateTime.utc(2026, 10, 26, 9),
              status: RequestStatus.confirmed,
              durationHours: 2),
          FrequentRequestModel.fromJson({
            'id': 'legacy',
            'date': '2026-10-27T09:00:00Z',
            'status': 'confirmed'
          }),
          FrequentRequestModel.fromJson({
            'id': 'invalid',
            'date': '2026-10-28T09:00:00Z',
            'status': 'confirmed',
            'durationHours': 0
          }),
        ]);
        await _open(tester, request, language: language, width: width);
        final l10n =
            AppLocalizations.of(tester.element(find.byType(Scaffold)))!;
        for (final id in ['three', 'legacy', 'invalid']) {
          final text =
              tester.widget<Text>(find.byKey(ValueKey('visit-duration-$id')));
          expect(text.data, l10n.housekeeping_duration_hours(3));
        }
        expect(
            tester
                .widget<Text>(find.byKey(const ValueKey('visit-duration-two')))
                .data,
            l10n.housekeeping_duration_hours(2));
        expect(find.text(l10n.housekeeping_duration_varies), findsWidgets);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('job card summarizes mixed visits in $language',
        (tester) async {
      await _open(tester, _fixture(),
          language: language, width: 320, card: true);
      final l10n = AppLocalizations.of(tester.element(find.byType(Scaffold)))!;
      expect(find.text(l10n.housekeeping_duration_varies), findsOneWidget);
      expect(find.text(l10n.housekeeping_duration_hours(3)), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('render actual provider preview in $language', (tester) async {
      final capture = GlobalKey();
      final request = _fixture();
      final preview = request.copyWith(subRequests: [
        request.subRequests!.first.copyWith(status: RequestStatus.completed),
        ...request.subRequests!.skip(1),
      ]);
      await _open(tester, preview, language: language, captureKey: capture);
      expect(tester.takeException(), isNull);
      if (const bool.fromEnvironment('CAPTURE_VISIT_FOCUS_PREVIEWS')) {
        final boundary = capture.currentContext!.findRenderObject()!
            as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 2);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await File(
                  '/private/tmp/provider-housekeeping-visit-focus-$language.png')
              .writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
    });

    for (final width in [320.0, 1200.0]) {
      testWidgets(
          'scrambled visits sort by date after completion and reschedule refresh in $language at $width',
          (tester) async {
        final date = DateTime.now().toUtc().add(const Duration(days: 2));
        final earlier = FrequentRequestModel(
            id: 'earlier',
            date: date.subtract(const Duration(days: 1)),
            status: RequestStatus.completed,
            durationHours: 3);
        final first = FrequentRequestModel(
            id: 'first',
            date: date,
            status: RequestStatus.inProgress,
            durationHours: 3);
        final next = FrequentRequestModel(
            id: 'next',
            date: date.add(const Duration(days: 1)),
            status: RequestStatus.confirmed,
            durationHours: 2);
        final later = FrequentRequestModel(
            id: 'later',
            date: date.add(const Duration(days: 2)),
            status: RequestStatus.confirmed,
            durationHours: 2);
        final request = _fixture(visits: [later, next, first, earlier]);
        final actions =
            await _open(tester, request, language: language, width: width);
        final l10n =
            AppLocalizations.of(tester.element(find.byType(Scaffold)))!;
        final firstCard = find.byKey(const ValueKey('visit-card-first'));
        final nextCard = find.byKey(const ValueKey('visit-card-next'));
        final laterCard = find.byKey(const ValueKey('visit-card-later'));
        final earlierCard = find.byKey(const ValueKey('visit-card-earlier'));
        expect(tester.getTopLeft(firstCard).dy,
            lessThan(tester.getTopLeft(nextCard).dy));
        expect(tester.getTopLeft(nextCard).dy,
            lessThan(tester.getTopLeft(laterCard).dy));
        expect(tester.getTopLeft(laterCard).dy,
            lessThan(tester.getTopLeft(earlierCard).dy));
        expect(request.subRequests!.map((visit) => visit.id),
            ['later', 'next', 'first', 'earlier']);
        expect(
            find.descendant(
                of: firstCard,
                matching: find.text(l10n.housekeeping_visit_current)),
            findsOneWidget);
        final complete = find.descendant(
            of: firstCard,
            matching: find.widgetWithText(FilledButton, l10n.complete_job));
        await tester.ensureVisible(complete);
        await tester.tap(complete);
        final update =
            actions.events.whereType<UpdateFrequencyRequestEvent>().single;
        expect(update.body.toJson(),
            {'frequencyDateId': 'first', 'status': 'completed'});
        actions.deliver(RequestFrequencyUpdated(request.copyWith(subRequests: [
          later,
          next,
          first.copyWith(status: RequestStatus.completed),
          earlier,
        ])));
        await tester.pumpAndSettle();
        expect(tester.getTopLeft(nextCard).dy,
            lessThan(tester.getTopLeft(laterCard).dy));
        expect(tester.getTopLeft(laterCard).dy,
            lessThan(tester.getTopLeft(earlierCard).dy));
        expect(tester.getTopLeft(earlierCard).dy,
            lessThan(tester.getTopLeft(firstCard).dy));
        expect(
            tester
                .widget<AnimatedOpacity>(
                    find.byKey(const ValueKey('visit-opacity-first')))
                .opacity,
            0.6);
        expect(
            tester
                .widget<AnimatedOpacity>(
                    find.byKey(const ValueKey('visit-opacity-next')))
                .opacity,
            1);
        expect(
            find.descendant(
                of: nextCard,
                matching: find.text(l10n.housekeeping_visit_next)),
            findsOneWidget);
        expect(find.text(l10n.housekeeping_visit_current), findsNothing);
        expect(
            find.descendant(of: firstCard, matching: find.byType(FilledButton)),
            findsNothing);
        expect(
            find.descendant(of: firstCard, matching: find.text(l10n.completed)),
            findsOneWidget);

        // A refreshed appointment moves by date while keeping its original ID.
        actions.deliver(JobRefreshed(request.copyWith(subRequests: [
          next.copyWith(date: date.add(const Duration(days: 3))),
          first.copyWith(status: RequestStatus.completed),
          later,
          earlier,
        ])));
        await tester.pumpAndSettle();
        expect(tester.getTopLeft(laterCard).dy,
            lessThan(tester.getTopLeft(nextCard).dy));
        expect(tester.getTopLeft(nextCard).dy,
            lessThan(tester.getTopLeft(earlierCard).dy));
        expect(tester.getTopLeft(earlierCard).dy,
            lessThan(tester.getTopLeft(firstCard).dy));
        expect(
            find.descendant(
                of: laterCard,
                matching: find.text(l10n.housekeeping_visit_next)),
            findsOneWidget);
        expect(
            find.descendant(
                of: nextCard,
                matching: find.text(l10n.housekeeping_visit_next)),
            findsNothing);
        final start = find.descendant(
            of: laterCard,
            matching: find.widgetWithText(FilledButton, l10n.start_job));
        await tester.ensureVisible(start);
        await tester.tap(start);
        expect(
            actions.events
                .whereType<UpdateFrequencyRequestEvent>()
                .last
                .body
                .toJson(),
            {'frequencyDateId': 'later', 'status': 'inProgress'});
        expect(request.subRequests!.map((visit) => visit.id),
            ['later', 'next', 'first', 'earlier']);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets(
      'status writes omit duration and server refresh keeps the override',
      (tester) async {
    final visit = FrequentRequestModel(
        id: 'visit-2',
        date: DateTime.utc(2026, 10, 26, 9),
        status: RequestStatus.confirmed,
        durationHours: 2);
    final request = _fixture(visits: [visit]);
    final actions = await _open(tester, request);
    await tester.tap(find.widgetWithText(FilledButton, 'Start Job'));
    final update =
        actions.events.whereType<UpdateFrequencyRequestEvent>().single;
    expect(update.body.toJson(),
        {'frequencyDateId': 'visit-2', 'status': 'inProgress'});
    actions.deliver(RequestFrequencyUpdated(request.copyWith(
        subRequests: [visit.copyWith(status: RequestStatus.inProgress)])));
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('visit-duration-visit-2')))
            .data,
        '2 hours');
    expect(find.widgetWithText(FilledButton, 'Complete Job'), findsOneWidget);
  });
}
