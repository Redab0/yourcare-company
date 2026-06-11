import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const Object _unset = Object();

class ChatLauncherState extends Equatable {
  final bool hasActiveChat;
  final String? conversationId;
  final String? openConversationId;
  final String? requestId;
  final String? businessId;
  final bool hasLastMessage;
  final bool isChatWindowOpen;
  final String? dismissedConversationId;
  final DateTime? dismissedAt;
  final Set<String> unreadConversationIds;
  final Map<String, ChatConversationPreview> conversationPreviews;

  const ChatLauncherState({
    required this.hasActiveChat,
    required this.conversationId,
    required this.openConversationId,
    required this.requestId,
    required this.businessId,
    required this.hasLastMessage,
    required this.isChatWindowOpen,
    required this.dismissedConversationId,
    required this.dismissedAt,
    required this.unreadConversationIds,
    required this.conversationPreviews,
  });

  const ChatLauncherState.initial()
      : hasActiveChat = false,
        conversationId = null,
        openConversationId = null,
        requestId = null,
        businessId = null,
        hasLastMessage = false,
        isChatWindowOpen = false,
        dismissedConversationId = null,
        dismissedAt = null,
        unreadConversationIds = const <String>{},
        conversationPreviews = const <String, ChatConversationPreview>{};

  ChatLauncherState copyWith({
    bool? hasActiveChat,
    Object? conversationId = _unset,
    Object? openConversationId = _unset,
    Object? requestId = _unset,
    Object? businessId = _unset,
    bool? hasLastMessage,
    bool? isChatWindowOpen,
    Object? dismissedConversationId = _unset,
    Object? dismissedAt = _unset,
    Set<String>? unreadConversationIds,
    Map<String, ChatConversationPreview>? conversationPreviews,
  }) {
    return ChatLauncherState(
      hasActiveChat: hasActiveChat ?? this.hasActiveChat,
      conversationId: identical(conversationId, _unset)
          ? this.conversationId
          : conversationId as String?,
      openConversationId: identical(openConversationId, _unset)
          ? this.openConversationId
          : openConversationId as String?,
      requestId:
          identical(requestId, _unset) ? this.requestId : requestId as String?,
      businessId: identical(businessId, _unset)
          ? this.businessId
          : businessId as String?,
      hasLastMessage: hasLastMessage ?? this.hasLastMessage,
      isChatWindowOpen: isChatWindowOpen ?? this.isChatWindowOpen,
      dismissedConversationId: identical(dismissedConversationId, _unset)
          ? this.dismissedConversationId
          : dismissedConversationId as String?,
      dismissedAt: identical(dismissedAt, _unset)
          ? this.dismissedAt
          : dismissedAt as DateTime?,
      unreadConversationIds:
          unreadConversationIds ?? this.unreadConversationIds,
      conversationPreviews: conversationPreviews ?? this.conversationPreviews,
    );
  }

  @override
  List<Object?> get props => [
        hasActiveChat,
        conversationId,
        openConversationId,
        requestId,
        businessId,
        hasLastMessage,
        isChatWindowOpen,
        dismissedConversationId,
        dismissedAt,
        unreadConversationIds,
        conversationPreviews,
      ];
}

class ChatConversationPreview extends Equatable {
  final String text;
  final DateTime sentAt;

  const ChatConversationPreview({
    required this.text,
    required this.sentAt,
  });

  @override
  List<Object?> get props => [text, sentAt];
}

class ChatLauncherCubit extends Cubit<ChatLauncherState> {
  ChatLauncherCubit() : super(const ChatLauncherState.initial());

  void setActiveChat({
    required String conversationId,
    String? requestId,
    String? businessId,
    required bool hasLastMessage,
  }) {
    emit(
      state.copyWith(
        hasActiveChat: true,
        conversationId: conversationId,
        requestId: requestId,
        businessId: businessId,
        hasLastMessage: hasLastMessage,
        isChatWindowOpen: state.isChatWindowOpen,
        dismissedConversationId: null,
        dismissedAt: null,
      ),
    );
  }

  void setWindowOpen(bool value, {String? conversationId}) {
    emit(
      state.copyWith(
        isChatWindowOpen: value,
        openConversationId: value ? conversationId : null,
      ),
    );
  }

  void markConversationUnread(String conversationId) {
    final id = conversationId.trim();
    if (id.isEmpty || state.unreadConversationIds.contains(id)) return;
    emit(
      state.copyWith(
        unreadConversationIds: Set<String>.unmodifiable({
          ...state.unreadConversationIds,
          id,
        }),
      ),
    );
  }

  void updateConversationPreview({
    required String conversationId,
    required String text,
    required DateTime sentAt,
  }) {
    final id = conversationId.trim();
    final previewText = text.trim();
    if (id.isEmpty || previewText.isEmpty) return;

    final current = state.conversationPreviews[id];
    if (current != null && sentAt.isBefore(current.sentAt)) return;

    emit(
      state.copyWith(
        conversationPreviews:
            Map<String, ChatConversationPreview>.unmodifiable({
          ...state.conversationPreviews,
          id: ChatConversationPreview(text: previewText, sentAt: sentAt),
        }),
      ),
    );
  }

  void clearConversationUnread(String conversationId) {
    final id = conversationId.trim();
    if (id.isEmpty || !state.unreadConversationIds.contains(id)) return;
    final updated = Set<String>.from(state.unreadConversationIds)..remove(id);
    emit(
      state.copyWith(
        unreadConversationIds: Set<String>.unmodifiable(updated),
      ),
    );
  }

  void clear() {
    emit(const ChatLauncherState.initial());
  }

  void clearActiveChat() {
    emit(
      state.copyWith(
        hasActiveChat: false,
        conversationId: null,
        requestId: null,
        businessId: null,
        hasLastMessage: false,
      ),
    );
  }

  void dismissFab() {
    emit(
      state.copyWith(
        hasActiveChat: false,
        dismissedConversationId: state.conversationId,
        dismissedAt: DateTime.now(),
      ),
    );
  }
}
