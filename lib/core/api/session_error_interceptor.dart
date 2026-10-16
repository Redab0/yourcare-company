import 'package:dio/dio.dart';
import '../security/session_renewal_coordinator.dart';
import 'session_request_interceptor.dart';

class SessionErrorInterceptor extends Interceptor {
  SessionErrorInterceptor(this.sessions, this.dio);
  final SessionRenewalCoordinator sessions;
  final Dio dio;
  static const _retried = 'session_expiry_retried';

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final error = err;
    final request = error.requestOptions;
    final authorization = request.headers['Authorization'];
    if (authorization is! String || !authorization.startsWith('Bearer ')) {
      handler.next(error);
      return;
    }
    final token = authorization.substring(7);
    final code = SessionRenewalCoordinator.authCode(error);
    final requestGeneration =
        request.extra[SessionRequestInterceptor.accountGenerationKey];
    if (requestGeneration != sessions.storage.authGeneration) {
      handler.next(error);
      return;
    }
    try {
      if (SessionRenewalCoordinator.terminalCodes.contains(code)) {
        await sessions.rejectCapturedToken(token,
            generation: requestGeneration as int);
      } else if (code == 'AUTH_ACCESS_EXPIRED' &&
          request.extra[_retried] != true &&
          request.cancelToken?.isCancelled != true &&
          _reusable(request.data)) {
        final generation = sessions.storage.authGeneration;
        final replacement =
            await sessions.ensureSession(force: true, expiredToken: token);
        if (replacement != null &&
            replacement.token != token &&
            generation == sessions.storage.authGeneration &&
            request.cancelToken?.isCancelled != true) {
          final retry = request.copyWith(extra: {
            ...request.extra,
            _retried: true,
            SessionRequestInterceptor.expectedGenerationKey: requestGeneration
          }, headers: Map<String, dynamic>.from(request.headers));
          // The normal interceptor reads the fresh committed bearer.
          final response = await dio.fetch<dynamic>(retry);
          handler.resolve(response);
          return;
        }
      }
    } catch (_) {/* Preserve the original failure and committed session. */}
    handler.next(error);
  }

  static bool _reusable(dynamic body, [int depth = 0]) {
    if (depth > 16) return false;
    if (body == null || body is String || body is num || body is bool) {
      return true;
    }
    if (body is Map) {
      return body.length <= 1000 &&
          body.keys.every((key) => key is String) &&
          body.values.every((value) => _reusable(value, depth + 1));
    }
    if (body is List) {
      return body.length <= 1000 &&
          body.every((value) => _reusable(value, depth + 1));
    }
    return false;
  }
  // FormData and arbitrary streams are never automatically replayed.
}
