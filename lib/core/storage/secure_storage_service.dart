import 'package:cleaning_service_driver/core/api/api_environment.dart';
import 'dart:convert';
import '../security/session_credentials.dart';

import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:cleaning_service_driver/data/models/profile/area_response.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const androidOptions =
      AndroidOptions(encryptedSharedPreferences: true, resetOnError: false);
  static int _authGeneration = 0;
  int get authGeneration => _authGeneration;
  static int _credentialRevision = 0;
  int get credentialRevision => _credentialRevision;
  static int _pendingAuthOperations = 0;
  static Future<void> _authOperations = Future<void>.value();
  static Future<T> _withAuthLock<T>(Future<T> Function() operation) {
    final idle = _pendingAuthOperations == 0;
    _pendingAuthOperations++;
    final next = idle
        ? Future<T>.microtask(operation)
        : _authOperations.then((_) => operation());
    final settled = next.whenComplete(() {
      _pendingAuthOperations--;
    });
    _authOperations =
        settled.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return settled;
  }

  Future<String?> _read(String key) => _secureStorage.read(key: _key(key));
  String _key(String key) => ApiEnvironment.storageKey(key);
  // Authentication tokens
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String tokenExpiryKey = 'token_expiry';
  static const String refreshTokenExpiryKey = 'refresh_token_expiry';
  static const String userIdKey = 'user_id';
  static const String deviceIdKey = 'device_id';
  static const String _userKey = 'auth_user';
  static const String _pendingSessionKey = 'auth_session_pending';
  static const String sessionEnvelopeKey = 'auth_session_v2';
  static const String alternateEnvelopeKey = 'auth_session_v2_backup';
  static const _kTokenKey = 'fcm_token';
  static const _kAskedPermKey = 'notif_perm_prompted';

  // Demo mode keys
  static const String isLoggedInKey = 'is_logged_in';
  static const String userEmailKey = 'user_email';

  final FlutterSecureStorage _secureStorage;

  SecureStorageService({
    FlutterSecureStorage? secureStorage,
  }) : _secureStorage = secureStorage ??
            const FlutterSecureStorage(
              aOptions: androidOptions,
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.unlocked_this_device,
              ),
              mOptions: MacOsOptions(
                accessibility: KeychainAccessibility.unlocked_this_device,
              ),
            );

  /// Copy into a new device-only key; never rewrite the only legacy key.
  /// The iOS plugin can DELETE+ADD when accessibility changes.
  Future<void> upgradeProtection() => _withAuthLock(() async {
        if (await _readRecord() != null) return;
        final session = await _loadCredentials();
        if (session != null) await _writeCredentials(session);
      });

  Future<({String key, Map<String, dynamic> data})?> _readRecord() async {
    ({String key, Map<String, dynamic> data})? selected;
    var malformed = false;
    for (final key in [sessionEnvelopeKey, alternateEnvelopeKey]) {
      final encoded = await _read(key);
      if (encoded == null) continue;
      try {
        final data = jsonDecode(encoded) as Map<String, dynamic>;
        if (data['version'] != 2 ||
            (data['revision'] != null && data['revision'] is! int)) {
          throw const FormatException('Invalid stored session.');
        }
        final revision = data['revision'] as int? ?? 0;
        if (revision < 0) {
          throw const FormatException('Invalid stored revision.');
        }
        if (selected == null ||
            revision > (selected.data['revision'] as int? ?? 0)) {
          selected = (key: key, data: data);
        }
      } catch (_) {
        malformed = true;
      }
    }
    if (selected == null && malformed) {
      throw const FormatException('Unreadable stored session.');
    }
    return selected;
  }

  Future<void> _writeRecord(Map<String, dynamic> data) async {
    final current = await _readRecord();
    final target = current?.key == sessionEnvelopeKey
        ? alternateEnvelopeKey
        : sessionEnvelopeKey;
    final revision = (current?.data['revision'] as int? ?? 0) + 1;
    // Never write over the newest record. The native plugin can delete an
    // existing item after an unsuccessful update, even without changing policy.
    await _secureStorage.write(
        key: _key(target), value: jsonEncode({...data, 'revision': revision}));
  }

  Future<void> _writeCredentials(SessionCredentials session) =>
      _writeRecord(session.toJson());

  Future<SessionCredentials?> _loadCredentials() async {
    final record = await _readRecord();
    if (record != null) {
      if (record.data['signedOut'] == true) return null;
      return SessionCredentials.fromJson(record.data);
    }
    if (await _read(_pendingSessionKey) != null) return null;
    final token = await _read(accessTokenKey);
    if (token == null) return null;
    final userJson = await _read(_userKey);
    User? user;
    if (userJson != null) {
      try {
        user = User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
      } catch (_) {/* An unreadable cache does not revoke a valid bearer. */}
    }
    return SessionCredentials(token: token, user: user);
  }

  Future<SessionCredentials?> credentials() => _withAuthLock(
      () => _loadCredentials().timeout(const Duration(seconds: 4)));

  Future<SessionCredentials?> prepareRenewal(
          {required String expectedToken,
          required int generation,
          required String requestId}) =>
      _withAuthLock(() async {
        final current = await _loadCredentials();
        if (_authGeneration != generation || current?.token != expectedToken) {
          return null;
        }
        if (current!.requestId != null) return current;
        final pending = current.withRecovery(requestId);
        // Failure means no request is sent; legacy credentials remain intact.
        await _writeCredentials(pending);
        return pending;
      });

  Future<bool> commitRenewal(SessionCredentials replacement,
          {required SessionCredentials expected,
          required int generation,
          DateTime? now}) =>
      _withAuthLock(() async {
        final current = await _loadCredentials();
        if (_authGeneration != generation ||
            current?.token != expected.token ||
            current?.requestId != expected.requestId ||
            current?.requestCredential != expected.requestCredential) {
          return false;
        }
        if (current!.user?.id != null &&
            current.user!.id != replacement.user?.id) {
          throw const FormatException('Session identity changed.');
        }
        replacement.validateReplacement(current, now ?? DateTime.now());
        final newerProfile = current.user != null &&
            jsonEncode(current.user!.toJson()) !=
                jsonEncode(expected.user?.toJson());
        await _writeCredentials(
            newerProfile ? replacement.withUser(current.user!) : replacement);
        _credentialRevision++;
        await _deleteLegacyCredentials();
        return true;
      });

  Future<String?> getAskedForNotificationsPermission() async {
    final String? asked = await _read(_kAskedPermKey);
    if (asked == null) return null;
    try {
      return asked;
    } catch (e) {
      await _secureStorage.delete(key: _key(_kAskedPermKey));
      return null;
    }
  }

  Future<void> askedForNotificationsPermission() async {
    await _secureStorage.write(key: _key(_kAskedPermKey), value: '1');
  }

  Future<String?> getFcmToken() async {
    final String? fcmToken = await _read(_kTokenKey);
    if (fcmToken == null) return null;
    try {
      return fcmToken;
    } catch (e) {
      await _secureStorage.delete(key: _key(_kTokenKey));
      return null;
    }
  }

  Future<void> saveFcmToken(String token) async {
    await _secureStorage.write(key: _key(_kTokenKey), value: token);
  }

  Future<void> deleteFcmToken() async {
    await _secureStorage.delete(key: _key(_kTokenKey));
  }

  // Compatibility helper; normal login writes the complete envelope.
  Future<void> saveAccessToken(String token) => _withAuthLock(() async {
        _authGeneration++;
        final current = await _loadCredentials();
        await _writeCredentials(
            SessionCredentials(token: token, user: current?.user));
        _credentialRevision++;
      });

  Future<void> saveUser(User user) => _withAuthLock(() async {
        final current = await _loadCredentials();
        if (current == null || user.id == null || current.user?.id != user.id) {
          return;
        }
        await _writeCredentials(current.withUser(user));
      });

  Future<String?> _readCommittedToken() async =>
      (await _loadCredentials().timeout(const Duration(seconds: 4)))?.token;

  Future<String?> getAccessToken() => _withAuthLock(_readCommittedToken);

  // Save refresh token
  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: _key(refreshTokenKey), value: token);
  }

  // Get refresh token
  Future<String?> getRefreshToken() async {
    return await _read(refreshTokenKey);
  }

  // Save token expiry time
  Future<void> saveTokenExpiry(DateTime expiryTime) async {
    await _secureStorage.write(
      key: _key(tokenExpiryKey),
      value: expiryTime.millisecondsSinceEpoch.toString(),
    );
  }

  // Get token expiry time
  Future<DateTime?> getTokenExpiry() async {
    final expiry = await _read(tokenExpiryKey);
    if (expiry != null) {
      return DateTime.fromMillisecondsSinceEpoch(int.parse(expiry));
    }
    return null;
  }

  // Save refresh token expiry time
  Future<void> saveRefreshTokenExpiry(DateTime expiryTime) async {
    await _secureStorage.write(
      key: _key(refreshTokenExpiryKey),
      value: expiryTime.millisecondsSinceEpoch.toString(),
    );
  }

  Future<void> saveAreas(List<AreaResponse> areas) async {
    final areasJson = jsonEncode(areas.map((a) => a.toJson()).toList());
    await _secureStorage.write(key: _key('areas'), value: areasJson);
  }

  Future<List<AreaResponse>> getAreas() async {
    final areasJson = await _read('areas');
    if (areasJson == null) return [];

    final List<dynamic> decoded = jsonDecode(areasJson);
    return decoded.map((json) => AreaResponse.fromJson(json)).toList();
  }

  // Get refresh token expiry time
  Future<DateTime?> getRefreshTokenExpiry() async {
    final expiry = await _read(refreshTokenExpiryKey);
    if (expiry != null) {
      return DateTime.fromMillisecondsSinceEpoch(int.parse(expiry));
    }
    return null;
  }

  // Save user ID
  Future<void> saveUserId(String userId) async {
    await _secureStorage.write(key: _key(userIdKey), value: userId);
  }

  // Get user ID
  Future<String?> getUserId() async {
    return await _read(userIdKey);
  }

  Future<User?> getUser() async {
    // Optional probes do not hold the mutex while the native platform waits.
    while (true) {
      final barrier = _authOperations;
      if (_pendingAuthOperations != 0) await barrier;
      final generation = _authGeneration;
      final record = await _readRecord();
      User? user;
      if (record != null) {
        final json = record.data;
        if (json['signedOut'] != true) {
          user = SessionCredentials.fromJson(json).user;
        }
      } else if (await _read(_pendingSessionKey) == null) {
        final json = await _read(_userKey);
        if (json != null) {
          try {
            user = User.fromJson(jsonDecode(json) as Map<String, dynamic>);
          } catch (_) {/* Leave invalid optional cache out of the UI. */}
        }
      }
      if (!identical(barrier, _authOperations) ||
          generation != _authGeneration) {
        continue;
      }
      return user;
    }
  }

  // Save device ID
  Future<void> saveDeviceId(String deviceId) async {
    await _secureStorage.write(key: _key(deviceIdKey), value: deviceId);
  }

  // Get device ID
  Future<String?> getDeviceId() async {
    return await _read(deviceIdKey);
  }

  // Demo mode methods
  Future<void> setBool(String key, bool value) async {
    await _secureStorage.write(key: _key(key), value: value.toString());
  }

  Future<bool?> getBool(String key) async {
    final value = await _read(key);
    if (value != null) {
      return value.toLowerCase() == 'true';
    }
    return null;
  }

  Future<void> setString(String key, String value) async {
    await _secureStorage.write(key: _key(key), value: value);
  }

  Future<String?> getString(String key) async {
    return await _read(key);
  }

  Future<void> saveSession(String token, User user,
          {Future<void> Function()? beforeSave, int? expectedGeneration}) =>
      _withAuthLock(() async {
        if (expectedGeneration != null &&
            _authGeneration != expectedGeneration) {
          throw StateError('The account changed during sign-in.');
        }
        // Invalidate old work even if native storage persists before returning
        // an error; the newly selected record must never keep account A's epoch.
        _authGeneration++;
        await beforeSave?.call();
        // A complete record commits the pair. A failed write can expose only a
        // complete old or new pair, never token B plus user A.
        await _writeCredentials(SessionCredentials(token: token, user: user));
        _credentialRevision++;
        await _deleteLegacyAccountData();
      });

  Future<({String? token, User? user})> sessionSnapshot() =>
      _withAuthLock(() async {
        final session =
            await _loadCredentials().timeout(const Duration(seconds: 4));
        return (token: session?.token, user: session?.user);
      });

  /// Invalidates renewal before remote logout, then durably prevents fallback.
  Future<
      ({
        SessionCredentials? session,
        String? fcmToken,
        String? deviceId,
        int generation
      })> beginLogout(
          {Future<void> Function()? onCleared}) =>
      _withAuthLock(() async {
        _authGeneration++;
        _credentialRevision++;
        SessionCredentials? session;
        String? fcmToken;
        String? deviceId;
        try {
          session = await _loadCredentials();
        } catch (_) {}
        try {
          fcmToken = await _read(_kTokenKey);
        } catch (_) {}
        try {
          deviceId = await _read(deviceIdKey);
        } catch (_) {}
        try {
          await _signedOut();
        } finally {
          await onCleared?.call();
        }
        return (
          session: session,
          fcmToken: fcmToken,
          deviceId: deviceId,
          generation: _authGeneration
        );
      });

  Future<bool> clearAuthDataIfTokenMatches(String? sentToken,
          {Future<void> Function()? onCleared, int? expectedGeneration}) =>
      _withAuthLock(() async {
        if (expectedGeneration != null &&
            _authGeneration != expectedGeneration) {
          return false;
        }
        if (await _readCommittedToken() != sentToken) return false;
        _authGeneration++;
        _credentialRevision++;
        await _signedOut();
        await onCleared?.call();
        return true;
      });

  Future<bool> whileSessionMatches(
          String? token, Future<void> Function() action) =>
      _withAuthLock(() async {
        if (await _readCommittedToken() != token) return false;
        await action();
        return true;
      });

  Future<bool> whileGenerationMatches(
          int generation, Future<void> Function() action) =>
      _withAuthLock(() async {
        if (_authGeneration != generation) return false;
        await action();
        return true;
      });

  Future<bool> clearAuthDataIfGenerationMatches(int generation,
          {Future<void> Function()? onCleared}) =>
      _withAuthLock(() async {
        if (_authGeneration != generation) return false;
        _authGeneration++;
        _credentialRevision++;
        await _signedOut();
        await onCleared?.call();
        return true;
      });

  Future<void> clearAuthData({Future<void> Function()? onCleared}) =>
      _withAuthLock(() async {
        _authGeneration++;
        _credentialRevision++;
        await _signedOut();
        await onCleared?.call();
      });

  Future<void> _signedOut() async {
    try {
      await _writeRecord({'version': 2, 'signedOut': true});
      try {
        // Erase the other record only after a durable tombstone exists.
        await _writeRecord({'version': 2, 'signedOut': true});
      } catch (_) {
        /* The first committed tombstone still wins revision selection. */
      }
    } finally {
      await _deleteLegacyAccountData();
    }
  }

  Future<void> _deleteLegacyAccountData() async {
    for (final key in [
      accessTokenKey,
      refreshTokenKey,
      tokenExpiryKey,
      refreshTokenExpiryKey,
      userIdKey,
      _userKey,
      _pendingSessionKey,
      _kTokenKey,
      isLoggedInKey,
      userEmailKey,
      'areas'
    ]) {
      try {
        // A nil accessibility query removes all legacy accessibility variants.
        await _secureStorage.delete(
            key: _key(key),
            iOptions: const IOSOptions(accessibility: null),
            mOptions: const MacOsOptions(accessibility: null));
      } catch (_) {
        /* The committed envelope/tombstone remains authoritative. */
      }
    }
  }

  Future<void> _deleteLegacyCredentials() async {
    for (final key in [
      accessTokenKey,
      refreshTokenKey,
      tokenExpiryKey,
      refreshTokenExpiryKey,
      userIdKey,
      _userKey,
      _pendingSessionKey
    ]) {
      try {
        await _secureStorage.delete(
            key: _key(key),
            iOptions: const IOSOptions(accessibility: null),
            mOptions: const MacOsOptions(accessibility: null));
      } catch (_) {/* Canonical envelope prevents legacy fallback. */}
    }
  }

  // Clear everything
  Future<void> clearAll() async {
    final entries = await _secureStorage.readAll();
    for (final key in entries.keys.toList()) {
      if (ApiEnvironment.ownsStorageKey(key)) {
        await _secureStorage.delete(key: key);
      }
    }
  }

  // Check if we have valid auth tokens stored
  Future<bool> hasValidTokens() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    final refreshExpiry = await getRefreshTokenExpiry();

    // If refresh token is expired, consider tokens invalid
    if (refreshExpiry != null && DateTime.now().isAfter(refreshExpiry)) {
      return false;
    }

    return accessToken != null && refreshToken != null;
  }
}
