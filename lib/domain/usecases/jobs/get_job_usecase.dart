import 'package:cleaning_service_driver/data/models/requests/cleaning_request.dart';
import 'package:cleaning_service_driver/data/repositories/jobs/jobs_repository.dart';

class GetJobUseCase {
  final JobsRepository repository;

  GetJobUseCase(this.repository);

  Future<CleaningRequest> call(String id) => repository.getJob(id);
}
