import 'package:dio/dio.dart';
import '../access/price_access.dart';
import '../access/price_access_interceptor.dart';
import '../api/api_environment.dart';
import '../api/upload_limits.dart';
import 'request_security.dart';
import '../api/session_request_interceptor.dart';

/// Runs before session credentials are read or attached.
class RequestSecurityInterceptor extends Interceptor {
  RequestSecurityInterceptor(
      {this.trustedApiUrl = ApiEnvironment.apiUrl, this.accountGeneration});
  final String trustedApiUrl;
  final int Function()? accountGeneration;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    try {
      options.extra.putIfAbsent(
          PriceAccessInterceptor.epochKey, () => PriceAccess.instance.epoch);
      if (accountGeneration != null) {
        options.extra.putIfAbsent(
            SessionRequestInterceptor.expectedGenerationKey,
            () => accountGeneration!());
      }
      RequestSecurity.destination(options, trustedApiUrl);
      final endpoint =
          options.uri.path.substring(Uri.parse(trustedApiUrl).path.length);
      options.queryParameters = Map<String, dynamic>.from(
          RequestSecurity.prepare(options.queryParameters,
              endpoint: endpoint, query: true) as Map);
      if (options.data is FormData) {
        final form = options.data as FormData;
        if (form.fields.length > RequestSecurity.maxCollection) {
          throw const FormatException('Too many upload fields.');
        }
        // A list preserves duplicate keys and shares one cumulative budget.
        final normalized = RequestSecurity.prepare(
            form.fields.map((field) => {field.key: field.value}).toList(),
            endpoint: endpoint) as List;
        form.fields.clear();
        for (final field in normalized.cast<Map<String, dynamic>>()) {
          form.fields
              .add(MapEntry(field.keys.single, field.values.single as String));
        }
        UploadLimits.validate(form.files.map((entry) {
          if (entry.key != 'images') {
            throw const FormatException('Unsupported upload field.');
          }
          final file = entry.value;
          UploadLimits.validateFilename(file.filename);
          final type = file.contentType?.mimeType;
          if (!UploadLimits.imageMimeTypes.contains(type)) {
            throw const FormatException('Unsupported image format.');
          }
          return UploadFileSize(file.length);
        }).toList());
      } else {
        options.data =
            RequestSecurity.prepare(options.data, endpoint: endpoint);
      }
      handler.next(options);
    } catch (_) {
      handler.reject(DioException(
          requestOptions: options,
          error: const FormatException('Invalid request.'),
          message: 'Please check the entered information.'));
    }
  }
}
