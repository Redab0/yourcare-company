import 'package:cleaning_service_driver/data/models/profile/business_profile_model.dart';
import 'package:cleaning_service_driver/data/repositories/profile/business/business_profile_repository.dart';

class GetBusinessProfileUseCase {
  final BusinessProfileRepository _profileRepository;

  GetBusinessProfileUseCase(this._profileRepository);

  Future<BusinessProfileModel> call() async {
    try {
      return await _profileRepository.getBusinessProfile();
    } catch (e) {
      throw (Exception('Getting Profile Failed ${e.toString()}'));
    }
  }
}
