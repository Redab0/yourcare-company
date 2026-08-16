import 'package:cleaning_service_driver/data/models/car_wash/car_wash_models.dart';
import 'package:cleaning_service_driver/data/repositories/car_wash/car_wash_repository.dart';

class CreateCarWashPackageUseCase {
  final CarWashRepository _repository;

  CreateCarWashPackageUseCase(this._repository);

  Future<void> call(CarWashPackageMutationRequest request) =>
      _repository.createPackage(request);
}
