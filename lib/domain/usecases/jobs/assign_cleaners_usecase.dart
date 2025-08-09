import 'package:cleaning_service_driver/data/models/requests/accept_house_keeping_model.dart';
import 'package:cleaning_service_driver/data/models/requests/cleaning_request.dart';
import 'package:cleaning_service_driver/data/repositories/jobs/jobs_repository.dart';

class AssignCleanersUseCase {
  final JobsRepository _jobsRepository;

  const AssignCleanersUseCase(this._jobsRepository);

  Future<CleaningRequest> call(String id, AcceptHouseKeepingModel model) async {
    try {
      return await _jobsRepository.assignCleaners(id, model);
    } catch (e) {
      throw Exception("Failed Assigning cleaners $e");
    }
  }
}
