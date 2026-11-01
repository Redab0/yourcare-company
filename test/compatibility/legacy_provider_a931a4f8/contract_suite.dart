// This suite is copied into a private package with byte-exact historical lib/.
// Run it through prepare.py, never against the current application's models.
import 'dart:convert';
import 'dart:io';

import 'package:cleaning_service_driver/core/models/response.dart';
import 'package:cleaning_service_driver/core/models/response_payload.dart';
import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:cleaning_service_driver/data/models/laundry/laundry_history.dart';
import 'package:cleaning_service_driver/data/models/requests/cleaning_request.dart';
import 'package:cleaning_service_driver/data/services/jobs/jobs_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _actors = ['missing-worker', 'missing-manager', 'old-editor-created'];
const _services = [
  'houseCleaning',
  'deepCleaning',
  'upholsteryCleaning',
  'carWash',
  'laundry'
];

class _DenyNativeNetwork extends HttpOverrides {
  int denied = 0;
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    denied++;
    throw StateError('Historical fixture denies native network creation.');
  }
}

class _FixtureAdapter implements HttpClientAdapter {
  _FixtureAdapter(this.row);
  final Map<String, dynamic> row;
  int calls = 0;
  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    if (++calls != 1 ||
        options.uri.origin != 'https://legacy-fixture.invalid' ||
        options.method != row['method'] ||
        options.uri.path != '/api${row['path']}') {
      throw StateError('Unmatched historical fixture request blocked.');
    }
    return ResponseBody.fromString(
        jsonEncode(row['body']), row['status'] as int,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType]
        });
  }

  @override
  void close({bool force = false}) {}
}

Map<String, dynamic> _map(Object? value) =>
    Map<String, dynamic>.from(value as Map);

Map<String, dynamic> _leaf(Map<String, dynamic> body) =>
    _map(_map(body['data'])['data']);

Dio _dio(_FixtureAdapter adapter) =>
    Dio(BaseOptions(baseUrl: 'https://legacy-fixture.invalid/api'))
      ..httpClientAdapter = adapter;

Future<CleaningRequest> _historicalJob(Map<String, dynamic> row) async {
  final adapter = _FixtureAdapter(row);
  final dio = _dio(adapter);
  try {
    final response =
        await JobsService(dio).getJob((row['path'] as String).split('/').last);
    expect(response.success, isTrue);
    expect(adapter.calls, 1);
    return response.data!.data!;
  } finally {
    dio.close(force: true);
  }
}

ApiResponse<ResponsePayload<CleaningRequest>> _historicalJobEnvelope(
        Map<String, dynamic> body) =>
    ApiResponse<ResponsePayload<CleaningRequest>>.fromJson(
        body,
        (value) => ResponsePayload<CleaningRequest>.fromJson(
            _map(value), (request) => CleaningRequest.fromJson(_map(request))));

User _historicalUserEnvelope(Map<String, dynamic> body) =>
    ApiResponse<ResponsePayload<User>>.fromJson(
        body,
        (value) => ResponsePayload<User>.fromJson(
            _map(value), (user) => User.fromJson(_map(user)))).data!.data!;

bool _containsKey(Object? value, Set<String> names) {
  if (value is Map) {
    return value.entries.any((entry) =>
        names.contains(entry.key) || _containsKey(entry.value, names));
  }
  return value is List && value.any((child) => _containsKey(child, names));
}

void registerLegacyProviderContractTests() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Map<String, dynamic> fixture;
  late HttpOverrides? previous;
  final network = _DenyNativeNetwork();
  setUpAll(() async {
    previous = HttpOverrides.current;
    HttpOverrides.global = network;
    fixture = _map(jsonDecode(
        await rootBundle.loadString('assets/backend-fixtures.json')));
    expect(fixture['syntheticOnly'], isTrue);
    expect(fixture['moneyUnit'], 'KWD');
    expect(fixture['cases'], hasLength(21));
  });
  tearDownAll(() => HttpOverrides.global = previous);

  Map<String, dynamic> job(String actor, String service) =>
      (fixture['cases'] as List).map(_map).singleWhere((row) =>
          row['actorCase'] == actor &&
          row['service'] == service &&
          row['method'] == 'GET');

  test('native network creation is blocked before any connection', () {
    final before = network.denied;
    expect(() => HttpClient(), throwsStateError);
    expect(network.denied, before + 1);
  });
  test('unmatched Dio traffic cannot escape the synthetic adapter', () async {
    final adapter = _FixtureAdapter(job('missing-worker', 'houseCleaning'));
    final dio = _dio(adapter);
    try {
      await expectLater(dio.get('/unmatched'), throwsA(isA<DioException>()));
      expect(adapter.calls, 1);
    } finally {
      dio.close(force: true);
    }
  });

  for (final actor in _actors) {
    for (final service in _services) {
      test('historical $actor $service preserves real money', () async {
        final row = job(actor, service);
        final leaf = _leaf(_map(row['body']));
        expect(leaf['totalPrice'], row['expectedTotalKwd']);
        expect(leaf['pricesHidden'], isNot(true));
        final request = await _historicalJob(row);
        expect(request.type, service);
        expect(request.totalPrice,
            closeTo((row['expectedTotalKwd'] as num).toDouble(), 1e-12));
        expect(request.totalPrice, greaterThan(0));
        if (request is LaundryHistory) {
          final rawInvoice = _map(_map(leaf['Laundry'])['invoice']);
          final invoice = request.detail.invoice!;
          final rawItems = rawInvoice['items'] as List;
          expect(rawItems, isNotEmpty);
          expect(invoice.items.length, rawItems.length);
          for (var i = 0; i < rawItems.length; i++) {
            final line = _map(rawItems[i]);
            expect(invoice.items[i].unitPrice, line['unitPrice']);
            expect(invoice.items[i].total, line['total']);
            expect(invoice.items[i].unitPrice, greaterThan(0));
          }
          expect(invoice.total, rawInvoice['total']);
          expect(invoice.total, greaterThan(0));
        }
      });
    }
  }

  for (final service in _services) {
    test('explicit denial still removes private $service money', () async {
      final row = job('explicit-false', service);
      final body = _map(row['body']);
      final leaf = _leaf(body);
      expect(body['pricesHidden'], isTrue);
      expect(leaf['pricesHidden'], isTrue);
      expect(
          _containsKey(leaf, {
            'totalPrice',
            'totalPriceWithFees',
            'platformFees',
            'unitPrice',
            'price',
            'amount',
            'subtotal',
            'total',
            'pickupFee',
            'deliveryFee',
            'discount',
            'campaign',
            'campaignDiscountAmount'
          }),
          isFalse);
      if (service == 'houseCleaning' ||
          service == 'deepCleaning' ||
          service == 'laundry') {
        await expectLater(_historicalJob(row), throwsA(isA<Exception>()));
      } else {
        // Historical Furniture/CarWash normalizers manufacture zero locally.
        // This is recorded incompatibility, never a server compatibility shim.
        final parsed = await _historicalJob(row);
        expect(parsed.totalPrice, 0);
      }
    });
  }

  for (final actor in [..._actors, 'explicit-false']) {
    test('historical $actor profile accepts the additive access flag', () {
      final row = (fixture['profiles'] as List)
          .map(_map)
          .singleWhere((row) => row['actorCase'] == actor);
      final body = _map(row['body']);
      final raw = _leaf(body);
      expect(raw['canSeePrices'], actor != 'explicit-false');
      final user = _historicalUserEnvelope(body);
      expect(user.id, raw['id']);
      expect(user.role, raw['role']);
      expect(user.toJson().containsKey('canSeePrices'), isFalse,
          reason: 'This proves the old User model is executing.');
    });
    test('historical $actor login keeps its existing envelope', () {
      final row = (fixture['logins'] as List)
          .map(_map)
          .singleWhere((row) => row['actorCase'] == actor);
      final body = _map(row['body']);
      final raw = _map(body['data']);
      final login = LoginResponse.fromJson(body);
      expect(login.success, isTrue);
      expect(login.data.token, raw['token']);
      expect(login.data.user.id, _map(raw['user'])['id']);
      expect(login.data.user.toJson().containsKey('canSeePrices'), isFalse);
    });
  }

  test('old editor creation response remains usable', () {
    final body = _map(fixture['oldEditorCreate']);
    expect(_leaf(body)['canSeePrices'], isTrue);
    final user = _historicalUserEnvelope(body);
    expect(user.id, _leaf(body)['id']);
    expect(user.role, 'worker');
  });

  test('actual shared operational mutation envelope retains money', () async {
    final row = (fixture['cases'] as List)
        .map(_map)
        .singleWhere((row) => row['method'] == 'PATCH');
    final dio = _dio(_FixtureAdapter(row));
    try {
      final response = await dio
          .patch(row['path'] as String, data: {'requestStatus': 'inProgress'});
      final parsed = _historicalJobEnvelope(_map(response.data)).data!.data!;
      expect(parsed.totalPrice, row['expectedTotalKwd']);
      expect(parsed.requestStatus.name, 'inProgress');
    } finally {
      dio.close(force: true);
    }
  });
  test('explicitly denied financial route remains HTTP403', () async {
    final denied = _map(fixture['financialDenied']);
    expect(denied['status'], 403);
    expect(_map(denied['body'])['code'], 'PRICE_ACCESS_DENIED');
    final dio = _dio(_FixtureAdapter({
      ...denied,
      'method': 'GET',
      'path': '/company/requests/reports/statistics'
    }));
    try {
      await expectLater(
          dio.get('/company/requests/reports/statistics'),
          throwsA(isA<DioException>().having(
              (error) => error.response?.statusCode, 'HTTP status', 403)));
    } finally {
      dio.close(force: true);
    }
  });
  test('cashback removal also defeats the old legacy gift fallback', () {
    final body = _map(fixture['hiddenCashback']);
    final leaf = _leaf(body);
    expect(leaf.containsKey('campaign'), isFalse);
    expect(leaf.containsKey('registrationGiftApplied'), isFalse);
    expect(leaf.containsKey('campaignDiscountAmount'), isFalse);
    final parsed = _historicalJobEnvelope(body).data!.data!;
    expect(parsed.hasVisibleCampaignBenefit, isFalse);
    expect(parsed.totalPrice, greaterThan(0));
  });
  test('targeted noncashback company discount remains visible to old models',
      () {
    final row = job('missing-worker', 'houseCleaning');
    final body = _map(row['body']);
    expect(_leaf(body)['companyCampaignVisible'], isTrue);
    final parsed = _historicalJobEnvelope(body).data!.data!;
    expect(parsed.campaignSnapshot?.discountKwd, 1.125);
    expect(parsed.hasVisibleCampaignBenefit, isTrue);
  });
  testWidgets('isolated historical fixture summary renders without app startup',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
            body: Center(
                child: Text(
                    'Historical provider a931a4f8\nSynthetic contract fixture')))));
    expect(find.textContaining('Historical provider a931a4f8'), findsOneWidget);
  });
}
