import 'package:cleaning_service_driver/data/models/requests/cleaning_request.dart';
import 'package:cleaning_service_driver/data/repositories/jobs/jobs_repository.dart';

class StartJobUseCase {
  final JobsRepository jobsRepository;

  StartJobUseCase(this.jobsRepository);

  Future<CleaningRequest> call(String id) async {
    try {
      return await jobsRepository.startJob(id);
    } catch (e) {
      throw (Exception('Start Job Failed ${e.toString()}'));
    }
  }
}
