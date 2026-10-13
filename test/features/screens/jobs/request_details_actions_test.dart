import 'package:cleaning_service_driver/components/registration_gift_badge.dart';
import 'package:cleaning_service_driver/data/models/requests/request_campaign.dart';
import 'package:cleaning_service_driver/core/utils/request_status_enum.dart';
import 'package:cleaning_service_driver/data/models/auth/address.dart';
import 'package:cleaning_service_driver/data/models/customer/customer.dart';
import 'package:cleaning_service_driver/data/models/requests/car_wash_history.dart';
import 'package:cleaning_service_driver/data/models/requests/cleaning_request.dart';
import 'package:cleaning_service_driver/data/models/requests/deep_cleaning_history.dart';
import 'package:cleaning_service_driver/data/models/requests/house_keeping_history.dart';
import 'package:cleaning_service_driver/data/models/requests/upholstery_cleaning_history.dart'
    hide FrequentRequestModel;
import 'package:cleaning_service_driver/features/bloc/jobs/job_actions_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/jobs/job_actions_event.dart';
import 'package:cleaning_service_driver/features/bloc/jobs/job_actions_state.dart';
import 'package:cleaning_service_driver/features/bloc/jobs/job_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/jobs/job_event.dart';
import 'package:cleaning_service_driver/features/bloc/jobs/job_state.dart'
    show JobState, JobInitial;
import 'package:cleaning_service_driver/features/screens/jobs/car_wash_job_details_screen.dart';
import 'package:cleaning_service_driver/features/screens/jobs/deep_cleaning_job_details_screen.dart';
import 'package:cleaning_service_driver/features/screens/jobs/house_keeping_job_details_screen.dart';
import 'package:cleaning_service_driver/features/screens/jobs/upholstery_cleaning_job_details_screen.dart';
import 'package:cleaning_service_driver/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  for (final type in [
    'deepCleaning',
    'upholsteryCleaning',
    'houseCleaning',
    'carWash'
  ]) {
    for (final language in ['en', 'ar']) {
      testWidgets(
          '$type starts and completes without media with $language feedback',
          (tester) async {
        final actions = _ActionsBloc();
        final jobs = _JobsBloc();
        await _pump(
            tester, _request(type, RequestStatus.confirmed), actions, jobs,
            language: language);
        final l10n =
            AppLocalizations.of(tester.element(find.byType(Scaffold).first))!;

        await tester.tap(find.widgetWithText(FilledButton, l10n.start_job));
        expect(
            actions.events.whereType<StartJobEvent>().single.id, 'request-1');
        actions.deliver(JobStarted(_request(type, RequestStatus.inProgress)));
        await tester.pumpAndSettle();
        expect(find.text(l10n.request_status_updated), findsOneWidget);
        expect(jobs.events.whereType<LoadJobsEvent>(), hasLength(1));

        await tester.tap(find.widgetWithText(FilledButton, l10n.complete_job));
        expect(
            actions.events
                .whereType<CompleteJobEvent>()
                .single
                .completeJobRequest,
            isNull);
        actions.deliver(JobCompleted(_request(type, RequestStatus.completed)));
        await tester.pumpAndSettle();
        expect(find.text('Completion screen'), findsOneWidget);
        expect(find.text(l10n.request_status_updated), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    for (final language in ['en', 'ar']) {
      testWidgets(
          '$type refreshes gift reservation, actual discount and release in $language',
          (tester) async {
        tester.view.physicalSize = const Size(320, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final actions = _ActionsBloc();
        CleaningRequest withGift(String state, {bool applied = true}) =>
            _request(type, RequestStatus.confirmed,
                registrationGiftApplied: applied,
                campaign: RequestCampaign(
                    type: 'registration_gift',
                    state: state,
                    registrationGiftApplied: applied,
                    discountKwd: 1.25));
        await _pump(tester, withGift('reserved'), actions, _JobsBloc(),
            language: language);
        final badge = find.byType(RegistrationGiftBadge);
        expect(badge, findsOneWidget);
        expect(
            tester
                .widget<RegistrationGiftBadge>(badge)
                .request
                .isRegistrationGiftReserved,
            isTrue);
        expect(
            tester
                .widget<RegistrationGiftBadge>(badge)
                .request
                .registrationGiftDiscountKwd,
            1.25);
        actions.deliver(JobRefreshed(withGift('applied')));
        await tester.pumpAndSettle();
        expect(
            tester
                .widget<RegistrationGiftBadge>(badge)
                .request
                .isRegistrationGiftReserved,
            isFalse);
        expect(find.descendant(of: badge, matching: find.byType(Text)),
            findsOneWidget);
        actions.deliver(JobRefreshed(withGift('released', applied: false)));
        await tester.pumpAndSettle();
        expect(find.descendant(of: badge, matching: find.byType(Text)),
            findsNothing);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('$type refreshes the matching request without a success toast',
        (tester) async {
      final actions = _ActionsBloc();
      await _pump(tester, _request(type, RequestStatus.confirmed), actions,
          _JobsBloc());
      await tester.tap(find.byIcon(Icons.refresh));
      expect(
          actions.events.whereType<RefreshJobEvent>().single.id, 'request-1');
      actions.deliver(JobRefreshed(_request(type, RequestStatus.inProgress)));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(FilledButton, 'Complete Job'), findsOneWidget);
      expect(find.text('Status was updated'), findsNothing);
    });
  }

  for (final type in ['deepCleaning', 'upholsteryCleaning']) {
    testWidgets('$type waits for active uploads before completing',
        (tester) async {
      final actions = _ActionsBloc();
      await _pump(tester, _request(type, RequestStatus.inProgress), actions,
          _JobsBloc());
      actions.deliver(MediaUploading());
      await tester.pumpAndSettle();
      final button = find.widgetWithText(FilledButton, 'Complete Job');
      expect(tester.widget<FilledButton>(button).onPressed, isNull);
      actions.deliver(const JobActionFailed('Upload failed'));
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(button).onPressed, isNotNull);
      expect(find.text('Upload failed'), findsOneWidget);
    });
  }

  testWidgets(
      'housekeeping uses visit _id and refreshes jobs after status changes',
      (tester) async {
    final actions = _ActionsBloc();
    final jobs = _JobsBloc();
    final base = _request('houseCleaning', RequestStatus.confirmed)
        as HouseKeepingHistory;
    final visit = FrequentRequestModel.fromJson({
      '_id': 'visit-1',
      'date': '2026-09-13T10:00:00Z',
      'status': 'confirmed',
    });
    await _pump(tester, base.copyWith(subRequests: [visit]), actions, jobs);
    await tester.tap(find.widgetWithText(FilledButton, 'Start Job'));
    final event =
        actions.events.whereType<UpdateFrequencyRequestEvent>().single;
    expect(event.body.frequencyDateId, 'visit-1');
    expect(event.body.status, RequestStatus.inProgress);
    expect(actions.events.whereType<StartJobEvent>(), isEmpty);
    actions.deliver(RequestFrequencyUpdated(base.copyWith(
      subRequests: [visit.copyWith(status: RequestStatus.inProgress)],
    )));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(FilledButton, 'Complete Job'), findsOneWidget);
    expect(find.text('Status was updated'), findsOneWidget);
    expect(jobs.events.whereType<LoadJobsEvent>(), hasLength(1));
  });

  testWidgets(
      'housekeeping explains missing IDs without changing the entire request',
      (tester) async {
    final actions = _ActionsBloc();
    final base = _request('houseCleaning', RequestStatus.confirmed)
        as HouseKeepingHistory;
    await _pump(
        tester,
        base.copyWith(subRequests: [
          FrequentRequestModel(status: RequestStatus.confirmed),
          FrequentRequestModel(id: 'visit-without-status'),
        ]),
        actions,
        _JobsBloc());
    final button = find.widgetWithText(FilledButton, 'Start Job');
    expect(tester.widget<FilledButton>(button).onPressed, isNull);
    expect(
        find.textContaining('This visit is missing its ID.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pump(WidgetTester tester, CleaningRequest request,
    _ActionsBloc actions, _JobsBloc jobs,
    {String language = 'en'}) async {
  final Widget screen;
  if (request is DeepCleaningHistory) {
    screen = DeepCleaningJobDetailsScreen(request: request);
  } else if (request is UpholsteryCleaningHistory) {
    screen = UpholsteryCleaningJobDetailsScreen(request: request);
  } else if (request is HouseKeepingHistory) {
    screen = HouseKeepingJobDetails(request: request);
  } else {
    screen = CarWashJobDetailsScreen(request: request as CarWashHistory);
  }
  final router = GoRouter(routes: [
    GoRoute(path: '/', builder: (_, __) => screen),
    GoRoute(
        path: '/success',
        name: 'jobCompletedSuccessScreen',
        builder: (_, __) => const Scaffold(body: Text('Completion screen'))),
  ]);
  addTearDown(router.dispose);
  addTearDown(actions.close);
  addTearDown(jobs.close);
  await tester.pumpWidget(MultiBlocProvider(
    providers: [
      BlocProvider<JobActionsBloc>.value(value: actions),
      BlocProvider<JobBloc>.value(value: jobs),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      locale: Locale(language),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  ));
  await tester.pumpAndSettle();
}

CleaningRequest _request(String type, RequestStatus status,
    {bool registrationGiftApplied = false, RequestCampaign? campaign}) {
  final now = DateTime.utc(2026, 9, 13, 10);
  final customer = Customer(username: 'Customer');
  final address = Address(latitude: 29.3, longitude: 47.9, area: 'Area');
  switch (type) {
    case 'deepCleaning':
      return DeepCleaningHistory(
          id: 'request-1',
          registrationGiftApplied: registrationGiftApplied,
          campaign: campaign,
          type: type,
          requestStatus: status,
          totalPrice: 10,
          createdAt: now,
          updatedAt: now,
          scheduledTime: now,
          customer: customer,
          detail: DeepCleaningDetail(address: address));
    case 'upholsteryCleaning':
      return UpholsteryCleaningHistory(
          id: 'request-1',
          registrationGiftApplied: registrationGiftApplied,
          campaign: campaign,
          type: type,
          requestStatus: status,
          totalPrice: 10,
          createdAt: now,
          updatedAt: now,
          scheduledTime: now,
          customer: customer,
          upholsteryCleaning: UpholsteryCleaningDetails(address: address));
    case 'houseCleaning':
      return HouseKeepingHistory(
          id: 'request-1',
          registrationGiftApplied: registrationGiftApplied,
          campaign: campaign,
          type: type,
          requestStatus: status,
          totalPrice: 10,
          createdAt: now,
          updatedAt: now,
          scheduledTime: now,
          customer: customer,
          detail: HouseKeepingDetail(address: address));
    default:
      return CarWashHistory(
          id: 'request-1',
          registrationGiftApplied: registrationGiftApplied,
          campaign: campaign,
          requestStatus: status,
          totalPrice: 10,
          createdAt: now,
          updatedAt: now,
          scheduledTime: now,
          customer: customer,
          detail: CarWashHistoryDetail(address: address));
  }
}

class _ActionsBloc extends Cubit<JobActionsState> implements JobActionsBloc {
  _ActionsBloc() : super(JobActionsInitial());
  final events = <JobActionsEvent>[];
  @override
  void add(JobActionsEvent event) => events.add(event);
  void deliver(JobActionsState value) => emit(value);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _JobsBloc extends Cubit<JobState> implements JobBloc {
  _JobsBloc() : super(JobInitial());
  final events = <JobEvent>[];
  @override
  void add(JobEvent event) => events.add(event);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
