import '../access/price_access.dart';
import 'dart:async';

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
  Future<void>? _confirmationFlight;
  CancelToken? _confirmationCancellation;
  int? _confirmationGeneration;
  String? _confirmationSessionId;
  DateTime? _confirmationRetryAt;
  int? _confirmedGeneration;
  String? _confirmedSessionId;

  void cancelRenewal() {
    _epoch++;
    _cancellation?.cancel();
    _cancellation = null;
    _flight = null;
    _flightGeneration = null;
    _retryAt = null;
    _confirmationCancellation?.cancel();
    _confirmationCancellation = null;
    _confirmationFlight = null;
    _confirmationRetryAt = null;
    _confirmedGeneration = null;
    _confirmedSessionId = null;
  }

  Future<SessionCredentials?> ensureSession(
      {bool force = false, String? expiredToken}) async {
    final session = await storage.credentials();
    if (session == null) return null;
    final generation = storage.authGeneration;
    if (expiredToken != null && session.token != expiredToken) {
      _scheduleConfirmation(session, generation);
      return session;
    }
    final due = session.requestId != null ||
        session.refreshToken == null ||
        session.accessExpiresAt == null ||
        !session.accessExpiresAt!
            .isAfter(_now().add(const Duration(seconds: 60)));
    if (!force && !due) {
      _scheduleConfirmation(session, generation);
      return session;
    }
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
      final accessEpoch = PriceAccess.instance.epoch;
      final replacement = await transport.renew(pending, cancellation);
      if (epoch == _epoch && !cancellation.isCancelled) {
        final committed = await storage.commitRenewal(replacement,
            expected: pending,
            generation: generation,
            expectedAccessEpoch: accessEpoch,
            now: _now());
        if (committed &&
            epoch == _epoch &&
            storage.authGeneration == generation) {
          _scheduleConfirmation(replacement, generation);
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

  /// Runs separately from renewal: even an explicit confirmation rejection
  /// cannot clear the replacement which has already been safely saved.
  void _scheduleConfirmation(SessionCredentials session, int generation) {
    if (session.refreshToken == null ||
        session.requestId != null ||
        session.sessionId == null ||
        session.user?.id == null ||
        session.accessExpiresAt?.isAfter(_now()) != true ||
        (_confirmedGeneration == generation &&
            _confirmedSessionId == session.sessionId)) {
      return;
    }
    final sameSession = _confirmationGeneration == generation &&
        _confirmationSessionId == session.sessionId;
    if (sameSession &&
        (_confirmationFlight != null ||
            _confirmationRetryAt?.isAfter(_now()) == true)) {
      return;
    }
    // Account switches may have left a request in flight. Cancel it before
    // scheduling the new account; a late completion never marks that account.
    _confirmationCancellation?.cancel();
    final cancellation = CancelToken();
    _confirmationCancellation = cancellation;
    _confirmationGeneration = generation;
    _confirmationSessionId = session.sessionId;
    _confirmationRetryAt = null;
    final epoch = _epoch;
    final future = _confirmCommitted(session, generation, epoch, cancellation);
    _confirmationFlight = future;
    unawaited(future.whenComplete(() {
      if (identical(_confirmationFlight, future)) {
        _confirmationFlight = null;
        _confirmationCancellation = null;
      }
    }));
  }

  Future<void> _confirmCommitted(SessionCredentials expected, int generation,
      int epoch, CancelToken cancellation) async {
    try {
      // A successful write is insufficient: the native store must return the
      // complete replacement before its legacy bearer can be retired remotely.
      final current = await storage.credentials();
      if (epoch != _epoch ||
          cancellation.isCancelled ||
          storage.authGeneration != generation ||
          current?.token != expected.token ||
          current?.refreshToken != expected.refreshToken ||
          current?.sessionId != expected.sessionId ||
          current?.user?.id != expected.user?.id ||
          current?.requestId != null ||
          current?.accessExpiresAt?.isAfter(_now()) != true) {
        return;
      }
      await transport.confirm(current!, cancellation);
      if (epoch == _epoch &&
          !cancellation.isCancelled &&
          storage.authGeneration == generation) {
        _confirmedGeneration = generation;
        _confirmedSessionId = expected.sessionId;
      }
    } catch (error) {
      if (epoch == _epoch &&
          !cancellation.isCancelled &&
          storage.authGeneration == generation) {
        _confirmationRetryAt = _now().add(
            error is DioException && error.response?.statusCode == 404
                ? unsupportedCooldown
                : retryCooldown);
      }
    }
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
