import 'package:cleaning_service_driver/data/models/upholstery/upholstery_pricing_models.dart';
import 'package:cleaning_service_driver/data/repositories/upholstery/upholstery_pricing_repository.dart';

class UpdateUpholsteryAvailabilityUseCase {
  final UpholsteryPricingRepository _repository;

  UpdateUpholsteryAvailabilityUseCase(this._repository);

  Future<UpholsteryAvailability> call(
    UpdateUpholsteryAvailabilityRequest request,
  ) =>
      _repository.updateAvailability(request);
}
