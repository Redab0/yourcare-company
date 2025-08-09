import 'package:cleaning_service_driver/data/models/staff/team_model.dart';
import 'package:cleaning_service_driver/data/repositories/staff/staff_repository.dart';

class GetTeamsUseCase {
  final StaffRepository _staffRepository;

  GetTeamsUseCase(this._staffRepository);

  Future<List<TeamModel>> call() async {
    try {
      return _staffRepository.getTeams();
    } catch (e) {
      throw Exception("Getting teams failed $e");
    }
  }
}
