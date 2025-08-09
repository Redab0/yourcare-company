import 'package:cleaning_service_driver/data/models/profile/business_profile_model.dart';
import 'package:cleaning_service_driver/data/models/profile/update_business_profile_model.dart';
import 'package:cleaning_service_driver/data/repositories/profile/profile_repository.dart';

class UpdateBusinessProfileUseCase {
  final ProfileRepository _profileRepository;

  UpdateBusinessProfileUseCase(this._profileRepository);

  Future<BusinessProfileModel> call(UpdateBusinessProfileModel model) async {
    try {
      return await _profileRepository.updateBusinessProfile(model);
    } catch (e) {
      throw (Exception('Updating Profile Failed ${e.toString()}'));
    }
  }
}
