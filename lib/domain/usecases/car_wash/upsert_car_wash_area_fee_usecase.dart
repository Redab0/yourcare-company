import 'package:cleaning_service_driver/data/models/car_wash/car_wash_models.dart';
import 'package:cleaning_service_driver/data/repositories/car_wash/car_wash_repository.dart';

class UpsertCarWashAreaFeeUseCase {
  final CarWashRepository _repository;

  UpsertCarWashAreaFeeUseCase(this._repository);

  Future<void> call(CarWashAreaFeeRequest request) =>
      _repository.upsertAreaFee(request);
}
