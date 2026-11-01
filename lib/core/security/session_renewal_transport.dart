import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../data/models/auth/login_response.dart';
import '../api/api_environment.dart';
import 'request_security.dart';
import 'session_credentials.dart';

abstract interface class SessionRenewalTransport {
  Future<SessionCredentials> renew(
      SessionCredentials pending, CancelToken cancel);
  Future<void> confirm(SessionCredentials session, CancelToken cancel);
  Future<void> revoke(SessionCredentials session, CancelToken cancel);
  Future<void> deactivate(
      {required String bearer,
      required String fcmToken,
      required String deviceId,
      required String platform,
      required CancelToken cancel});
}

/// A separate Dio has no session interceptor and cannot recursively renew.
/// The adapter provider deliberately follows the app's configured adapter:
/// injected local fakes apply to renewal and cannot escape to production.
class DioSessionRenewalTransport implements SessionRenewalTransport {
  DioSessionRenewalTransport(
      {required HttpClientAdapter Function() adapter,
      required String Function() languageTag,
      this.apiUrl = ApiEnvironment.apiUrl,
      this.deadline = const Duration(seconds: 8)})
      : _languageTag = languageTag,
        _dio = Dio(BaseOptions(
            baseUrl: apiUrl,
            connectTimeout: deadline,
            sendTimeout: deadline,
            receiveTimeout: deadline,
            followRedirects: false,
            maxRedirects: 0)) {
    _dio.httpClientAdapter = _BorrowedAdapter(adapter);
  }
  final String apiUrl;
  final Duration deadline;
  final String Function() _languageTag;
  final Dio _dio;

  Future<Response<dynamic>> _post(
      String path, Map<String, dynamic>? body, CancelToken cancel,
      {String? bearer}) async {
    final language = _languageTag();
    if (!RegExp(r'^(?:en|ar)(?:-[A-Za-z]{2,8})?$').hasMatch(language)) {
      throw const FormatException('Unsupported request language.');
    }
    if (bearer != null) _credential(bearer);
    final options = Options(headers: {
      'channel': 'MANAGER',
      'Content-Type': 'application/json',
      'Accept-Language': language,
      'locale': language,
      if (bearer != null) 'Authorization': 'Bearer $bearer'
    }, followRedirects: false, maxRedirects: 0)
        .compose(_dio.options, path, data: body, cancelToken: cancel);
    RequestSecurity.destination(options, apiUrl);
    options.data = RequestSecurity.prepare(body, endpoint: path);
    return _dio.fetch<dynamic>(options).timeout(deadline, onTimeout: () {
      // Also cancels an adapter that completes after the caller's deadline.
      cancel.cancel();
      throw TimeoutException('Session request timed out.');
    });
  }

  @override
  Future<SessionCredentials> renew(
      SessionCredentials pending, CancelToken cancel) async {
    final id = pending.requestId;
    final credential = pending.requestCredential;
    if (id == null || !_uuid.hasMatch(id) || credential == null) {
      throw const FormatException('Missing renewal recovery.');
    }
    _credential(credential);
    final response = await _post(
        pending.requestIsRefresh ? '/auth/refresh' : '/auth/session',
        {
          'requestId': id,
          if (pending.requestIsRefresh) 'refreshToken': credential
        },
        cancel,
        bearer: pending.requestIsRefresh ? null : credential);
    return parse(response.data);
  }

  static final _uuid = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-4[0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$');
  static void _credential(String value) {
    if (value.isEmpty ||
        value.length > 16384 ||
        value.contains(RegExp(r'[\x00-\x20\x7f]'))) {
      throw const FormatException('Invalid session credential.');
    }
  }

  static SessionCredentials parse(dynamic body) {
    if (body is! Map || body['success'] != true || body['data'] is! Map) {
      throw const FormatException('Invalid renewal response.');
    }
    final data = Map<String, dynamic>.from(body['data'] as Map);
    final token = data['token'];
    final refresh = data['refreshToken'];
    final sessionId = data['sessionId'];
    final expires = data['accessExpiresAt'];
    if (token is! String ||
        refresh is! String ||
        sessionId is! String ||
        !_uuid.hasMatch(sessionId) ||
        expires is! String ||
        !expires.endsWith('Z') ||
        data['user'] is! Map) {
      throw const FormatException('Invalid renewal response.');
    }
    _credential(token);
    _credential(refresh);
    final expiry = DateTime.tryParse(expires);
    final user = User.fromJson(Map<String, dynamic>.from(data['user'] as Map));
    if (expiry == null ||
        !SessionCredentials.jwtPattern.hasMatch(token) ||
        user.id == null ||
        !RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(user.id!) ||
        !SessionCredentials.providerRoles.contains(user.role) ||
        user.enabled == false) {
      throw const FormatException('Invalid renewal identity.');
    }
    return SessionCredentials(
        token: token,
        user: user,
        refreshToken: refresh,
        accessExpiresAt: expiry.toUtc(),
        sessionId: sessionId);
  }

  @override
  Future<void> confirm(SessionCredentials session, CancelToken cancel) async {
    final request = SessionConfirmationRequest(session.sessionId);
    if (session.refreshToken == null ||
        session.requestId != null ||
        !SessionCredentials.jwtPattern.hasMatch(session.token)) {
      throw const FormatException('Missing committed renewable session.');
    }
    final response = await _post(
        '/auth/session/confirm', request.toJson(), cancel,
        bearer: session.token);
    if (response.statusCode != 204) {
      throw DioException.badResponse(
          statusCode: response.statusCode ?? 0,
          requestOptions: response.requestOptions,
          response: response);
    }
  }

  @override
  Future<void> revoke(SessionCredentials session, CancelToken cancel) async {
    if (session.refreshToken != null) {
      _credential(session.refreshToken!);
      await _post('/auth/session-revoke',
          {'refreshToken': session.refreshToken}, cancel);
    } else {
      await _post('/auth/logout', null, cancel, bearer: session.token);
    }
  }

  @override
  Future<void> deactivate(
      {required String bearer,
      required String fcmToken,
      required String deviceId,
      required String platform,
      required CancelToken cancel}) async {
    await _post(
        '/notifications/deactivate-token',
        {'fcmToken': fcmToken, 'deviceId': deviceId, 'platform': platform},
        cancel,
        bearer: bearer);
  }
}

/// The confirmation endpoint never accepts a caller-selected account or root.
class SessionConfirmationRequest {
  SessionConfirmationRequest(String? value)
      : sessionId =
            value ?? (throw const FormatException('Missing session ID.')) {
    if (!SessionCredentials.uuidPattern.hasMatch(sessionId)) {
      throw const FormatException('Invalid session ID.');
    }
  }

  final String sessionId;
  Map<String, String> toJson() => {'sessionId': sessionId};
}

class _BorrowedAdapter implements HttpClientAdapter {
  _BorrowedAdapter(this._adapter);
  final HttpClientAdapter Function() _adapter;
  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? stream,
      Future<void>? cancelFuture) async {
    final response = await _adapter().fetch(options, stream, cancelFuture);
    const maximum = 1024 * 1024;
    final size =
        int.tryParse(response.headers['content-length']?.firstOrNull ?? '');
    if (size != null && size > maximum) {
      await response.stream.listen((_) {}).cancel();
      throw const FormatException('Session response exceeds the limit.');
    }
    response.stream = _bounded(response.stream, maximum);
    return response;
  }

  static Stream<Uint8List> _bounded(
      Stream<Uint8List> source, int maximum) async* {
    var bytes = 0;
    await for (final chunk in source) {
      bytes += chunk.length;
      if (bytes > maximum) {
        throw const FormatException('Session response exceeds the limit.');
      }
      yield chunk;
    }
  }

  @override
  void close({bool force = false}) {/* The app owns the borrowed adapter. */}
}
