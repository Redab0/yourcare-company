import 'dart:async';
import 'dart:convert';

import 'package:cleaning_service_driver/core/api/api_environment.dart';
import 'package:cleaning_service_driver/core/security/session_credentials.dart';
import 'package:cleaning_service_driver/core/security/session_renewal_coordinator.dart';
import 'package:cleaning_service_driver/core/security/session_renewal_transport.dart';
import 'package:cleaning_service_driver/core/storage/secure_storage_service.dart';
import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _account = '0123456789abcdef01234567';
const _otherAccount = 'bbbbbbbbbbbbbbbbbbbbbbbb';
const _sessionId = '1a6a33df-8db6-4bc7-b526-577f8c258dd0';
const _requestId = '7d3f10b2-875d-4e73-8857-5d268e80d326';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  late Map<String, String> persisted;
  late DateTime now;
  late _ReadGateStorage storage;
  late _Transport transport;
  late SessionRenewalCoordinator sessions;
  Future<void> Function(String, String)? onWrite;
  Future<void> Function(String)? onRead;
  var terminal = 0;
  String key(String raw) => ApiEnvironment.storageKey(raw);
  SessionCredentials renewed() => SessionCredentials(
      token: _jwt('replacement'),
      user: User(id: _account, role: 'manager'),
      refreshToken: 'replacement-refresh',
      sessionId: _sessionId,
      accessExpiresAt: now.add(const Duration(minutes: 15)));
  SessionRenewalCoordinator coordinator() => SessionRenewalCoordinator(
      storage: storage,
      transport: transport,
      onTerminal: () async => terminal++,
      now: () => now,
      newId: () => _requestId);

  setUp(() {
    now = DateTime.utc(2026, 10, 22);
    terminal = 0;
    onWrite = null;
    onRead = null;
    persisted = {
      key('access_token'): 'legacy',
      key('auth_user'): jsonEncode(User(id: _account, role: 'manager').toJson())
    };
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      final args = call.arguments as Map;
      final storageKey = args['key'] as String;
      switch (call.method) {
        case 'read':
          await onRead?.call(storageKey);
          return persisted[storageKey];
        case 'write':
          final value = args['value'] as String;
          await onWrite?.call(storageKey, value);
          persisted[storageKey] = value;
          return null;
        case 'delete':
          persisted.remove(storageKey);
          return null;
        default:
          throw StateError('Unexpected secure-storage operation.');
      }
    });
    storage = _ReadGateStorage();
    transport = _Transport((_) async => renewed());
    sessions = coordinator();
  });

  tearDown(() async {
    sessions.cancelRenewal();
    await _drain();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('confirmation waits for commit completion and a fresh native read',
      () async {
    final committed = Completer<void>();
    final release = Completer<void>();
    var replacementWritten = false;
    var reread = false;
    onWrite = (_, value) async {
      if (jsonDecode(value)['refreshToken'] != null) {
        committed.complete();
        await release.future;
        replacementWritten = true;
      }
    };
    onRead = (_) async {
      if (replacementWritten) reread = true;
    };
    transport.onConfirm = (session, _) async {
      expect(replacementWritten, isTrue);
      expect(reread, isTrue);
      final stored = await SecureStorageService().credentials();
      expect(stored?.token, session.token);
      expect(stored?.refreshToken, session.refreshToken);
      expect(stored?.requestId, isNull);
      expect(stored?.sessionId, _sessionId);
      expect(session.token, isNot('legacy'));
    };
    final switching = sessions.ensureSession();
    await committed.future;
    await _drain();
    expect(transport.confirmations, isEmpty);
    release.complete();
    expect((await switching)?.token, renewed().token);
    await _drain();
    expect(transport.confirmations, hasLength(1));
    expect(await storage.getAccessToken(), renewed().token);
    expect(terminal, 0);
  });

  test('failed secure-storage commit never confirms the legacy migration',
      () async {
    onWrite = (_, value) async {
      if (jsonDecode(value)['refreshToken'] != null) {
        throw PlatformException(code: 'write-failed');
      }
    };
    expect((await sessions.ensureSession())?.token, 'legacy');
    await _drain();
    expect(transport.confirmations, isEmpty);
    expect((await storage.credentials())?.requestCredential, 'legacy');
    expect(terminal, 0);
  });

  test('a transient reread failure postpones retirement without losing login',
      () async {
    var failNext = false;
    onWrite = (_, value) async {
      if (jsonDecode(value)['refreshToken'] != null) failNext = true;
    };
    onRead = (_) async {
      if (failNext) {
        failNext = false;
        throw PlatformException(code: 'read-failed');
      }
    };
    expect((await sessions.ensureSession())?.token, renewed().token);
    await _drain();
    expect(transport.confirmations, isEmpty);
    expect(await storage.getAccessToken(), renewed().token);
    now = now.add(const Duration(seconds: 31));
    await sessions.ensureSession();
    await _drain();
    expect(transport.confirmations, hasLength(1));
    expect(transport.renewals, 1);
    expect(terminal, 0);
  });

  test('saved renewable session confirms on restart without reenrollment',
      () async {
    await sessions.ensureSession();
    await _drain();
    sessions = coordinator();
    await sessions.ensureSession();
    await _drain();
    expect(transport.renewals, 1);
    expect(transport.confirmations, hasLength(2));
    expect(transport.confirmations.last.sessionId, _sessionId);
  });

  test('concurrent reads share confirmation and do not wait for its network',
      () async {
    await sessions.ensureSession();
    await _drain();
    sessions = coordinator();
    final reply = Completer<void>();
    transport.onConfirm = (_, __) => reply.future;
    final reads =
        await Future.wait(List.generate(12, (_) => sessions.ensureSession()));
    await _drain();
    expect(reads.every((session) => session?.token == renewed().token), isTrue);
    expect(transport.confirmations, hasLength(2));
    expect(transport.renewals, 1);
    reply.complete();
    await _drain();
    await sessions.ensureSession();
    await _drain();
    expect(transport.confirmations, hasLength(2));
  });

  for (final failure in [
    (401, 'AUTH_ACCESS_EXPIRED'),
    (401, 'AUTH_SESSION_REVOKED'),
    (401, 'AUTH_INVALID'),
    (403, null),
    (404, null),
    (429, null),
    (503, 'AUTH_UNAVAILABLE'),
    (0, null)
  ]) {
    test('confirmation failure ${failure.$1} retains credentials and retries',
        () async {
      transport.onConfirm = (_, __) async {
        if (failure.$1 == 0) throw TimeoutException('Lost 204 response.');
        throw _failure(failure.$1, failure.$2);
      };
      expect((await sessions.ensureSession())?.token, renewed().token);
      await _drain();
      expect(transport.confirmations, hasLength(1));
      await sessions.ensureSession();
      await _drain();
      expect(transport.confirmations, hasLength(1));
      expect(await storage.getAccessToken(), renewed().token);
      expect(terminal, 0);
      now = now.add(failure.$1 == 404
          ? const Duration(minutes: 5, seconds: 1)
          : const Duration(seconds: 31));
      transport.onConfirm = (_, __) async {};
      await sessions.ensureSession();
      await _drain();
      expect(transport.confirmations, hasLength(2));
      expect(transport.renewals, 1);
      expect(terminal, 0);
    });
  }

  test('expired saved access proof renews before confirming with the new proof',
      () async {
    await sessions.ensureSession();
    await _drain();
    sessions = coordinator();
    now = now.add(const Duration(minutes: 16));
    transport.onRenew = (pending) async {
      expect(pending.requestIsRefresh, isTrue);
      final values = renewed().toJson()..['token'] = _jwt('refreshed');
      return SessionCredentials.fromJson(values);
    };
    await sessions.ensureSession();
    await _drain();
    expect(transport.renewals, 2);
    expect(transport.confirmations.last.token, _jwt('refreshed'));
    expect(transport.confirmations.last.token, isNot(_jwt('replacement')));
  });

  test('account switch during confirmation reread cannot send a stale proof',
      () async {
    await sessions.ensureSession();
    await _drain();
    sessions = coordinator();
    final reached = Completer<void>();
    final release = Completer<void>();
    // Initial ensure read passes; the independent confirmation reread pauses.
    storage.onRead = (session) async {
      storage.onRead = (_) async {
        storage.onRead = null;
        reached.complete();
        await release.future;
      };
    };
    await sessions.ensureSession();
    await reached.future;
    await storage.saveSession('account-B', User(id: _otherAccount));
    release.complete();
    await _drain();
    expect(transport.confirmations, hasLength(1));
    expect(await storage.getAccessToken(), 'account-B');
    expect(terminal, 0);
  });

  test(
      'logout cancels confirmation and late errors cannot restore or clear login',
      () async {
    final reply = Completer<void>();
    transport.onConfirm = (_, __) => reply.future;
    await sessions.ensureSession();
    await _drain();
    final cancellation = transport.cancellations.single;
    sessions.cancelRenewal();
    await storage.beginLogout();
    expect(cancellation.isCancelled, isTrue);
    await storage.saveSession('account-B', User(id: _otherAccount));
    reply.completeError(_failure(401, 'AUTH_SESSION_REVOKED'));
    await _drain();
    expect(await storage.getAccessToken(), 'account-B');
    expect(terminal, 0);
  });

  test('typed confirmation transport sends only new bearer and session ID',
      () async {
    final requests = <RequestOptions>[];
    final direct = DioSessionRenewalTransport(
        adapter: () => _Adapter((request) {
              requests.add(request);
              return ResponseBody.fromString('', 204);
            }),
        languageTag: () => 'ar');
    await direct.confirm(renewed(), CancelToken());
    final request = requests.single;
    expect(request.uri.path, '/api/auth/session/confirm');
    expect(request.headers['Authorization'], 'Bearer ${renewed().token}');
    expect(request.headers['channel'], 'MANAGER');
    expect(request.headers['Accept-Language'], 'ar');
    expect(request.headers['locale'], 'ar');
    expect(request.data, {'sessionId': _sessionId});
    expect(request.followRedirects, isFalse);
    expect(request.maxRedirects, 0);
    expect(request.receiveTimeout, const Duration(seconds: 8));
  });

  test('confirmation validates typed UUID and committed renewable credentials',
      () async {
    var sends = 0;
    final direct = DioSessionRenewalTransport(
        adapter: () => _Adapter((_) {
              sends++;
              return ResponseBody.fromString('', 204);
            }),
        languageTag: () => 'en');
    for (final change in [
      {'sessionId': 'not-a-uuid'},
      {'sessionId': '1a6a33df-8db6-1bc7-b526-577f8c258dd0'},
      {'refreshToken': null},
      {'token': 'legacy'},
      {'requestId': _requestId}
    ]) {
      await expectLater(
          direct.confirm(
              SessionCredentials.fromJson({...renewed().toJson(), ...change}),
              CancelToken()),
          throwsFormatException);
    }
    expect(sends, 0);
  });

  test('confirmation rejects redirect and unexpected success responses',
      () async {
    for (final status in [200, 302]) {
      final direct = DioSessionRenewalTransport(
          adapter: () =>
              _Adapter((_) => ResponseBody.fromString('', status, headers: {
                    'location': ['https://untrusted.invalid/confirm']
                  })),
          languageTag: () => 'en');
      await expectLater(direct.confirm(renewed(), CancelToken()),
          throwsA(isA<DioException>()));
    }
  });

  test('confirmation rejects an insecure destination before adapter dispatch',
      () async {
    var sends = 0;
    final direct = DioSessionRenewalTransport(
        apiUrl: 'http://fixture.invalid/api',
        adapter: () => _Adapter((_) {
              sends++;
              return ResponseBody.fromString('', 204);
            }),
        languageTag: () => 'en');
    await expectLater(
        direct.confirm(renewed(), CancelToken()), throwsFormatException);
    expect(sends, 0);
  });

  test('confirmation deadline cancels its transport without credential changes',
      () async {
    final never = Completer<ResponseBody>();
    final cancellation = CancelToken();
    final direct = DioSessionRenewalTransport(
        deadline: const Duration(milliseconds: 20),
        adapter: () => _Adapter((_) => never.future),
        languageTag: () => 'en');
    await expectLater(direct.confirm(renewed(), cancellation),
        throwsA(isA<TimeoutException>()));
    expect(cancellation.isCancelled, isTrue);
    never.complete(ResponseBody.fromString('', 204));
    expect(await storage.getAccessToken(), 'legacy');
  });
}

Future<void> _drain() async {
  for (var i = 0; i < 20; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

class _ReadGateStorage extends SecureStorageService {
  Future<void> Function(SessionCredentials?)? onRead;
  @override
  Future<SessionCredentials?> credentials() async {
    final session = await super.credentials();
    await onRead?.call(session);
    return session;
  }
}

class _Transport implements SessionRenewalTransport {
  _Transport(this.onRenew);
  Future<SessionCredentials> Function(SessionCredentials) onRenew;
  Future<void> Function(SessionCredentials, CancelToken) onConfirm =
      (_, __) async {};
  int renewals = 0;
  final confirmations = <SessionCredentials>[];
  final cancellations = <CancelToken>[];
  @override
  Future<SessionCredentials> renew(
      SessionCredentials pending, CancelToken cancel) {
    renewals++;
    return onRenew(pending);
  }

  @override
  Future<void> confirm(SessionCredentials session, CancelToken cancel) {
    confirmations.add(session);
    cancellations.add(cancel);
    return onConfirm(session, cancel);
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

DioException _failure(int status, String? code) {
  final request = RequestOptions(path: '/auth/session/confirm');
  return DioException(
      requestOptions: request,
      response: Response(
          requestOptions: request,
          statusCode: status,
          data: {if (code != null) 'code': code}));
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
