import 'package:cleaning_service_driver/data/models/profile/area_model.dart';
import 'package:cleaning_service_driver/data/repositories/profile/profile_repository.dart';

class GetAreasUseCase {
  final ProfileRepository profileRepository;

  GetAreasUseCase(this.profileRepository);

  Future<List<AreaModel>> execute() async {
    try {
      return await profileRepository.getAreas();
    } catch (e) {
      throw (Exception('Getting Areas Failed ${e.toString()}'));
    }
  }
}
