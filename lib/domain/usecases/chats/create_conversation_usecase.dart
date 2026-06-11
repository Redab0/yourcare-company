import 'package:cleaning_service_driver/data/models/chats/conversation_model.dart';
import 'package:cleaning_service_driver/data/repos/chats/chats_repository.dart';

class CreateConversationUseCase {
  final ChatsRepository _repository;

  CreateConversationUseCase(this._repository);

  Future<ConversationModel> call({
    String? requestId,
  }) {
    return _repository.createOrGetConversation(
      requestId: requestId,
    );
  }
}
