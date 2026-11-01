import 'dart:typed_data';
import 'package:dio/dio.dart';

/// Bounds the incoming stream before Dio allocates a full document buffer.
class BoundedResponseAdapter implements HttpClientAdapter {
  BoundedResponseAdapter(this.delegate);
  final HttpClientAdapter delegate;
  static const maxDocumentBytes = 10 * 1024 * 1024;

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    final response = await delegate.fetch(options, requestStream, cancelFuture);
    if (options.responseType != ResponseType.bytes ||
        !RegExp(r'/company/documents/[^/]+/download$')
            .hasMatch(options.uri.path)) {
      return response;
    }
    final original = response.stream;
    final size =
        int.tryParse(response.headers['content-length']?.firstOrNull ?? '');
    if (size != null && size > maxDocumentBytes) {
      await original.listen((_) {}).cancel();
      throw DioException(
          requestOptions: options,
          message: 'Document exceeds the download limit.');
    }
    response.stream = _bounded(original, options);
    return response;
  }

  static Stream<Uint8List> _bounded(
      Stream<Uint8List> source, RequestOptions options) async* {
    var received = 0;
    await for (final chunk in source) {
      received += chunk.length;
      if (received > maxDocumentBytes) {
        throw DioException(
            requestOptions: options,
            message: 'Document exceeds the download limit.');
      }
      yield chunk;
    }
  }

  @override
  void close({bool force = false}) => delegate.close(force: force);
}
