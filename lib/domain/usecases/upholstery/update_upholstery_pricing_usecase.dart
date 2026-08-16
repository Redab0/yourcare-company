import 'package:cleaning_service_driver/data/models/upholstery/upholstery_pricing_models.dart';
import 'package:cleaning_service_driver/data/repositories/upholstery/upholstery_pricing_repository.dart';

class UpdateUpholsteryPricingUseCase {
  final UpholsteryPricingRepository _repository;

  UpdateUpholsteryPricingUseCase(this._repository);

  Future<List<UpholsteryPricingGroup>> call(
    UpholsteryPricingRequest request,
  ) async {
    final profile = await _repository.updatePricing(request);
    return profile?.upholsteryPricing ?? request.pricing;
  }
}
