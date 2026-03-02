import 'package:cleaning_service_driver/data/models/schedule/cleaner_availability.dart';
import 'package:cleaning_service_driver/data/repositories/schedule/schedule_repository.dart';

class CreateCleanerAvailabilityUseCase {
  final ScheduleRepository _scheduleRepository;

  CreateCleanerAvailabilityUseCase(this._scheduleRepository);

  Future<CleanerAvailabilitySlot> call(
      CleanerAvailabilityRequest request) async {
    try {
      return await _scheduleRepository.createCleanerAvailability(request);
    } catch (e) {
      throw Exception('Creating availability failed ${e.toString()}');
    }
  }
}
