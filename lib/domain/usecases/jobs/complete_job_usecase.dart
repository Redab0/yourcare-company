import 'package:cleaning_service_driver/data/models/requests/cleaning_request.dart';
import 'package:cleaning_service_driver/data/repositories/jobs/jobs_repository.dart';

class CompleteJobUseCase {
  final JobsRepository jobsRepository;

  CompleteJobUseCase(this.jobsRepository);

  Future<CleaningRequest> call(String id) async {
    try {
      return await jobsRepository.completeJob(id);
    } catch (e) {
      throw (Exception('Start Job Failed ${e.toString()}'));
    }
  }
}
