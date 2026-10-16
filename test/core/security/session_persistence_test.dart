import 'dart:async';
import 'dart:convert';
import 'package:cleaning_service_driver/core/api/api_environment.dart';
import 'package:cleaning_service_driver/core/security/session_credentials.dart';
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
  Future<void> Function(String key, Map options)? deleteFault;
  setUp(() {
    readWait = null;
    writeFault = null;
    deleteFault = null;
    persisted = {
      key('access_token'): 'old-token',
      key('auth_user'):
          jsonEncode(User(id: '0123456789abcdef01234567').toJson())
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
          await deleteFault?.call(storageKey, arguments['options'] as Map);
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

  test(
      'new device-only envelope write failure preserves the original token/user',
      () async {
    writeFault = (_, __) async => throw PlatformException(code: 'write-failed');
    final storage = SecureStorageService();
    await expectLater(
        storage.upgradeProtection(), throwsA(isA<PlatformException>()));
    expect(persisted[key('access_token')], 'old-token');
    expect((await storage.getUser())?.id, '0123456789abcdef01234567');
    expect(await storage.getAccessToken(), 'old-token');
  });

  test(
      'native persist-then-error exposes only a complete new pair, never mismatched keys',
      () async {
    writeFault = (storageKey, value) async {
      if (storageKey == key(SecureStorageService.sessionEnvelopeKey)) {
        persisted[storageKey] = value;
        throw PlatformException(code: 'persisted-before-error');
      }
    };
    await expectLater(
        SecureStorageService().saveSession('new-token', User(id: 'new-user')),
        throwsA(isA<PlatformException>()));
    final reconstructed = SecureStorageService();
    expect(await reconstructed.getAccessToken(), 'new-token');
    expect((await reconstructed.getUser())?.id, 'new-user');
    expect(persisted[key('access_token')], 'old-token');
  });

  test(
      'failed renewal commit retains original credential and durable retry recovery',
      () async {
    final storage = SecureStorageService();
    await storage.saveSession(
        'old-token', User(id: '0123456789abcdef01234567', role: 'manager'));
    final generation = storage.authGeneration;
    final pending = (await storage.prepareRenewal(
        expectedToken: 'old-token',
        generation: generation,
        requestId: 'persisted-operation'))!;
    writeFault = (storageKey, value) async {
      if (jsonDecode(value)['refreshToken'] == 'new-refresh') {
        // Model the native plugin's failed SecItemUpdate -> DELETE -> failed ADD.
        persisted.remove(storageKey);
        throw PlatformException(code: 'replacement-failed');
      }
    };
    await expectLater(
        storage.commitRenewal(
            SessionCredentials(
                token:
                    'eyJhbGciOiJIUzI1NiJ9.eyJmaXh0dXJlIjp0cnVlfQ.ccccccccccccccccccccccccccccccccccccccccccc',
                user: User(id: '0123456789abcdef01234567', role: 'manager'),
                sessionId: '1a6a33df-8db6-4bc7-b526-577f8c258dd0',
                accessExpiresAt:
                    DateTime.now().add(const Duration(minutes: 15)),
                refreshToken: 'new-refresh'),
            expected: pending,
            generation: generation),
        throwsA(isA<PlatformException>()));
    final resumed = await SecureStorageService().credentials();
    expect(resumed?.token, 'old-token');
    expect(resumed?.requestId, 'persisted-operation');
    expect(resumed?.requestCredential, 'old-token');
    expect(persisted[key('access_token')], isNull);
    expect(persisted[key(SecureStorageService.sessionEnvelopeKey)], isNull);
    expect(
        persisted[key(SecureStorageService.alternateEnvelopeKey)], isNotNull);
  });

  test(
      'Android transient read errors are configured to retain encrypted values',
      () {
    expect(SecureStorageService.androidOptions.params['resetOnError'], 'false');
    expect(
        SecureStorageService
            .androidOptions.params['encryptedSharedPreferences'],
        'true');
  });

  test(
      'durable logout tombstone defeats legacy fallback even if every delete fails',
      () async {
    final optionsSeen = <Map>[];
    deleteFault = (_, options) async {
      optionsSeen.add(options);
      throw PlatformException(code: 'delete-failed');
    };
    final captured = await SecureStorageService().beginLogout();
    expect(captured.session?.token, 'old-token');
    expect(persisted[key('access_token')], 'old-token');
    expect(optionsSeen, isNotEmpty);
    expect(
        optionsSeen.every((options) => !options.containsKey('accessibility')),
        isTrue);
    final restarted = SecureStorageService();
    expect(await restarted.getAccessToken(), isNull);
    expect(await restarted.getUser(), isNull);
    expect(await restarted.sessionSnapshot(), (token: null, user: null));
  });

  test('an initial native read failure still permits durable local sign-out',
      () async {
    var failed = false;
    readWait = (storageKey) async {
      if (storageKey == key(SecureStorageService.sessionEnvelopeKey) &&
          !failed) {
        failed = true;
        throw PlatformException(code: 'read-unavailable');
      }
    };
    final captured = await SecureStorageService().beginLogout();
    expect(captured.session, isNull);
    expect(await SecureStorageService().getAccessToken(), isNull);
    expect(persisted[key('access_token')], isNull);
  });

  test('direct readers wait for the complete envelope commit', () async {
    final written = Completer<void>();
    final finish = Completer<void>();
    writeFault = (storageKey, value) async {
      if (storageKey == key(SecureStorageService.sessionEnvelopeKey)) {
        persisted[storageKey] = value;
        written.complete();
        await finish.future;
      }
    };
    final storage = SecureStorageService();
    final saving = storage.saveSession('new-token', User(id: 'new-user'));
    await written.future;
    var visible = false;
    final reading = storage.getUser().then((user) {
      visible = true;
      return user;
    });
    final token = storage.getAccessToken();
    await Future<void>.delayed(Duration.zero);
    expect(visible, isFalse);
    finish.complete();
    await saving;
    expect((await reading)?.id, 'new-user');
    expect(await token, 'new-token');
  });

  test('a synchronous before-save read queues behind the complete new session',
      () async {
    final storage = SecureStorageService();
    late Future<String?> queuedRead;
    await storage.saveSession('new-token', User(id: 'new-user'),
        beforeSave: () {
      queuedRead = storage.getAccessToken();
      return Future<void>.value();
    });
    expect(await queuedRead, 'new-token');
    expect((await storage.getUser())?.id, 'new-user');
  });

  test(
      'a stalled optional legacy user read cannot block or overtake account replacement',
      () async {
    final reading = Completer<void>();
    final finish = Completer<void>();
    var paused = false;
    readWait = (storageKey) async {
      if (storageKey == key('auth_user') && !paused) {
        paused = true;
        reading.complete();
        await finish.future;
      }
    };
    final storage = SecureStorageService();
    final userRead = storage.getUser();
    await reading.future;
    await storage
        .saveSession('new-token', User(id: 'new-user'))
        .timeout(const Duration(seconds: 1));
    finish.complete();
    expect((await userRead)?.id, 'new-user');
  });

  test('a delayed profile refresh cannot replace a newer committed account',
      () async {
    final storage = SecureStorageService();
    await storage.saveSession(
        'new-token', User(id: 'new-user', username: 'New'));
    await storage
        .saveUser(User(id: '0123456789abcdef01234567', username: 'Stale'));
    expect((await storage.getUser())?.username, 'New');
    await storage.saveUser(User(id: 'new-user', username: 'Refreshed'));
    expect((await storage.getUser())?.username, 'Refreshed');
  });

  test(
      'interrupted phase-one pending keys remain unavailable until complete login',
      () async {
    persisted[key('auth_session_pending')] = '1';
    persisted[key('auth_user')] = jsonEncode(User(id: 'partial-user').toJson());
    final storage = SecureStorageService();
    expect(await storage.getAccessToken(), isNull);
    expect(await storage.getUser(), isNull);
    await storage.saveSession('replacement', User(id: 'replacement-user'));
    expect(await storage.getAccessToken(), 'replacement');
    expect((await storage.getUser())?.id, 'replacement-user');
  });
}
