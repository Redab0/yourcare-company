import 'dart:async';
import 'dart:io';
import '../../../core/security/session_renewal_coordinator.dart';
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
  final SessionRenewalCoordinator? sessions;
  final Duration logoutTimeout;
  AuthRepository(this._authService,
      {this.logoutTimeout = const Duration(seconds: 5),
      SecureStorageService? storage,
      this.sessions})
      : _storage = storage ?? SecureStorageService();

  Future<User> login({required LoginCredentials loginCredentials}) async {
    final generation = _storage.authGeneration;
    final response = await _authService.login(loginCredentials);

    if (response.success && response.data != null) {
      await _storage.saveSession(response.data.token, response.data.user,
          expectedGeneration: generation, beforeSave: clearSessionState);
      if (_storage.authGeneration != generation + 1) {
        throw StateError('The account changed during sign-in.');
      }
      final renewal = sessions;
      if (renewal != null) {
        unawaited(renewal
            .ensureSession()
            .then<void>((_) {}, onError: (Object _, StackTrace __) {}));
      }
      return response.data.user;
    } else {
      throw Exception(response.message);
    }
  }

  Future<void> logout() async {
    sessions?.cancelRenewal();
    final captured = await _storage.beginLogout(onCleared: clearSessionState);
    final session = captured.session;
    if (session == null) return;
    final transport = sessions?.transport;
    if (transport != null &&
        captured.fcmToken != null &&
        captured.deviceId != null) {
      final pushCancellation = CancelToken();
      try {
        await transport
            .deactivate(
                bearer: session.token,
                fcmToken: captured.fcmToken!,
                deviceId: captured.deviceId!,
                platform: Platform.isAndroid ? 'android' : 'ios',
                cancel: pushCancellation)
            .timeout(logoutTimeout);
      } catch (_) {
        /* Offline push cleanup cannot block local logout. */
      } finally {
        pushCancellation.cancel();
      }
    }
    if (sl.isRegistered<NotificationsRepository>()) {
      await sl<NotificationsRepository>()
          .onSignedOut(generation: captured.generation);
    }
    final cancellation = CancelToken();
    try {
      if (transport != null) {
        await transport.revoke(session, cancellation).timeout(logoutTimeout);
      } else {
        // Explicitly injected legacy AuthService adapters remain usable.
        await _authService
            .logout('Bearer ${session.token}', cancellation)
            .timeout(logoutTimeout);
      }
    } catch (_) {
      /* Local tombstone already prevents session resurrection. */
    } finally {
      cancellation.cancel();
    }
  }

  Future<String?> getToken() async {
    return await _storage.getAccessToken();
  }
}
