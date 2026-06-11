part of 'chats_bloc.dart';

const Object _unset = Object();

class ChatsState extends Equatable {
  final String? conversationId;
  final List<ChatMessageModel> messages;
  final ConversationModel? conversation;
  final bool isLoading;
  final bool isLoadingOlder;
  final bool isSending;
  final bool hasMoreHistory;
  final int historyPage;
  final int sendSuccessCount;
  final bool shouldScrollToBottom;
  final String status;
  final String? error;

  const ChatsState({
    required this.conversationId,
    required this.messages,
    required this.conversation,
    required this.isLoading,
    required this.isLoadingOlder,
    required this.isSending,
    required this.hasMoreHistory,
    required this.historyPage,
    required this.sendSuccessCount,
    required this.shouldScrollToBottom,
    required this.status,
    required this.error,
  });

  const ChatsState.initial()
      : conversationId = null,
        messages = const [],
        conversation = null,
        isLoading = false,
        isLoadingOlder = false,
        isSending = false,
        hasMoreHistory = false,
        historyPage = 1,
        sendSuccessCount = 0,
        shouldScrollToBottom = false,
        status = 'disconnected',
        error = null;

  ChatsState copyWith({
    String? conversationId,
    List<ChatMessageModel>? messages,
    Object? conversation = _unset,
    bool? isLoading,
    bool? isLoadingOlder,
    bool? isSending,
    bool? hasMoreHistory,
    int? historyPage,
    int? sendSuccessCount,
    bool? shouldScrollToBottom,
    String? status,
    Object? error = _unset,
  }) {
    return ChatsState(
      conversationId: conversationId ?? this.conversationId,
      messages: messages ?? this.messages,
      conversation: identical(conversation, _unset)
          ? this.conversation
          : conversation as ConversationModel?,
      isLoading: isLoading ?? this.isLoading,
      isLoadingOlder: isLoadingOlder ?? this.isLoadingOlder,
      isSending: isSending ?? this.isSending,
      hasMoreHistory: hasMoreHistory ?? this.hasMoreHistory,
      historyPage: historyPage ?? this.historyPage,
      sendSuccessCount: sendSuccessCount ?? this.sendSuccessCount,
      shouldScrollToBottom: shouldScrollToBottom ?? this.shouldScrollToBottom,
      status: status ?? this.status,
      error: identical(error, _unset) ? this.error : error as String?,
    );
  }

  @override
  List<Object?> get props => [
        conversationId,
        messages,
        conversation,
        isLoading,
        isLoadingOlder,
        isSending,
        hasMoreHistory,
        historyPage,
        sendSuccessCount,
        shouldScrollToBottom,
        status,
        error,
      ];
}
