import 'package:cleaning_service_driver/data/models/chats/conversation_model.dart';
import 'package:cleaning_service_driver/data/repos/chats/chats_repository.dart';

class CloseConversationUseCase {
  final ChatsRepository _repository;

  CloseConversationUseCase(this._repository);

  Future<ConversationModel> call(String conversationId) {
    return _repository.closeConversation(conversationId);
  }
}
