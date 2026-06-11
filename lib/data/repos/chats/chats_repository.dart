import 'package:cleaning_service_driver/data/models/chats/chat_message_model.dart';
import 'package:cleaning_service_driver/data/models/chats/chat_history_result.dart';
import 'package:cleaning_service_driver/data/models/chats/conversation_model.dart';
import 'package:cleaning_service_driver/data/models/chats/create_conversation_request.dart';
import 'package:cleaning_service_driver/data/services/chats/chat_service.dart';

class ChatsRepository {
  final ChatService _chatService;

  ChatsRepository(this._chatService);

  Future<ConversationModel> createOrGetConversation({
    String? requestId,
  }) async {
    final response = await _chatService.createOrGetConversation(
      CreateConversationRequest(
        requestId: requestId,
      ),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }
    throw Exception(
        response.message.isEmpty ? 'Failed to create chat' : response.message);
  }

  Future<ChatHistoryResult> getMessages({
    required String conversationId,
    required String? currentUserId,
    required bool fallbackMineWhenCustomer,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _chatService.getConversationMessages(
      conversationId,
      page: page,
      limit: limit,
    );
    if (!response.success || response.data == null) {
      throw Exception(response.message.isEmpty
          ? 'Failed to load chat history'
          : response.message);
    }

    final raw = response.data!;
    return ChatHistoryResult(
      conversation: raw.conversation == null
          ? null
          : ConversationModel.fromJson(raw.conversation!),
      messages: raw.messages
          .map(
            (e) => ChatMessageModel.fromJson(
              e,
              currentUserId: currentUserId,
              fallbackMineWhenCustomer: fallbackMineWhenCustomer,
            ),
          )
          .toList(),
      page: raw.page,
      limit: raw.limit,
      total: raw.total,
    );
  }

  Future<ConversationModel?> getLatestConversationWithMessage() async {
    final conversations = await getConversations(page: 1, limit: 50);
    if (conversations.isEmpty) return null;
    final withMessage = conversations
        .where((c) => c.id.isNotEmpty && c.hasLastMessage && !c.isClosed)
        .toList(growable: false);
    if (withMessage.isEmpty) return null;
    withMessage.sort((a, b) {
      final aTime = a.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
    return withMessage.first;
  }

  Future<List<ConversationModel>> getConversations({
    int page = 1,
    int limit = 50,
  }) async {
    final response =
        await _chatService.getConversations(page: page, limit: limit);
    if (!response.success || response.data == null || response.data!.isEmpty) {
      return const [];
    }
    final items = response.data!.where((c) => c.id.isNotEmpty).toList();
    items.sort((a, b) {
      final aTime = a.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
    return items;
  }

  Future<ConversationModel> closeConversation(String conversationId) async {
    final response = await _chatService.closeConversation(conversationId);
    if (response.success && response.data != null) return response.data!;
    throw Exception(
        response.message.isEmpty ? 'Failed to close chat' : response.message);
  }

  Future<ConversationModel> openConversation(String conversationId) async {
    final response = await _chatService.openConversation(conversationId);
    if (response.success && response.data != null) return response.data!;
    throw Exception(
        response.message.isEmpty ? 'Failed to open chat' : response.message);
  }
}
