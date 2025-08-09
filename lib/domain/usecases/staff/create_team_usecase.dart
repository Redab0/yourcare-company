import 'package:cleaning_service_driver/data/models/staff/create_team_model.dart';
import 'package:cleaning_service_driver/data/models/staff/create_team_response.dart';
import 'package:cleaning_service_driver/data/repositories/staff/staff_repository.dart';

class CreateTeamUseCase {
  final StaffRepository _staffRepository;

  CreateTeamUseCase(this._staffRepository);

  Future<CreateTeamResponse> call(CreateTeamModel model) async {
    try {
      return _staffRepository.createTeam(model);
    } catch (e) {
      throw Exception("Creating team failed $e");
    }
  }
}
