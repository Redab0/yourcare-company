import 'dart:async';
import 'package:cleaning_service_driver/core/security/session_credentials.dart';
import 'package:cleaning_service_driver/core/security/session_renewal_coordinator.dart';
import 'package:cleaning_service_driver/core/security/session_renewal_transport.dart';
import 'package:cleaning_service_driver/core/storage/secure_storage_service.dart';
import 'package:cleaning_service_driver/data/models/auth/login_credentials.dart';
import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:cleaning_service_driver/data/repositories/auth/auth_repository.dart';
import 'package:cleaning_service_driver/data/services/auth/auth_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SecureStorageService storage;
  late _Transport transport;
  late SessionRenewalCoordinator sessions;
  late AuthRepository repository;
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({'access_token': 'session'});
    storage = SecureStorageService();
    transport = _Transport();
    sessions = SessionRenewalCoordinator(
        storage: storage, transport: transport, onTerminal: () async {});
    repository = AuthRepository(_AuthService(),
        storage: storage,
        sessions: sessions,
        logoutTimeout: const Duration(milliseconds: 40));
  });

  test(
      'manual logout tombstones before remote revocation with captured credential',
      () async {
    transport.remote = (captured) async {
      expect(captured.token, 'session');
      expect(await storage.getAccessToken(), isNull);
      expect(await storage.getUser(), isNull);
    };
    await repository.logout();
    expect(transport.called, isTrue);
    expect(transport.cancelToken?.isCancelled, isTrue);
    expect(await storage.getAccessToken(), isNull);
  });

  test('offline/older server cannot undo durable local sign-out', () async {
    transport.remote = (_) async => throw StateError('offline/404');
    await repository.logout();
    expect(await storage.getAccessToken(), isNull);
    expect(transport.cancelToken?.isCancelled, isTrue);
  });

  test('an old remote logout cannot clear a newer complete login', () async {
    final pending = Completer<void>();
    transport.remote = (_) => pending.future;
    final logout = repository.logout();
    while (!transport.called) {
      await Future<void>.delayed(Duration.zero);
    }
    await storage.saveSession('new-session', User(id: 'new-user'));
    pending.complete();
    await logout;
    expect(await storage.getAccessToken(), 'new-session');
    expect((await storage.getUser())?.id, 'new-user');
  });

  test('pinned push deactivation precedes remote revoke after local tombstone',
      () async {
    await storage.saveFcmToken('old-push');
    await storage.saveDeviceId('device');
    final order = <String>[];
    transport.deactivation = (bearer, fcm) async {
      expect(bearer, 'session');
      expect(fcm, 'old-push');
      expect(await storage.getAccessToken(), isNull);
      order.add('push');
    };
    transport.remote = (_) async {
      order.add('revoke');
    };
    await repository.logout();
    expect(order, ['push', 'revoke']);
  });

  test('timed-out remote revoke is cancelled and cannot hold local sign-out',
      () async {
    transport.remote = (_) => Completer<void>().future;
    await repository.logout();
    expect(await storage.getAccessToken(), isNull);
    expect(transport.cancelToken?.isCancelled, isTrue);
  });

  test('logout invalidates in-flight renewal before any awaited storage work',
      () async {
    final response = Completer<SessionCredentials>();
    transport.renewal = (_) => response.future;
    final renewal = sessions.ensureSession();
    while (transport.renewCancel == null) {
      await Future<void>.delayed(Duration.zero);
    }
    await repository.logout();
    expect(transport.renewCancel?.isCancelled, isTrue);
    response.complete(SessionCredentials(token: 'late', user: User(id: 'old')));
    await renewal;
    expect(await storage.getAccessToken(), isNull);
  });

  for (final replacement in [false, true]) {
    test(
        'a delayed password login cannot undo ${replacement ? 'account B' : 'logout'}',
        () async {
      final response = Completer<LoginResponse>();
      final auth = AuthRepository(
          _AuthService(loginRemote: () => response.future),
          storage: storage,
          sessions: sessions);
      final signingIn = expectLater(
          auth.login(
              loginCredentials:
                  LoginCredentials(phone: '99999999', password: 'unchanged')),
          throwsStateError);
      await storage.beginLogout();
      if (replacement) {
        await storage.saveSession('account-B', User(id: 'account-B'));
      }
      response.complete(LoginResponse(
          success: true,
          message: '',
          data: LoginData(
              user: User(id: 'late-user'),
              token: 'late-token',
              message: '',
              locale: 'en')));
      await signingIn;
      expect(await storage.getAccessToken(), replacement ? 'account-B' : null);
    });
  }
}

class _AuthService implements AuthService {
  _AuthService({this.loginRemote});
  final Future<LoginResponse> Function()? loginRemote;
  @override
  Future<void> logout(String authorization, CancelToken token) =>
      throw StateError('Must use dedicated revoke transport');
  @override
  Future<LoginResponse> login(LoginCredentials body) =>
      loginRemote?.call() ?? (throw UnimplementedError());
}

class _Transport implements SessionRenewalTransport {
  @override
  Future<void> confirm(SessionCredentials session, CancelToken cancel) async {}
  Future<void> Function(SessionCredentials)? remote;
  Future<SessionCredentials> Function(SessionCredentials)? renewal;
  Future<void> Function(String, String)? deactivation;
  bool called = false;
  CancelToken? cancelToken;
  CancelToken? renewCancel;
  @override
  Future<void> revoke(SessionCredentials session, CancelToken cancel) {
    called = true;
    cancelToken = cancel;
    return remote?.call(session) ?? Future<void>.value();
  }

  @override
  Future<SessionCredentials> renew(
      SessionCredentials pending, CancelToken cancel) {
    renewCancel = cancel;
    return renewal!(pending);
  }

  @override
  Future<void> deactivate(
      {required String bearer,
      required String fcmToken,
      required String deviceId,
      required String platform,
      required CancelToken cancel}) async {
    await deactivation?.call(bearer, fcmToken);
  }
}
