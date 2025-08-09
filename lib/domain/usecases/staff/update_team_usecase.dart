import 'package:cleaning_service_driver/data/models/staff/create_team_model.dart';
import 'package:cleaning_service_driver/data/models/staff/create_team_response.dart';
import 'package:cleaning_service_driver/data/repositories/staff/staff_repository.dart';

class UpdateTeamUseCase {
  final StaffRepository _staffRepository;

  UpdateTeamUseCase(this._staffRepository);

  Future<CreateTeamResponse> call(CreateTeamModel model, String id) async {
    try {
      return _staffRepository.updateTeam(model, id);
    } catch (e) {
      throw Exception("Updating team failed $e");
    }
  }
}
