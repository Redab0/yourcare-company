import 'package:cleaning_service_driver/data/models/schedule/cleaner_availability.dart';
import 'package:cleaning_service_driver/data/repositories/schedule/schedule_repository.dart';

class GetCleanerAvailabilityUseCase {
  final ScheduleRepository _scheduleRepository;

  GetCleanerAvailabilityUseCase(this._scheduleRepository);

  Future<List<CleanerAvailabilitySlot>> call() async {
    try {
      return await _scheduleRepository.getCleanerAvailability();
    } catch (e) {
      throw Exception('Getting availability failed ${e.toString()}');
    }
  }
}
