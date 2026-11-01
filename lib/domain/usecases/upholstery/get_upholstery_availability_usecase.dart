import 'package:cleaning_service_driver/data/models/upholstery/upholstery_pricing_models.dart';
import 'package:cleaning_service_driver/data/repositories/upholstery/upholstery_pricing_repository.dart';

class GetUpholsteryAvailabilityUseCase {
  final UpholsteryPricingRepository _repository;

  GetUpholsteryAvailabilityUseCase(this._repository);

  Future<UpholsteryAvailability> call() => _repository.getAvailability();
}
