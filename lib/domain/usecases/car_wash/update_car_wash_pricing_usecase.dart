import 'package:cleaning_service_driver/data/models/car_wash/car_wash_models.dart';
import 'package:cleaning_service_driver/data/repositories/car_wash/car_wash_repository.dart';

class UpdateCarWashPricingUseCase {
  final CarWashRepository _repository;

  UpdateCarWashPricingUseCase(this._repository);

  Future<void> call(CarWashPricingAssignmentRequest request) =>
      _repository.updatePricing(request);
}
