import 'package:cleaning_service_driver/data/models/car_wash/car_wash_models.dart';
import 'package:cleaning_service_driver/data/repositories/car_wash/car_wash_repository.dart';

class UpdateCarWashWorkingHoursUseCase {
  final CarWashRepository _repository;

  UpdateCarWashWorkingHoursUseCase(this._repository);

  Future<List<CarWashWorkingHour>> call(
    CarWashWorkingHoursRequest request,
  ) async {
    final profile = await _repository.updateWorkingHours(request);
    return profile?.carWashWorkingHours ?? request.hours;
  }
}
