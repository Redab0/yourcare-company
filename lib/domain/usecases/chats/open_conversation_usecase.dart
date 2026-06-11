import 'package:cleaning_service_driver/data/models/chats/conversation_model.dart';
import 'package:cleaning_service_driver/data/repos/chats/chats_repository.dart';

class OpenConversationUseCase {
  final ChatsRepository _repository;

  OpenConversationUseCase(this._repository);

  Future<ConversationModel> call(String conversationId) {
    return _repository.openConversation(conversationId);
  }
}
