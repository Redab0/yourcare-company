import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'package:cleaning_service_driver/core/access/price_access.dart';
import 'package:cleaning_service_driver/core/access/price_access_interceptor.dart';
import 'package:cleaning_service_driver/core/security/request_security_interceptor.dart';
import 'package:cleaning_service_driver/core/security/session_credentials.dart';
import 'package:cleaning_service_driver/core/storage/secure_storage_service.dart';
import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:cleaning_service_driver/data/models/staff/create_user_model.dart';
import 'package:cleaning_service_driver/data/models/staff/update_user_model.dart';
import 'package:cleaning_service_driver/data/models/requests/cleaning_request.dart';
import 'package:cleaning_service_driver/data/models/laundry/laundry_history.dart';
import 'package:cleaning_service_driver/core/utils/request_helpers.dart';
import 'package:cleaning_service_driver/data/repositories/staff/staff_repository.dart';
import 'package:cleaning_service_driver/data/services/staff/staff_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

const id = '0123456789abcdef01234567';
Map<String, dynamic> requestFixture(String type, {bool hidden = true}) => {
      'id': 'JOB1',
      'type': type,
      'requestStatus': 'confirmed',
      'createdAt': '2026-10-28T08:00:00Z',
      'updatedAt': '2026-10-28T08:00:00Z',
      'scheduledTime': '2026-10-29T08:00:00Z',
      'customer': <String, dynamic>{},
      'pricesHidden': hidden,
      if (!hidden) 'totalPrice': 0,
      'HouseCleaning': <String, dynamic>{},
      'DeepCleaning': <String, dynamic>{},
      'UpholsteryCleaning': <String, dynamic>{},
      'CarWash': {
        'vehicles': [
          {'vehicleTypeId': 'vehicle', 'packageId': 'package'}
        ]
      },
      'Laundry': {
        'pricingMode': 'pickup_invoice_later',
        'status': 'confirmed',
        'paymentStatus': 'paid',
        'invoice': {
          'status': 'paid',
          'items': [
            {'itemId': 'shirt', 'itemName': 'Shirt', 'quantity': 2}
          ]
        }
      }
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    PriceAccess.instance.reset();
  });
  test('role defaults, explicit booleans, owner override and unresolved denial',
      () {
    final access = PriceAccess();
    expect(access.allowed, isFalse);
    for (final role in [
      'worker',
      'driver',
      'manager',
      'business_owner',
      'admin'
    ]) {
      expect(User(role: role).effectiveCanSeePrices, isTrue);
      expect(User(role: role, canSeePrices: false).effectiveCanSeePrices,
          role == 'business_owner' || role == 'admin');
    }
    expect(
        User(role: 'worker', canSeePrices: true).effectiveCanSeePrices, isTrue);
    for (final value in [null, 'false', 0, 1]) {
      expect(
          () => User.fromJson({'canSeePrices': value}), throwsFormatException);
    }
  });
  for (final modernServer in [false, true]) {
    test(
        'worker profile and renewal preserve legacy access on '
        '${modernServer ? 'effective-boolean' : 'omitted-flag'} servers',
        () async {
      final storage = SecureStorageService();
      await storage.saveSession('legacy', User(id: id, role: 'worker'));
      final generation = storage.authGeneration;
      final dio = Dio(BaseOptions(baseUrl: 'https://fixture.invalid/api'));
      dio.httpClientAdapter = _Adapter((_) async => {
            'data': {
              'data': {
                'id': id,
                'role': 'worker',
                if (modernServer) 'canSeePrices': true
              }
            }
          });
      dio.interceptors.add(RequestSecurityInterceptor(
          trustedApiUrl: 'https://fixture.invalid/api',
          accountGeneration: () => storage.authGeneration));
      dio.interceptors.add(PriceAccessInterceptor(storage));
      await dio.get('/users/profile');
      expect(PriceAccess.instance.allowed, isTrue);
      expect((await storage.getUser())?.canSeePrices,
          modernServer ? isTrue : isNull);
      final pending = (await storage.prepareRenewal(
          expectedToken: 'legacy',
          generation: generation,
          requestId: 'legacy-worker'))!;
      final now = DateTime.utc(2026, 10, 29);
      expect(
          await storage.commitRenewal(
              SessionCredentials(
                  token: 'e30.e30.${List.filled(43, 'a').join()}',
                  user: User.fromJson({
                    'id': id,
                    'role': 'worker',
                    if (modernServer) 'canSeePrices': true
                  }),
                  refreshToken: 'opaque',
                  sessionId: '1a6a33df-8db6-4bc7-b526-577f8c258dd0',
                  accessExpiresAt: now.add(const Duration(minutes: 15))),
              expected: pending,
              generation: generation,
              now: now),
          isTrue);
      expect(PriceAccess.instance.allowed, isTrue);
      expect(storage.authGeneration, generation);
      // Credential rotation stores the effective capability locally; it does
      // not change the server record or grant an explicit-denied account.
      expect((await storage.getUser())?.canSeePrices, isTrue);
    });
  }
  for (final type in [
    'houseCleaning',
    'deepCleaning',
    'upholsteryCleaning',
    'carWash',
    'laundry'
  ]) {
    test('$type redacted operational model never invents zero money', () {
      final request = CleaningRequest.fromJson(requestFixture(type));
      expect(request.pricesHidden, isTrue);
      expect(request.totalPrice, isNull);
      expect(request.originalServiceTotal, isNull);
      expect(request.totalIncludingExtraInvoices, isNull);
      expect(request.customer, isNotNull);
      if (request is LaundryHistory) {
        expect(request.detail.invoice?.subtotal, isNull);
        expect(request.detail.invoice?.items.single.unitPrice, isNull);
        expect(request.displayDetail.nextStatuses, contains('completed'));
      }
      expect(
          CleaningRequest.fromJson(requestFixture(type, hidden: false))
              .totalPrice,
          0);
    });
  }
  test(
      'staff repository serializes explicit false and omits unchanged price access',
      () async {
    final calls = <RequestOptions>[];
    final dio = Dio(BaseOptions(baseUrl: 'https://fixture.invalid/api'));
    dio.interceptors.add(InterceptorsWrapper(onRequest: (o, h) {
      calls.add(o);
      h.resolve(Response(requestOptions: o, statusCode: 200, data: {
        'success': true,
        'message': 'ok',
        'data': {
          'locale': 'en',
          'data': {'id': id, 'role': 'worker', 'canSeePrices': false}
        }
      }));
    }));
    final repository = StaffRepository(StaffService(dio));
    await repository.createUser(CreateUserModel(
        username: 'worker',
        role: 'worker',
        image: '',
        email: null,
        password: null,
        phone: null,
        canSeePrices: false));
    await repository.updateUser(UpdateUserModel(username: 'worker'), id);
    await repository.updateUser(UpdateUserModel(canSeePrices: false), id);
    expect(calls[0].data['canSeePrices'], isFalse);
    expect((calls[1].data as Map).containsKey('canSeePrices'), isFalse);
    expect(calls[2].data, {'canSeePrices': false});
  });
  test(
      'renewal applies authoritative revoke while retaining newer local profile and session',
      () async {
    final storage = SecureStorageService();
    await storage.saveSession('old',
        User(id: id, role: 'manager', username: 'old', canSeePrices: true));
    final generation = storage.authGeneration;
    final pending = (await storage.prepareRenewal(
        expectedToken: 'old', generation: generation, requestId: 'req'))!;
    await storage.saveUser(User(
        id: id, role: 'manager', username: 'new profile', canSeePrices: true));
    final now = DateTime.utc(2026, 10, 28);
    final token = 'e30.e30.${List.filled(43, 'a').join()}';
    expect(
        await storage.commitRenewal(
            SessionCredentials(
                token: token,
                user: User(
                    id: id,
                    role: 'manager',
                    username: 'server',
                    canSeePrices: false),
                refreshToken: 'opaque',
                sessionId: '1a6a33df-8db6-4bc7-b526-577f8c258dd0',
                accessExpiresAt: now.add(const Duration(minutes: 15))),
            expected: pending,
            generation: generation,
            now: now),
        isTrue);
    expect((await storage.getUser())?.username, 'new profile');
    expect((await storage.getUser())?.canSeePrices, isFalse);
    expect(storage.authGeneration, generation);
    expect(await storage.getAccessToken(), token);
    expect(PriceAccess.instance.allowed, isFalse);
  });
  for (final cachedRole in ['business_owner', 'admin']) {
    test('$cachedRole hidden marker survives lost-response renewal restart',
        () async {
      var storage = SecureStorageService();
      await storage.saveSession('legacy', User(id: id, role: cachedRole));
      final generation = storage.authGeneration;
      await storage.prepareRenewal(
          expectedToken: 'legacy',
          generation: generation,
          requestId: 'pending');
      await storage.markPricesHidden(
          generation: generation, accessEpoch: PriceAccess.instance.epoch);
      expect(PriceAccess.instance.allowed, isFalse);
      expect(PriceAccess.instance.canManage, isFalse);
      // Recreate presentation/service objects with the same durable records.
      PriceAccess.instance.reset();
      storage = SecureStorageService();
      final recovered = (await storage.credentials())!;
      expect(recovered.priceAccessDenied, isTrue);
      expect(recovered.requestPriceAccessDenied, isFalse);
      final now = DateTime.utc(2026, 10, 28);
      final replacement = SessionCredentials(
          token: 'e30.e30.${List.filled(43, 'a').join()}',
          user: User(id: id, role: 'business_owner'),
          refreshToken: 'opaque',
          sessionId: '1a6a33df-8db6-4bc7-b526-577f8c258dd0',
          accessExpiresAt: now.add(const Duration(minutes: 15)));
      expect(
          await storage.commitRenewal(replacement,
              expected: recovered,
              generation: generation,
              expectedAccessEpoch: PriceAccess.instance.epoch,
              now: now),
          isTrue);
      expect((await storage.credentials())?.priceAccessDenied, isTrue);
      expect(PriceAccess.instance.allowed, isFalse);
      expect(PriceAccess.instance.canManage, isFalse);
      expect(storage.authGeneration, generation);
      // Fresh current-user authority may clear the forced denial, after the
      // actual downgraded role and effective capability have been received.
      await storage.saveUser(User(id: id, role: 'manager', canSeePrices: false),
          authoritativeAccess: true,
          expectedGeneration: generation,
          expectedAccessEpoch: PriceAccess.instance.epoch);
      expect((await storage.credentials())?.priceAccessDenied, isFalse);
      expect(PriceAccess.instance.allowed, isFalse);
      expect(PriceAccess.instance.canManage, isFalse);
      await storage.saveUser(User(id: id, role: 'manager', canSeePrices: true),
          authoritativeAccess: true,
          expectedGeneration: generation,
          expectedAccessEpoch: PriceAccess.instance.epoch);
      expect(PriceAccess.instance.allowed, isTrue);
    });
  }
  test('a delayed profile grant cannot overwrite a newer access epoch',
      () async {
    final storage = SecureStorageService();
    await storage.saveSession(
        'old', User(id: id, role: 'manager', canSeePrices: true));
    final epoch = PriceAccess.instance.epoch;
    await storage.markPricesHidden(
        generation: storage.authGeneration, accessEpoch: epoch);
    expect(
        await storage.saveUser(
            User(id: id, role: 'manager', canSeePrices: true),
            authoritativeAccess: true,
            expectedGeneration: storage.authGeneration,
            expectedAccessEpoch: epoch),
        isFalse);
    expect((await storage.getUser())?.canSeePrices, isFalse);
    expect(PriceAccess.instance.allowed, isFalse);
    expect(await storage.getAccessToken(), 'old');
  });
  test(
      'pricesHidden denies a cached owner immediately during a slow native write',
      () async {
    final native = _SlowStorage();
    final storage = SecureStorageService(secureStorage: native);
    await storage.saveSession('old', User(id: id, role: 'business_owner'));
    final gate = Completer<void>();
    final started = Completer<void>();
    native.beforeWrite = () async {
      if (!started.isCompleted) started.complete();
      await gate.future;
    };
    addTearDown(() {
      if (!gate.isCompleted) gate.complete();
    });
    final dio = Dio(BaseOptions(baseUrl: 'https://fixture.invalid/api'));
    dio.httpClientAdapter = _Adapter((o) async => {
          'pricesHidden': true,
          'data': {'id': 'job'}
        });
    dio.interceptors.add(RequestSecurityInterceptor(
        trustedApiUrl: 'https://fixture.invalid/api',
        accountGeneration: () => storage.authGeneration));
    dio.interceptors.add(PriceAccessInterceptor(storage,
        storageWait: const Duration(milliseconds: 20)));
    final result = dio.get('/company/requests');
    await started.future;
    expect(PriceAccess.instance.allowed, isFalse);
    expect(PriceAccess.instance.canManage, isFalse);
    expect((await result).data['pricesHidden'], isTrue);
    expect(gate.isCompleted, isFalse);
    gate.complete();
    expect((await storage.credentials())?.priceAccessDenied, isTrue);
    expect(await storage.getAccessToken(), 'old');
  });
  test(
      'an old profile native write cannot publish over an immediate server denial',
      () async {
    final native = _SlowStorage();
    final storage = SecureStorageService(secureStorage: native);
    await storage.saveSession('old', User(id: id, role: 'business_owner'));
    final gate = Completer<void>();
    final started = Completer<void>();
    native.beforeWrite = () async {
      if (!started.isCompleted) started.complete();
      await gate.future;
    };
    addTearDown(() {
      if (!gate.isCompleted) gate.complete();
    });
    final dio = Dio(BaseOptions(baseUrl: 'https://fixture.invalid/api'));
    dio.httpClientAdapter = _Adapter((o) async => o.path == '/users/profile'
        ? {
            'data': {
              'data': {'id': id, 'role': 'business_owner', 'canSeePrices': true}
            }
          }
        : {
            'pricesHidden': true,
            'data': {'id': 'job'}
          });
    dio.interceptors.add(RequestSecurityInterceptor(
        trustedApiUrl: 'https://fixture.invalid/api',
        accountGeneration: () => storage.authGeneration));
    dio.interceptors.add(PriceAccessInterceptor(storage));
    final profile = dio.get('/users/profile');
    final rejected = expectLater(
        profile,
        throwsA(isA<DioException>()
            .having((e) => e.type, 'type', DioExceptionType.cancel)));
    await started.future;
    final denied = Completer<void>();
    void onAccessChanged() {
      if (!PriceAccess.instance.allowed && !denied.isCompleted) {
        denied.complete();
      }
    }

    PriceAccess.instance.addListener(onAccessChanged);
    addTearDown(() => PriceAccess.instance.removeListener(onAccessChanged));
    final hidden = dio.get('/company/requests');
    // Observe the actual revocation instead of assuming a scheduler completes
    // both HTTP response interceptors within a fixed wall-clock sleep.
    await denied.future.timeout(const Duration(seconds: 4));
    expect(PriceAccess.instance.allowed, isFalse);
    expect(PriceAccess.instance.canManage, isFalse);
    gate.complete();
    await rejected;
    await hidden;
    expect(PriceAccess.instance.allowed, isFalse);
    expect((await storage.credentials())?.priceAccessDenied, isTrue);
  });
  test('old access epoch response is cancelled after revocation', () async {
    final storage = SecureStorageService();
    await storage.saveSession(
        'old', User(id: id, role: 'manager', canSeePrices: true));
    final gate = Completer<void>();
    final started = Completer<void>();
    final dio = Dio(BaseOptions(baseUrl: 'https://fixture.invalid/api'));
    dio.interceptors.add(RequestSecurityInterceptor(
        trustedApiUrl: 'https://fixture.invalid/api',
        accountGeneration: () => storage.authGeneration));
    dio.httpClientAdapter = _Adapter((o) async {
      started.complete();
      await gate.future;
      return {'totalPrice': 55};
    });
    dio.interceptors.add(PriceAccessInterceptor(storage));
    final result = dio.get('/company/requests');
    final assertion = expectLater(
        result,
        throwsA(isA<DioException>()
            .having((e) => e.type, 'type', DioExceptionType.cancel)));
    await started.future;
    PriceAccess.instance.deny();
    gate.complete();
    await assertion;
    expect(await storage.getAccessToken(), 'old');
  });
  test(
      'outer pricesHidden revokes actor; target user false does not revoke owner',
      () async {
    final storage = SecureStorageService();
    await storage.saveSession(
        'old', User(id: id, role: 'manager', canSeePrices: true));
    final dio = Dio(BaseOptions(baseUrl: 'https://fixture.invalid/api'));
    var hidden = false;
    dio.interceptors.add(RequestSecurityInterceptor(
        trustedApiUrl: 'https://fixture.invalid/api',
        accountGeneration: () => storage.authGeneration));
    dio.httpClientAdapter = _Adapter((o) async => {
          if (hidden) 'pricesHidden': true,
          'data': {'canSeePrices': false},
        });
    dio.interceptors.add(PriceAccessInterceptor(storage));
    await dio.get('/business-company/users');
    expect(PriceAccess.instance.allowed, isTrue);
    hidden = true;
    await dio.get('/company/requests');
    expect(PriceAccess.instance.allowed, isFalse);
    expect(await storage.getAccessToken(), 'old');
  });
}

class _Adapter implements HttpClientAdapter {
  _Adapter(this.reply);
  final Future<Map<String, dynamic>> Function(RequestOptions) reply;
  @override
  Future<ResponseBody> fetch(RequestOptions options,
          Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async =>
      ResponseBody.fromString(jsonEncode(await reply(options)), 200, headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType]
      });
  @override
  void close({bool force = false}) {}
}

class _SlowStorage extends FlutterSecureStorage {
  Future<void> Function()? beforeWrite;
  @override
  Future<void> write(
      {required String key,
      required String? value,
      IOSOptions? iOptions,
      AndroidOptions? aOptions,
      LinuxOptions? lOptions,
      WebOptions? webOptions,
      MacOsOptions? mOptions,
      WindowsOptions? wOptions}) async {
    await beforeWrite?.call();
    await super.write(
        key: key,
        value: value,
        iOptions: iOptions,
        aOptions: aOptions,
        lOptions: lOptions,
        webOptions: webOptions,
        mOptions: mOptions,
        wOptions: wOptions);
  }
}
