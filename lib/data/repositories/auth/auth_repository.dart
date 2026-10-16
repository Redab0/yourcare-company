import '../../../core/di/dependency_injection.dart';
import '../notifications/notifications_repository.dart';
import 'package:cleaning_service_driver/core/storage/secure_storage_service.dart';
import '../../../core/security/session_state.dart';
import 'package:dio/dio.dart';
import 'package:cleaning_service_driver/data/models/auth/login_credentials.dart';
import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:cleaning_service_driver/data/services/auth/auth_service.dart';

class AuthRepository {
  final AuthService _authService;

  final SecureStorageService _storage;
  final Duration logoutTimeout;
  AuthRepository(this._authService,
      {this.logoutTimeout = const Duration(seconds: 5),
      SecureStorageService? storage})
      : _storage = storage ?? SecureStorageService();

  Future<User> login({required LoginCredentials loginCredentials}) async {
    final response = await _authService.login(loginCredentials);

    if (response.success && response.data != null) {
      await _storage.saveSession(response.data.token, response.data.user,
          beforeSave: clearSessionState);
      return response.data.user;
    } else {
      throw Exception(response.message);
    }
  }

  Future<void> logout() async {
    final storage = _storage;
    final generation = storage.authGeneration;
    String? token;
    var tokenRead = false;
    final cancellation = CancelToken();
    try {
      token = await storage.getAccessToken().timeout(logoutTimeout);
      tokenRead = true;
      if (token != null) {
        if (sl.isRegistered<NotificationsRepository>()) {
          try {
            await sl<NotificationsRepository>()
                .onLogoutCleanup(expectedToken: token);
          } catch (_) {
            // Push cleanup cannot prevent revocation/local sign-out.
          }
        }
        await _authService
            .logout('Bearer $token', cancellation)
            .timeout(logoutTimeout);
      }
    } catch (_) {
      // Offline/older servers cannot prevent local sign-out.
    } finally {
      cancellation.cancel();
      if (tokenRead) {
        await storage.clearAuthDataIfTokenMatches(token,
            onCleared: clearSessionState);
      } else {
        await storage.clearAuthDataIfGenerationMatches(generation,
            onCleared: clearSessionState);
      }
    }
  }

  Future<String?> getToken() async {
    return await _storage.getAccessToken();
  }
}
