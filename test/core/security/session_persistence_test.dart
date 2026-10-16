import 'dart:async';
import 'dart:convert';
import 'package:cleaning_service_driver/core/api/api_environment.dart';
import 'package:cleaning_service_driver/core/storage/secure_storage_service.dart';
import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  String key(String raw) => ApiEnvironment.storageKey(raw);
  late Map<String, String> persisted;
  Future<void> Function(String key)? readWait;
  Future<void> Function(String key, String value)? writeFault;
  Future<void> Function(String key)? deleteFault;
  setUp(() {
    readWait = null;
    writeFault = null;
    deleteFault = null;
    persisted = {
      key('access_token'): 'old-token',
      key('auth_user'): jsonEncode(User(id: 'old-user').toJson()),
    };
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      final arguments = call.arguments as Map;
      final storageKey = arguments['key'] as String;
      switch (call.method) {
        case 'read':
          await readWait?.call(storageKey);
          return persisted[storageKey];
        case 'write':
          final value = arguments['value'] as String;
          await writeFault?.call(storageKey, value);
          persisted[storageKey] = value;
          return null;
        case 'delete':
          await deleteFault?.call(storageKey);
          persisted.remove(storageKey);
          return null;
        default:
          throw StateError('Unexpected secure-storage operation');
      }
    });
  });
  tearDown(() => TestDefaultBinaryMessengerBinding
      .instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, null));

  test('platform user-write failure cannot leave a new token with the old user',
      () async {
    writeFault = (storageKey, _) async {
      if (storageKey == key('auth_user')) {
        throw PlatformException(code: 'user-write-failed');
      }
    };
    final storage = SecureStorageService();
    await expectLater(storage.saveSession('new-token', User(id: 'new-user')),
        throwsA(isA<PlatformException>()));
    expect(persisted[key('access_token')], isNull);
    expect(persisted[key('auth_user')], isNull);
    expect(persisted[key('auth_session_pending')], '1');
    expect(await storage.getAccessToken(), isNull);
    expect(await storage.getUser(), isNull);
    expect(await storage.sessionSnapshot(), (token: null, user: null));
  });

  test(
      'persisted token-write failure plus rollback-delete failure stays unusable after reconstruction',
      () async {
    var rollback = false;
    writeFault = (storageKey, value) async {
      if (storageKey == key('access_token')) {
        persisted[storageKey] =
            value; // Native write persisted before reporting failure.
        rollback = true;
        throw PlatformException(code: 'token-write-failed');
      }
    };
    deleteFault = (storageKey) async {
      if (rollback && storageKey == key('access_token')) {
        throw PlatformException(code: 'rollback-delete-failed');
      }
    };
    await expectLater(
        SecureStorageService().saveSession('new-token', User(id: 'new-user')),
        throwsA(isA<PlatformException>()));
    expect(persisted[key('access_token')], 'new-token');
    expect(jsonDecode(persisted[key('auth_user')]!)['id'], 'new-user');
    expect(persisted[key('auth_session_pending')], '1');
    final restartedStorage = SecureStorageService();
    expect(await restartedStorage.getAccessToken(), isNull);
    expect(await restartedStorage.getUser(), isNull);
    expect(await restartedStorage.sessionSnapshot(), (token: null, user: null));
    deleteFault = null;
    writeFault = null;
    await restartedStorage.clearAuthData();
    expect(persisted[key('access_token')], isNull);
    expect(persisted[key('auth_session_pending')], isNull);
  });

  test('failure clearing the commit marker leaves the session unavailable',
      () async {
    deleteFault = (storageKey) async {
      if (storageKey == key('auth_session_pending')) {
        throw PlatformException(code: 'commit-failed');
      }
    };
    final storage = SecureStorageService();
    await expectLater(storage.saveSession('new-token', User(id: 'new-user')),
        throwsA(isA<PlatformException>()));
    expect(persisted[key('auth_session_pending')], '1');
    expect(await storage.getAccessToken(), isNull);
    expect(await storage.getUser(), isNull);
  });

  test(
      'direct user/token/snapshot reads wait until the whole replacement commits',
      () async {
    final userWritten = Completer<void>();
    final finishUserWrite = Completer<void>();
    writeFault = (storageKey, value) async {
      if (storageKey == key('auth_user')) {
        persisted[storageKey] = value;
        userWritten.complete();
        await finishUserWrite.future;
      }
    };
    final storage = SecureStorageService();
    final saving = storage.saveSession('new-token', User(id: 'new-user'));
    await userWritten.future;
    expect(persisted[key('access_token')], isNull);
    expect(jsonDecode(persisted[key('auth_user')]!)['id'], 'new-user');
    var userVisible = false;
    var tokenVisible = false;
    var snapshotVisible = false;
    final readingUser = storage.getUser().then((user) {
      userVisible = true;
      return user;
    });
    final readingToken = storage.getAccessToken().then((token) {
      tokenVisible = true;
      return token;
    });
    final readingSnapshot = storage.sessionSnapshot().then((snapshot) {
      snapshotVisible = true;
      return snapshot;
    });
    await Future<void>.delayed(Duration.zero);
    expect(userVisible || tokenVisible || snapshotVisible, isFalse);
    finishUserWrite.complete();
    await saving;
    expect((await readingUser)?.id, 'new-user');
    expect(await readingToken, 'new-token');
    final snapshot = await readingSnapshot;
    expect(snapshot.user?.id, 'new-user');
    expect(snapshot.token, 'new-token');
    expect(persisted[key('auth_session_pending')], isNull);
  });

  test('a synchronous before-save read queues behind the complete new session',
      () async {
    final storage = SecureStorageService();
    late Future<String?> queuedRead;
    await storage.saveSession('new-token', User(id: 'new-user'), beforeSave: () {
      // A synchronous listener can enqueue work without awaiting this
      // intentionally non-reentrant lifecycle queue.
      queuedRead = storage.getAccessToken();
      return Future<void>.value();
    });
    expect(await queuedRead, 'new-token');
    expect((await storage.getUser())?.id, 'new-user');
  });

  test(
      'a stalled optional user read cannot block a session replacement or expose an overtaken user',
      () async {
    final readingOldUser = Completer<void>();
    final finishOldRead = Completer<void>();
    var paused = false;
    readWait = (storageKey) async {
      if (storageKey == key('auth_user') && !paused) {
        paused = true;
        readingOldUser.complete();
        await finishOldRead.future;
      }
    };
    final storage = SecureStorageService();
    final userRead = storage.getUser();
    await readingOldUser.future;
    await storage
        .saveSession('new-token', User(id: 'new-user'))
        .timeout(const Duration(seconds: 1));
    finishOldRead.complete();
    expect((await userRead)?.id, 'new-user');
    expect(await storage.getAccessToken(), 'new-token');
  });

  test('a delayed profile refresh cannot replace a newer committed account',
      () async {
    final storage = SecureStorageService();
    await storage.saveSession(
        'new-token', User(id: 'new-user', username: 'New'));
    await storage.saveUser(User(id: 'old-user', username: 'Stale'));
    expect((await storage.getUser())?.id, 'new-user');
    expect((await storage.getUser())?.username, 'New');
    await storage.saveUser(User(id: 'new-user', username: 'Refreshed'));
    expect((await storage.getUser())?.username, 'Refreshed');
    expect(await storage.getAccessToken(), 'new-token');
  });

  test(
      'a pending session from an interrupted process is not exposed by any auth reader',
      () async {
    persisted[key('auth_session_pending')] = '1';
    persisted[key('auth_user')] =
        jsonEncode(User(id: 'partially-written-user').toJson());
    final storage = SecureStorageService();
    expect(await storage.getAccessToken(), isNull);
    expect(await storage.getUser(), isNull);
    expect(await storage.sessionSnapshot(), (token: null, user: null));
    await storage.saveSession(
        'replacement-token', User(id: 'replacement-user'));
    expect(await storage.getAccessToken(), 'replacement-token');
    expect((await storage.getUser())?.id, 'replacement-user');
    expect(persisted[key('auth_session_pending')], isNull);
  });
}
