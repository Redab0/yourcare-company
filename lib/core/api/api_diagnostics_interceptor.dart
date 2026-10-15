import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import '../diagnostics/app_diagnostics.dart';

/// Correlates retries with a bounded opaque ID; never logs bodies or URLs.
class ApiDiagnosticsInterceptor extends Interceptor {
  static const requestIdHeader = 'X-Request-ID';
  static final _validId = RegExp(r'^[A-Za-z0-9][A-Za-z0-9._-]{7,63}$');
  final String Function() newId;
  ApiDiagnosticsInterceptor({String Function()? newId})
      : newId = newId ?? const Uuid().v4;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final existing = options.headers.entries
        .where((entry) => entry.key.toLowerCase() == 'x-request-id')
        .map((entry) => entry.value)
        .firstOrNull;
    options.headers
        .removeWhere((key, _) => key.toLowerCase() == 'x-request-id');
    options.headers[requestIdHeader] =
        existing is String && _validId.hasMatch(existing) ? existing : newId();
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _record(response.requestOptions, response.statusCode ?? 0);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _record(err.requestOptions, err.response?.statusCode ?? 0);
    handler.next(err);
  }

  void _record(RequestOptions request, int status) {
    if (request.extra['skipDiagnostics'] == true ||
        request.uri.path.endsWith('/telemetry/client-errors')) {
      return;
    }
    AppDiagnostics.recordApi(
      method: request.method,
      operation: operationFor(request.uri.path),
      status: status,
      requestId: request.headers[requestIdHeader]?.toString() ?? 'unavailable',
    );
  }

  static String operationFor(String path) {
    final parts = Uri.parse(path).pathSegments;
    for (final allowed in const [
      'auth',
      'requests',
      'laundry',
      'payments',
      'upload',
      'jobs',
      'chats'
    ]) {
      if (parts.contains(allowed)) return allowed;
    }
    return 'other';
  }
}
