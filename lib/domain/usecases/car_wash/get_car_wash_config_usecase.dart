import 'package:cleaning_service_driver/data/models/car_wash/car_wash_models.dart';
import 'package:cleaning_service_driver/data/repositories/car_wash/car_wash_repository.dart';

class GetCarWashConfigUseCase {
  final CarWashRepository _repository;

  GetCarWashConfigUseCase(this._repository);

  Future<
      ({
        CarWashCategoryResponse categories,
        CarWashPackagesConfiguration configuration,
        List<CarWashWorkingHour> hours,
      })> call() async {
    final results = await Future.wait([
      _repository.getCategories(),
      _repository.getPackagesConfiguration(),
    ]);
    final categories = results[0] as CarWashCategoryResponse;
    final configuration = results[1] as CarWashPackagesConfiguration;
    return (
      categories: categories,
      configuration: configuration,
      hours: const <CarWashWorkingHour>[],
    );
  }
}
