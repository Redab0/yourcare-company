import 'package:cleaning_service_driver/components/extra_invoice.dart';
import 'package:cleaning_service_driver/core/utils/request_helpers.dart';
import 'package:cleaning_service_driver/core/utils/request_status_enum.dart';
import 'package:cleaning_service_driver/data/models/requests/add_extra_fees_request.dart';
import 'package:cleaning_service_driver/data/models/requests/car_wash_history.dart';
import 'package:cleaning_service_driver/data/models/requests/cleaning_request.dart';
import 'package:cleaning_service_driver/data/models/requests/deep_cleaning_history.dart';
import 'package:cleaning_service_driver/data/models/requests/house_keeping_history.dart';
import 'package:cleaning_service_driver/data/models/requests/upholstery_cleaning_history.dart';
import 'package:cleaning_service_driver/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const submitted = AddExtraFeesRequest(
    extraFees: 7.5,
    extraFeesDescription: 'Additional service requested on site',
  );

  test('extra-fees payload matches the generic Swagger contract', () {
    expect(submitted.toJson(), {
      'extraFees': 7.5,
      'extraFeesDescription': 'Additional service requested on site',
    });
  });

  group('generic extra invoices', () {
    for (final fixture in _fixtures) {
      test('${fixture.name} parses invoice fields', () {
        final request = CleaningRequest.fromJson(
          _requestJson(fixture),
        );

        expect(request.runtimeType, fixture.expectedType);
        expect(request.extraFees, 4.25);
        expect(request.extraFeesDescription, 'Existing extra invoice');
        expect(request.awaitingExtraPayment, isTrue);
        expect(request.extraPaymentUrl, 'https://example.com/pay');
        expect(request.hasExtraInvoice, isTrue);
      });

      test('${fixture.name} supports local pending-state fallback', () {
        final request = CleaningRequest.fromJson(_requestJson(fixture));
        final updated = request.copyWithExtraInvoice(
          extraFees: submitted.extraFees,
          extraFeesDescription: submitted.extraFeesDescription,
          awaitingExtraPayment: true,
        );

        expect(updated.runtimeType, request.runtimeType);
        expect(updated.extraFees, submitted.extraFees);
        expect(
          updated.extraFeesDescription,
          submitted.extraFeesDescription,
        );
        expect(updated.awaitingExtraPayment, isTrue);
      });

      test('${fixture.name} trusts an all-paid invoice list over stale flags',
          () {
        final json = _requestJson(fixture)
          ..['invoices'] = [
            {
              'type': 'extra_fees',
              'amount': '4.25',
              'status': 'paid',
              'paymentMethod': 'tahseeel',
              'description': 'Existing extra invoice',
              'transactionReference': 'transaction-reference',
              'createdAt': '2026-08-10T08:35:00.000Z',
              'paidAt': '2026-08-10T08:40:00.000Z',
              '_id': 'invoice-id',
            },
          ];

        final request = CleaningRequest.fromJson(json);

        expect(request.awaitingExtraPayment, isFalse);
        expect(request.hasPendingExtraInvoicePayment, isFalse);
        expect(request.allExtraInvoicePaymentsSuccessful, isTrue);
        expect(request.extraInvoices.single.amount, 4.25);
        expect(request.extraInvoices.single.isPaid, isTrue);
        expect(request.extraInvoices.single.id, 'invoice-id');
        expect(request.totalIncludingExtraInvoices, 24.25);
        expect(request.totalPaidIncludingExtraInvoices, 24.25);
      });

      test('${fixture.name} keeps payment pending when any invoice is unpaid',
          () {
        final json = _requestJson(fixture)
          ..['awaitingExtraPayment'] = false
          ..['invoices'] = [
            {
              'type': 'extra_fees',
              'amount': 2,
              'status': 'paid',
            },
            {
              'type': 'extra_fees',
              'amount': 3,
              'status': 'pending',
            },
          ];

        final request = CleaningRequest.fromJson(json);

        expect(request.awaitingExtraPayment, isTrue);
        expect(request.hasPendingExtraInvoicePayment, isTrue);
        expect(request.allExtraInvoicePaymentsSuccessful, isFalse);
        expect(request.totalIncludingExtraInvoices, 25);
        expect(request.totalPaidIncludingExtraInvoices, 22);
      });
    }

    test('only confirmed and in-progress requests allow a new invoice', () {
      for (final status in RequestStatus.values) {
        final request = CleaningRequest.fromJson(
          _requestJson(_fixtures.first, status: status.toJson()),
        );
        final expected = status == RequestStatus.confirmed ||
            status == RequestStatus.inProgress;

        expect(request.canCreateExtraInvoice, expected);
      }
    });

    test('resolver keeps server data and normalizes payment to pending', () {
      final current = CleaningRequest.fromJson(_requestJson(_fixtures.first))
          as HouseKeepingHistory;
      final server = current.copyWithExtraInvoice(
        extraFees: submitted.extraFees,
        extraFeesDescription: submitted.extraFeesDescription,
        awaitingExtraPayment: false,
        extraPaymentUrl: 'https://example.com/new-payment',
      );

      final result = resolveExtraInvoiceResult<HouseKeepingHistory>(
        currentRequest: current,
        submittedRequest: submitted,
        updatedRequest: server,
      );

      expect(result.runtimeType, server.runtimeType);
      expect(result.awaitingExtraPayment, isTrue);
      expect(result.extraPaymentUrl, 'https://example.com/new-payment');
      expect(result.invoices, hasLength(1));
      expect(result.invoices.single.status, 'pending');
    });

    test('resolver marks the local request pending for envelope responses', () {
      final current = CleaningRequest.fromJson(_requestJson(_fixtures.first))
          as HouseKeepingHistory;

      final result = resolveExtraInvoiceResult<HouseKeepingHistory>(
        currentRequest: current,
        submittedRequest: submitted,
      );

      expect(result.extraFees, submitted.extraFees);
      expect(result.awaitingExtraPayment, isTrue);
      expect(result.invoices, hasLength(1));
    });

    test('resolver appends a second card after the first invoice was paid', () {
      final json = _requestJson(_fixtures.first)
        ..['awaitingExtraPayment'] = false
        ..['invoices'] = [
          {
            'type': 'extra_fees',
            'amount': 2.5,
            'status': 'paid',
            'description': 'First invoice',
            '_id': 'paid-invoice',
          },
        ];
      final current = CleaningRequest.fromJson(json) as HouseKeepingHistory;

      final result = resolveExtraInvoiceResult<HouseKeepingHistory>(
        currentRequest: current,
        submittedRequest: submitted,
      );

      expect(result.invoices, hasLength(2));
      expect(result.invoices.first.status, 'paid');
      expect(result.invoices.last.status, 'pending');
      expect(result.invoices.last.amount, submitted.extraFees);
      expect(result.hasPendingExtraInvoicePayment, isTrue);
    });
  });

  testWidgets('all-paid invoice lists show success instead of pending payment',
      (tester) async {
    final json = _requestJson(_fixtures.first)
      ..['totalPrice'] = 24.25
      ..['invoices'] = [
        {
          'type': 'extra_fees',
          'amount': 4.25,
          'status': 'paid',
          'description': 'Existing extra invoice',
          '_id': 'invoice-id',
        },
      ];
    final request = CleaningRequest.fromJson(json);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ExtraInvoiceStatusCard(request: request),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Extra invoice payments successful'), findsOneWidget);
    expect(find.text('Waiting for extra payment'), findsNothing);
    expect(find.text('Paid'), findsOneWidget);
    expect(find.text('Existing extra invoice'), findsOneWidget);
    expect(find.text(RequestFmt.price(4.25)), findsNWidgets(2));
    expect(find.text('Total paid'), findsOneWidget);
    expect(find.text(RequestFmt.price(24.25)), findsOneWidget);
  });

  testWidgets('renders a separate card for every returned invoice',
      (tester) async {
    final json = _requestJson(_fixtures.first)
      ..['totalPrice'] = 25.5
      ..['invoices'] = [
        {
          'type': 'extra_fees',
          'amount': 2.5,
          'status': 'paid',
          'description': 'First invoice',
          '_id': 'paid-invoice',
        },
        {
          'type': 'extra_fees',
          'amount': 3,
          'status': 'pending',
          'description': 'Second invoice',
          '_id': 'pending-invoice',
        },
      ];
    final request = CleaningRequest.fromJson(json);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: ExtraInvoiceStatusCard(request: request),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('extra-invoice-paid-invoice')),
        findsOneWidget);
    expect(find.byKey(const ValueKey('extra-invoice-pending-invoice')),
        findsOneWidget);
    expect(find.text('First invoice'), findsOneWidget);
    expect(find.text('Second invoice'), findsOneWidget);
    expect(find.text('Paid'), findsOneWidget);
    expect(find.text('Pending payment'), findsOneWidget);
    expect(find.text('Total paid'), findsOneWidget);
    expect(find.text(RequestFmt.price(22.5)), findsOneWidget);
  });
}

class _Fixture {
  final String name;
  final String type;
  final String detailKey;
  final Type expectedType;

  const _Fixture({
    required this.name,
    required this.type,
    required this.detailKey,
    required this.expectedType,
  });
}

const _fixtures = <_Fixture>[
  _Fixture(
    name: 'housekeeping',
    type: 'houseCleaning',
    detailKey: 'HouseCleaning',
    expectedType: HouseKeepingHistory,
  ),
  _Fixture(
    name: 'deep cleaning',
    type: 'deepCleaning',
    detailKey: 'DeepCleaning',
    expectedType: DeepCleaningHistory,
  ),
  _Fixture(
    name: 'furniture cleaning',
    type: 'upholsteryCleaning',
    detailKey: 'UpholsteryCleaning',
    expectedType: UpholsteryCleaningHistory,
  ),
  _Fixture(
    name: 'car wash',
    type: 'carWash',
    detailKey: 'CarWash',
    expectedType: CarWashHistory,
  ),
];

Map<String, dynamic> _requestJson(
  _Fixture fixture, {
  String status = 'confirmed',
}) {
  return <String, dynamic>{
    'id': 'REQUEST-1',
    'type': fixture.type,
    'requestStatus': status,
    'totalPrice': 20,
    'createdAt': '2026-08-10T08:00:00.000Z',
    'updatedAt': '2026-08-10T08:30:00.000Z',
    'scheduledTime': '2026-08-10T12:00:00.000Z',
    'customer': <String, dynamic>{
      'id': 'customer-id',
      'username': 'Customer',
      'addresses': <Map<String, dynamic>>[],
    },
    fixture.detailKey: <String, dynamic>{
      'totalPrice': 20,
      if (fixture.type == 'upholsteryCleaning')
        'items': <Map<String, dynamic>>[],
      if (fixture.type == 'carWash') 'vehicles': <Map<String, dynamic>>[],
    },
    if (fixture.type == 'deepCleaning')
      'myBid': <String, dynamic>{'totalPrice': 20},
    'extraFees': 4.25,
    'extraFeesDescription': 'Existing extra invoice',
    'awaitingExtraPayment': true,
    'extraPaymentUrl': 'https://example.com/pay',
  };
}
