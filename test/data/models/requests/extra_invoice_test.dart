import 'package:cleaning_service_driver/components/extra_invoice.dart';
import 'package:cleaning_service_driver/core/utils/request_status_enum.dart';
import 'package:cleaning_service_driver/data/models/requests/add_extra_fees_request.dart';
import 'package:cleaning_service_driver/data/models/requests/car_wash_history.dart';
import 'package:cleaning_service_driver/data/models/requests/cleaning_request.dart';
import 'package:cleaning_service_driver/data/models/requests/deep_cleaning_history.dart';
import 'package:cleaning_service_driver/data/models/requests/house_keeping_history.dart';
import 'package:cleaning_service_driver/data/models/requests/upholstery_cleaning_history.dart';
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
    });
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
      if (fixture.type == 'upholsteryCleaning')
        'items': <Map<String, dynamic>>[],
      if (fixture.type == 'carWash') 'vehicles': <Map<String, dynamic>>[],
    },
    'extraFees': 4.25,
    'extraFeesDescription': 'Existing extra invoice',
    'awaitingExtraPayment': true,
    'extraPaymentUrl': 'https://example.com/pay',
  };
}
