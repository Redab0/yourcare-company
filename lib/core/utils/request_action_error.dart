import 'package:dio/dio.dart';

/// Preserve the API's actionable message; leave transport failures localized
/// by the screen's generic error fallback.
String requestActionErrorMessage(Object error) {
  if (error is DioException) {
    final data = error.response?.data;
    final message = data is Map ? data['message'] : null;
    if (message is String) return message.trim();
    if (message is List) return message.whereType<String>().join('\n');
    return '';
  }
  if (error is Exception) {
    return error.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
  }
  return '';
}
