import 'package:cleaning_service_driver/core/models/page_wrapper.dart';
import 'package:cleaning_service_driver/data/models/requests/cleaning_request.dart';
import 'package:cleaning_service_driver/data/repositories/requests/requests_repository.dart';

class GetAvailableRequestsUseCase {
  final RequestsRepository requestsRepository;

  GetAvailableRequestsUseCase(this.requestsRepository);

  Future<PaginatedData<CleaningRequest>> call(int page, int limit) async {
    try {
      return await requestsRepository.getRequests(page, limit);
    } catch (e) {
      throw (Exception('Getting Requests Failed ${e.toString()}'));
    }
  }
}
