import 'package:cleaning_service_driver/components/job_tile.dart';
import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/core/themes/app_theme.dart';
import 'package:cleaning_service_driver/core/utils/request_status_enum.dart';
import 'package:cleaning_service_driver/data/models/customer/customer.dart';
import 'package:cleaning_service_driver/data/models/laundry/laundry_history.dart';
import 'package:cleaning_service_driver/data/models/requests/cleaning_request.dart';
import 'package:cleaning_service_driver/data/models/requests/house_keeping_history.dart';
import 'package:cleaning_service_driver/data/repositories/laundry/laundry_repository.dart';
import 'package:cleaning_service_driver/data/services/laundry/laundry_service.dart';
import 'package:cleaning_service_driver/features/bloc/jobs/job_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/jobs/job_event.dart';
import 'package:cleaning_service_driver/features/bloc/jobs/job_state.dart';
import 'package:cleaning_service_driver/features/screens/jobs/jobs_screen.dart';
import 'package:cleaning_service_driver/features/screens/laundry/laundry_job_details_screen.dart';
import 'package:cleaning_service_driver/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../data/models/laundry/laundry_models_test.dart'
    show laundryFixture;

class _Repository extends LaundryRepository {
  _Repository() : super(LaundryService(Dio()));
  final statuses = <String>[];
  Object? error;

  @override
  Future<LaundryHistory> updateStatus(String id, String status) async {
    statuses.add(status);
    if (error != null) throw error!;
    return LaundryHistory.fromJson(laundryFixture(
        status: status, payment: status == 'cancelled' ? 'refunded' : 'paid'));
  }
}

class _JobsBloc extends Cubit<JobState> implements JobBloc {
  _JobsBloc(List<CleaningRequest> jobs)
      : super(JobState(all: jobs, hasMore: false));
  final events = <JobEvent>[];
  @override
  void add(JobEvent event) => events.add(event);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _app(Widget home, String language) => MaterialApp(
    theme: AppTheme.light(),
    locale: Locale(language),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home);

LaundryHistory _order(String id, String status,
    {String mode = 'pickup_invoice_later', String payment = 'unpaid'}) {
  final fixture = laundryFixture(mode: mode, status: status, payment: payment);
  fixture['id'] = id;
  fixture['requestStatus'] = 'inProgress';
  return LaundryHistory.fromJson(fixture);
}

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  for (final language in ['en', 'ar']) {
    testWidgets('initial bag pricing and status remain visible in $language',
        (tester) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repository = _Repository();
      sl.registerSingleton<LaundryRepository>(repository);
      addTearDown(() => sl.unregister<LaundryRepository>());
      final fixture = laundryFixture(status: 'pending_pickup');
      (fixture['Laundry'] as Map).remove('invoice');
      await tester.pumpWidget(_app(
          LaundryJobDetailsScreen(request: LaundryHistory.fromJson(fixture)),
          language));
      await tester.pumpAndSettle();
      final l10n = AppLocalizations.of(tester.element(find.byType(Scaffold)))!;
      expect(find.widgetWithText(Chip, l10n.laundry_pending_pickup),
          findsOneWidget);
      final pricing = find.text(l10n.laundry_create_invoice);
      expect(pricing, findsOneWidget);
      expect(tester.getRect(pricing).bottom, lessThanOrEqualTo(900));
      expect(find.text(l10n.laundry_bags), findsOneWidget,
          reason: 'The footer must leave room for the order details');
      expect(find.text(l10n.laundry_accept_pickup), findsNothing);
      expect(find.text(l10n.laundry_mark_picked_up), findsNothing);
      expect(find.text(l10n.laundry_start_work), findsNothing);
      expect(find.text(l10n.laundry_complete), findsNothing);
      expect(repository.statuses, isEmpty);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'legacy paid list chip uses Confirmed label and color in $language',
        (tester) async {
      await tester.pumpWidget(_app(
          Scaffold(
              body: JobTile(
                  request: _order('legacy', 'in_progress', payment: 'paid'))),
          language));
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(JobTile));
      final l10n = AppLocalizations.of(context)!;
      final chip = tester.widget<Chip>(find.byType(Chip));
      expect((chip.label as Text).data, l10n.confirmed);
      expect(chip.backgroundColor, Colors.teal,
          reason: 'The stale shared inProgress field cannot color laundry');
      expect(find.text(l10n.inprogress), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'completion confirmation, failure and retry keep order in $language',
        (tester) async {
      tester.view.physicalSize = const Size(900, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repository = _Repository();
      sl.registerSingleton<LaundryRepository>(repository);
      addTearDown(() => sl.unregister<LaundryRepository>());
      await tester.pumpWidget(_app(
          LaundryJobDetailsScreen(
              request: _order('LD12', 'ready_for_delivery', payment: 'paid')),
          language));
      await tester.pumpAndSettle();
      final l10n = AppLocalizations.of(tester.element(find.byType(Scaffold)))!;
      expect(find.widgetWithText(Chip, l10n.confirmed), findsOneWidget);
      expect(find.text(l10n.request_paid), findsWidgets,
          reason: 'Payment and invoice statuses still say Paid');
      final complete = find.widgetWithText(FilledButton, l10n.laundry_complete);
      await tester.tap(complete);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, l10n.cancel));
      await tester.pumpAndSettle();
      expect(repository.statuses, isEmpty);
      repository.error = Exception('Payment changed; refresh order');
      await tester.tap(complete);
      await tester.pumpAndSettle();
      await tester.tap(complete.last);
      await tester.pumpAndSettle();
      expect(repository.statuses, ['completed']);
      expect(find.text('Payment changed; refresh order'), findsOneWidget);
      expect(find.widgetWithText(Chip, l10n.confirmed), findsOneWidget);
      expect(complete, findsOneWidget);
      repository.error = null;
      await tester.tap(complete);
      await tester.pumpAndSettle();
      await tester.tap(complete.last);
      await tester.pumpAndSettle();
      expect(repository.statuses, ['completed', 'completed']);
      expect(find.widgetWithText(Chip, l10n.completed), findsOneWidget);
      expect(complete, findsNothing);
      expect(find.text(l10n.laundry_cancel_order), findsNothing);
      expect(find.text(l10n.chat_with_customer), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'incomplete payments and refunds never unlock completion in $language',
        (tester) async {
      final repository = _Repository();
      sl.registerSingleton<LaundryRepository>(repository);
      addTearDown(() => sl.unregister<LaundryRepository>());
      for (final payment in ['paid', 'unpaid', 'refunded']) {
        for (final invoiceStatus in [null, 'draft', 'sent', 'paid']) {
          if (payment == 'paid' && invoiceStatus == 'paid') continue;
          final fixture = laundryFixture(status: 'confirmed', payment: payment);
          final detail = fixture['Laundry'] as Map;
          if (invoiceStatus == null) {
            detail.remove('invoice');
          } else {
            (detail['invoice'] as Map)['status'] = invoiceStatus;
          }
          await tester.pumpWidget(_app(
              LaundryJobDetailsScreen(
                  key: ValueKey('$payment-$invoiceStatus'),
                  request: LaundryHistory.fromJson(fixture)),
              language));
          await tester.pumpAndSettle();
          final l10n =
              AppLocalizations.of(tester.element(find.byType(Scaffold)))!;
          for (final label in [
            l10n.laundry_complete,
            l10n.laundry_start_work,
            l10n.laundry_mark_ready,
            l10n.laundry_start_delivery,
            l10n.laundry_mark_delivered,
            l10n.laundry_create_invoice,
            l10n.laundry_edit_invoice,
            l10n.laundry_send_invoice
          ]) {
            expect(find.text(label), findsNothing,
                reason: '$payment / $invoiceStatus');
          }
          expect(tester.takeException(), isNull);
        }
      }
      expect(repository.statuses, isEmpty);
    });

    testWidgets(
        'shared terminal snapshots never offer fulfillment in $language',
        (tester) async {
      final repository = _Repository();
      sl.registerSingleton<LaundryRepository>(repository);
      addTearDown(() => sl.unregister<LaundryRepository>());
      for (final shared in ['completed', 'cancelled']) {
        for (final payment in ['unpaid', 'paid']) {
          final fixture =
              laundryFixture(status: 'pending_pickup', payment: payment);
          fixture['requestStatus'] = shared;
          await tester.pumpWidget(_app(
              LaundryJobDetailsScreen(
                  key: ValueKey('$shared-$payment'),
                  request: LaundryHistory.fromJson(fixture)),
              language));
          await tester.pumpAndSettle();
          final l10n =
              AppLocalizations.of(tester.element(find.byType(Scaffold)))!;
          expect(
              find.widgetWithText(Chip,
                  shared == 'completed' ? l10n.completed : l10n.cancelled),
              findsOneWidget);
          for (final label in [
            l10n.laundry_complete,
            l10n.laundry_cancel_order,
            l10n.laundry_create_invoice,
            l10n.laundry_edit_invoice,
            l10n.laundry_send_invoice,
            l10n.chat_with_customer
          ]) {
            expect(find.text(label), findsNothing);
          }
          expect(tester.takeException(), isNull);
        }
      }
      expect(repository.statuses, isEmpty);
    });

    testWidgets(
        'mixed jobs keep unpaid and paid laundry out of In progress in $language',
        (tester) async {
      tester.view.physicalSize = const Size(900, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final now = DateTime.utc(2026, 10, 12);
      final housekeeping = HouseKeepingHistory(
          id: 'house-in-progress',
          type: 'houseCleaning',
          requestStatus: RequestStatus.inProgress,
          totalPrice: 10,
          createdAt: now,
          updatedAt: now,
          scheduledTime: now,
          customer: Customer(id: 'customer1'),
          detail: HouseKeepingDetail());
      final jobs = _JobsBloc([
        _order('new-bag', 'pending_pickup'),
        _order('invoice-unpaid', 'invoice_sent'),
        _order('cart-unpaid', 'pending_pickup', mode: 'cart_pay_upfront'),
        _order('legacy-paid', 'in_progress', payment: 'paid'),
        housekeeping,
      ]);
      addTearDown(jobs.close);
      await tester.pumpWidget(_app(
          BlocProvider<JobBloc>.value(value: jobs, child: const JobsScreen()),
          language));
      await tester.pumpAndSettle();
      final l10n = AppLocalizations.of(tester.element(find.byType(Scaffold)))!;
      expect(find.text('# new-bag'), findsOneWidget);
      expect(find.text('# invoice-unpaid'), findsOneWidget);
      expect(find.text('# cart-unpaid'), findsOneWidget);
      expect(find.text('# legacy-paid'), findsOneWidget);
      expect(find.text('# house-in-progress'), findsNothing);
      final load = jobs.events.whereType<LoadJobsEvent>().single;
      expect(load.status, isNull);
      expect(load.type, isNull);
      await tester.tap(find.widgetWithText(Tab, l10n.inprogress));
      await tester.pumpAndSettle();
      expect(find.text('# house-in-progress'), findsOneWidget);
      for (final id in [
        'new-bag',
        'invoice-unpaid',
        'cart-unpaid',
        'legacy-paid'
      ]) {
        expect(find.text('# $id'), findsNothing);
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
}
