import 'dart:async';
import '../../../core/security/request_security.dart';
import '../../../core/security/socket_transport.dart';
import '../../../core/security/session_renewal_coordinator.dart';
import '../../../core/api/api_client.dart';

import 'package:cleaning_service_driver/core/api/api_environment.dart';
import 'package:cleaning_service_driver/data/models/chats/chat_message_model.dart';
import 'package:cleaning_service_driver/data/models/chats/conversation_model.dart';
import 'package:cleaning_service_driver/data/models/chats/send_chat_message_request.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class ChatSocketService {
  static const _connectionTimeout = Duration(seconds: 10);
  static const _ackTimeout = Duration(seconds: 12);

  final String _chatUrl;
  io.Socket? _socket;
  String? _currentUserId;
  String? _authHeader;
  int _generation = 0;
  final SessionRenewalCoordinator? _sessions;
  final io.Socket Function(String, Map<String, dynamic>) _socketFactory;

  final _messagesController = StreamController<ChatMessageModel>.broadcast();
  final _conversationController =
      StreamController<ConversationModel>.broadcast();
  final _statusController = StreamController<String>.broadcast();

  Stream<ChatMessageModel> get messagesStream => _messagesController.stream;
  Stream<ConversationModel> get conversationStream =>
      _conversationController.stream;
  Stream<String> get statusStream => _statusController.stream;

  ChatSocketService(
      {String? chatUrl,
      SessionRenewalCoordinator? sessions,
      io.Socket Function(String, Map<String, dynamic>)? socketFactory})
      : _chatUrl = chatUrl ?? ApiEnvironment.chatUrl,
        _sessions = sessions,
        _socketFactory = socketFactory ?? io.io;

  SessionRenewalCoordinator get _renewal => _sessions ?? ApiClient().sessions;

  Future<void> refreshCredentials() async {
    if (_socket == null) return;
    await disconnect(keepStreams: true);
    await connect();
  }

  Future<void> connect() async {
    RequestSecurity.socketDestination(_chatUrl, ApiEnvironment.chatUrl);
    final generation = _generation;
    final snapshot = await _renewal.ensureSession().timeout(_connectionTimeout);
    final token = snapshot?.token;
    final user = snapshot?.user;
    if (generation != _generation) return;
    _currentUserId = user?.id;

    if (token == null || token.isEmpty) {
      await disconnect();
      _statusController.add('error');
      return;
    }
    if (token.length > 16384 || token.contains(RegExp(r'[\x00-\x20\x7f]'))) {
      await disconnect();
      throw const FormatException('Invalid session credential.');
    }
    final authHeader = 'Bearer $token';

    final existing = _socket;
    if (existing != null && _authHeader == authHeader) {
      if (existing.connected) {
        _statusController.add('connected');
      } else {
        _statusController.add('connecting');
        existing.connect();
      }
      return;
    }

    if (existing != null) {
      existing.disconnect();
      existing.dispose();
      _socket = null;
    }
    _authHeader = authHeader;

    _statusController.add('connecting');

    final socket = _socketFactory(
      _chatUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .disableMultiplex()
          .enableForceNew()
          .setExtraHeaders({'Authorization': authHeader})
          .setTransportOptions({
            'websocket': {
              'extraHeaders': {'Authorization': authHeader}
            }
          })
          .build()
        ..['httpClientAdapter'] = createSecureSocketAdapter(),
    );

    socket.onConnect((_) {
      if (generation != _generation || _socket != socket) return;
      _statusController.add('connected');
    });

    socket.onDisconnect((_) {
      if (generation != _generation || _socket != socket) return;
      _statusController.add('disconnected');
    });

    socket.onConnectError((e) {
      if (generation != _generation || _socket != socket) return;
      _statusController.add('error');
    });

    socket.onError((e) {
      if (generation != _generation || _socket != socket) return;
      _statusController.add('error');
    });

    void handleIncoming(dynamic payload, String eventName) {
      if (generation != _generation || _socket != socket) return;
      if (payload is! Map) return;
      final map = Map<String, dynamic>.from(payload);

      final message = ChatMessageModel.fromJson(
        map,
        currentUserId: _currentUserId,
        fallbackMineWhenCustomer: false,
      );
      if (message.id.isEmpty || message.text.trim().isEmpty) return;
      _messagesController.add(message);
    }

    void handleConversation(dynamic payload, String eventName) {
      if (generation != _generation || _socket != socket) return;
      if (payload is! Map) return;
      final map = Map<String, dynamic>.from(payload);

      final conversation = ConversationModel.fromJson(map);
      if (conversation.id.isEmpty) return;
      _conversationController.add(conversation);
    }

    socket.on('newMessage', (p) => handleIncoming(p, 'newMessage'));
    socket.on('message', (p) => handleIncoming(p, 'message'));
    socket.on('chatMessage', (p) => handleIncoming(p, 'chatMessage'));
    socket.on('messageCreated', (p) => handleIncoming(p, 'messageCreated'));
    socket.on('conversationUpdated',
        (p) => handleConversation(p, 'conversationUpdated'));
    socket.on('conversationClosed',
        (p) => handleConversation(p, 'conversationClosed'));
    socket.on('auth_error', (payload) async {
      if (generation != _generation || _socket != socket || payload is! Map) {
        return;
      }
      final code = payload['code'];
      if (code == 'AUTH_ACCESS_EXPIRED') {
        final replacement =
            await _renewal.ensureSession(force: true, expiredToken: token);
        if (generation == _generation &&
            replacement != null &&
            replacement.token != token) {
          await refreshCredentials();
        }
      } else if (SessionRenewalCoordinator.terminalCodes.contains(code)) {
        await _renewal.rejectCapturedToken(token);
      }
    });

    _socket = socket;
    socket.connect();
  }

  Future<void> sendMessage(SendChatMessageRequest request) async {
    final payload = RequestSecurity.prepare(request.toJson(),
        endpoint: '/chat/sendMessage');
    await _ensureConnected();
    final socket = _socket;
    if (socket == null || !socket.connected) {
      throw StateError('Chat socket is not connected.');
    }

    final completer = Completer<void>();
    late final Timer timer;

    timer = Timer(_ackTimeout, () {
      if (completer.isCompleted) return;
      completer.completeError(
        TimeoutException('Timed out while sending chat message.'),
      );
    });

    socket.emitWithAck('sendMessage', payload, ack: (ack) {
      if (completer.isCompleted) return;
      final normalizedAck = _normalizeAck(ack);
      if (_ackFailed(normalizedAck)) {
        completer.completeError(
          Exception(_ackErrorMessage(normalizedAck)),
        );
        return;
      }
      completer.complete();
    });

    await completer.future.whenComplete(timer.cancel);
  }

  Future<void> disconnect({bool keepStreams = false}) async {
    _generation++;
    final socket = _socket;
    if (socket != null) {
      socket.dispose();
      socket.disconnect();
    }
    _socket = null;
    _authHeader = null;
    if (!keepStreams) {
      _currentUserId = null;
    }
  }

  Future<void> close() async {
    await disconnect();
    await _messagesController.close();
    await _conversationController.close();
    await _statusController.close();
  }

  Future<void> _ensureConnected() async {
    await connect();
    if (_socket?.connected ?? false) return;
    if (_socket == null) {
      throw StateError('Chat socket is unavailable.');
    }

    final completer = Completer<void>();
    late final StreamSubscription<String> sub;
    late final Timer timer;

    sub = statusStream.listen((status) {
      if (completer.isCompleted) return;
      if (status == 'connected') {
        completer.complete();
      } else if (status == 'error') {
        completer.completeError(StateError('Chat socket connection failed.'));
      }
    });

    if (_socket?.connected ?? false) {
      await sub.cancel();
      return;
    }

    timer = Timer(_connectionTimeout, () {
      if (completer.isCompleted) return;
      completer.completeError(
        TimeoutException('Timed out while connecting chat socket.'),
      );
    });

    await completer.future.whenComplete(() {
      timer.cancel();
      sub.cancel();
    });
  }

  dynamic _normalizeAck(dynamic ack) {
    if (ack is List && ack.length == 1) return ack.first;
    return ack;
  }

  bool _ackFailed(dynamic ack) {
    if (ack is Map) {
      final map = Map<String, dynamic>.from(ack);
      if (map['success'] == false || map['ok'] == false) return true;
      if (map['error'] != null) return true;
      if (map['status']?.toString().toLowerCase() == 'error') return true;
    }
    return false;
  }

  String _ackErrorMessage(dynamic ack) {
    if (ack is Map) {
      final map = Map<String, dynamic>.from(ack);
      return (map['message'] ?? map['error'] ?? 'Failed to send message')
          .toString();
    }
    return 'Failed to send message';
  }
}
