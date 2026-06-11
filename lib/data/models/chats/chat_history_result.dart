import 'package:cleaning_service_driver/data/models/chats/chat_message_model.dart';
import 'package:cleaning_service_driver/data/models/chats/conversation_model.dart';

class ChatHistoryResult {
  final ConversationModel? conversation;
  final List<ChatMessageModel> messages;
  final int page;
  final int limit;
  final int? total;

  const ChatHistoryResult({
    required this.conversation,
    required this.messages,
    required this.page,
    required this.limit,
    required this.total,
  });

  bool get hasMore {
    final totalCount = total;
    if (totalCount == null) return messages.length >= limit;
    return page * limit < totalCount;
  }
}
