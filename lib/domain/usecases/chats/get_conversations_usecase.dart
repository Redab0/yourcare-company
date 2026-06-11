import 'package:cleaning_service_driver/data/models/chats/conversation_model.dart';
import 'package:cleaning_service_driver/data/repos/chats/chats_repository.dart';

class GetConversationsUseCase {
  final ChatsRepository _repository;

  GetConversationsUseCase(this._repository);

  Future<List<ConversationModel>> call({int page = 1, int limit = 50}) {
    return _repository.getConversations(page: page, limit: limit);
  }
}
