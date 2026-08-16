import 'package:cleaning_service_driver/data/repositories/car_wash/car_wash_repository.dart';

class DeleteCarWashPackageUseCase {
  final CarWashRepository _repository;

  DeleteCarWashPackageUseCase(this._repository);

  Future<void> call(String packageId) => _repository.deletePackage(packageId);
}
