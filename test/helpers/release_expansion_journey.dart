import 'dart:io';
import 'package:cleaning_service_driver/components/permission_editor.dart';
import 'package:cleaning_service_driver/components/permission_copy.dart';
import 'package:cleaning_service_driver/core/utils/permissions_helper.dart';
import 'package:cleaning_service_driver/components/price_access_checkbox.dart';
import 'package:cleaning_service_driver/components/cleaning_job_card.dart';
import 'package:cleaning_service_driver/components/registration_gift_badge.dart';
import 'package:cleaning_service_driver/core/access/price_access.dart';
import 'package:cleaning_service_driver/core/access/price_widgets.dart';
import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:cleaning_service_driver/data/models/staff/permission_model.dart';
import 'package:cleaning_service_driver/data/models/requests/cleaning_request.dart';
import 'package:cleaning_service_driver/data/models/requests/house_keeping_history.dart';
import 'package:cleaning_service_driver/features/screens/jobs/house_keeping_job_details_screen.dart';
import 'package:cleaning_service_driver/features/bloc/jobs/job_actions_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/jobs/job_actions_event.dart';
import 'package:cleaning_service_driver/features/bloc/jobs/job_actions_state.dart';
import 'package:cleaning_service_driver/features/bloc/jobs/job_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/jobs/job_event.dart';
import 'package:cleaning_service_driver/features/bloc/jobs/job_state.dart'
    show JobState, JobInitial;
import 'package:cleaning_service_driver/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class NoNetwork extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => throw StateError(
      'Network is forbidden in the synthetic provider journey.');
}

PermissionModel capability(String id, String name) => PermissionModel(
    id, null, name, null, null, name.split(':').first, name.split(':').last);
HouseKeepingHistory fixtureJob({bool visibleCampaign = true}) =>
    CleaningRequest.fromJson({
      'id': 'HK-FIXTURE',
      'type': 'houseCleaning',
      'requestStatus': 'confirmed',
      'totalPrice': 17.625,
      'createdAt': '2026-10-28T08:00:00Z',
      'updatedAt': '2026-10-28T08:00:00Z',
      'scheduledTime': '2026-11-03T08:00:00Z',
      'customer': {'username': 'Fixture customer'},
      'HouseCleaning': <String, dynamic>{},
      'companyCampaignVisible': visibleCampaign,
      'registrationGiftApplied': false,
      'campaign': {'type': 'discount', 'state': 'applied', 'discountKwd': 1.25},
    }) as HouseKeepingHistory;

class FixtureActions extends Cubit<JobActionsState> implements JobActionsBloc {
  FixtureActions() : super(JobActionsInitial());
  @override
  void add(JobActionsEvent event) {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FixtureJobs extends Cubit<JobState> implements JobBloc {
  FixtureJobs() : super(JobInitial());
  @override
  void add(JobEvent event) {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void providerReleaseJourneys(
    {Future<void> Function(WidgetTester, String)? screenshot}) {
  for (final language in ['en', 'ar']) {
    testWidgets(
        'individual access, owner checkbox and manager restriction $language',
        (tester) async {
      final access = PriceAccess()
        ..publish(User(id: 'owner', role: 'business_owner'), generation: 0);
      var selected = <String>{'see', 'unknown-existing'};
      var price = false;
      final catalog = [
        capability('see', 'staff:read'),
        capability('change', 'staff:update')
      ];
      await tester.pumpWidget(PriceAccessScope(
          access: access,
          child: MaterialApp(
            locale: Locale(language),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
                body: StatefulBuilder(
                    builder: (context, setState) => ListView(children: [
                          PriceAccessCheckbox(
                              value: price,
                              onChanged: (value) =>
                                  setState(() => price = value)),
                          PermissionEditor(
                              catalog: catalog,
                              selectedIds: selected,
                              onChanged: (value) =>
                                  setState(() => selected = value)),
                        ]))),
          )));
      await tester.pumpAndSettle();
      final labelContext = tester.element(find.byType(PermissionEditor));
      final l10n = AppLocalizations.of(labelContext)!;
      for (final permission in Permission.values) {
        final copy = permissionCopy(labelContext, permission.value);
        expect(copy.title, isNot(l10n.permissionOtherTitle),
            reason: permission.value);
        expect(copy.description, isNotEmpty);
        expect(
            RegExp(r'\b(read|write|CRUD)\b', caseSensitive: false)
                .hasMatch(copy.title),
            isFalse);
      }

      expect(
          tester
              .widget<CheckboxListTile>(
                  find.byKey(const ValueKey('permission-see')))
              .value,
          isTrue);
      expect(
          tester
              .widget<CheckboxListTile>(
                  find.byKey(const ValueKey('permission-change')))
              .value,
          isFalse);
      await tester.tap(find.byKey(const ValueKey('permission-change')));
      await tester.pumpAndSettle();
      expect(selected, {'see', 'change', 'unknown-existing'});
      await tester.tap(find.byKey(const ValueKey('staff-can-see-prices')));
      await tester.pumpAndSettle();
      expect(price, isTrue);
      if (screenshot != null) {
        await screenshot(tester, 'provider-permissions-$language');
      }
      access.publish(User(id: 'owner', role: 'business_owner'),
          generation: 0, pricesHidden: true);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('staff-can-see-prices')), findsNothing);
      access.publish(User(id: 'manager', role: 'manager', canSeePrices: true),
          generation: 1);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('staff-can-see-prices')), findsNothing);
      expect(selected, contains('unknown-existing'));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      access.dispose();
    });
    testWidgets('actual list/detail/campaign revoke without logout $language',
        (tester) async {
      final access = PriceAccess()
        ..publish(User(id: 'staff', role: 'manager', canSeePrices: true),
            generation: 0);
      final job = fixtureJob();
      final actions = FixtureActions();
      final jobs = FixtureJobs();
      final router = GoRouter(routes: [
        GoRoute(
            path: '/',
            builder: (context, _) => Scaffold(
                    body: ListView(children: [
                  CleaningJobCard(request: job, onAccept: () {}),
                  RegistrationGiftBadge(request: job),
                  TextButton(
                      onPressed: () => GoRouter.of(context).go('/detail'),
                      child: const Text('Details')),
                ]))),
        GoRoute(
            path: '/detail',
            builder: (_, __) => HouseKeepingJobDetails(request: job)),
      ]);
      await tester.pumpWidget(PriceAccessScope(
          access: access,
          child: MultiBlocProvider(
              providers: [
                BlocProvider<JobActionsBloc>.value(value: actions),
                BlocProvider<JobBloc>.value(value: jobs),
              ],
              child: MaterialApp.router(
                  routerConfig: router,
                  locale: Locale(language),
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales))));
      await tester.pumpAndSettle();
      expect(find.textContaining('17.625'), findsOneWidget);
      expect(
          find.descendant(
              of: find.byType(RegistrationGiftBadge),
              matching: find.byType(Text)),
          findsOneWidget);
      access.publish(User(id: 'staff', role: 'manager', canSeePrices: false),
          generation: 0);
      await tester.pumpAndSettle();
      expect(find.textContaining('17.625'), findsNothing);
      expect(
          find.descendant(
              of: find.byType(RegistrationGiftBadge),
              matching: find.byType(Text)),
          findsNothing);
      await tester.tap(find.text('Details'));
      await tester.pumpAndSettle();
      expect(find.byType(HouseKeepingJobDetails), findsOneWidget);
      expect(find.textContaining('17.625'), findsNothing);
      if (screenshot != null) {
        await screenshot(tester, 'provider-prices-hidden-$language');
      }
      access.publish(User(id: 'staff', role: 'manager', canSeePrices: true),
          generation: 0);
      await tester.pumpAndSettle();
      expect(find.textContaining('17.625'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await actions.close();
      await jobs.close();
      router.dispose();
      access.dispose();
    });
  }
}
