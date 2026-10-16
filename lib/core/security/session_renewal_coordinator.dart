import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../storage/secure_storage_service.dart';
import 'session_credentials.dart';
import 'session_renewal_transport.dart';

/// Shared by HTTP, startup/resume and sockets. Network work never holds the
/// storage queue. Only confirmed terminal machine codes can clear a session.
class SessionRenewalCoordinator {
  SessionRenewalCoordinator(
      {required this.storage,
      required this.transport,
      required this.onTerminal,
      this.onRotated,
      DateTime Function()? now,
      String Function()? newId,
      this.retryCooldown = const Duration(seconds: 30),
      this.unsupportedCooldown = const Duration(minutes: 5)})
      : _now = now ?? DateTime.now,
        _newId = newId ?? const Uuid().v4;
  final SecureStorageService storage;
  final SessionRenewalTransport transport;
  final Future<void> Function() onTerminal;
  final Future<void> Function()? onRotated;
  final DateTime Function() _now;
  final String Function() _newId;
  final Duration retryCooldown;
  final Duration unsupportedCooldown;
  Future<SessionCredentials?>? _flight;
  int? _flightGeneration;
  int _epoch = 0;
  CancelToken? _cancellation;
  DateTime? _retryAt;
  int? _retryGeneration;

  void cancelRenewal() {
    _epoch++;
    _cancellation?.cancel();
    _cancellation = null;
    _flight = null;
    _flightGeneration = null;
    _retryAt = null;
  }

  Future<SessionCredentials?> ensureSession(
      {bool force = false, String? expiredToken}) async {
    final session = await storage.credentials();
    if (session == null) return null;
    final generation = storage.authGeneration;
    if (expiredToken != null && session.token != expiredToken) return session;
    final due = session.requestId != null ||
        session.refreshToken == null ||
        session.accessExpiresAt == null ||
        !session.accessExpiresAt!
            .isAfter(_now().add(const Duration(seconds: 60)));
    if (!force && !due) return session;
    if (_retryGeneration == generation && _retryAt?.isAfter(_now()) == true) {
      return session;
    }
    if (_flightGeneration == generation && _flight != null) return _flight;
    final epoch = _epoch;
    final cancellation = CancelToken();
    _cancellation = cancellation;
    _flightGeneration = generation;
    final future = _renew(session, generation, epoch, cancellation);
    _flight = future;
    try {
      return await future;
    } finally {
      if (identical(_flight, future)) {
        _flight = null;
        _flightGeneration = null;
        _cancellation = null;
      }
    }
  }

  Future<SessionCredentials?> _renew(SessionCredentials session, int generation,
      int epoch, CancelToken cancellation) async {
    SessionCredentials? pending;
    try {
      pending = await storage.prepareRenewal(
          expectedToken: session.token,
          generation: generation,
          requestId: _newId());
      if (pending == null || epoch != _epoch || cancellation.isCancelled) {
        return storage.credentials();
      }
      final replacement = await transport.renew(pending, cancellation);
      if (epoch == _epoch && !cancellation.isCancelled) {
        final committed = await storage.commitRenewal(replacement,
            expected: pending, generation: generation, now: _now());
        if (committed &&
            epoch == _epoch &&
            storage.authGeneration == generation) {
          await onRotated?.call();
        }
      }
    } catch (error) {
      final code = authCode(error);
      if (epoch == _epoch &&
          storage.authGeneration == generation &&
          terminalCodes.contains(code)) {
        await storage.clearAuthDataIfTokenMatches(session.token,
            expectedGeneration: generation, onCleared: onTerminal);
      } else if (epoch == _epoch && storage.authGeneration == generation) {
        _retryGeneration = generation;
        _retryAt = _now().add(
            error is DioException && error.response?.statusCode == 404
                ? unsupportedCooldown
                : retryCooldown);
      }
    }
    return storage.credentials();
  }

  static const terminalCodes = {
    'AUTH_SESSION_REVOKED',
    'AUTH_REFRESH_INVALID',
    'AUTH_INVALID'
  };
  static String? authCode(Object error) {
    if (error is! DioException || error.response?.statusCode != 401) {
      return null;
    }
    final body = error.response?.data;
    return body is Map && body['code'] is String
        ? body['code'] as String
        : null;
  }

  Future<void> rejectCapturedToken(String token, {int? generation}) => storage
      .clearAuthDataIfTokenMatches(token,
          expectedGeneration: generation, onCleared: onTerminal)
      .then((_) {});
}
