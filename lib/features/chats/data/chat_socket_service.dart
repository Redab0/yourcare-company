import 'dart:async';
import 'dart:developer' as developer;

import 'package:cleaning_service_driver/core/api/api_client.dart';
import 'package:cleaning_service_driver/core/storage/secure_storage_service.dart';
import 'package:cleaning_service_driver/data/models/chats/chat_message_model.dart';
import 'package:cleaning_service_driver/data/models/chats/conversation_model.dart';
import 'package:cleaning_service_driver/data/models/chats/send_chat_message_request.dart';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class ChatSocketService {
  static const _connectionTimeout = Duration(seconds: 10);
  static const _ackTimeout = Duration(seconds: 12);

  final String _chatUrl;
  io.Socket? _socket;
  String? _currentUserId;
  String? _authHeader;

  final _messagesController = StreamController<ChatMessageModel>.broadcast();
  final _conversationController =
      StreamController<ConversationModel>.broadcast();
  final _statusController = StreamController<String>.broadcast();

  Stream<ChatMessageModel> get messagesStream => _messagesController.stream;
  Stream<ConversationModel> get conversationStream =>
      _conversationController.stream;
  Stream<String> get statusStream => _statusController.stream;

  ChatSocketService({String? chatUrl})
      : _chatUrl = chatUrl ?? _chatUrlFromApiBase(ApiClient.baseUrl);

  Future<void> connect() async {
    final token = await SecureStorageService().getAccessToken();
    final user = await SecureStorageService().getUser();
    _currentUserId = user?.id;

    if (token == null || token.isEmpty) {
      _statusController.add('error');
      return;
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

    final socket = io.io(
      _chatUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setExtraHeaders({'Authorization': authHeader})
          .setTransportOptions({
            'websocket': {
              'extraHeaders': {'Authorization': authHeader}
            }
          })
          .build(),
    );

    socket.onConnect((_) {
      if (kDebugMode) developer.log('[ChatSocket] connected');
      _statusController.add('connected');
    });

    socket.onDisconnect((_) {
      if (kDebugMode) developer.log('[ChatSocket] disconnected');
      _statusController.add('disconnected');
    });

    socket.onConnectError((e) {
      if (kDebugMode) developer.log('[ChatSocket] connect error: $e');
      _statusController.add('error');
    });

    socket.onError((e) {
      if (kDebugMode) developer.log('[ChatSocket] error: $e');
      _statusController.add('error');
    });

    void handleIncoming(dynamic payload, String eventName) {
      if (payload is! Map) return;
      final map = Map<String, dynamic>.from(payload);
      _logSocketEvent(eventName, map);
      final message = ChatMessageModel.fromJson(
        map,
        currentUserId: _currentUserId,
        fallbackMineWhenCustomer: false,
      );
      if (message.id.isEmpty || message.text.trim().isEmpty) return;
      _messagesController.add(message);
    }

    void handleConversation(dynamic payload, String eventName) {
      if (payload is! Map) return;
      final map = Map<String, dynamic>.from(payload);
      _logSocketEvent(eventName, map);
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

    _socket = socket;
    socket.connect();
  }

  Future<void> sendMessage(SendChatMessageRequest request) async {
    await _ensureConnected();
    final socket = _socket;
    if (socket == null || !socket.connected) {
      throw StateError('Chat socket is not connected.');
    }

    final payload = request.toJson();
    if (kDebugMode) {
      developer.log(
        '[ChatSocket] sendMessage conversationId=${request.conversationId}',
      );
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
      if (kDebugMode) {
        developer.log('[ChatSocket] sendMessage ack=${_ackStatus(ack)}');
      }
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

  void _logSocketEvent(String eventName, Map<String, dynamic> payload) {
    if (!kDebugMode) return;
    final id = payload['_id'] ?? payload['id'] ?? '';
    final conversationId = payload['conversationId'] ?? payload['_id'] ?? '';
    final senderType = payload['senderType'] ?? '';
    final status = payload['status'] ?? '';
    developer.log(
      '[ChatSocket] $eventName id=$id conversationId=$conversationId senderType=$senderType status=$status',
    );
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

  String _ackStatus(dynamic ack) {
    final normalizedAck = _normalizeAck(ack);
    if (normalizedAck is Map) {
      final map = Map<String, dynamic>.from(normalizedAck);
      if (map.containsKey('success')) return 'success=${map['success']}';
      if (map.containsKey('status')) return 'status=${map['status']}';
      if (map.containsKey('error')) return 'error';
    }
    return normalizedAck == null
        ? 'received'
        : normalizedAck.runtimeType.toString();
  }

  static String _chatUrlFromApiBase(String apiBaseUrl) {
    final uri = Uri.parse(apiBaseUrl);
    final segments = List<String>.from(uri.pathSegments);
    if (segments.isNotEmpty && segments.last == 'api') {
      segments.removeLast();
    }
    segments.add('chat');
    return uri
        .replace(pathSegments: segments, query: '', fragment: '')
        .toString();
  }
}
