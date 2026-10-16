import 'dart:async';
import 'dart:typed_data';
import 'package:cleaning_service_driver/core/api/session_request_interceptor.dart';
import 'package:cleaning_service_driver/core/validators/validators.dart';
import 'package:cleaning_service_driver/core/security/socket_transport.dart';
import 'package:cleaning_service_driver/core/api/upload_limits.dart';
import 'package:cleaning_service_driver/core/security/bounded_response_adapter.dart';
import 'package:cleaning_service_driver/core/security/request_security.dart';
import 'package:cleaning_service_driver/core/security/request_security_interceptor.dart';
import 'package:cleaning_service_driver/core/storage/secure_storage_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const origin = 'https://fixture.invalid/api';
  dynamic prepare(dynamic value, [String endpoint = '']) =>
      RequestSecurity.prepare(value, endpoint: endpoint);

  test(
      'normalizes human fields and Arabic phones, preserving punctuation and secrets',
      () {
    const password = ' \u0000<"Pa\$\$word">\n ';
    final result = prepare({
      'phone': ' ٩٩٩٩٩٩٩٩ ',
      'password': password,
      'description': "  O'Brien <b>نص عربي</b>\nالسطر الثاني  ",
    }, '/auth/login') as Map;
    expect(result['phone'], '99999999');
    expect(result['password'], password);
    expect(result['description'], "O'Brien <b>نص عربي</b>\nالسطر الثاني");
  });

  test('every nested field is bounded, controls/keys/nonfinite numbers fail',
      () {
    for (final body in [
      {'name': 'bad\u0000value'},
      {'name': 'x' * 16385},
      {
        'nested': {'price': double.nan}
      },
      {
        'nested': {'price': double.infinity}
      },
      {
        'nested': {'\$where': 'query'}
      },
      {
        'nested': {'a.b': 'query'}
      },
      {'__proto__': {}},
      {'list': List.filled(1001, 0)},
      {'bad': Stream<int>.empty()},
    ]) {
      expect(() => prepare(body), throwsFormatException,
          reason: body.keys.first);
    }
    dynamic deep = 'leaf';
    for (var i = 0; i < 18; i++) {
      deep = {'next': deep};
    }
    expect(() => prepare(deep), throwsFormatException);
    final cycle = <String, dynamic>{};
    cycle['self'] = cycle;
    expect(() => prepare(cycle), throwsFormatException);
    expect(() => prepare(List.generate(1000, (_) => List.filled(11, 0))),
        throwsFormatException);
  });

  test(
      'phone/email/coordinates reject malformed values; optional clears and zero prices survive',
      () {
    for (final body in [
      {'phone': '+1234567'},
      {'phone': '19999999'},
      {'email': 'a@@b.c'},
      {'latitude': 91},
      {'longitude': -181},
      {'price': -1},
      {'price': 'NaN'},
      {'active': 'true'},
      {'discountPercentage': 100.01},
      {'serviceType': 'other'},
      {'userId': '../private'},
    ]) {
      expect(() => prepare(body), throwsFormatException);
    }
    expect(prepare({'phone': '', 'email': null, 'price': 0, 'discount': 0}),
        {'phone': '', 'email': null, 'price': 0, 'discount': 0});
    expect(prepare({'price': 0}, '/business/my-business/car-wash-packages'),
        {'price': 0});
    expect(prepare({'discount': 1000}, '/requests/laundry/id/invoice/send'),
        {'discount': 1000});
  });

  test(
      'laundry rules distinguish managed prices, catalog prices, quantities and KWD discounts',
      () {
    expect(prepare({'price': 0}, '/business/my-business/laundry-catalog'),
        {'price': 0});
    expect(
        () =>
            prepare({'price': 0}, '/business/my-business/laundry-products/id'),
        throwsFormatException);
    expect(() => prepare({'quantity': 0}, '/requests/laundry/id/invoice'),
        throwsFormatException);
    expect(prepare({'quantity': 0.001}, '/requests/laundry/id'),
        {'quantity': 0.001});
    expect(prepare({'quantity': 10000}, '/requests/laundry/id'),
        {'quantity': 10000});
    expect(() => prepare({'quantity': 10000.001}, '/requests/laundry/id'),
        throwsFormatException);
    expect(
        () =>
            prepare({'price': 1.0001}, '/business/my-business/laundry-catalog'),
        throwsFormatException);
    expect(
        () => prepare(
            {'nameEn': 'a' * 121}, '/business/my-business/laundry-catalog'),
        throwsFormatException);
    expect(
        prepare(
            {'categoryId': null}, '/business/my-business/laundry-catalog/id'),
        {'categoryId': null});
    expect(
        () => prepare({
              'items': [
                {'productId': 'id', 'itemId': 'id'}
              ]
            }, '/business/my-business/laundry-catalog/prices'),
        throwsFormatException);
    expect(
        prepare({'minimumCharge': 100000, 'workingHours': []},
            '/business/my-business/laundry-settings'),
        {'minimumCharge': 100000, 'workingHours': []});
    expect(() => prepare({'status': 'paid'}, '/requests/laundry/id/status'),
        throwsFormatException);
    expect(
        prepare({'status': 'pickup_rejected'}, '/requests/laundry/id/status'),
        {'status': 'pickup_rejected'});
  });

  test(
      'staff rules stay scoped and login accepts existing passwords without complexity rules',
      () {
    expect(prepare({'name': 'شركة الرعاية'}, '/business/my-business'),
        {'name': 'شركة الرعاية'});
    expect(() => prepare({'username': 'شركة'}, '/business-company/users'),
        throwsFormatException);
    expect(
        prepare({
          'username': 'staff_123',
          'password': null,
          'email': null,
          'phone': null,
          'role': 'worker'
        }, '/business-company/users'),
        isA<Map>());
    expect(
        () => prepare({'username': 'staff_123', 'password': 'weak'},
            '/business-company/users'),
        throwsFormatException);
    expect(prepare({'phone': '99999999', 'password': 'a'}, '/auth/login'),
        isA<Map>());
    expect(() => prepare({'phone': '99999999', 'password': ''}, '/auth/login'),
        throwsFormatException);
  });

  test('schedules/chat reject invalid ranges and preserve legitimate content',
      () {
    expect(
        () => prepare(
            {'startHour': 20, 'endHour': 10}, '/company/cleaner-availability'),
        throwsFormatException);
    expect(
        () => prepare(
            {'startTime': '24:00'}, '/business/my-business/laundry-settings'),
        throwsFormatException);
    expect(
        prepare({'startTime': '23:00', 'endTime': '24:00'},
            '/business/my-business/laundry-settings'),
        isA<Map>());
    expect(() => prepare({'startTime': '23:00', 'endTime': '22:00'}),
        throwsFormatException);
    expect(
        () => prepare(
            {'conversationId': 'id', 'content': '   ', 'type': 'text'},
            '/chat/sendMessage'),
        throwsFormatException);
    expect(
        prepare({
          'conversationId': 'id',
          'content': 'مرحبا\nعالم <3',
          'type': 'text'
        }, '/chat/sendMessage'),
        isA<Map>());
    expect(
        () => RequestSecurity.socketDestination(
            'https://fixture.invalid/chat', 'https://fixture.invalid/chat'),
        returnsNormally);
    expect(
        () => RequestSecurity.socketDestination(
            'https://fixture.invalid/chat?token=bad',
            'https://fixture.invalid/chat'),
        throwsFormatException);
  });

  test('untrusted origins/paths cannot read credentials or dispatch requests',
      () async {
    final dio = Dio(BaseOptions(baseUrl: origin));
    addTearDown(dio.close);
    var reads = 0;
    var dispatches = 0;
    dio.interceptors.add(RequestSecurityInterceptor(trustedApiUrl: origin));
    dio.interceptors.add(SessionRequestInterceptor(
        trustedApiUrl: origin,
        readAccessToken: () async {
          reads++;
          return 'secret';
        },
        languageTag: () => 'ar'));
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      dispatches++;
      handler.resolve(Response(requestOptions: options, statusCode: 200));
    }));
    for (final path in [
      'https://evil.invalid/api/users',
      '//evil.invalid/api/users',
      'http://fixture.invalid/api/users',
      'https://fixture.invalid/apix/users',
      'https://fixture.invalid:444/api/users',
      'https://user:pass@fixture.invalid/api/users',
      '/users/../auth/login',
      '/users/%2e%2e/auth/login',
      '/users/%252e%252e/auth/login',
      '/users/id%2fadmin',
      '/users/id?admin=true',
      '/users/id#secret',
    ]) {
      await expectLater(dio.get(path), throwsA(isA<DioException>()),
          reason: path);
    }
    expect(reads, 0);
    expect(dispatches, 0);
    final valid = await dio.post('/auth/login',
        data: {'phone': ' ٩٩٩٩٩٩٩٩ ', 'password': ' secret '},
        options: Options(
            followRedirects: true, headers: {'authorization': 'injected'}));
    expect(valid.requestOptions.headers['Authorization'], 'Bearer secret');
    expect(
        valid.requestOptions.headers.keys
            .where((key) => key.toLowerCase() == 'authorization'),
        hasLength(1));
    expect(valid.requestOptions.followRedirects, isFalse);
    expect(valid.requestOptions.maxRedirects, 0);
    expect(valid.requestOptions.data['password'], ' secret ');
    expect(reads, 1);
    expect(dispatches, 1);
  });

  test(
      'session interceptor independently rejects unsafe destination before reading storage',
      () async {
    final dio = Dio(BaseOptions(baseUrl: origin));
    addTearDown(dio.close);
    var reads = 0;
    dio.interceptors.add(SessionRequestInterceptor(
        trustedApiUrl: origin,
        readAccessToken: () async {
          reads++;
          return 'secret';
        },
        languageTag: () => 'en'));
    await expectLater(
        dio.get('https://evil.invalid'), throwsA(isA<DioException>()));
    expect(reads, 0);
  });

  test(
      'matching-token logout removes account data and cannot clear a newer session',
      () async {
    FlutterSecureStorage.setMockInitialValues({
      'access_token': 'old',
      'auth_user': '{}',
      'fcm_token': 'fcm',
      'device_id': 'device',
      'development_access_token': 'dev',
    });
    final storage = SecureStorageService();
    expect(await storage.clearAuthDataIfTokenMatches('stale'), isFalse);
    expect(await storage.getAccessToken(), 'old');
    await storage.saveAccessToken('new');
    expect(await storage.clearAuthDataIfTokenMatches('old'), isFalse);
    expect(await storage.getAccessToken(), 'new');
    expect(await storage.clearAuthDataIfTokenMatches('new'), isTrue);
    expect(await storage.getAccessToken(), isNull);
    expect(await storage.getString('auth_user'), isNull);
    expect(await storage.getFcmToken(), isNull);
    expect(await storage.getDeviceId(), 'device');
    expect(
        await const FlutterSecureStorage()
            .read(key: 'development_access_token'),
        'dev');
  });

  test(
      'raw numeric drafts cannot be silently clamped or rounded into valid money',
      () {
    for (final value in [
      '',
      'bad',
      'NaN',
      'Infinity',
      '-1',
      '1.0001',
      '1e308'
    ]) {
      expect(Validators.validAmount(value), isFalse, reason: value);
    }
    expect(Validators.validAmount('0'), isTrue);
    expect(Validators.validAmount('1.001'), isTrue);
    expect(Validators.validAmount('1,001'), isTrue);
    expect(Validators.validAmount('101', maximum: 100), isFalse);
  });

  test('a stale logout cannot attach a new account credential', () async {
    final dio = Dio(BaseOptions(baseUrl: origin));
    addTearDown(dio.close);
    var dispatches = 0;
    dio.interceptors.add(SessionRequestInterceptor(
        trustedApiUrl: origin,
        readAccessToken: () async => 'new-session',
        languageTag: () => 'en'));
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      dispatches++;
      handler.resolve(Response(requestOptions: options, statusCode: 204));
    }));
    await expectLater(
        dio.post('/auth/logout',
            options: Options(headers: {'Authorization': 'Bearer old-session'})),
        throwsA(isA<DioException>()));
    expect(dispatches, 0);
    await dio.post('/auth/logout',
        options: Options(headers: {'Authorization': 'Bearer new-session'}));
    expect(dispatches, 1);
  });

  test(
      'secure-storage upgrade rewrites existing account entries once without changing credentials',
      () async {
    FlutterSecureStorage.setMockInitialValues(
        {'access_token': 'exact-token', 'auth_user': '{}'});
    final storage = SecureStorageService();
    await storage.upgradeProtection();
    expect(await storage.getAccessToken(), 'exact-token');
    expect(await storage.getString('secure_storage_policy_version'), '1');
    await storage.upgradeProtection();
    expect(await storage.getAccessToken(), 'exact-token');
  });

  test(
      'native socket upgrade rejects unsafe origins/path/schemes before transport',
      () async {
    final dynamic adapter = createSecureSocketAdapter();
    for (final target in [
      'ws://be-cleaning.yourcarehere.com/socket.io/',
      'wss://evil.invalid/socket.io/',
      'wss://be-cleaning.yourcarehere.com/chat',
      'wss://user:secret@be-cleaning.yourcarehere.com/socket.io/',
    ]) {
      await expectLater(adapter.connect(target), throwsFormatException);
    }
  });

  test(
      'multipart fields share aggregate limits and retain duplicate-key validation',
      () async {
    final dio = Dio(BaseOptions(baseUrl: origin));
    addTearDown(dio.close);
    dio.interceptors.add(RequestSecurityInterceptor(trustedApiUrl: origin));
    final duplicate = FormData();
    duplicate.fields.addAll([
      const MapEntry('description', 'bad\u0000'),
      const MapEntry('description', 'valid')
    ]);
    await expectLater(dio.post('/upload/multiple', data: duplicate),
        throwsA(isA<DioException>()));
    final large = FormData();
    large.fields
        .addAll(List.generate(70, (_) => MapEntry('description', 'x' * 16384)));
    await expectLater(dio.post('/upload/multiple', data: large),
        throwsA(isA<DioException>()));
  });

  test('upload filenames/signatures reject traversal and disguised SVG', () {
    for (final name in ['../image.jpg', 'bad\r\nname.jpg', '.', 'x' * 256]) {
      expect(() => UploadLimits.validateFilename(name), throwsFormatException);
    }
    expect(UploadLimits.imageMime([0xff, 0xd8, 0xff, 0]), 'image/jpeg');
    expect(
        UploadLimits.imageMime([137, 80, 78, 71, 13, 10, 26, 10]), 'image/png');
    expect(() => UploadLimits.imageMime('<svg onload="bad">'.codeUnits),
        throwsFormatException);
  });

  test('document stream is capped even without trustworthy content length',
      () async {
    final dio = Dio();
    addTearDown(dio.close);
    dio.httpClientAdapter = BoundedResponseAdapter(_ChunkAdapter());
    await expectLater(
        dio.get<List<int>>(
            'https://fixture.invalid/api/company/documents/id/download',
            options: Options(responseType: ResponseType.bytes)),
        throwsA(isA<DioException>()));
  });
}

class _ChunkAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(RequestOptions options,
          Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async =>
      ResponseBody(
          Stream.fromIterable(List.generate(11, (_) => Uint8List(1024 * 1024))),
          200);
  @override
  void close({bool force = false}) {}
}
