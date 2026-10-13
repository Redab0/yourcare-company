import 'package:cleaning_service_driver/data/models/requests/cleaning_request.dart';
import 'package:cleaning_service_driver/data/models/requests/complete_job_media_request.dart';
import 'package:cleaning_service_driver/data/repositories/jobs/jobs_repository.dart';

class CompleteJobUseCase {
  final JobsRepository jobsRepository;

  CompleteJobUseCase(this.jobsRepository);

  Future<CleaningRequest> call(String id,
          {CompleteJobRequest? completeJobRequest}) =>
      jobsRepository.completeJob(id, completeJobRequest: completeJobRequest);
}
