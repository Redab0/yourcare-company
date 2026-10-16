import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/data/repositories/notifications/notifications_repository.dart';
import 'dart:async';
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
  setUp(() =>
      FlutterSecureStorage.setMockInitialValues({'access_token': 'session'}));

  test('manual logout revokes the session before clearing local credentials',
      () async {
    final service = _AuthService(() async {
      expect(await SecureStorageService().getAccessToken(), 'session');
    });
    await AuthRepository(service).logout();
    expect(service.called, isTrue);
    expect(service.cancelToken?.isCancelled, isTrue);
    expect(await SecureStorageService().getAccessToken(), isNull);
  });

  test('offline/older server logout still clears local credentials', () async {
    final service = _AuthService(() async => throw StateError('offline/404'));
    await AuthRepository(service).logout();
    expect(await SecureStorageService().getAccessToken(), isNull);
    expect(service.cancelToken?.isCancelled, isTrue);
  });

  test('an old manual logout cannot clear a newer successful login', () async {
    final pending = Completer<void>();
    final service = _AuthService(() => pending.future);
    final logout = AuthRepository(service).logout();
    while (!service.called) {
      await Future<void>.delayed(Duration.zero);
    }
    await SecureStorageService().saveAccessToken('new-session');
    pending.complete();
    await logout;
    expect(await SecureStorageService().getAccessToken(), 'new-session');
  });

  test(
      'push deactivation precedes server revocation while the captured token is valid',
      () async {
    final order = <String>[];
    final notifications = _Notifications(() async {
      order.add('push');
    });
    sl.registerSingleton<NotificationsRepository>(notifications);
    addTearDown(() => sl.unregister<NotificationsRepository>());
    final service = _AuthService(() async {
      order.add('revoke');
    });
    await AuthRepository(service).logout();
    expect(order, ['push', 'revoke']);
  });

  test(
      'initial secure-token read failure still attempts generation-matched local cleanup',
      () async {
    final storage = _UnavailableStorage();
    await AuthRepository(_AuthService(() async {}), storage: storage).logout();
    expect(storage.attempted, isTrue);
  });

  test('timed-out remote logout is cancelled and cannot hold local sign-out',
      () async {
    final service = _AuthService(() => Completer<void>().future);
    await AuthRepository(service,
            logoutTimeout: const Duration(milliseconds: 10))
        .logout();
    expect(await SecureStorageService().getAccessToken(), isNull);
    expect(service.cancelToken?.isCancelled, isTrue);
  });
}

class _AuthService implements AuthService {
  _AuthService(this.remote);
  final Future<void> Function() remote;
  bool called = false;
  CancelToken? cancelToken;
  @override
  Future<void> logout(String authorization, CancelToken token) {
    called = true;
    cancelToken = token;
    return remote();
  }

  @override
  Future<LoginResponse> login(LoginCredentials body) =>
      throw UnimplementedError();
}

class _UnavailableStorage extends SecureStorageService {
  bool attempted = false;
  @override
  Future<String?> getAccessToken() async =>
      throw StateError('keychain unavailable');
  @override
  Future<bool> clearAuthDataIfGenerationMatches(int generation,
      {Future<void> Function()? onCleared}) async {
    attempted = true;
    return true;
  }
}

class _Notifications implements NotificationsRepository {
  _Notifications(this.cleanup);
  final Future<void> Function() cleanup;
  @override
  Future<void> onLogoutCleanup({required String expectedToken}) => cleanup();
  @override
  void invalidateLocalSession() {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
