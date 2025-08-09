import 'package:cleaning_service_driver/data/models/requests/cleaning_request.dart';
import 'package:cleaning_service_driver/data/repositories/jobs/jobs_repository.dart';

class CancelJobUseCase {
  final JobsRepository jobsRepository;

  CancelJobUseCase(this.jobsRepository);

  Future<CleaningRequest> call(String id) async {
    try {
      return await jobsRepository.cancelJob(id);
    } catch (e) {
      throw (Exception('Start Job Failed ${e.toString()}'));
    }
  }
}
