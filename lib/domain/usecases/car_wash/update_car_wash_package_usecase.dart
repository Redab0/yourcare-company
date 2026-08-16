import 'package:cleaning_service_driver/data/models/car_wash/car_wash_models.dart';
import 'package:cleaning_service_driver/data/repositories/car_wash/car_wash_repository.dart';

class UpdateCarWashPackageUseCase {
  final CarWashRepository _repository;

  UpdateCarWashPackageUseCase(this._repository);

  Future<void> call(
    String packageId,
    CarWashPackageMutationRequest request,
  ) =>
      _repository.updatePackage(packageId, request);
}
