import 'package:cleaning_service_driver/core/api/api_environment.dart';
import 'dart:convert';

import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:cleaning_service_driver/data/models/profile/area_response.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static int _authGeneration = 0;
  int get authGeneration => _authGeneration;
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
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.unlocked_this_device,
              ),
            );

  /// Rewrites existing known entries once so older iOS keychain items also
  /// receive the device-only, unlocked protection (constructor options alone do
  /// not migrate previously stored accessibility attributes).
  Future<void> upgradeProtection() => _withAuthLock(() async {
        const marker = 'secure_storage_policy_version';
        if (await _read(marker) == '1') return;
        for (final key in [
          accessTokenKey,
          refreshTokenKey,
          tokenExpiryKey,
          refreshTokenExpiryKey,
          userIdKey,
          _userKey,
          _kTokenKey,
          deviceIdKey,
          _kAskedPermKey,
          isLoggedInKey,
          userEmailKey,
          'areas'
        ]) {
          final value = await _read(key);
          if (value != null) {
            await _secureStorage.write(key: _key(key), value: value);
          }
        }
        await _secureStorage.write(key: _key(marker), value: '1');
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

  // Save access token
  Future<void> saveAccessToken(String token) async {
    await _withAuthLock(() async {
      _authGeneration++;
      await _secureStorage.write(key: _key(accessTokenKey), value: token);
    });
  }

  Future<void> saveUser(User user) => _withAuthLock(() async {
        if (await _read(_pendingSessionKey) != null ||
            await _read(accessTokenKey) == null) {
          return;
        }
        final currentJson = await _read(_userKey);
        if (currentJson == null || user.id == null) return;
        final currentUser =
            User.fromJson(jsonDecode(currentJson) as Map<String, dynamic>);
        // An old profile request must not replace a newer account's cache.
        if (currentUser.id != user.id) return;
        await _secureStorage.write(
            key: _key(_userKey), value: jsonEncode(user.toJson()));
      });

  Future<String?> _readCommittedToken() async {
    if (await _read(_pendingSessionKey).timeout(const Duration(seconds: 2)) !=
        null) {
      return null;
    }
    return _read(accessTokenKey).timeout(const Duration(seconds: 2));
  }

  // Get access token
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
    // Optional profile reads must not hold the session mutex while waiting for
    // the platform. Retry if any serialized operation overtakes this read.
    while (true) {
      final barrier = _authOperations;
      // An idle completed barrier may belong to a previous async zone. Only
      // wait on live operations; this also keeps optional probes independent.
      if (_pendingAuthOperations != 0) await barrier;
      final generation = _authGeneration;
      final pending = await _read(_pendingSessionKey);
      final userJson = pending == null ? await _read(_userKey) : null;
      if (!identical(barrier, _authOperations) || generation != _authGeneration) {
        continue;
      }
      if (userJson == null) return null;
      try {
        return User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
      } catch (_) {
        await _withAuthLock(() async {
          if (generation == _authGeneration &&
              await _read(_userKey) == userJson) {
            await _secureStorage.delete(key: _key(_userKey));
          }
        });
        return null;
      }
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

  // Clear all auth related data
  /// A persistent pending marker makes partially written sessions unusable,
  /// including when rollback deletion fails or the process exits mid-write.
  Future<void> saveSession(String token, User user,
          {Future<void> Function()? beforeSave}) =>
      _withAuthLock(() async {
        _authGeneration++;
        try {
          await beforeSave?.call();
          await _secureStorage.write(key: _key(_pendingSessionKey), value: '1');
          await _deleteAccountData(keepPendingMarker: true);
          await _secureStorage.write(
              key: _key(_userKey), value: jsonEncode(user.toJson()));
          await _secureStorage.write(key: _key(accessTokenKey), value: token);
          // Only a complete token/user pair may become visible to readers.
          await _secureStorage.delete(key: _key(_pendingSessionKey));
        } catch (_) {
          try {
            // A platform may report failure after physically clearing a key.
            // Reassert the marker before attempting rollback.
            await _secureStorage.write(
                key: _key(_pendingSessionKey), value: '1');
          } catch (_) {
            // The original pending marker remains when the commit did not clear it.
          }
          try {
            await _deleteAccountData(keepPendingMarker: true);
          } catch (_) {
            // Keep the durable marker: guarded reads remain signed out even
            // when the platform cannot physically erase the partial session.
          }
          rethrow;
        }
      });

  Future<({String? token, User? user})> sessionSnapshot() =>
      _withAuthLock(() async {
        if (await _read(_pendingSessionKey)
                .timeout(const Duration(seconds: 2)) !=
            null) {
          return (token: null, user: null);
        }
        final token =
            await _read(accessTokenKey).timeout(const Duration(seconds: 2));
        final userJson =
            await _read(_userKey).timeout(const Duration(seconds: 2));
        User? user;
        if (userJson != null) {
          try {
            user = User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
          } catch (_) {
            await _secureStorage.delete(key: _key(_userKey));
          }
        }
        return (token: token, user: user);
      });

  Future<bool> clearAuthDataIfTokenMatches(String? sentToken,
          {Future<void> Function()? onCleared}) =>
      _withAuthLock(() async {
        if (await _readCommittedToken() != sentToken) {
          return false;
        }
        await _deleteAccountData();
        await onCleared?.call();
        return true;
      });

  Future<bool> whileSessionMatches(
          String? token, Future<void> Function() action) =>
      _withAuthLock(() async {
        if (await _read(_pendingSessionKey)
                    .timeout(const Duration(seconds: 2)) !=
                null ||
            await _read(accessTokenKey).timeout(const Duration(seconds: 2)) !=
                token) {
          return false;
        }
        await action();
        return true;
      });

  Future<bool> clearAuthDataIfGenerationMatches(int generation,
          {Future<void> Function()? onCleared}) =>
      _withAuthLock(() async {
        if (_authGeneration != generation) return false;
        await _deleteAccountData();
        await onCleared?.call();
        return true;
      });

  Future<void> clearAuthData({Future<void> Function()? onCleared}) =>
      _withAuthLock(() async {
        await _deleteAccountData();
        await onCleared?.call();
      });

  Future<void> _deleteAccountData({bool keepPendingMarker = false}) async {
    _authGeneration++;
    for (final key in [
      accessTokenKey,
      refreshTokenKey,
      tokenExpiryKey,
      refreshTokenExpiryKey,
      userIdKey,
      _userKey,
      _kTokenKey,
      isLoggedInKey,
      userEmailKey,
      'areas'
    ]) {
      await _secureStorage.delete(key: _key(key));
    }
    if (!keepPendingMarker) {
      await _secureStorage.delete(key: _key(_pendingSessionKey));
    }
    // Keep device identity, locale and the notification-permission preference.
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
