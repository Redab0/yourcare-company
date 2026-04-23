import 'package:cleaning_service_driver/data/models/profile/covered_service_item_model.dart';
import 'package:cleaning_service_driver/data/repositories/profile/business/business_profile_repository.dart';

class UpdateCoveredServiceItemsUseCase {
  final BusinessProfileRepository _profileRepository;

  UpdateCoveredServiceItemsUseCase(this._profileRepository);

  Future<List<CoveredServiceGroup>> call(List<String> serviceItemIds) {
    return _profileRepository.updateCoveredServiceItems(serviceItemIds);
  }
}
