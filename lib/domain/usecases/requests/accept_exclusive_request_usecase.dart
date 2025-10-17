import 'package:cleaning_service_driver/data/models/requests/cleaning_request.dart';
import 'package:cleaning_service_driver/data/repositories/requests/requests_repository.dart';

class AcceptExclusiveRequestUseCase {
  final RequestsRepository requestsRepository;

  AcceptExclusiveRequestUseCase(this.requestsRepository);

  Future<CleaningRequest> call(String id) async {
    try {
      return await requestsRepository.acceptReorderRequest(id);
    } catch (e) {
      throw (Exception('Accepting Request Failed ${e.toString()}'));
    }
  }
}
