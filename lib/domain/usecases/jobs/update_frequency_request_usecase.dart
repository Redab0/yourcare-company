import 'package:cleaning_service_driver/data/models/requests/cleaning_request.dart';
import 'package:cleaning_service_driver/data/models/requests/update_request_frequency_request.dart';
import 'package:cleaning_service_driver/data/repositories/jobs/jobs_repository.dart';

class UpdateFrequencyRequestUseCase {
  final JobsRepository _jobsRepository;

  const UpdateFrequencyRequestUseCase(this._jobsRepository);

  Future<CleaningRequest> call(
      String id, UpdateRequestFrequencyRequest body) async {
    try {
      return await _jobsRepository.updateFrequencyStatus(id, body);
    } catch (e) {
      throw Exception("Updating Request Failed $e");
    }
  }
}
