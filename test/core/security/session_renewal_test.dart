import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

import 'package:cleaning_service_driver/core/api/api_environment.dart';
import 'package:cleaning_service_driver/core/api/session_error_interceptor.dart';
import 'package:cleaning_service_driver/core/api/session_request_interceptor.dart';
import 'package:cleaning_service_driver/core/security/session_credentials.dart';
import 'package:cleaning_service_driver/core/security/session_lifecycle.dart';
import 'package:cleaning_service_driver/core/security/request_security_interceptor.dart';
import 'package:cleaning_service_driver/core/security/session_renewal_coordinator.dart';
import 'package:cleaning_service_driver/core/security/session_renewal_transport.dart';
import 'package:cleaning_service_driver/core/storage/secure_storage_service.dart';
import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:cleaning_service_driver/features/chats/data/chat_socket_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;

const _id = '0123456789abcdef01234567';
const _requestId = '7d3f10b2-875d-4e73-8857-5d268e80d326';
const _sessionId = '1a6a33df-8db6-4bc7-b526-577f8c258dd0';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late DateTime now;
  late SecureStorageService storage;
  late _Transport transport;
  late SessionRenewalCoordinator sessions;
  var terminal = 0;
  SessionCredentials renewed([String token = 'fresh']) => SessionCredentials(
      token: _jwt(token),
      user: User(id: _id, username: 'اسم <plain>', role: 'manager'),
      refreshToken: 'refresh-new',
      sessionId: _sessionId,
      accessExpiresAt: now.add(const Duration(seconds: 900)));
  void coordinator() {
    sessions = SessionRenewalCoordinator(
        storage: storage,
        transport: transport,
        onTerminal: () async {
          terminal++;
        },
        now: () => now,
        newId: () => _requestId);
  }

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({
      'access_token': 'legacy',
      'auth_user': jsonEncode(User(id: _id).toJson()),
      'fcm_token': 'push',
      'areas': 'cache'
    });
    now = DateTime.utc(2026, 10, 16);
    storage = SecureStorageService();
    terminal = 0;
    transport = _Transport((_) async => renewed());
    coordinator();
  });

  test(
      'five-field envelope accepts optional user fields without login-only metadata',
      () {
    final parsed = DioSessionRenewalTransport.parse({
      'success': true,
      'data': {
        'user': {'id': _id, 'role': 'manager'},
        'token': _jwt('access'),
        'refreshToken': 'opaque',
        'sessionId': _sessionId,
        'accessExpiresAt': '2026-10-16T00:15:00.000Z'
      }
    });
    expect(parsed.user?.id, _id);
    expect(parsed.refreshToken, 'opaque');
    for (final field in [
      'user',
      'token',
      'refreshToken',
      'sessionId',
      'accessExpiresAt'
    ]) {
      final body = {
        'success': true,
        'data': {...parsed.toJson()}..remove(field)
      };
      expect(
          () => DioSessionRenewalTransport.parse(body), throwsFormatException);
    }
  });

  test('actual disposable backend payloads preserve provider identity',
      () async {
    final fixture = jsonDecode(
        File('test/fixtures/session_renewal_provider.json')
            .readAsStringSync()) as Map;
    final migrated = DioSessionRenewalTransport.parse(fixture['migration']);
    final refreshed = DioSessionRenewalTransport.parse(fixture['renewal']);
    now = migrated.accessExpiresAt!.subtract(const Duration(seconds: 900));
    FlutterSecureStorage.setMockInitialValues({
      'access_token': fixture['legacyBearer'] as String,
      'auth_user': jsonEncode(migrated.user!.toJson()),
    });
    transport.remote = (pending) async {
      expect(pending.requestIsRefresh, isFalse);
      expect(pending.requestCredential, fixture['legacyBearer']);
      return migrated;
    };
    final generation = storage.authGeneration;
    expect((await sessions.ensureSession())?.user?.role, 'manager');
    expect((await storage.getUser())?.businessId, migrated.user?.businessId);
    now = migrated.accessExpiresAt!.subtract(const Duration(seconds: 60));
    transport.remote = (pending) async {
      expect(pending.requestCredential, migrated.refreshToken);
      expect(pending.requestIsRefresh, isTrue);
      return refreshed;
    };
    expect((await sessions.ensureSession())?.token, refreshed.token);
    expect(storage.authGeneration, generation);
    expect((await storage.credentials())?.user?.id, refreshed.user?.id);
  });

  test('enrollment persists request and original proof before network use',
      () async {
    transport.remote = (pending) async {
      final persisted = jsonDecode((await storage
          .getString(SecureStorageService.sessionEnvelopeKey))!) as Map;
      expect(persisted['requestId'], pending.requestId);
      expect(persisted['requestCredential'], 'legacy');
      expect(await storage.getString('access_token'), 'legacy');
      return renewed();
    };
    final generation = storage.authGeneration;
    final revision = storage.credentialRevision;
    expect((await sessions.ensureSession())?.token, _jwt('fresh'));
    expect(storage.authGeneration, generation);
    expect(storage.credentialRevision, revision + 1);
    expect(await storage.getFcmToken(), 'push');
    expect(await storage.getString('areas'), 'cache');
    expect((await storage.credentials())?.requestId, isNull);
  });

  test('credential rotation preserves a newer concurrently saved profile',
      () async {
    transport.remote = (_) async {
      await storage
          .saveUser(User(id: _id, role: 'manager', username: 'newer profile'));
      return renewed();
    };
    final generation = storage.authGeneration;
    expect((await sessions.ensureSession())?.token, _jwt('fresh'));
    expect((await storage.getUser())?.username, 'newer profile');
    expect(storage.authGeneration, generation);
  });

  test('concurrent callers share one enrollment', () async {
    final response = Completer<SessionCredentials>();
    transport.remote = (_) => response.future;
    final callers = List.generate(12, (_) => sessions.ensureSession());
    while (transport.calls == 0) {
      await Future<void>.delayed(Duration.zero);
    }
    expect(transport.calls, 1);
    response.complete(renewed());
    expect((await Future.wait(callers)).every((s) => s?.token == _jwt('fresh')),
        isTrue);
    expect(transport.calls, 1);
  });

  test('lost enrollment response survives restart with identical request/proof',
      () async {
    transport.remote = (_) async => throw TimeoutException('offline');
    expect((await sessions.ensureSession())?.token, 'legacy');
    final first = transport.inputs.single;
    coordinator(); // Recovery is from storage, not the old coordinator.
    transport.remote = (pending) async {
      expect(pending.requestId, first.requestId);
      expect(pending.requestCredential, first.requestCredential);
      return renewed();
    };
    expect((await sessions.ensureSession())?.token, _jwt('fresh'));
  });

  test('refresh retries the previous credential and same persisted operation',
      () async {
    await sessions.ensureSession();
    now = now.add(const Duration(seconds: 850));
    transport.remote = (_) async => throw TimeoutException('lost response');
    await sessions.ensureSession();
    final first = transport.inputs.last;
    expect(first.requestIsRefresh, isTrue);
    expect(first.requestCredential, 'refresh-new');
    coordinator();
    transport.remote = (pending) async {
      expect(pending.requestId, first.requestId);
      expect(pending.requestCredential, first.requestCredential);
      return renewed('next-access');
    };
    expect((await sessions.ensureSession())?.token, _jwt('next-access'));
  });

  for (final status in [400, 401, 403, 404, 429, 500, 503]) {
    test(
        'HTTP$status without terminal code retains login and limits retry traffic',
        () async {
      transport.remote = (_) async =>
          throw _failure(status, status == 503 ? 'AUTH_UNAVAILABLE' : null);
      expect((await sessions.ensureSession())?.token, 'legacy');
      expect((await sessions.ensureSession(force: true))?.token, 'legacy');
      expect(transport.calls, 1);
      expect(terminal, 0);
      expect(await storage.getAccessToken(), 'legacy');
      now = now.add(Duration(minutes: status == 404 ? 6 : 1));
      await sessions.ensureSession();
      expect(transport.calls, 2);
    });
  }

  for (final code in SessionRenewalCoordinator.terminalCodes) {
    test('confirmed $code clears only its captured session', () async {
      transport.remote = (_) async => throw _failure(401, code);
      expect(await sessions.ensureSession(), isNull);
      expect(await storage.getAccessToken(), isNull);
      expect(terminal, 1);
    });
  }

  test('late terminal response cannot clear a replacement account', () async {
    final remote = Completer<SessionCredentials>();
    transport.remote = (_) => remote.future;
    final old = sessions.ensureSession();
    while (transport.calls == 0) {
      await Future<void>.delayed(Duration.zero);
    }
    await storage.saveSession(
        'account-B', User(id: 'bbbbbbbbbbbbbbbbbbbbbbbb'));
    remote.completeError(_failure(401, 'AUTH_SESSION_REVOKED'));
    await old;
    expect(await storage.getAccessToken(), 'account-B');
    expect(terminal, 0);
  });

  test(
      'logout cancels renewal; ignored cancellation and late success cannot restore it',
      () async {
    final remote = Completer<SessionCredentials>();
    transport.remote = (_) => remote.future;
    final pending = sessions.ensureSession();
    while (transport.calls == 0) {
      await Future<void>.delayed(Duration.zero);
    }
    sessions.cancelRenewal();
    final captured = await storage.beginLogout();
    expect(captured.session?.token, 'legacy');
    expect(transport.lastCancellation?.isCancelled, isTrue);
    remote.complete(renewed());
    await pending;
    expect(await storage.getAccessToken(), isNull);
    expect(await storage.getUser(), isNull);
  });

  test('renewal is proactive only within the sixty-second window', () async {
    await sessions.ensureSession();
    now = now.add(const Duration(seconds: 839));
    await sessions.ensureSession();
    expect(transport.calls, 1);
    now = now.add(const Duration(seconds: 1));
    await sessions.ensureSession();
    expect(transport.calls, 2);
  });

  test('malformed response preserves committed credentials and retry recovery',
      () async {
    transport.remote = (_) async =>
        DioSessionRenewalTransport.parse({'success': true, 'data': {}});
    expect((await sessions.ensureSession())?.token, 'legacy');
    expect((await storage.credentials())?.requestId, _requestId);
  });

  for (final invalid in [
    'identity',
    'role',
    'disabled',
    'expiry',
    'longExpiry',
    'sessionId',
    'jwt'
  ]) {
    test('invalid renewed $invalid retains the committed session and recovery',
        () async {
      await sessions.ensureSession();
      final values = renewed('bad').toJson();
      if (invalid == 'identity') {
        values['user'] = {'id': 'bbbbbbbbbbbbbbbbbbbbbbbb', 'role': 'manager'};
      }
      if (invalid == 'role') values['user'] = {'id': _id, 'role': 'customer'};
      if (invalid == 'disabled') {
        values['user'] = {'id': _id, 'role': 'manager', 'enabled': false};
      }
      if (invalid == 'expiry') {
        values['accessExpiresAt'] =
            now.subtract(const Duration(seconds: 1)).toIso8601String();
      }
      if (invalid == 'longExpiry') {
        values['accessExpiresAt'] =
            now.add(const Duration(hours: 2)).toIso8601String();
      }
      if (invalid == 'sessionId') values['sessionId'] = _requestId;
      if (invalid == 'jwt') values['token'] = 'opaque-invalid-access';
      transport.remote = (_) async => SessionCredentials.fromJson(values);
      expect((await sessions.ensureSession(force: true))?.token, _jwt('fresh'));
      expect((await storage.credentials())?.requestId, isNotNull);
      expect(terminal, 0);
    });
  }

  test('confirmed pre-handler access expiry retries reusable JSON only once',
      () async {
    await sessions.ensureSession();
    final dio = _api(sessions);
    var calls = 0;
    dio.httpClientAdapter = _Adapter((options) {
      calls++;
      expect(options.data, {'amount': 0});
      if (calls == 1) {
        return ResponseBody.fromString(
            jsonEncode({'code': 'AUTH_ACCESS_EXPIRED'}), 401,
            headers: {
              Headers.contentTypeHeader: ['application/json']
            });
      }
      expect(options.headers['Authorization'], 'Bearer ${_jwt('second')}');
      return ResponseBody.fromString(jsonEncode({'ok': true}), 200, headers: {
        Headers.contentTypeHeader: ['application/json']
      });
    });
    transport.remote = (_) async => renewed('second');
    expect((await dio.post('/orders', data: {'amount': 0})).data, {'ok': true});
    expect(calls, 2);
    expect(transport.calls, 2);
    dio.close();
  });

  for (final status in [401, 403, 500, 503]) {
    test(
        'unclassified HTTP$status never replays a mutation or clears credentials',
        () async {
      await sessions.ensureSession();
      final dio = _api(sessions);
      var calls = 0;
      dio.httpClientAdapter = _Adapter((options) {
        calls++;
        return ResponseBody.fromString('{}', status, headers: {
          Headers.contentTypeHeader: ['application/json']
        });
      });
      await expectLater(dio.post('/orders', data: {'amount': 0}),
          throwsA(isA<DioException>()));
      expect(calls, 1);
      expect(transport.calls, 1);
      expect(await storage.getAccessToken(), _jwt('fresh'));
      dio.close();
    });
  }

  for (final code in ['AUTH_ACCESS_EXPIRED', 'AUTH_SESSION_REVOKED']) {
    test('a stale $code cannot retry a mutation under or clear account B',
        () async {
      await sessions.ensureSession();
      final dio = _api(sessions);
      var calls = 0;
      dio.httpClientAdapter = _Adapter((options) async {
        calls++;
        await storage.saveSession(
            'account-B', User(id: 'bbbbbbbbbbbbbbbbbbbbbbbb'));
        return ResponseBody.fromString(jsonEncode({'code': code}), 401,
            headers: {
              Headers.contentTypeHeader: ['application/json']
            });
      });
      await expectLater(dio.post('/orders', data: {'amount': 0}),
          throwsA(isA<DioException>()));
      expect(calls, 1);
      expect(transport.calls, 1);
      expect(await storage.getAccessToken(), 'account-B');
      dio.close();
    });
  }

  test(
      'an account change behind an asynchronous request gate cannot dispatch account B',
      () async {
    await sessions.ensureSession();
    final dio = _api(sessions);
    final reached = Completer<void>();
    final release = Completer<void>();
    dio.interceptors.insert(2,
        InterceptorsWrapper(onRequest: (options, handler) async {
      reached.complete();
      await release.future;
      handler.next(options);
    }));
    var dispatched = 0;
    dio.httpClientAdapter = _Adapter((_) {
      dispatched++;
      return ResponseBody.fromString('{}', 200);
    });
    final request = expectLater(
        dio.post('/orders', data: {'amount': 0}), throwsA(isA<DioException>()));
    await reached.future;
    await storage.saveSession(
        'account-B', User(id: 'bbbbbbbbbbbbbbbbbbbbbbbb'));
    release.complete();
    await request;
    expect(dispatched, 0);
    expect(await storage.getAccessToken(), 'account-B');
    dio.close();
  });

  test('finalized multipart is never automatically replayed', () async {
    await sessions.ensureSession();
    final form = FormData.fromMap({
      'images': MultipartFile.fromBytes([0x89, 0x50, 0x4e, 0x47],
          filename: 'fixture.png', contentType: MediaType('image', 'png'))
    });
    await form.finalize().drain<void>();
    final dio = _api(sessions);
    var calls = 0;
    dio.interceptors.insert(3,
        InterceptorsWrapper(onRequest: (options, handler) {
      calls++;
      handler.reject(_failure(401, 'AUTH_ACCESS_EXPIRED', options), true);
    }));
    await expectLater(
        dio.post('/upload', data: form), throwsA(isA<DioException>()));
    expect(calls, 1);
    expect(transport.calls, 1);
    dio.close();
  });

  test(
      'dedicated transport uses injected adapter, exact headers and public refresh/revoke',
      () async {
    final paths = <String>[];
    final adapter = _Adapter((request) {
      paths.add(request.uri.path);
      expect(request.followRedirects, isFalse);
      expect(request.maxRedirects, 0);
      expect(request.headers['Accept-Language'], 'ar');
      if (request.uri.path.endsWith('/session')) {
        expect(request.headers['Authorization'], 'Bearer legacy');
      } else {
        expect(
            request.headers.keys
                .where((k) => k.toLowerCase() == 'authorization'),
            isEmpty);
      }
      if (request.uri.path.endsWith('/session-revoke')) {
        return ResponseBody.fromString('', 204);
      }
      return ResponseBody.fromString(
          jsonEncode({
            'success': true,
            'data': {
              'user': {'id': _id, 'role': 'manager'},
              'token': _jwt('access'),
              'refreshToken': 'refresh',
              'sessionId': _sessionId,
              'accessExpiresAt': '2026-10-16T00:15:00Z'
            }
          }),
          200,
          headers: {
            Headers.contentTypeHeader: ['application/json']
          });
    });
    final direct = DioSessionRenewalTransport(
        adapter: () => adapter, languageTag: () => 'ar');
    final enrolled = await direct.renew(
        const SessionCredentials(token: 'legacy').withRecovery(_requestId),
        CancelToken());
    await direct.renew(enrolled.withRecovery(_requestId), CancelToken());
    await direct.revoke(enrolled, CancelToken());
    expect(paths,
        ['/api/auth/session', '/api/auth/refresh', '/api/auth/session-revoke']);
  });

  test('dedicated transport bounds chunked response bytes before JSON decoding',
      () async {
    final adapter = _Adapter((_) => ResponseBody(
            Stream<Uint8List>.fromIterable(
                [Uint8List(700 * 1024), Uint8List(700 * 1024)]),
            200,
            headers: {
              Headers.contentTypeHeader: ['application/json']
            }));
    final direct = DioSessionRenewalTransport(
        adapter: () => adapter, languageTag: () => 'en');
    await expectLater(
        direct.renew(
            const SessionCredentials(token: 'legacy').withRecovery(_requestId),
            CancelToken()),
        throwsA(predicate((error) =>
            error is DioException &&
            error.error is FormatException &&
            (error.error as FormatException).message ==
                'Session response exceeds the limit.')));
  });

  testWidgets('startup and foreground resume share proactive renewal',
      (tester) async {
    await tester.pumpWidget(
        SessionLifecycle(sessions: sessions, child: const SizedBox()));
    await tester.pumpAndSettle();
    expect(transport.calls, 1);
    now = now.add(const Duration(seconds: 850));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(transport.calls, 2);
    await tester.pumpWidget(const SizedBox());
  });

  test(
      'socket connection renews first and confirmed expiry rebuilds its bearer',
      () async {
    final sockets = <_Socket>[];
    final bearers = <String>[];
    final chat = ChatSocketService(
        sessions: sessions,
        socketFactory: (url, options) {
          bearers
              .add((options['extraHeaders'] as Map)['Authorization'] as String);
          final socket = _Socket();
          sockets.add(socket);
          return socket;
        });
    await chat.connect();
    expect(bearers, ['Bearer ${_jwt('fresh')}']);
    expect(transport.calls, 1);
    transport.remote = (_) async => renewed('socket-new');
    await sockets
        .first.handlers['auth_error']!({'code': 'AUTH_ACCESS_EXPIRED'});
    expect(
        bearers, ['Bearer ${_jwt('fresh')}', 'Bearer ${_jwt('socket-new')}']);
    expect(sockets.first.disposed, isTrue);
    await sockets.last.handlers['auth_error']!({'code': 'AUTH_UNAVAILABLE'});
    expect(await storage.getAccessToken(), _jwt('socket-new'));
    await chat.close();
  });

  test('logout during socket renewal cannot reconnect a stale account',
      () async {
    final remote = Completer<SessionCredentials>();
    transport.remote = (_) => remote.future;
    var sockets = 0;
    final chat = ChatSocketService(
        sessions: sessions,
        socketFactory: (_, __) {
          sockets++;
          return _Socket();
        });
    final connecting = chat.connect();
    while (transport.calls == 0) {
      await Future<void>.delayed(Duration.zero);
    }
    sessions.cancelRenewal();
    await storage.beginLogout();
    await chat.disconnect();
    remote.complete(renewed());
    await connecting;
    expect(sockets, 0);
    await chat.close();
  });
}

Dio _api(SessionRenewalCoordinator sessions) {
  final dio = Dio(BaseOptions(baseUrl: ApiEnvironment.apiUrl));
  dio.interceptors.add(RequestSecurityInterceptor(
      accountGeneration: () => sessions.storage.authGeneration));
  dio.interceptors.add(SessionRequestInterceptor(
      accountGeneration: () => sessions.storage.authGeneration,
      readAccessToken: () async => (await sessions.ensureSession())?.token,
      languageTag: () => 'en'));
  dio.interceptors.add(SessionErrorInterceptor(sessions, dio));
  return dio;
}

DioException _failure(int status, String? code, [RequestOptions? request]) {
  final options = request ?? RequestOptions(path: '/auth/session');
  return DioException(
      requestOptions: options,
      response: Response(
          requestOptions: options,
          statusCode: status,
          data: {if (code != null) 'code': code}));
}

class _Transport implements SessionRenewalTransport {
  _Transport(this.remote);
  Future<SessionCredentials> Function(SessionCredentials) remote;
  int calls = 0;
  final inputs = <SessionCredentials>[];
  CancelToken? lastCancellation;
  @override
  Future<SessionCredentials> renew(
      SessionCredentials pending, CancelToken cancel) {
    calls++;
    inputs.add(pending);
    lastCancellation = cancel;
    return remote(pending);
  }

  @override
  Future<void> revoke(SessionCredentials session, CancelToken cancel) async {}
  @override
  Future<void> deactivate(
      {required String bearer,
      required String fcmToken,
      required String deviceId,
      required String platform,
      required CancelToken cancel}) async {}
}

class _Adapter implements HttpClientAdapter {
  _Adapter(this.respond);
  final FutureOr<ResponseBody> Function(RequestOptions) respond;
  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? stream,
          Future<void>? cancelFuture) async =>
      respond(options);
  @override
  void close({bool force = false}) {}
}

class _Socket implements socket_io.Socket {
  @override
  var io = socket_io.io('https://fixture.invalid',
      <String, dynamic>{'autoConnect': false, 'forceNew': true}).io;
  final handlers = <String, dynamic Function(dynamic)>{};
  bool disposed = false;
  @override
  bool connected = false;
  @override
  Function() on(String event, dynamic Function(dynamic) handler) {
    handlers[event] = handler;
    return () {
      handlers.remove(event);
    };
  }

  @override
  socket_io.Socket connect() {
    connected = true;
    return this;
  }

  @override
  socket_io.Socket disconnect() {
    connected = false;
    return this;
  }

  @override
  void dispose() {
    disposed = true;
    connected = false;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

String _jwt(String fixture) {
  String encode(Object value) =>
      base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
  final signature =
      base64Url.encode(List<int>.filled(32, 7)).replaceAll('=', '');
  return '${encode({'alg': 'HS256', 'typ': 'JWT'})}.${encode({
        'fixture': fixture
      })}.$signature';
}
