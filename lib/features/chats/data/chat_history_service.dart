import 'package:cleaning_service_driver/data/models/chats/chat_history_result.dart';
import 'package:cleaning_service_driver/data/models/chats/conversation_model.dart';
import 'package:cleaning_service_driver/data/repos/chats/chats_repository.dart';

class ChatHistoryService {
  final ChatsRepository _repository;

  ChatHistoryService(this._repository);

  Future<ChatHistoryResult> loadHistory({
    required String conversationId,
    required String? currentUserId,
    required bool fallbackMineWhenCustomer,
    int page = 1,
    int limit = 20,
  }) {
    return _repository.getMessages(
      conversationId: conversationId,
      currentUserId: currentUserId,
      fallbackMineWhenCustomer: fallbackMineWhenCustomer,
      page: page,
      limit: limit,
    );
  }

  Future<ConversationModel> openConversation(String conversationId) {
    return _repository.openConversation(conversationId);
  }
}
