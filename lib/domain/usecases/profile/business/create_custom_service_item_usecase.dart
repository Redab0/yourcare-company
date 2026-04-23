import 'package:cleaning_service_driver/data/models/profile/covered_service_item_model.dart';
import 'package:cleaning_service_driver/data/repositories/profile/business/business_profile_repository.dart';

class CreateCustomServiceItemUseCase {
  final BusinessProfileRepository _profileRepository;

  CreateCustomServiceItemUseCase(this._profileRepository);

  Future<List<CoveredServiceGroup>> call({
    required String serviceType,
    required String titleEn,
    required String titleAr,
  }) {
    return _profileRepository.createCustomServiceItem(
      serviceType: serviceType,
      titleEn: titleEn,
      titleAr: titleAr,
    );
  }
}
