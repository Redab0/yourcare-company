import 'package:cleaning_service_driver/data/models/schedule/cleaner_availability.dart';
import 'package:cleaning_service_driver/data/repositories/schedule/schedule_repository.dart';

class UpdateCleanerAvailabilityUseCase {
  final ScheduleRepository _scheduleRepository;

  UpdateCleanerAvailabilityUseCase(this._scheduleRepository);

  Future<CleanerAvailabilitySlot> call(
    String id,
    CleanerAvailabilityRequest request,
  ) async {
    try {
      return await _scheduleRepository.updateCleanerAvailability(id, request);
    } catch (e) {
      throw Exception('Updating availability failed ${e.toString()}');
    }
  }
}
