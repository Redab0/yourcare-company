import 'package:cleaning_service_driver/data/models/chats/conversation_model.dart';
import 'package:cleaning_service_driver/data/repos/chats/chats_repository.dart';

class GetLatestConversationUseCase {
  final ChatsRepository _repository;

  GetLatestConversationUseCase(this._repository);

  Future<ConversationModel?> call() {
    return _repository.getLatestConversationWithMessage();
  }
}
