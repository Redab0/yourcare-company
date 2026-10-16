import 'dart:async';
import 'package:dio/dio.dart';
import 'api_environment.dart';
import '../security/request_security.dart';

/// Preparing request headers must settle even when the platform keychain fails.
class SessionRequestInterceptor extends Interceptor {
  final Future<String?> Function() readAccessToken;
  final String Function() languageTag;
  final Duration credentialsTimeout;
  final String trustedApiUrl;
  final int Function()? accountGeneration;
  static const accountGenerationKey = 'session_account_generation';
  static const expectedGenerationKey = 'session_expected_account_generation';
  SessionRequestInterceptor(
      {required this.readAccessToken,
      required this.languageTag,
      this.accountGeneration,
      this.trustedApiUrl = ApiEnvironment.apiUrl,
      this.credentialsTimeout = const Duration(seconds: 10)});

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      RequestSecurity.destination(options, trustedApiUrl);
      final requestedAuthorization = options.headers['Authorization'];
      options.headers
          .removeWhere((key, _) => key.toLowerCase() == 'authorization');
      final initialCancellation = options.cancelToken?.cancelError;
      if (initialCancellation != null) {
        handler.reject(initialCancellation);
        return;
      }
      final requestLanguage =
          options.headers['Accept-Language']?.toString().trim();
      final language = requestLanguage?.isNotEmpty == true
          ? requestLanguage!
          : languageTag();
      if (!RegExp(r'^(?:en|ar)(?:-[A-Za-z]{2,8})?$').hasMatch(language)) {
        throw const FormatException('Unsupported request language.');
      }
      final publicLogin = options.uri.path.endsWith('/auth/login');
      final generation = accountGeneration?.call();
      final expectedGeneration = options.extra[expectedGenerationKey];
      if (expectedGeneration != null && generation != expectedGeneration) {
        throw const FormatException('The account changed before retry.');
      }
      final token = publicLogin
          ? null
          : await readAccessToken().timeout(credentialsTimeout);
      if (generation != accountGeneration?.call()) {
        throw const FormatException('The account changed before the request.');
      }
      if (generation != null) options.extra[accountGenerationKey] = generation;
      if (token != null &&
          (token.isEmpty ||
              token.length > 16384 ||
              token.contains(RegExp(r'[\x00-\x20\x7f]')))) {
        throw const FormatException('Invalid session credential.');
      }
      if ((options.uri.path.endsWith('/auth/logout') ||
              (options.uri.path.endsWith('/notifications/deactivate-token') &&
                  requestedAuthorization != null)) &&
          requestedAuthorization != (token == null ? null : 'Bearer $token')) {
        throw const FormatException('The session changed before sign-out.');
      }
      final cancellation = options.cancelToken?.cancelError;
      if (cancellation != null) {
        handler.reject(cancellation);
        return;
      }
      options.headers['Accept-Language'] = language;
      options.headers['locale'] = language;
      if (token != null) options.headers['Authorization'] = 'Bearer $token';
      handler.next(options);
    } catch (error, stackTrace) {
      handler.reject(DioException(
          requestOptions: options,
          error: error,
          stackTrace: stackTrace,
          message: 'Could not prepare authenticated request'));
    }
  }
}
