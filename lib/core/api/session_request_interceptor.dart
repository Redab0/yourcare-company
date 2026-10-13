import 'dart:async';
import 'package:dio/dio.dart';

/// Preparing request headers must settle even when the platform keychain fails.
class SessionRequestInterceptor extends Interceptor {
  final Future<String?> Function() readAccessToken;
  final String Function() languageTag;
  final Duration credentialsTimeout;
  SessionRequestInterceptor(
      {required this.readAccessToken,
      required this.languageTag,
      this.credentialsTimeout = const Duration(seconds: 10)});

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    try {
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
      final token = await readAccessToken().timeout(credentialsTimeout);
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
