import 'dart:convert';

import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:cleaning_service_driver/data/models/profile/area_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  // Authentication tokens
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String tokenExpiryKey = 'token_expiry';
  static const String refreshTokenExpiryKey = 'refresh_token_expiry';
  static const String userIdKey = 'user_id';
  static const String deviceIdKey = 'device_id';
  static const String _userKey = 'auth_user';
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
                accessibility: KeychainAccessibility.first_unlock,
              ),
            );

  Future<String?> getAskedForNotificationsPermission() async {
    final String? asked = await _secureStorage.read(key: _kAskedPermKey);
    if (asked == null) return null;
    try {
      return asked;
    } catch (e) {
      await _secureStorage.delete(key: _kAskedPermKey);
      return null;
    }
  }

  Future<void> askedForNotificationsPermission() async {
    await _secureStorage.write(key: _kAskedPermKey, value: '1');
  }

  Future<String?> getFcmToken() async {
    final String? fcmToken = await _secureStorage.read(key: _kTokenKey);
    if (fcmToken == null) return null;
    try {
      return fcmToken;
    } catch (e) {
      await _secureStorage.delete(key: _kTokenKey);
      return null;
    }
  }

  Future<void> saveFcmToken(String token) async {
    await _secureStorage.write(key: _kTokenKey, value: token);
  }

  Future<void> deleteFcmToken() async {
    await _secureStorage.delete(key: _kTokenKey);
  }

  // Save access token
  Future<void> saveAccessToken(String token) async {
    await _secureStorage.write(key: accessTokenKey, value: token);
  }

  Future<void> saveUser(User user) async {
    final String userJson = jsonEncode(user.toJson());
    await _secureStorage.write(key: _userKey, value: userJson);
  }

  // Get access token
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: accessTokenKey);
  }

  // Save refresh token
  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: refreshTokenKey, value: token);
  }

  // Get refresh token
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: refreshTokenKey);
  }

  // Save token expiry time
  Future<void> saveTokenExpiry(DateTime expiryTime) async {
    await _secureStorage.write(
      key: tokenExpiryKey,
      value: expiryTime.millisecondsSinceEpoch.toString(),
    );
  }

  // Get token expiry time
  Future<DateTime?> getTokenExpiry() async {
    final expiry = await _secureStorage.read(key: tokenExpiryKey);
    if (expiry != null) {
      return DateTime.fromMillisecondsSinceEpoch(int.parse(expiry));
    }
    return null;
  }

  // Save refresh token expiry time
  Future<void> saveRefreshTokenExpiry(DateTime expiryTime) async {
    await _secureStorage.write(
      key: refreshTokenExpiryKey,
      value: expiryTime.millisecondsSinceEpoch.toString(),
    );
  }

  Future<void> saveAreas(List<AreaModel> areas) async {
    final storage = FlutterSecureStorage();
    final areasJson = jsonEncode(areas.map((a) => a.toJson()).toList());
    await storage.write(key: 'areas', value: areasJson);
  }

  Future<List<AreaModel>> getAreas() async {
    final storage = FlutterSecureStorage();
    final areasJson = await storage.read(key: 'areas');
    if (areasJson == null) return [];

    final List<dynamic> decoded = jsonDecode(areasJson);
    return decoded.map((json) => AreaModel.fromJson(json)).toList();
  }

  // Get refresh token expiry time
  Future<DateTime?> getRefreshTokenExpiry() async {
    final expiry = await _secureStorage.read(key: refreshTokenExpiryKey);
    if (expiry != null) {
      return DateTime.fromMillisecondsSinceEpoch(int.parse(expiry));
    }
    return null;
  }

  // Save user ID
  Future<void> saveUserId(String userId) async {
    await _secureStorage.write(key: userIdKey, value: userId);
  }

  // Get user ID
  Future<String?> getUserId() async {
    return await _secureStorage.read(key: userIdKey);
  }

  Future<User?> getUser() async {
    final String? userJson = await _secureStorage.read(key: _userKey);
    if (userJson == null) return null;

    try {
      final Map<String, dynamic> userMap = jsonDecode(userJson);
      return User.fromJson(userMap);
    } catch (e) {
      // If parsing fails, clear the invalid data
      await _secureStorage.delete(key: _userKey);
      return null;
    }
  }

  // Save device ID
  Future<void> saveDeviceId(String deviceId) async {
    await _secureStorage.write(key: deviceIdKey, value: deviceId);
  }

  // Get device ID
  Future<String?> getDeviceId() async {
    return await _secureStorage.read(key: deviceIdKey);
  }

  // Demo mode methods
  Future<void> setBool(String key, bool value) async {
    await _secureStorage.write(key: key, value: value.toString());
  }

  Future<bool?> getBool(String key) async {
    final value = await _secureStorage.read(key: key);
    if (value != null) {
      return value.toLowerCase() == 'true';
    }
    return null;
  }

  Future<void> setString(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  Future<String?> getString(String key) async {
    return await _secureStorage.read(key: key);
  }

  // Clear all auth related data
  Future<void> clearAuthData() async {
    await _secureStorage.delete(key: accessTokenKey);
    await _secureStorage.delete(key: refreshTokenKey);
    await _secureStorage.delete(key: tokenExpiryKey);
    await _secureStorage.delete(key: refreshTokenExpiryKey);
    await _secureStorage.delete(key: userIdKey);
    // Note: We don't clear device ID as it should persist between sessions
  }

  // Clear everything
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
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
