import 'package:cleaning_service_driver/data/repositories/car_wash/car_wash_repository.dart';

class DeleteCarWashAreaFeeUseCase {
  final CarWashRepository _repository;

  DeleteCarWashAreaFeeUseCase(this._repository);

  Future<void> call(String areaId) => _repository.deleteAreaFee(areaId);
}
