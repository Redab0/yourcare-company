import 'package:cleaning_service_driver/data/models/requests/cleaning_request.dart';
import 'package:cleaning_service_driver/data/models/requests/complete_job_media_request.dart';
import 'package:cleaning_service_driver/data/repositories/jobs/jobs_repository.dart';

class CompleteJobUseCase {
  final JobsRepository jobsRepository;

  CompleteJobUseCase(this.jobsRepository);

  Future<CleaningRequest> call(String id,
      {CompleteJobRequest? completeJobRequest}) async {
    try {
      return await jobsRepository.completeJob(id,
          completeJobRequest: completeJobRequest);
    } catch (e) {
      print("ERROR ${e.toString()}");
      throw (Exception('Start Job Failed ${e.toString()}'));
    }
  }
}
