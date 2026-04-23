import 'package:cleaning_service_driver/data/models/profile/covered_service_item_model.dart';
import 'package:cleaning_service_driver/data/repositories/profile/business/business_profile_repository.dart';

class DeleteCustomServiceItemUseCase {
  final BusinessProfileRepository _profileRepository;

  DeleteCustomServiceItemUseCase(this._profileRepository);

  Future<List<CoveredServiceGroup>> call(String serviceItemId) {
    return _profileRepository.deleteCustomServiceItem(serviceItemId);
  }
}
