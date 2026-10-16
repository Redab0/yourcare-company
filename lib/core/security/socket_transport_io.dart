import 'dart:io';

import 'package:socket_io_client/socket_io_client.dart' show HttpClientAdapter;
import '../api/api_environment.dart';

Object createSecureSocketAdapter() => _SecureSocketAdapter();

class _SecureSocketAdapter implements HttpClientAdapter {
  @override
  Future<WebSocket> connect(String uri, {Map<String, dynamic>? headers}) async {
    final target = Uri.parse(uri);
    final expected = Uri.parse(ApiEnvironment.chatUrl);
    if (target.scheme != 'wss' ||
        target.host != expected.host ||
        target.port != 443 ||
        target.userInfo.isNotEmpty ||
        target.path != '/socket.io/' ||
        target.hasFragment) {
      throw const FormatException('Invalid chat transport destination.');
    }
    final client = _NoRedirectClient();
    try {
      return await WebSocket.connect(uri,
              headers: headers, customClient: client)
          .timeout(const Duration(seconds: 10));
    } finally {
      // An upgraded WebSocket owns its detached transport independently.
      client.close(force: true);
    }
  }
}

/// WebSocket.connect delegates its HTTP upgrade request to openUrl. The Dart
/// HttpClient otherwise follows GET redirects, including credentialed upgrades.
class _NoRedirectClient implements HttpClient {
  final HttpClient _client = HttpClient()
    ..connectionTimeout = const Duration(seconds: 10);

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    final request = await _client.openUrl(method, url);
    request.followRedirects = false;
    request.maxRedirects = 0;
    return request;
  }

  @override
  void close({bool force = false}) => _client.close(force: force);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
