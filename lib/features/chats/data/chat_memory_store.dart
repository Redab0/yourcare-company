import 'package:cleaning_service_driver/data/models/chats/chat_message_model.dart';

class ChatMemoryStore {
  final Map<String, List<ChatMessageModel>> _messagesByConversation = {};

  List<ChatMessageModel> getMessages(String conversationId) =>
      List.unmodifiable(_messagesByConversation[conversationId] ??
          const <ChatMessageModel>[]);

  // History and sockets may renew a signed URL under the same message ID.
  bool addMessage(String conversationId, ChatMessageModel message) {
    final id = message.id.trim();
    if (id.isEmpty ||
        (message.conversationId != null &&
            message.conversationId!.isNotEmpty &&
            message.conversationId != conversationId)) {
      return false;
    }
    final list = _messagesByConversation.putIfAbsent(
        conversationId, () => <ChatMessageModel>[]);
    final index = list.indexWhere((item) => item.id.trim() == id);
    if (index >= 0) {
      final previous = list[index];
      list[index] = message;
      if (previous.text == message.text &&
          previous.senderId == message.senderId &&
          previous.isMine == message.isMine &&
          previous.sentAt == message.sentAt &&
          previous.conversationId == message.conversationId) {
        return false;
      }
    } else {
      list.add(message);
    }
    list.sort((a, b) => (a.sentAt.millisecondsSinceEpoch)
        .compareTo(b.sentAt.millisecondsSinceEpoch));
    return true;
  }

  void mergeMessages(String conversationId, List<ChatMessageModel> messages) {
    for (final message in messages) {
      addMessage(conversationId, message);
    }
  }

  void clearConversation(String conversationId) {
    _messagesByConversation.remove(conversationId);
  }

  void clearAll() {
    _messagesByConversation.clear();
  }
}
