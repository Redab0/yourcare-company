import 'package:cleaning_service_driver/data/models/requests/add_extra_fees_request.dart';
import 'package:cleaning_service_driver/data/models/requests/cleaning_request.dart';
import 'package:cleaning_service_driver/data/repositories/jobs/jobs_repository.dart';

class AddExtraFeesUseCase {
  final JobsRepository _jobsRepository;

  const AddExtraFeesUseCase(this._jobsRepository);

  Future<CleaningRequest?> call(
    String id,
    AddExtraFeesRequest request,
  ) {
    return _jobsRepository.addExtraFees(id, request);
  }
}
