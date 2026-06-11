import 'dart:async';

import 'package:cleaning_service_driver/core/storage/secure_storage_service.dart';
import 'package:cleaning_service_driver/data/models/chats/chat_message_model.dart';
import 'package:cleaning_service_driver/data/models/chats/conversation_model.dart';
import 'package:cleaning_service_driver/data/models/chats/send_chat_message_request.dart';
import 'package:cleaning_service_driver/features/chats/data/chat_history_service.dart';
import 'package:cleaning_service_driver/features/chats/data/chat_memory_store.dart';
import 'package:cleaning_service_driver/features/chats/data/chat_socket_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'chats_event.dart';
part 'chats_state.dart';

class ChatsBloc extends Bloc<ChatsEvent, ChatsState> {
  final ChatSocketService _socketService;
  final ChatMemoryStore _memoryStore;
  final ChatHistoryService _historyService;

  StreamSubscription<ChatMessageModel>? _messagesSub;
  StreamSubscription<String>? _statusSub;
  bool _wasConnected = false;
  bool _historyLoading = false;
  bool _olderHistoryLoading = false;

  ChatsBloc(
    this._socketService,
    this._memoryStore,
    this._historyService,
  ) : super(const ChatsState.initial()) {
    on<ConnectChatEvent>(_onConnect);
    on<LoadChatHistoryEvent>(_onLoadHistory);
    on<LoadOlderChatHistoryEvent>(_onLoadOlderHistory);
    on<SendChatMessageEvent>(_onSendMessage);
    on<CloseChatEvent>(_onClose);
    on<MinimizeChatEvent>(_onMinimize);
    on<_IncomingMessageEvent>(_onIncomingMessage);
    on<_SocketStatusEvent>(_onSocketStatus);
  }

  Future<void> _onConnect(
      ConnectChatEvent event, Emitter<ChatsState> emit) async {
    _wasConnected = false;
    final cached = _memoryStore.getMessages(event.conversationId);
    emit(state.copyWith(
      conversationId: event.conversationId,
      messages: cached,
      conversation: null,
      status: 'connecting',
      error: null,
      isLoading: cached.isEmpty,
      isLoadingOlder: false,
      hasMoreHistory: false,
      historyPage: 1,
      shouldScrollToBottom: cached.isNotEmpty,
    ));

    await _messagesSub?.cancel();
    await _statusSub?.cancel();

    _messagesSub = _socketService.messagesStream.listen(
      (m) => add(_IncomingMessageEvent(m)),
    );
    _statusSub = _socketService.statusStream.listen(
      (s) => add(_SocketStatusEvent(s)),
    );

    await _socketService.connect();
  }

  Future<void> _onLoadHistory(
      LoadChatHistoryEvent event, Emitter<ChatsState> emit) async {
    if (state.conversationId == null) return;
    if (_historyLoading) return;
    if (!event.force && state.messages.isNotEmpty) return;

    _historyLoading = true;
    final shouldShowLoader = state.messages.isEmpty;
    emit(state.copyWith(
      isLoading: shouldShowLoader,
      error: null,
      shouldScrollToBottom: false,
    ));
    try {
      final user = await SecureStorageService().getUser();
      final history = await _historyService.loadHistory(
        conversationId: state.conversationId!,
        currentUserId: user?.id,
        fallbackMineWhenCustomer: false,
        page: 1,
      );
      _memoryStore.mergeMessages(state.conversationId!, history.messages);
      emit(state.copyWith(
        messages: _memoryStore.getMessages(state.conversationId!),
        conversation: history.conversation ?? state.conversation,
        isLoading: false,
        hasMoreHistory: history.hasMore,
        historyPage: history.page,
        shouldScrollToBottom: true,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    } finally {
      _historyLoading = false;
    }
  }

  Future<void> _onLoadOlderHistory(
      LoadOlderChatHistoryEvent event, Emitter<ChatsState> emit) async {
    final conversationId = state.conversationId;
    if (conversationId == null) return;
    if (_olderHistoryLoading || !state.hasMoreHistory) return;

    _olderHistoryLoading = true;
    emit(state.copyWith(
      isLoadingOlder: true,
      error: null,
      shouldScrollToBottom: false,
    ));
    try {
      final user = await SecureStorageService().getUser();
      final history = await _historyService.loadHistory(
        conversationId: conversationId,
        currentUserId: user?.id,
        fallbackMineWhenCustomer: false,
        page: state.historyPage + 1,
      );
      _memoryStore.mergeMessages(conversationId, history.messages);
      emit(state.copyWith(
        messages: _memoryStore.getMessages(conversationId),
        conversation: history.conversation ?? state.conversation,
        isLoadingOlder: false,
        hasMoreHistory: history.hasMore,
        historyPage: history.page,
        shouldScrollToBottom: false,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(isLoadingOlder: false, error: e.toString()));
    } finally {
      _olderHistoryLoading = false;
    }
  }

  Future<void> _onSendMessage(
      SendChatMessageEvent event, Emitter<ChatsState> emit) async {
    final conversationId = state.conversationId;
    if (conversationId == null) return;
    if (state.isSending) return;
    final text = event.text.trim();
    if (text.isEmpty) return;
    emit(state.copyWith(isSending: true, error: null));
    if (state.conversation?.isClosed ?? false) {
      try {
        final conversation =
            await _historyService.openConversation(conversationId);
        emit(state.copyWith(conversation: conversation, error: null));
      } catch (e) {
        emit(state.copyWith(isSending: false, error: e.toString()));
        return;
      }
    }

    try {
      await _socketService.sendMessage(
        SendChatMessageRequest(
          conversationId: conversationId,
          content: text,
        ),
      );
      emit(state.copyWith(
        isSending: false,
        sendSuccessCount: state.sendSuccessCount + 1,
        error: null,
      ));
      add(const LoadChatHistoryEvent(force: true));
    } catch (e) {
      emit(state.copyWith(isSending: false, error: e.toString()));
    }
  }

  Future<void> _onClose(CloseChatEvent event, Emitter<ChatsState> emit) async {
    final conversationId = state.conversationId;
    _wasConnected = false;
    if (conversationId != null) {
      _memoryStore.clearConversation(conversationId);
    }
    emit(const ChatsState.initial());
  }

  Future<void> _onMinimize(
      MinimizeChatEvent event, Emitter<ChatsState> emit) async {}

  Future<void> _onIncomingMessage(
      _IncomingMessageEvent event, Emitter<ChatsState> emit) async {
    final conversationId = state.conversationId;
    if (conversationId == null) return;
    if (event.message.conversationId != null &&
        event.message.conversationId!.isNotEmpty &&
        event.message.conversationId != conversationId) {
      return;
    }
    final added = _memoryStore.addMessage(conversationId, event.message);
    if (!added) return;
    emit(state.copyWith(
      messages: _memoryStore.getMessages(conversationId),
      shouldScrollToBottom: true,
    ));
  }

  Future<void> _onSocketStatus(
      _SocketStatusEvent event, Emitter<ChatsState> emit) async {
    final becameConnected = event.status == 'connected' && !_wasConnected;
    _wasConnected = event.status == 'connected';
    emit(state.copyWith(status: event.status));
    if (becameConnected && state.conversationId != null) {
      add(const LoadChatHistoryEvent(force: true));
    }
  }

  @override
  Future<void> close() async {
    await _messagesSub?.cancel();
    await _statusSub?.cancel();
    return super.close();
  }
}
