import 'package:cleaning_service_driver/data/models/chats/chat_message_model.dart';

class ChatMemoryStore {
  final Map<String, List<ChatMessageModel>> _messagesByConversation = {};
  final Map<String, Set<String>> _seenIdsByConversation = {};

  List<ChatMessageModel> getMessages(String conversationId) =>
      List.unmodifiable(_messagesByConversation[conversationId] ?? const []);

  bool addMessage(String conversationId, ChatMessageModel message) {
    final id = message.id.trim();
    if (id.isEmpty) return false;
    final seen = _seenIdsByConversation.putIfAbsent(conversationId, () => {});
    if (seen.contains(id)) return false;
    seen.add(id);
    final list = _messagesByConversation.putIfAbsent(
        conversationId, () => <ChatMessageModel>[]);
    list.add(message);
    list.sort((a, b) => a.sentAt.compareTo(b.sentAt));
    return true;
  }

  void mergeMessages(String conversationId, List<ChatMessageModel> messages) {
    final seen = _seenIdsByConversation.putIfAbsent(conversationId, () => {});
    final list = _messagesByConversation.putIfAbsent(
        conversationId, () => <ChatMessageModel>[]);
    for (final m in messages) {
      final id = m.id.trim();
      if (id.isEmpty || seen.contains(id)) continue;
      seen.add(id);
      list.add(m);
    }
    list.sort((a, b) => a.sentAt.compareTo(b.sentAt));
  }

  void clearConversation(String conversationId) {
    _messagesByConversation.remove(conversationId);
    _seenIdsByConversation.remove(conversationId);
  }

  void clearAll() {
    _messagesByConversation.clear();
    _seenIdsByConversation.clear();
  }
}
