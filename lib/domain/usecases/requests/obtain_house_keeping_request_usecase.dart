import 'package:cleaning_service_driver/data/models/requests/accept_house_keeping_model.dart';
import 'package:cleaning_service_driver/data/models/requests/cleaning_request.dart';
import 'package:cleaning_service_driver/data/repositories/requests/requests_repository.dart';

class ObtainHouseKeepingRequestUseCase {
  final RequestsRepository requestsRepository;

  ObtainHouseKeepingRequestUseCase(this.requestsRepository);

  Future<CleaningRequest> call(
      {required String id, AcceptHouseKeepingModel? model}) async {
    try {
      return await requestsRepository.obtainHouseKeepingRequest(
          id: id, model: model);
    } catch (e) {
      throw (Exception('Getting Requests Failed ${e.toString()}'));
    }
  }
}
