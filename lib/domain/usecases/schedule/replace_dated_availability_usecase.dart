import 'package:cleaning_service_driver/data/models/schedule/cleaner_availability.dart';
import 'package:cleaning_service_driver/data/repositories/schedule/schedule_repository.dart';

class ReplaceDatedAvailabilityUseCase {
  final ScheduleRepository _repository;

  ReplaceDatedAvailabilityUseCase(this._repository);

  Future<List<CleanerAvailabilitySlot>> call(
    DatedAvailabilityRequest request,
  ) =>
      _repository.replaceDatedAvailability(request);
}
