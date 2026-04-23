import 'package:cleaning_service_driver/data/models/profile/covered_service_item_model.dart';
import 'package:cleaning_service_driver/data/repositories/profile/business/business_profile_repository.dart';

class GetCoveredServiceItemsUseCase {
  final BusinessProfileRepository _profileRepository;

  GetCoveredServiceItemsUseCase(this._profileRepository);

  Future<List<CoveredServiceGroup>> call() {
    return _profileRepository.getCoveredServiceItems();
  }
}
