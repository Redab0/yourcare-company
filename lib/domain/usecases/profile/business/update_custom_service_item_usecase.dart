import 'package:cleaning_service_driver/data/models/profile/covered_service_item_model.dart';
import 'package:cleaning_service_driver/data/repositories/profile/business/business_profile_repository.dart';

class UpdateCustomServiceItemUseCase {
  final BusinessProfileRepository _profileRepository;

  UpdateCustomServiceItemUseCase(this._profileRepository);

  Future<List<CoveredServiceGroup>> call({
    required String serviceItemId,
    required String titleEn,
    required String titleAr,
  }) {
    return _profileRepository.updateCustomServiceItem(
      serviceItemId: serviceItemId,
      titleEn: titleEn,
      titleAr: titleAr,
    );
  }
}
