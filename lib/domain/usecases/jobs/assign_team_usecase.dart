import 'package:cleaning_service_driver/data/models/requests/assign_team_model.dart';
import 'package:cleaning_service_driver/data/models/requests/cleaning_request.dart';
import 'package:cleaning_service_driver/data/repositories/jobs/jobs_repository.dart';

class AssignTeamUseCase {
  final JobsRepository _jobsRepository;

  const AssignTeamUseCase(this._jobsRepository);

  Future<CleaningRequest> call(String id, String teamId) async {
    try {
      return await _jobsRepository.assignTeam(id, AssignTeamModel(teamId));
    } catch (e) {
      throw Exception("Failed Assigning team $e");
    }
  }
}
